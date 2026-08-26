#!/usr/bin/env python3

from __future__ import annotations

import base64
import hashlib
import json
import os
import sys
import tempfile
import time
import urllib.error
import urllib.request
from pathlib import Path
from xml.etree import ElementTree


INSTALLER_DATABASE = "https://www.meldaproduction.com/download/MINSTALLERDATABASE.xml"
MANAGER_DATABASE = "https://www.meldaproduction.com/download/MPLUGINMANAGERDATABASE.xml"
PACKAGE_ROOT = "https://meldaproduction.b-cdn.net/download"
FAKE_HASH = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="
USER_AGENT = "maudioplugins-nix-update/1"


def request(url: str):
    return urllib.request.Request(url, headers={"User-Agent": USER_AGENT})


def fetch(url: str) -> bytes:
    for attempt in range(3):
        try:
            with urllib.request.urlopen(request(url), timeout=60) as response:
                return response.read()
        except (OSError, urllib.error.URLError) as error:
            if attempt == 2:
                raise RuntimeError(f"could not download {url}: {error}") from error
            time.sleep(2**attempt)
    raise AssertionError("unreachable")


def version_key(version: str) -> tuple[int, ...]:
    try:
        return tuple(int(component) for component in version.split("."))
    except ValueError as error:
        raise RuntimeError(f"unexpected Melda version: {version!r}") from error


def sri_sha256(url: str, expected_md5: str | None = None) -> str:
    sha256 = hashlib.sha256()
    md5 = hashlib.md5()
    downloaded = 0

    for attempt in range(3):
        try:
            with urllib.request.urlopen(request(url), timeout=60) as response:
                length_header = response.headers.get("Content-Length")
                length = int(length_header) if length_header else None
                while block := response.read(1024 * 1024):
                    sha256.update(block)
                    md5.update(block)
                    downloaded += len(block)
                if length is not None and downloaded != length:
                    raise RuntimeError(
                        f"short download from {url}: received {downloaded}, expected {length}"
                    )
            break
        except (OSError, urllib.error.URLError) as error:
            if attempt == 2:
                raise RuntimeError(f"could not download {url}: {error}") from error
            sha256 = hashlib.sha256()
            md5 = hashlib.md5()
            downloaded = 0
            time.sleep(2**attempt)

    actual_md5 = md5.hexdigest()
    if expected_md5 is not None and actual_md5.lower() != expected_md5.lower():
        raise RuntimeError(
            f"MD5 mismatch for {url}: got {actual_md5}, expected {expected_md5}"
        )
    return "sha256-" + base64.b64encode(sha256.digest()).decode("ascii")


def package_metadata(database: ElementTree.Element, names: set[str]):
    groups = {group.attrib["name"]: group for group in database.findall("packages")}
    missing = sorted(names - groups.keys())
    if missing:
        raise RuntimeError(f"installer database is missing: {', '.join(missing)}")

    result = {}
    for name in sorted(names):
        group = groups[name]
        stable = [
            package
            for package in group.findall("package")
            if package.attrib.get("enabled") == "1"
            and package.attrib.get("beta") == "0"
        ]
        if not stable:
            raise RuntimeError(f"installer database has no stable enabled package for {name}")
        package = max(stable, key=lambda item: version_key(item.attrib["version"]))
        result[name] = {
            "folder": group.attrib["folder"],
            "md5": package.attrib["hash"].lower(),
            "version": package.attrib["version"],
        }
    return result


def manager_metadata(database: ElementTree.Element):
    installers = next(
        (
            group
            for group in database.findall("mpluginmanager_installers")
            if group.attrib.get("name") == "AVAILABLE_VERSIONS_PC"
        ),
        None,
    )
    if installers is None:
        raise RuntimeError("manager database has no Windows installer list")
    latest = max(
        installers.findall("mpluginmanager"),
        key=lambda item: version_key(item.attrib["version"]),
    )
    return {
        "setupName": latest.attrib["setupname"],
        "time": latest.attrib["time"],
        "version": latest.attrib["version"],
    }


def valid_hash(value: str | None) -> bool:
    return bool(value and value != FAKE_HASH)


def write_json_atomic(path: Path, value) -> None:
    mode = path.stat().st_mode & 0o777
    descriptor, temporary_name = tempfile.mkstemp(prefix=path.name + ".", dir=path.parent)
    temporary = Path(temporary_name)
    try:
        with os.fdopen(descriptor, "w", encoding="utf-8") as output:
            json.dump(value, output, indent=2, sort_keys=True)
            output.write("\n")
        os.chmod(temporary, mode)
        os.replace(temporary, path)
    finally:
        temporary.unlink(missing_ok=True)


def main() -> None:
    source_file = Path(__file__).with_name("sources.json")
    current = json.loads(source_file.read_text(encoding="utf-8"))

    print("Fetching Melda installer metadata...")
    installer_database = ElementTree.fromstring(fetch(INSTALLER_DATABASE))
    manager_database = ElementTree.fromstring(fetch(MANAGER_DATABASE))

    latest_packages = package_metadata(installer_database, set(current["packages"]))
    latest_manager = manager_metadata(manager_database)
    updated = {"manager": latest_manager, "packages": latest_packages}
    changes: list[str] = []

    for name, metadata in updated["packages"].items():
        previous = current["packages"].get(name, {})
        unchanged = (
            all(previous.get(key) == metadata[key] for key in ("folder", "md5", "version"))
            and valid_hash(previous.get("hash"))
        )
        if unchanged:
            metadata["hash"] = previous["hash"]
            continue

        url = (
            f"{PACKAGE_ROOT}/{metadata['folder']}/"
            f"{name}_{metadata['version']}.pkgm"
        )
        print(f"Hashing {name} {metadata['version']}...")
        metadata["hash"] = sri_sha256(url, metadata["md5"])
        changes.append(
            f"{name}: {previous.get('version', '<missing>')} -> {metadata['version']}"
        )

    previous_manager = current.get("manager", {})
    manager_unchanged = (
        all(
            previous_manager.get(key) == latest_manager[key]
            for key in ("setupName", "time", "version")
        )
        and valid_hash(previous_manager.get("hash"))
    )
    if manager_unchanged:
        latest_manager["hash"] = previous_manager["hash"]
    else:
        manager_url = f"{PACKAGE_ROOT}/mpluginmanager/{latest_manager['setupName']}"
        print(f"Hashing MPluginManager {latest_manager['version']}...")
        latest_manager["hash"] = sri_sha256(manager_url)
        changes.append(
            "MPluginManager: "
            f"{previous_manager.get('version', '<missing>')} -> {latest_manager['version']}"
        )

    if updated == current:
        print(
            "maudioplugins is up to date: kernel "
            f"{updated['packages']['BINEffects_binkernel']['version']}, "
            f"manager {updated['manager']['version']}"
        )
        return

    write_json_atomic(source_file, updated)
    print("Updated maudioplugins sources:")
    for change in changes:
        print(f"  {change}")


if __name__ == "__main__":
    try:
        main()
    except Exception as error:
        print(f"maudioplugins update failed: {error}", file=sys.stderr)
        raise SystemExit(1)
