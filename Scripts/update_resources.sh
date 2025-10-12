#!/bin/bash

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
RESOURCES_DIR="$SCRIPT_DIR/../Sources/YouTubeKit/Resources"

echo -e "${GREEN}==> Updating YouTubeKit JavaScript resources${NC}\n"

# Create temp directory
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

cd "$TEMP_DIR"

# Step 1: Clone and build yt-dlp/ejs
echo -e "${YELLOW}[1/3]${NC} Cloning yt-dlp/ejs..."
git clone --depth 1 https://github.com/yt-dlp/ejs.git ytdlp-ejs 2>&1 | grep -v "^Cloning" || true
cd ytdlp-ejs

echo -e "${YELLOW}[1/3]${NC} Installing dependencies..."
npm install --silent 2>&1 | grep -E "^(added|changed|removed|audited)" || true

echo -e "${YELLOW}[1/3]${NC} Building yt-dlp/ejs..."
npm run bundle --silent 2>&1 | grep -E "^(SHA3|created)" || true

# Get versions from package.json
MERIYAH_VERSION=$(node -pe "require('./package.json').dependencies.meriyah")
ASTRING_VERSION=$(node -pe "require('./package.json').dependencies.astring")

echo -e "${GREEN}✓${NC} Built yt.solver.core.js"
echo -e "  Using meriyah@${MERIYAH_VERSION}, astring@${ASTRING_VERSION}\n"

# Go back to temp dir
cd "$TEMP_DIR"

# Step 2: Download meriyah
echo -e "${YELLOW}[2/3]${NC} Downloading meriyah@${MERIYAH_VERSION}..."
curl -sL "https://cdn.jsdelivr.net/npm/meriyah@${MERIYAH_VERSION}/dist/meriyah.umd.js" \
  -o meriyah.umd.js

if [ ! -s meriyah.umd.js ]; then
    echo -e "${RED}✗${NC} Failed to download meriyah.umd.js"
    exit 1
fi
echo -e "${GREEN}✓${NC} Downloaded meriyah.umd.js ($(wc -c < meriyah.umd.js | awk '{print int($1/1024)}')KB)\n"

# Step 3: Download astring
echo -e "${YELLOW}[3/3]${NC} Downloading astring@${ASTRING_VERSION}..."
curl -sL "https://unpkg.com/astring@${ASTRING_VERSION}/dist/astring.min.js" \
  -o astring.umd.js

if [ ! -s astring.umd.js ]; then
    echo -e "${RED}✗${NC} Failed to download astring.umd.js"
    exit 1
fi
echo -e "${GREEN}✓${NC} Downloaded astring.umd.js ($(wc -c < astring.umd.js | awk '{print int($1/1024)}')KB)\n"

# Copy files to Resources
echo -e "${YELLOW}Copying files to Resources directory...${NC}"
cp ytdlp-ejs/dist/yt.solver.core.js "$RESOURCES_DIR/yt_ejs_helper.js"
cp meriyah.umd.js "$RESOURCES_DIR/"
cp astring.umd.js "$RESOURCES_DIR/"

# Show final sizes
echo -e "\n${GREEN}==> Update complete!${NC}"
echo -e "\nResource files:"
ls -lh "$RESOURCES_DIR" | grep -E "\.(js)$" | awk '{printf "  %-25s %6s\n", $9, $5}'

echo -e "\n${YELLOW}Next steps:${NC}"
echo -e "  1. Run tests: ${GREEN}swift test${NC}"
echo -e "  2. Commit changes if tests pass\n"
