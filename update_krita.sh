#!/bin/bash

set -euo pipefail

URL_BASE="https://download.kde.org/stable/krita/"
DIRECTORY_INSTALL="/opt/krita"
DIRECTORY_RUN="/usr/local/bin"
DIRECTORY_APPLICATIONS="$HOME/.local/share/applications"

# Determine the latest version directory (versions can have 3 or 4 parts, e.g. 6.0.4.1).
VERSION=$(curl -fsSL "$URL_BASE" | grep -oP '(?<=href=")\d+(\.\d+)+(?=/")' | sort -uV | tail -n 1)
if [[ -z "$VERSION" ]]; then
    echo "Could not find a Krita version on $URL_BASE"
    exit 1
fi
URL_PAGE="${URL_BASE}${VERSION}/"

# Find the x86_64 AppImage in that directory.
NAME_APPIMAGE=$(curl -fsSL "$URL_PAGE" | grep -oiP '(?<=href=")krita-[\d.]+-x86_64\.appimage(?=")' | sort -uV | tail -n 1)
if [[ -z "$NAME_APPIMAGE" ]]; then
    echo "Could not find an x86_64 AppImage on $URL_PAGE"
    exit 1
fi
URL_APPIMAGE="${URL_PAGE}${NAME_APPIMAGE}"
INSTALL_APPIMAGE="$DIRECTORY_INSTALL/$NAME_APPIMAGE"
echo "Latest is $URL_APPIMAGE"

if [[ -f "$INSTALL_APPIMAGE" ]]; then
    echo "$INSTALL_APPIMAGE is already installed."
else
    # Download and extract in a temporary directory that is always cleaned up.
    DIRECTORY_TEMP=$(mktemp -d)
    trap 'rm -rf "$DIRECTORY_TEMP"' EXIT

    echo "Downloading $URL_APPIMAGE..."
    curl -fL -o "$DIRECTORY_TEMP/$NAME_APPIMAGE" "$URL_APPIMAGE"
    chmod +x "$DIRECTORY_TEMP/$NAME_APPIMAGE"

    # Extract and edit the .desktop file (--appimage-extract writes to the current directory).
    (cd "$DIRECTORY_TEMP" && "./$NAME_APPIMAGE" --appimage-extract "org.kde.krita.desktop" > /dev/null)
    DESKTOP_FILE="$DIRECTORY_TEMP/squashfs-root/org.kde.krita.desktop"
    if [[ -f "$DESKTOP_FILE" ]]; then
        sed -i 's/^Icon=krita$/Icon=org.kde.krita/' "$DESKTOP_FILE"
        mkdir -p "$DIRECTORY_APPLICATIONS"
        mv "$DESKTOP_FILE" "$DIRECTORY_APPLICATIONS/krita.desktop"
        echo "Updated $DIRECTORY_APPLICATIONS/krita.desktop"
    else
        echo "Warning: org.kde.krita.desktop not found in the AppImage; desktop entry not updated."
    fi

    sudo mkdir -p "$DIRECTORY_INSTALL"
    sudo mv "$DIRECTORY_TEMP/$NAME_APPIMAGE" "$INSTALL_APPIMAGE"
    echo "Installed $INSTALL_APPIMAGE"
fi

# Update the symbolic link (also repairs it when the AppImage was already installed).
sudo ln -sf "$INSTALL_APPIMAGE" "$DIRECTORY_RUN/krita"
echo "Updated symbolic link $DIRECTORY_RUN/krita -> $INSTALL_APPIMAGE"
