#!/bin/bash

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# Defaults
REPO="Sheetaa/flowchestra"
REF="main"
TARGET_DIR=".opencode"

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --global|-g)
      TARGET_DIR="$HOME/.config/opencode"
      shift
      ;;
    --branch|-b)
      REF="$2"
      shift 2
      ;;
    --help|-h)
      echo "Usage: install.sh [OPTIONS]"
      echo ""
      echo "Options:"
      echo "  --global, -g         Install globally to ~/.config/opencode"
      echo "  --branch, -b <name>  Specify branch to install from (default: main)"
      echo "  --help, -h           Show this help message"
      echo ""
      echo "Examples:"
      echo "  curl -fsSL https://raw.githubusercontent.com/Sheetaa/flowchestra/main/packages/opencode-flowchestra/install.sh | bash"
      echo "  curl -fsSL ... | bash -s -- --global"
      echo "  curl -fsSL ... | bash -s -- --branch develop"
      exit 0
      ;;
    *)
      echo -e "${RED}Unknown option: $1${NC}"
      exit 1
      ;;
  esac
done

TMP_DIR="$(mktemp -d)"

cleanup() {
  rm -rf "$TMP_DIR"
}

trap cleanup EXIT

echo "Downloading flowchestra from ${REPO}@${REF}..."
curl -fsSL "https://github.com/${REPO}/archive/refs/heads/${REF}.tar.gz" | tar -xz -C "$TMP_DIR"

# Find extracted directory (name varies based on branch)
EXTRACT_DIR=""
for dir in "$TMP_DIR"/flowchestra-*; do
  if [ -d "$dir" ]; then
    EXTRACT_DIR="$dir"
    break
  fi
done

if [ -z "$EXTRACT_DIR" ]; then
  echo -e "${RED}Failed to locate extracted flowchestra directory${NC}"
  exit 1
fi

SRC_DIR="$EXTRACT_DIR/packages/opencode-flowchestra"

echo "Installing OpenCode-Flowchestra to: $TARGET_DIR"
echo ""

# Create target directory if not exists
mkdir -p "$TARGET_DIR"

# Copy directories (merge, not overwrite)
for dir in agents prompts skills workflows; do
  if [ -d "$SRC_DIR/$dir" ]; then
    mkdir -p "$TARGET_DIR/$dir"
    cp -rn "$SRC_DIR/$dir/"* "$TARGET_DIR/$dir/" 2>/dev/null || cp -r "$SRC_DIR/$dir/"* "$TARGET_DIR/$dir/"
    echo -e "${GREEN}[OK]${NC} Copied $dir/"
  fi
done

echo ""
echo -e "${GREEN}Installation complete!${NC}"
echo ""
echo "Usage:"
echo "  - Press Tab to switch to Flowchestra agent"
echo "  - Or use @flowchestra mention"
