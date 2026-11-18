#!/usr/bin/env python3
"""Sync the version in ./version into README, the website and the script fallback.

Run from the repository root (or anywhere: paths are resolved from this file).
"""

import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parents[2]

# (file, pattern with two groups: prefix and suffix around the version)
TARGETS = [
    ("README.md", r"(Versi terbaru: \*\*)[^*]*(\*\*)"),
    ("README.md", r"(Media Toolkit  )\d+(?:\.\d+)*"),
    ("index.html", r'(<span id="mtk-version">)[^<]*(</span>)'),
    ("changelog/index.html", r'(<span id="mtk-version">)[^<]*(</span>)'),
    ("lib/core", r'(MTK_VERSION_FALLBACK=")[^"]*(")'),
]


def read_version():
    path = ROOT / "version"
    if not path.is_file():
        sys.exit("version file not found")
    lines = path.read_text(encoding="utf-8").strip().splitlines()
    value = lines[0].strip() if lines else ""
    if not re.fullmatch(r"\d+(?:\.\d+)*", value):
        sys.exit(f"invalid version in version file: {value!r}")
    return value


def main():
    version = read_version()
    changed = []

    for rel, pattern in TARGETS:
        path = ROOT / rel
        if not path.is_file():
            continue
        text = path.read_text(encoding="utf-8")
        rx = re.compile(pattern)
        updated, count = rx.subn(
            lambda m: m.group(1) + version + (m.group(2) if rx.groups > 1 else ""),
            text,
            count=1,
        )
        if count and updated != text:
            path.write_text(updated, encoding="utf-8")
            changed.append(rel)

    print(f"version: {version}")
    if changed:
        print("updated:", ", ".join(changed))
    else:
        print("all files already in sync")


if __name__ == "__main__":
    main()
