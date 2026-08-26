#!/usr/bin/env python3

from __future__ import annotations

import argparse
import hashlib
import mmap
import struct
import subprocess
import zlib
from dataclasses import dataclass, field
from pathlib import Path, PurePosixPath


class FormatError(RuntimeError):
    pass


@dataclass
class Node:
    kind: str
    attributes: dict[str, str | int] = field(default_factory=dict)


@dataclass
class FileRecord:
    path: PurePosixPath
    start: int
    size: int
    md5: str


@dataclass
class Manifest:
    attributes: dict[str, str | int]
    directories: list[PurePosixPath]
    files: list[FileRecord]
    parse_error: Exception | None = None


def unpack(data, fmt: str, offset: int):
    size = struct.calcsize(fmt)
    if offset < 0 or offset + size > len(data):
        raise FormatError(f"field at offset {offset} is outside the package")
    return struct.unpack_from(fmt, data, offset)


def decompress_zstd(data, start: int, end: int) -> bytes:
    process = subprocess.run(
        ["zstd", "--decompress", "--quiet", "--stdout"],
        input=data[start:end],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
    )
    if process.returncode != 0:
        error = process.stderr.decode("utf-8", errors="replace").strip()
        raise FormatError(f"zstd could not decompress bytes {start}:{end}: {error}")
    return process.stdout


def decode_manifest(data) -> tuple[bytes, int, bool]:
    if len(data) < 28:
        raise FormatError("package is too short to contain a Melda footer")

    compressed_size, reserved, compression = unpack(data, "<III", len(data) - 12)
    if reserved != 0:
        raise FormatError(f"unexpected reserved footer value: {reserved}")

    # Melda packages end with a 28-byte footer. The compressed manifest frame
    # immediately precedes it, and its size is the first footer field.
    frame_start = len(data) - 28 - compressed_size
    frame_end = len(data) - 28
    if frame_start < 0:
        raise FormatError("manifest frame starts before the package")

    try:
        if compression == 11:
            compressed_manifest = zlib.decompress(data[frame_start:frame_end])
        elif compression == 43:
            compressed_manifest = decompress_zstd(data, frame_start, frame_end)
        else:
            raise FormatError(f"unsupported manifest compression type: {compression}")
    except zlib.error as error:
        raise FormatError("could not decompress the outer manifest frame") from error

    checksum_valid = True
    try:
        manifest = zlib.decompress(compressed_manifest)
    except zlib.error as error:
        # GLOBAL_IR_17.00.00 (and one unrelated MXXX package) ships with a
        # malformed inner Adler-32 checksum. Its raw DEFLATE stream remains
        # usable, apart from the final three IR records repaired below.
        try:
            manifest = zlib.decompress(compressed_manifest[2:-4], -15)
        except zlib.error as raw_error:
            raise FormatError("could not decompress the inner manifest") from raw_error
        checksum_valid = False

    if not manifest.startswith(b"\0MBXXfiles\0"):
        raise FormatError("manifest has an unexpected signature")

    return manifest, frame_start, checksum_valid


def read_c_string(data: bytes, offset: int) -> tuple[str, int]:
    end = data.find(b"\0", offset)
    if end == -1:
        # The final structural token (usually /~) has no terminator.
        end = len(data)
        next_offset = end
    else:
        next_offset = end + 1
    try:
        value = data[offset:end].decode("utf-8")
    except UnicodeDecodeError as error:
        raise FormatError(f"invalid text token at manifest offset {offset}") from error
    return value, next_offset


def parse_manifest(data: bytes, allow_partial: bool) -> Manifest:
    if not data.startswith(b"\0MBXXfiles\0"):
        raise FormatError("manifest has an unexpected signature")

    offset = len(b"\0MBXXfiles\0")
    root: dict[str, str | int] = {}
    stack: list[Node] = []
    directories: list[PurePosixPath] = []
    files: list[FileRecord] = []

    def current_path(file_name: str | None = None) -> PurePosixPath:
        parts = [
            str(node.attributes["name"])
            for node in stack
            if node.kind == "Xdir" and "name" in node.attributes
        ]
        if file_name is not None:
            parts.append(file_name)
        path = PurePosixPath(*parts)
        if path.is_absolute() or ".." in path.parts:
            raise FormatError(f"unsafe path in manifest: {path}")
        return path

    def close_node() -> None:
        if not stack:
            raise FormatError("manifest closes a node that is not open")
        node = stack[-1]
        if node.kind == "Xdir":
            if node.attributes.get("op") == "delete":
                stack.pop()
                return
            if "name" not in node.attributes:
                raise FormatError("directory is missing its name")
            directories.append(current_path())
        elif node.kind == "Xfile":
            if node.attributes.get("op") == "delete":
                stack.pop()
                return
            required = {"name", "filestart", "filesize", "hash"}
            missing = sorted(required - node.attributes.keys())
            if missing:
                name = node.attributes.get("name", "<unnamed>")
                raise FormatError(
                    f"file record {name!r} is missing: {', '.join(missing)}"
                )
            files.append(
                FileRecord(
                    path=current_path(str(node.attributes["name"])),
                    start=int(node.attributes["filestart"]),
                    size=int(node.attributes["filesize"]),
                    md5=str(node.attributes["hash"]).upper(),
                )
            )
        stack.pop()

    parse_error: Exception | None = None
    try:
        while offset < len(data):
            token_offset = offset
            token, offset = read_c_string(data, offset)

            if token.startswith("A"):
                key = token[1:]
                if offset >= len(data):
                    raise FormatError(f"attribute {key!r} has no value")
                value_type = chr(data[offset])
                offset += 1
                if value_type == "s":
                    value, offset = read_c_string(data, offset)
                elif value_type in "1248":
                    size = int(value_type)
                    if offset + size > len(data):
                        raise FormatError(f"numeric attribute {key!r} is truncated")
                    value = int.from_bytes(data[offset : offset + size], "little")
                    offset += size
                else:
                    raise FormatError(
                        f"unsupported value type {value_type!r} for {key!r} "
                        f"at manifest offset {offset - 1}"
                    )
                (stack[-1].attributes if stack else root)[key] = value
                continue

            close_count = len(token) - len(token.lstrip("/"))
            structural = token[close_count:]
            if close_count > len(stack):
                raise FormatError(
                    f"too many node closures at manifest offset {token_offset}"
                )
            for _ in range(close_count):
                close_node()

            if structural == "~":
                if stack:
                    raise FormatError("manifest ended with open nodes")
                break
            # Optional human-readable package descriptions are stored as a
            # standalone Vs... token rather than as an Aname/value pair.
            if structural.startswith("Vs"):
                continue
            if structural.startswith("X"):
                stack.append(Node(structural))
            elif structural:
                raise FormatError(
                    f"unexpected structural token {structural!r} "
                    f"at manifest offset {token_offset}"
                )
    except (FormatError, UnicodeDecodeError, ValueError) as error:
        if not allow_partial:
            raise
        parse_error = error

    return Manifest(root, directories, files, parse_error)


def zlib_stream(data, start: int, end: int) -> tuple[bytes, int]:
    decompressor = zlib.decompressobj()
    try:
        payload = decompressor.decompress(data[start:end])
        payload += decompressor.flush()
    except zlib.error as error:
        raise FormatError(f"invalid zlib stream at package offset {start}") from error
    if not decompressor.eof:
        raise FormatError(f"unterminated zlib stream at package offset {start}")
    consumed = end - start - len(decompressor.unused_data)
    if consumed <= 0:
        raise FormatError(f"empty compressed stream at package offset {start}")
    return payload, consumed


def repair_global_ir(data, manifest: Manifest, manifest_start: int) -> None:
    if str(manifest.attributes.get("path")) != "PKG/GLOBAL_IR":
        raise FormatError(
            "manifest checksum is invalid and this package has no known repair"
        ) from manifest.parse_error
    if not manifest.files:
        raise FormatError("GLOBAL_IR repair has no intact file records")

    last = max(manifest.files, key=lambda record: record.start)
    _, consumed = zlib_stream(data, last.start, manifest_start)
    offset = last.start + consumed
    recovery_paths = [
        PurePosixPath("MeldaProduction IR/Special/The Cave.flac"),
        PurePosixPath("MeldaProduction IR/Special/Thickener.flac"),
        PurePosixPath("MeldaProduction IR/Special/Whispers.flac"),
    ]

    for path in recovery_paths:
        payload, consumed = zlib_stream(data, offset, manifest_start)
        manifest.files.append(
            FileRecord(
                path=path,
                start=offset,
                size=len(payload),
                md5=hashlib.md5(payload).hexdigest().upper(),
            )
        )
        offset += consumed

    if offset != manifest_start:
        raise FormatError(
            f"GLOBAL_IR repair ended at {offset}, expected {manifest_start}"
        )


def digest_file(path: Path) -> tuple[int, str]:
    digest = hashlib.md5()
    size = 0
    with path.open("rb") as source:
        while block := source.read(1024 * 1024):
            size += len(block)
            digest.update(block)
    return size, digest.hexdigest().upper()


def extract_zlib(data, start: int, end: int, output: Path) -> None:
    decompressor = zlib.decompressobj()
    with output.open("wb") as target:
        offset = start
        while offset < end:
            next_offset = min(offset + 1024 * 1024, end)
            block = decompressor.decompress(data[offset:next_offset])
            target.write(block)
            offset = next_offset
        target.write(decompressor.flush())
    if not decompressor.eof:
        raise FormatError(f"unterminated zlib stream at package offset {start}")
    if decompressor.unused_data:
        raise FormatError(f"unexpected trailing data after stream at offset {start}")


def extract_zstd(data, start: int, end: int, output: Path) -> None:
    with output.open("wb") as target:
        process = subprocess.Popen(
            ["zstd", "--decompress", "--quiet", "--stdout"],
            stdin=subprocess.PIPE,
            stdout=target,
            stderr=subprocess.PIPE,
        )
        assert process.stdin is not None
        try:
            offset = start
            while offset < end:
                next_offset = min(offset + 1024 * 1024, end)
                process.stdin.write(data[offset:next_offset])
                offset = next_offset
            process.stdin.close()
            assert process.stderr is not None
            error = process.stderr.read()
            return_code = process.wait()
        except BrokenPipeError:
            process.stdin.close()
            assert process.stderr is not None
            error = process.stderr.read()
            return_code = process.wait()
        if return_code != 0:
            message = error.decode("utf-8", errors="replace").strip()
            raise FormatError(
                f"zstd could not decompress stream at offset {start}: {message}"
            )


def extract_record(data, record: FileRecord, end: int, output: Path) -> None:
    output.parent.mkdir(parents=True, exist_ok=True)
    header = bytes(data[record.start : record.start + 4])
    try:
        if header.startswith(b"\x28\xb5\x2f\xfd"):
            extract_zstd(data, record.start, end, output)
        elif len(header) >= 2 and (header[0] << 8 | header[1]) % 31 == 0:
            extract_zlib(data, record.start, end, output)
        else:
            raise FormatError(
                f"unknown file compression at package offset {record.start}: "
                f"{header.hex()}"
            )

        actual_size, actual_md5 = digest_file(output)
        if actual_size != record.size:
            raise FormatError(
                f"{record.path}: extracted size {actual_size}, expected {record.size}"
            )
        if actual_md5 != record.md5:
            raise FormatError(
                f"{record.path}: extracted MD5 {actual_md5}, expected {record.md5}"
            )
    except Exception:
        output.unlink(missing_ok=True)
        raise


def selected(record: FileRecord, args: argparse.Namespace) -> bool:
    if str(record.path) in args.exclude:
        return False
    stem = record.path.name.rsplit(".", 1)[0]
    if args.exact_stem and stem not in args.exact_stem:
        return False
    if args.stem_prefix and not any(stem.startswith(prefix) for prefix in args.stem_prefix):
        return False
    return True


def output_path(record: FileRecord, args: argparse.Namespace) -> Path:
    relative = PurePosixPath(record.path.name) if args.flatten else record.path
    if args.dll_as_vst3:
        if relative.suffix.lower() != ".dll":
            raise FormatError(f"cannot turn non-DLL path into VST3: {relative}")
        relative = relative.with_suffix(".vst3")
    return args.output.joinpath(*relative.parts)


def main() -> None:
    parser = argparse.ArgumentParser(description="Extract files from a Melda .pkgm package")
    parser.add_argument("package", type=Path)
    parser.add_argument("output", type=Path)
    parser.add_argument("--exact-stem", action="append", default=[])
    parser.add_argument("--stem-prefix", action="append", default=[])
    parser.add_argument("--exclude", action="append", default=[])
    parser.add_argument("--dll-as-vst3", action="store_true")
    parser.add_argument("--flatten", action="store_true")
    args = parser.parse_args()

    args.output.mkdir(parents=True, exist_ok=True)
    with args.package.open("rb") as source:
        with mmap.mmap(source.fileno(), 0, access=mmap.ACCESS_READ) as data:
            manifest_data, manifest_start, checksum_valid = decode_manifest(data)
            manifest = parse_manifest(manifest_data, allow_partial=not checksum_valid)
            if manifest.parse_error is not None:
                repair_global_ir(data, manifest, manifest_start)

            records = sorted(manifest.files, key=lambda record: record.start)
            if not records:
                raise FormatError("package manifest contains no files")
            if len({record.start for record in records}) != len(records):
                raise FormatError("package manifest contains duplicate file offsets")

            selected_records = [record for record in records if selected(record, args)]
            selected_starts = {record.start for record in selected_records}
            for index, record in enumerate(records):
                if record.start not in selected_starts:
                    continue
                end = records[index + 1].start if index + 1 < len(records) else manifest_start
                extract_record(data, record, end, output_path(record, args))

    if args.exact_stem:
        found = {
            record.path.name.rsplit(".", 1)[0]
            for record in selected_records
        }
        missing = sorted(set(args.exact_stem) - found)
        if missing:
            raise FormatError(f"missing requested files: {', '.join(missing)}")

    print(
        f"extracted {len(selected_records)} of {len(records)} files from "
        f"{args.package.name}"
    )


if __name__ == "__main__":
    main()
