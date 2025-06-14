#!/bin/bash
set -e

# Directory where this script lives
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Ensure /usr/local/bin exists
if [ ! -d "/usr/local/bin" ]; then
  echo "Error: /usr/local/bin does not exist. Please create it or run with sudo."
  exit 1
fi

# Remove any existing speedtest binary or link
if [ -e "/usr/local/bin/speedtest" ]; then
  echo "speedtest already exists. Overwriting..."
  sudo rm -f "/usr/local/bin/speedtest"
fi

# Create a symlink to your main.sh
sudo ln -s "$SCRIPT_DIR/src/main.sh" "/usr/local/bin/speedtest"

# Make it executable
sudo chmod +x "/usr/local/bin/speedtest"

echo "Installation complete! Run 'speedtest' anywhere in your terminal."