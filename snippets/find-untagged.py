#!/usr/bin/env python3
"""find-untagged.py — list supported files under a desk root that carry no tags.

What it does:
    Asks the carrel CLI (subprocess + --json only, no library imports) for every
    tag in the desk db and the files carrying each one, then walks the root for
    files of the 11 supported types and prints the ones no tag points at.
    Useful as a periodic "what still needs filing?" report.

Requirements: carrel on PATH; a desk db (run `carrel --root DIR index` and
    `carrel --root DIR tag add FILE TAG...` first).
Usage:
    ./find-untagged.py [ROOT] [--json]
    CARREL="uv run carrel" ./find-untagged.py ~/library
"""

from __future__ import annotations

import json
import os
import shlex
import subprocess
import sys
from pathlib import Path

SUPPORTED = {".pdf", ".md", ".jpg", ".jpeg", ".png", ".ico",
             ".txt", ".html", ".json", ".xml", ".csv"}
SKIP_DIRS = {".carrel", ".git"}


def carrel_json(root: Path, *args: str) -> object:
    """Run `carrel --root ROOT --json ARGS...` and parse its stdout."""
    cmd = shlex.split(os.environ.get("CARREL", "carrel"))
    cmd += ["--root", str(root), "--json", *args]
    proc = subprocess.run(cmd, capture_output=True, text=True)
    if proc.returncode != 0:
        sys.stderr.write(proc.stderr)
        sys.exit(proc.returncode)
    return json.loads(proc.stdout)


def main() -> None:
    argv = [a for a in sys.argv[1:] if a != "--json"]
    as_json = "--json" in sys.argv[1:]
    root = Path(argv[0]).resolve() if argv else Path.cwd()

    # 1. every tag in the desk db, then the union of all tagged files
    tags: dict[str, int] = carrel_json(root, "tag", "ls")["tags"]  # type: ignore[index]
    tagged: set[str] = set()
    for tag in tags:
        tagged.update(carrel_json(root, "tag", "find", tag))  # paths relative to root

    # 2. supported files on disk (hidden entries skipped, like `carrel index`)
    on_disk: set[str] = set()
    for dirpath, dirnames, filenames in os.walk(root):
        dirnames[:] = [d for d in dirnames
                       if not d.startswith(".") and d not in SKIP_DIRS]
        for name in filenames:
            if name.startswith("."):
                continue
            if Path(name).suffix.lower() in SUPPORTED:
                on_disk.add(str((Path(dirpath) / name).relative_to(root)))

    untagged = sorted(on_disk - tagged)
    if as_json:
        print(json.dumps({"root": str(root), "tags": len(tags),
                          "tagged": len(tagged), "untagged": untagged}, indent=2))
    else:
        print(f"{len(on_disk)} supported file(s) under {root}; "
              f"{len(tagged)} tagged, {len(untagged)} untagged:")
        for path in untagged:
            print(f"  {path}")
        if untagged:
            print(f'\ntag one:  carrel --root {root} tag add "{untagged[0]}" some-tag')


if __name__ == "__main__":
    main()
