#!/bin/bash

set -e  # Exit on error

# === Configuration ===
GITHUB_REPO="https://api.github.com/repos/godotengine/godot/releases/latest"
INSTALL_DIR="/opt/godot"
SYMLINK_PATH="/usr/local/bin/godot"

# === Detect architecture ===
ARCH=$(uname -m)
if [[ "$ARCH" == "x86_64" ]]; then
    FILE_SUFFIX="linux.x86_64"
elif [[ "$ARCH" == "aarch64" ]]; then
    FILE_SUFFIX="linux.arm64"
else
    echo "Unsupported architecture: $ARCH"
    exit 1
fi

# === Fetch latest release info ===
echo "Fetching latest Godot release info..."
LATEST_JSON=$(curl -fsSL "$GITHUB_REPO")

# Extract version, asset URL, and filename
# Exact suffix match, so the mono build (mono_linux_x86_64.zip) is not picked up
VERSION=$(echo "$LATEST_JSON" | jq -r '.tag_name')
ASSET_JSON=$(echo "$LATEST_JSON" | jq -c --arg suffix "_${FILE_SUFFIX}.zip" \
    '[.assets[] | select(.name | endswith($suffix))][0] // empty')
ASSET_URL=$(echo "$ASSET_JSON" | jq -r '.browser_download_url // empty')
ASSET_NAME=$(echo "$ASSET_JSON" | jq -r '.name // empty')

if [[ -z "$ASSET_URL" || -z "$ASSET_NAME" ]]; then
    echo "Could not find a matching Godot release for arch: $FILE_SUFFIX"
    exit 1
fi

# Binary inside the zip has the same name minus the extension
BINARY_NAME="${ASSET_NAME%.zip}"
TARGET_PATH="$INSTALL_DIR/$BINARY_NAME"

if [[ -x "$TARGET_PATH" ]]; then
    echo "Godot $VERSION is already installed at $TARGET_PATH"
    sudo ln -sf "$TARGET_PATH" "$SYMLINK_PATH"
    exit 0
fi

# === Download and extract to a temp dir ===
TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT

echo "Downloading $ASSET_URL..."
curl -fL -o "$TEMP_DIR/$ASSET_NAME" "$ASSET_URL"

echo "Extracting ZIP archive..."
unzip -q "$TEMP_DIR/$ASSET_NAME" -d "$TEMP_DIR/extract"
FOUND_BINARY=$(find "$TEMP_DIR/extract" -type f -name "Godot*" | head -n 1)
if [[ -z "$FOUND_BINARY" ]]; then
    echo "Error: Could not locate Godot binary inside archive."
    exit 1
fi

# === Install, set permissions and symlink ===
sudo mkdir -p "$INSTALL_DIR"
sudo mv "$FOUND_BINARY" "$TARGET_PATH"
sudo chmod +x "$TARGET_PATH"
sudo ln -sf "$TARGET_PATH" "$SYMLINK_PATH"

echo "✅ Godot $VERSION installed successfully to $TARGET_PATH"
echo "✅ Symlink created at $SYMLINK_PATH"

# === Optional: Show version ===
"$SYMLINK_PATH" --version || echo "Godot installed, but version check failed (may require GUI)."
