"""Product identity: generated _product.py must mirror /product.json exactly."""

from __future__ import annotations

import json
import tomllib
from pathlib import Path

from carrel._product import PRODUCT

REPO_ROOT = Path(__file__).resolve().parents[1]


def test_product_matches_json():
    product_json = json.loads((REPO_ROOT / "product.json").read_text())
    assert PRODUCT == product_json, (
        "src/carrel/_product.py is out of sync with product.json — "
        "run scripts/sync_product.py"
    )


def test_pyproject_version_matches():
    pyproject = tomllib.loads((REPO_ROOT / "pyproject.toml").read_text())
    assert pyproject["project"]["version"] == PRODUCT["version"]
    assert pyproject["project"]["name"] == PRODUCT["package"]
