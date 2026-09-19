#!/usr/bin/env python3
"""Configure and verify the prepared Microsoft CRT/SDK cache."""

import hashlib
import json
import os
from pathlib import Path
import sys

CONFIG = json.loads(Path(__file__).with_name("config.json").read_text())


def inventory(root):
    entries = {}
    for path in sorted(root.rglob("*")):
        name = path.relative_to(root).as_posix()
        if path.is_symlink():
            if not path.resolve(strict=True).is_relative_to(root.resolve()):
                raise ValueError(f"sysroot symlink escapes cache: {name}")
            entries[name] = {"link": os.readlink(path)}
        elif path.is_file():
            with path.open("rb") as source:
                digest = hashlib.file_digest(source, "sha256").hexdigest()
            entries[name] = {"sha256": digest}
    return entries


def validate_layout(root):
    arches = set((root / "DONE").read_text().splitlines()[0].split())
    if arches != set(CONFIG["arch"].split(",")):
        raise ValueError("sysroot DONE architectures do not match configuration")
    required = ["crt/include/vcruntime.h", "sdk/include/um/windows.h"]
    for arch in CONFIG["arch"].split(","):
        required.extend([
            f"crt/lib/{arch}/libcmt.lib",
            f"sdk/lib/um/{arch}/kernel32.lib",
            f"sdk/lib/ucrt/{arch}/libucrt.lib",
        ])
    for name in required:
        if not (root / name).is_file() or (root / name).stat().st_size == 0:
            raise ValueError(f"sysroot is missing {name}")


def record(root):
    validate_layout(root / "xwin")
    manifest = {"config": CONFIG, "files": inventory(root / "xwin")}
    (root / "manifest.json").write_text(json.dumps(manifest, sort_keys=True))


def verify(root):
    manifest = json.loads((root / "manifest.json").read_text())
    if manifest["config"] != CONFIG:
        raise ValueError("sysroot configuration does not match cache key")
    validate_layout(root / "xwin")
    if inventory(root / "xwin") != manifest["files"]:
        raise ValueError("sysroot contents do not match manifest")


def configure():
    if os.environ["RUNNER_OS"] != "Linux":
        raise ValueError("Windows sysroot caching requires a Linux runner")
    root = Path(os.environ["RUNNER_TEMP"]) / "windows-sysroot"
    config_hash = hashlib.sha256(json.dumps(CONFIG, sort_keys=True).encode()).hexdigest()
    with open(os.environ["GITHUB_OUTPUT"], "a") as output:
        output.write(f"path={root}\n")
        output.write(f"key=windows-sysroot-v1-Linux-{os.environ['RUNNER_ARCH']}-{config_hash}\n")
        output.write(f"cargo-xwin={CONFIG['cargo_xwin']}\n")
    with open(os.environ["GITHUB_ENV"], "a") as env:
        env.write(f"XWIN_CACHE_DIR={root}\n")
        for key in ("version", "crt_version", "sdk_version", "arch", "variant"):
            env.write(f"XWIN_{key.upper()}={CONFIG[key]}\n")
        env.write("XWIN_CROSS_COMPILER=clang-cl\n")
        env.write("XWIN_INCLUDE_ATL=false\nXWIN_INCLUDE_DEBUG_LIBS=false\nXWIN_INCLUDE_DEBUG_SYMBOLS=false\n")


if __name__ == "__main__":
    command = sys.argv[1]
    if command == "configure":
        configure()
    elif command == "record":
        record(Path(os.environ["XWIN_CACHE_DIR"]))
    elif command == "verify":
        verify(Path(os.environ["XWIN_CACHE_DIR"]))
    else:
        raise ValueError(f"unknown command: {command}")
