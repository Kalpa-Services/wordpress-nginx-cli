#!/bin/bash

SCRIPT_URL="https://kalpaservices.fra1.cdn.digitaloceanspaces.com/wpnix.sh"


INSTALL_DIR="/usr/local/bin"
SCRIPT_NAME="wpnix"

# Download the main script
echo "Downloading the script..."
curl -fsSL "$SCRIPT_URL" -o "$INSTALL_DIR/$SCRIPT_NAME"

# Make the script executable
chmod +x "$INSTALL_DIR/$SCRIPT_NAME"

echo "Installation complete. Run with '$SCRIPT_NAME'."
