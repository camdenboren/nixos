// Regenerates an XMLTV guide for a set of iptv-org M3U playlists.
//
// The playlists Jellyfin consumes are generated from iptv-org's API, so the
// channel set can change at any time. Instead of a hand-maintained channel
// list, every run:
//
//   1. fetches each configured playlist and collects the `tvg-id` values
//      Jellyfin will match guide data against (the iptv-org stream ids),
//   2. resolves each stream id to a grabbing site/site_id using iptv-org's
//      published `guides.json` (falling back to the `*.channels.xml` files
//      shipped with this package when the API is unreachable),
//   3. writes a `channels.xml` for those ids and runs the upstream
//      `epg/grab` command into a temporary file, and
//   4. swaps the finished guide into place so readers (Jellyfin's XMLTV
//      provider) never observe a partially written file.
//
// Environment:
//   PLAYLISTS        comma-separated playlist URLs or local paths (required)
//   GUIDE_DIR        directory for guide.xml, guide.xml.gz and channels.xml
//   DATA_DIR         directory for the iptv-org API cache (default $GUIDE_DIR/data)
//   API_URL          base URL of the iptv-org API (default iptv-org.github.io)
//   SITE_PRIORITY    preferred sites, most preferred first
//   SITES_DIR        override the bundled site configs
//   DAYS             days of guide data to request
//   MAX_CONNECTIONS  concurrent requests to the guide sites
'use strict'

const { spawnSync } = require('node:child_process')
const fs = require('node:fs')
const fsp = require('node:fs/promises')
const path = require('node:path')

const PKG_ROOT = path.resolve(__dirname)
const GRAB = path.join(PKG_ROOT, 'dist', 'scripts', 'commands', 'epg', 'grab.js')

const PLAYLISTS = splitList(process.env.PLAYLISTS)
const SITE_PRIORITY = splitList(process.env.SITE_PRIORITY)
const SITES_DIR = process.env.SITES_DIR || path.join(PKG_ROOT, 'sites')
const GUIDE_DIR = process.env.GUIDE_DIR || process.cwd()
const DATA_DIR = process.env.DATA_DIR || path.join(GUIDE_DIR, 'data')
const API_URL = (process.env.API_URL || 'https://iptv-org.github.io/api').replace(/\/+$/, '')
const DAYS = process.env.DAYS || '2'
const MAX_CONNECTIONS = process.env.MAX_CONNECTIONS || '4'

// every file epg/grab's `loadData()` reads; they are written as empty lists
// so it does not log a stack trace per file (the guide itself does not use
// them besides channel logos, which come from the playlist anyway)
const API_FILES = [
  'blocklist',
  'categories',
  'channels',
  'cities',
  'countries',
  'feeds',
  'guides',
  'languages',
  'logos',
  'regions',
  'streams',
  'subdivisions',
  'timezones'
]

function splitList(value) {
  return (value || '')
    .split(',')
    .map((item) => item.trim())
    .filter(Boolean)
}

function log(message) {
  console.error(`[epg] ${message}`)
}

async function readUrl(url, { retries = 3, timeout = 60_000 } = {}) {
  if (!/^https?:\/\//.test(url)) {
    const file = url.startsWith('file://') ? new URL(url) : url
    return fsp.readFile(file, 'utf8')
  }

  let lastError

  for (let attempt = 1; attempt <= retries; attempt++) {
    try {
      const response = await fetch(url, {
        redirect: 'follow',
        signal: AbortSignal.timeout(timeout)
      })

      if (!response.ok) throw new Error(`HTTP ${response.status} ${response.statusText}`)

      return await response.text()
    } catch (error) {
      lastError = error
      if (attempt < retries) await new Promise((resolve) => setTimeout(resolve, attempt * 2_000))
    }
  }

  throw new Error(`failed to fetch ${url}: ${lastError?.message || lastError}`)
}

// some playlists carry the provider's own channel id in the stream URL, which
// is a more direct mapping than anything the site lists can offer
const STREAM_URL_RULES = [
  {
    site: 'pluto.tv',
    // iptv-org proxies Pluto streams through jmp2.uk/plu-<pluto channel id>
    pattern: /\/plu-([0-9a-f]{24})\.m3u8/i
  }
]

// -- playlist parsing -------------------------------------------------------

// Returns { ids: Map<tvg-id, { name, url }>, failed: string[] }
async function loadPlaylistIds() {
  const ids = new Map()
  const failed = []

  for (const playlist of PLAYLISTS) {
    log(`loading playlist ${playlist}`)

    let content
    try {
      content = await readUrl(playlist)
    } catch (error) {
      // a stale/renamed iptv-org playlist should not cost us the others
      log(`warning: skipping ${playlist}: ${error.message}`)
      failed.push(playlist)
      continue
    }

    let pending = null

    for (const line of content.split(/\r?\n/)) {
      if (line.startsWith('#EXTINF:')) {
        const id = /tvg-id="([^"]*)"/.exec(line)?.[1] || ''
        pending = { id, name: line.slice(line.lastIndexOf(',') + 1).trim() }
      } else if (pending) {
        if (pending.id && !/^#/.test(line)) {
          const existing = ids.get(pending.id) || {}
          ids.set(pending.id, {
            name: existing.name || pending.name,
            url: line.trim()
          })
        }
        pending = null
      }
    }
  }

  return { ids, failed }
}

// -- stream id -> site mapping ---------------------------------------------

function siteFromStreamUrl(url) {
  if (!url) return null

  for (const rule of STREAM_URL_RULES) {
    const match = rule.pattern.exec(url)
    if (match && siteConfigExists(rule.site)) return { site: rule.site, siteId: match[1] }
  }

  return null
}

function siteConfigExists(site) {
  return fs.existsSync(path.join(SITES_DIR, site, `${site}.config.js`))
}

function priorityIndex(site) {
  const index = SITE_PRIORITY.indexOf(site)
  return index === -1 ? SITE_PRIORITY.length : index
}

// A site that publishes a guide (i.mjh.nz, plex.tv, ...) is more likely to
// return data than one that merely shares ids; prefer those, then the
// configured priority order, then a stable alphabetical tie-break.
function compareCandidates(a, b) {
  const aPublished = a.sources && a.sources.length > 0 ? 0 : 1
  const bPublished = b.sources && b.sources.length > 0 ? 0 : 1
  if (aPublished !== bPublished) return aPublished - bPublished

  const aPriority = priorityIndex(a.site)
  const bPriority = priorityIndex(b.site)
  if (aPriority !== bPriority) return aPriority - bPriority

  return a.site.localeCompare(b.site)
}

async function loadApiMap() {
  const guides = JSON.parse(await readUrl(`${API_URL}/guides.json`))
  const map = new Map()

  for (const entry of guides) {
    if (!entry.channel) continue
    const streamId = entry.feed ? `${entry.channel}@${entry.feed}` : entry.channel
    if (!map.has(streamId)) map.set(streamId, [])
    map.get(streamId).push(entry)
  }

  return map
}

function parseAttributes(line) {
  const attributes = {}
  const pattern = /([a-z_]+)="([^"]*)"/g
  let match

  while ((match = pattern.exec(line))) attributes[match[1]] = match[2]

  return attributes
}

// last-resort mapping from the site channel lists shipped with the package
async function loadSiteMap() {
  const map = new Map()
  const siteDirs = await fsp.readdir(SITES_DIR, { withFileTypes: true })

  for (const dirent of siteDirs) {
    if (!dirent.isDirectory()) continue

    const dir = path.join(SITES_DIR, dirent.name)
    const files = (await fsp.readdir(dir)).filter((file) => file.endsWith('.channels.xml'))

    for (const file of files) {
      const xml = await fsp.readFile(path.join(dir, file), 'utf8')
      for (const line of xml.split(/\r?\n/)) {
        if (!line.includes('<channel ')) continue

        const { site, site_id: siteId, lang, xmltv_id: xmltvId } = parseAttributes(line)
        if (!site || !siteId || !xmltvId) continue
        if (!map.has(xmltvId)) map.set(xmltvId, [])
        map.get(xmltvId).push({ site, site_id: siteId, lang, sources: [{ url: file }] })
      }
    }
  }

  return map
}

// -- channel list -----------------------------------------------------------

function escapeXml(value) {
  return String(value)
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;')
    .replaceAll("'", '&apos;')
}

function writeChannelsXml(channels) {
  const lines = ['<?xml version="1.0" encoding="UTF-8"?>', '<channels>']

  for (const channel of channels) {
    lines.push(
      `  <channel site="${escapeXml(channel.site)}" site_id="${escapeXml(channel.siteId)}"` +
        ` lang="${escapeXml(channel.lang)}" xmltv_id="${escapeXml(channel.id)}">` +
        `${escapeXml(channel.name)}</channel>`
    )
  }

  lines.push('</channels>')

  return `${lines.join('\n')}\n`
}

async function selectChannels(ids) {
  let map
  let source

  try {
    map = await loadApiMap()
    source = `${API_URL}/guides.json`
  } catch (error) {
    log(`warning: ${error.message}`)
    log('warning: falling back to the bundled *.channels.xml files')
    map = await loadSiteMap()
    source = 'bundled site channel lists'
  }

  log(`resolving ${ids.size} channel(s) via ${source}`)
  const selected = []
  const missing = []

  for (const [id, { name, url }] of ids) {
    const direct = siteFromStreamUrl(url)

    if (direct) {
      selected.push({ id, name: name || id, site: direct.site, siteId: direct.siteId, lang: 'en' })
      continue
    }

    const candidates = (map.get(id) || []).filter((entry) => siteConfigExists(entry.site))

    if (candidates.length === 0) {
      missing.push(id)
      continue
    }

    candidates.sort(compareCandidates)
    const entry = candidates[0]

    selected.push({
      id,
      name: name || entry.site_name || id,
      site: entry.site,
      siteId: entry.site_id,
      lang: entry.lang || 'en'
    })
  }

  return { selected, missing }
}

// -- guide generation -------------------------------------------------------

// grab's `loadData()` reads the iptv-org API cache even though the guide
// itself only needs it for channel logos; empty lists keep it quiet without
// downloading data that would not change the guide
async function writeApiStubs() {
  await fsp.mkdir(DATA_DIR, { recursive: true })

  for (const basename of API_FILES) {
    const file = path.join(DATA_DIR, `${basename}.json`)
    if (!fs.existsSync(file)) await fsp.writeFile(file, '[]')
  }
}

function runGrab(channelsPath, outputPath) {
  const args = [
    GRAB,
    '--channels',
    channelsPath,
    '--output',
    outputPath,
    '--days',
    DAYS,
    '--maxConnections',
    MAX_CONNECTIONS,
    '--gzip'
  ]

  log(`running ${path.basename(GRAB)} for ${path.basename(channelsPath)}`)
  const result = spawnSync(process.execPath, args, { stdio: 'inherit' })

  if (result.error) throw result.error
  if (result.status !== 0) throw new Error(`grab exited with status ${result.status}`)
}

async function main() {
  if (PLAYLISTS.length === 0) throw new Error('PLAYLISTS must list at least one playlist URL')

  const { ids, failed } = await loadPlaylistIds()

  if (failed.length === PLAYLISTS.length) throw new Error('every playlist failed to load')

  log(`found ${ids.size} unique tvg-id(s)`)

  const { selected, missing } = await selectChannels(ids)
  log(`matched ${selected.length} channel(s)`)

  if (missing.length > 0) {
    log(`warning: no guide source for ${missing.length} channel(s): ${missing.join(', ')}`)
  }

  if (selected.length === 0) throw new Error('no channels matched a guide source')

  await fsp.mkdir(GUIDE_DIR, { recursive: true })
  await writeApiStubs()

  const channelsPath = path.join(GUIDE_DIR, 'channels.xml')
  await fsp.writeFile(channelsPath, writeChannelsXml(selected))

  // grab writes guide.xml and guide.xml.gz into a scratch directory, then the
  // finished files replace the previous guide in a single rename each
  const scratch = await fsp.mkdtemp(path.join(GUIDE_DIR, '.grab-'))
  const outputPath = path.join(scratch, 'guide.xml')

  try {
    runGrab(channelsPath, outputPath)

    const guidePath = path.join(GUIDE_DIR, 'guide.xml')
    await fsp.rename(outputPath, guidePath)
    log(`wrote ${guidePath}`)

    const gzipPath = path.join(GUIDE_DIR, 'guide.xml.gz')
    if (fs.existsSync(`${outputPath}.gz`)) {
      await fsp.rename(`${outputPath}.gz`, gzipPath)
      log(`wrote ${gzipPath}`)
    }
  } finally {
    await fsp.rm(scratch, { recursive: true, force: true })
  }
}

if (require.main === module) {
  main().catch((error) => {
    log(`error: ${error.message}`)
    process.exit(1)
  })
}

module.exports = { loadPlaylistIds, selectChannels, loadSiteMap, compareCandidates }
