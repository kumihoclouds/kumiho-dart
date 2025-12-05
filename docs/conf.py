# Configuration file for the Sphinx documentation builder.
#
# SPDX-License-Identifier: MIT
#
# This file configures Sphinx to build the Kumiho Dart SDK documentation.

from pathlib import Path

import yaml


project = "Kumiho Dart SDK"
author = "kumihoclouds"

_root = Path(__file__).resolve().parents[1]
package_info = yaml.safe_load((_root / "pubspec.yaml").read_text())
version = package_info.get("version", "0.0.0")
release = version
html_title = f"{project} v{version}"

extensions = [
    "sphinx.ext.autosectionlabel",
]

templates_path = ["_templates"]
exclude_patterns = ["_build", "Thumbs.db", ".DS_Store"]

html_theme = "alabaster"
html_static_path = ["_static"]
