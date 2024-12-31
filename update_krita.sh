#!/bin/bash

URL_BASE="https://download.kde.org/Attic/krita/"
DIRECTORY_DOWNLOAD="$HOME/Downloads"
DIRECTORY_INSTALL="/opt/krita"
DIRECTORY_RUN="/usr/local/bin"

sudo mkdir -p $DIRECTORY_INSTALL

# Determine the latest version directory on the Krita website.
VERSION_FOLDER=$(curl -s $URL_BASE | grep -oP '(?<=href=")\d+\.\d+\.\d+\/(?=")' | sort -V | tail -n 1)
URL_PAGE="${URL_BASE}${VERSION_FOLDER}"

# Construct the download URL for the latest release AppImage.
NAME_APPIMAGE=$(curl -s $URL_PAGE | grep -oP '(?<=href=")[^"]+x86_64\.appimage(?=")' | sort -V | tail -n 1)
URL_APPIMAGE="${URL_PAGE}${NAME_APPIMAGE}"
echo "Latest is $URL_APPIMAGE"

DOWNLOAD_APPIMAGE="$DIRECTORY_DOWNLOAD/$NAME_APPIMAGE"
INSTALL_APPIMAGE="$DIRECTORY_INSTALL/$NAME_APPIMAGE"

# Exit if the version is already installed.
if [[ -f $INSTALL_APPIMAGE ]]; then
    echo "$INSTALL_APPIMAGE is already installed."
    exit
fi

# Download the latest version.
if ! [[ -f $DOWNLOAD_APPIMAGE ]]; then
    echo "Downloading $URL_APPIMAGE..."
    curl -L -o $DOWNLOAD_APPIMAGE $URL_APPIMAGE
    if [[ -f $DOWNLOAD_APPIMAGE ]]; then
        echo "Downloaded $DOWNLOAD_APPIMAGE"
    else
        echo "Failed to download Krita. Please check the URL or network connection."
    fi
else
    echo "$DOWNLOAD_APPIMAGE has already been downloaded."
fi

# Extract and edit the .desktop file.
chmod +x $DOWNLOAD_APPIMAGE
$DOWNLOAD_APPIMAGE --appimage-extract "org.kde.krita.desktop"
sed -i 's/Icon=krita/Icon=org.kde.krita/g' "$DIRECTORY_DOWNLOAD/squashfs-root/org.kde.krita.desktop"
mv "$DIRECTORY_DOWNLOAD/squashfs-root/org.kde.krita.desktop" "$HOME/.local/share/applications/krita.desktop"
rm -R "$DIRECTORY_DOWNLOAD/squashfs-root"
echo "Updated $HOME/.local/share/applications/krita.desktop"

# Allow executing and move the AppImage to the install directory.
sudo mv $DOWNLOAD_APPIMAGE $INSTALL_APPIMAGE
echo "Moved AppImage to $INSTALL_APPIMAGE"

# Update the symbolic link.
sudo ln -sf "$INSTALL_APPIMAGE" "$DIRECTORY_RUN/krita"
echo "Updated symbolic link $DIRECTORY_RUN/krita -> $INSTALL_APPIMAGE"
