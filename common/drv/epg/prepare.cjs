// build-time helper: upstream lists build/test/lint tooling as runtime
// dependencies, so reclassify it as `devDependencies` for `npm prune --omit=dev`
// and drop the network lifecycle scripts.
'use strict'

const fs = require('node:fs')

const DEV_DEPENDENCIES = [
  '@eslint/eslintrc',
  '@eslint/js',
  '@freearhey/chronos',
  '@inquirer/prompts',
  '@stylistic/eslint-plugin',
  '@swc-node/register',
  '@swc/core',
  '@swc/jest',
  'cross-env',
  'eslint',
  'eslint-config-prettier',
  'globals',
  'husky',
  'inquirer',
  'jest',
  'pm2',
  'serve',
  'typescript',
  'typescript-eslint'
]

// `@types/*` is only used for type checking, which happens before pruning
const isTypePackage = (name) => name.startsWith('@types/')

const pkg = JSON.parse(fs.readFileSync('package.json', 'utf8'))

pkg.devDependencies ??= {}
for (const name of Object.keys(pkg.dependencies)) {
  if (!DEV_DEPENDENCIES.includes(name) && !isTypePackage(name)) continue
  pkg.devDependencies[name] = pkg.dependencies[name]
  delete pkg.dependencies[name]
}

// `postinstall` downloads the iptv-org API; `prepare` runs husky.
delete pkg.scripts.postinstall
delete pkg.scripts.prepare

fs.writeFileSync('package.json', `${JSON.stringify(pkg, null, 2)}\n`)

// only the CLI sources are needed
fs.writeFileSync(
  'tsconfig.build.json',
  `${JSON.stringify(
    {
      extends: './tsconfig.json',
      compilerOptions: {
        outDir: './dist',
        declaration: false,
        skipLibCheck: true
      },
      include: ['scripts/**/*'],
      exclude: ['node_modules', 'dist']
    },
    null,
    2
  )}\n`
)
