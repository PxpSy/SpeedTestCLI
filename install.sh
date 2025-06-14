#!/bin/bash
set -e

# Directory where this script lives
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Ensure /usr/local/bin exists
if [ ! -d "/usr/local/bin" ]; then
  echo "Error: /usr/local/bin does not exist. Please create it or run with sudo."
  exit 1
fi

# Remove any existing speedtest link or file
sudo rm -f "/usr/local/bin/speedtest"

# Create (or update) a symlink to your main.sh (at root level, not in src/)
sudo ln -sf "$SCRIPT_DIR/main.sh" "/usr/local/bin/speedtest"

# Make the source file executable (not the symlink)
sudo chmod +x "$SCRIPT_DIR/main.sh"

echo "Installation complete! Run 'speedtest' anywhere in your terminal."