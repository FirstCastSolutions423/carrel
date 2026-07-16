"""Unit tests for the carrel umbrella CLI (spec 00-core Acceptance)."""

from __future__ import annotations

import json
import subprocess
import sys
from pathlib import Path

import pytest
from click.testing import CliRunner

from carrel._product import PRODUCT
from carrel.cli import COMMANDS, cli

REPO_ROOT = Path(__file__).resolve().parents[1]


def _cli(*args: str) -> subprocess.CompletedProcess:
    """Drive the real entry point (carrel.cli.main) in a subprocess."""
    return subprocess.run(
        [sys.executable, "-m", "carrel.cli", *args],
        capture_output=True, text=True, timeout=60,
    )


def test_version_prints_product_identity():
    result = CliRunner().invoke(cli, ["--version"])
    assert result.exit_code == 0
    assert PRODUCT["name"] in result.output
    assert PRODUCT["version"] in result.output
    # and it genuinely matches product.json, not a hardcoded copy
    product = json.loads((REPO_ROOT / "product.json").read_text())
    assert product["version"] in result.output
    assert product["name"] in result.output


def test_version_subprocess():
    proc = _cli("--version")
    assert proc.returncode == 0
    assert PRODUCT["version"] in proc.stdout


# Known core issue (reported in W1.1): LazyGroup.get_command imports command
# modules eagerly while click formats --help, so `carrel --help` crashes until
# every module in COMMANDS exists (none do yet). ARCHITECTURE.md promises "a
# broken optional import breaks only its command" — get_command should catch
# ImportError. xfail(strict=False) so these flip green when commands land.
_HELP_XFAIL = pytest.mark.xfail(
    reason="carrel --help broken: LazyGroup.get_command raises ModuleNotFoundError "
           "for not-yet-implemented command modules (core bug, see W1.1 report)",
    strict=False,
)


@_HELP_XFAIL
def test_help_works():
    result = CliRunner().invoke(cli, ["--help"])
    assert result.exit_code == 0
    assert "Usage:" in result.output
    for flag in ("--json", "--debug", "--root"):
        assert flag in result.output


@_HELP_XFAIL
def test_help_lists_registered_commands():
    result = CliRunner().invoke(cli, ["--help"])
    assert result.exit_code == 0
    for name in COMMANDS:
        assert name in result.output


def test_bad_command_exits_2():
    proc = _cli("badcmd")
    assert proc.returncode == 2
    assert "badcmd" in proc.stderr
    assert proc.stdout == ""


def test_bad_command_cli_runner():
    result = CliRunner().invoke(cli, ["badcmd"])
    assert result.exit_code == 2


def test_bad_flag_exits_2():
    proc = _cli("--no-such-flag")
    assert proc.returncode == 2
