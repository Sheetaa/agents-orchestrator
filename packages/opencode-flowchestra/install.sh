#!/bin/bash

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Default to project-level installation
TARGET_DIR=".opencode"

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --global|-g)
      TARGET_DIR="$HOME/.config/opencode"
      shift
      ;;
    --help|-h)
      echo "Usage: install.sh [OPTIONS]"
      echo ""
      echo "Options:"
      echo "  --global, -g    Install globally to ~/.config/opencode"
      echo "  --help, -h      Show this help message"
      echo ""
      echo "By default, installs to .opencode/ in current directory"
      exit 0
      ;;
    *)
      echo -e "${RED}Unknown option: $1${NC}"
      exit 1
      ;;
  esac
done

echo "Installing OpenCode-Flowchestra to: $TARGET_DIR"
echo ""

# Create target directory if not exists
mkdir -p "$TARGET_DIR"

read_json() {
  # Strip // and /* */ comments, then parse JSON
  jq -R -s 'gsub("(?m)//.*$"; "") | gsub("(?s)/\\*.*?\\*/"; "") | fromjson' "$1"
}

# Copy directories (merge, not overwrite)
for dir in agents prompts skills; do
  if [ -d "$SCRIPT_DIR/$dir" ]; then
    mkdir -p "$TARGET_DIR/$dir"
    cp -rn "$SCRIPT_DIR/$dir/"* "$TARGET_DIR/$dir/" 2>/dev/null || cp -r "$SCRIPT_DIR/$dir/"* "$TARGET_DIR/$dir/"
    echo -e "${GREEN}[OK]${NC} Copied $dir/"
  fi
done


echo ""
echo -e "${GREEN}Installation complete!${NC}"
echo ""
echo "Usage:"
echo "  - Press Tab to switch to Flowchestra agent"
echo "  - Or use @flowchestra mention"
