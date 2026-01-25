#!/bin/bash

set -euo pipefail

REPO="${FLOWCHESTRA_REPO:-Sheetaa/flowchestra}"
REF="${FLOWCHESTRA_REF:-main}"
TMP_DIR="$(mktemp -d)"

cleanup() {
  rm -rf "$TMP_DIR"
}

trap cleanup EXIT

curl -fsSL "https://github.com/${REPO}/archive/refs/heads/${REF}.tar.gz" | tar -xz -C "$TMP_DIR"
"$TMP_DIR"/flowchestra-${REF}/packages/opencode-flowchestra/install.local.sh "$@"
