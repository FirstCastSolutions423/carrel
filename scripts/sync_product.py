#!/usr/bin/env python3
"""Regenerate src/carrel/_product.py and pyproject version from /product.json.

product.json is the single source of truth for product identity (see CLAUDE.md).
Run after editing product.json; finalize.sh runs it during rename.
"""
from __future__ import annotations

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent


def main() -> int:
    product = json.loads((ROOT / "product.json").read_text())

    gen = ROOT / "src" / "carrel" / "_product.py"
    gen.write_text(
        '"""GENERATED from /product.json by scripts/sync_product.py — do not edit."""\n\n'
        f"PRODUCT = {json.dumps(product, indent=4, ensure_ascii=False)}\n"
    )

    pyproject = ROOT / "pyproject.toml"
    text = pyproject.read_text()
    text = re.sub(r'(?m)^version = ".*"$', f'version = "{product["version"]}"', text, count=1)
    text = re.sub(
        r'(?m)^description = ".*"$',
        f'description = "{product["tagline"]} {product["description"]}"'.replace("\\", ""),
        text,
        count=1,
    )
    pyproject.write_text(text)

    print(f"synced: {product['name']} v{product['version']} -> {gen.relative_to(ROOT)}, pyproject.toml")
    return 0


if __name__ == "__main__":
    sys.exit(main())
