#!/bin/bash

URL_BASE="https://download.blender.org/release/"
DIRECTORY_DOWNLOAD="$HOME/Downloads"
DIRECTORY_INSTALL="/opt/blender"
DIRECTORY_RUN="/usr/local/bin"

sudo mkdir -p $DIRECTORY_INSTALL

# Determine the latest version directory on the Blender website.
VERSION_MAJOR=$(curl -s $URL_BASE | grep -oP '(?<=href=")Blender\d+\.\d+\/(?=")' | sort -V | tail -n 1)
URL_PAGE="${URL_BASE}${VERSION_MAJOR}"

# Construct the download URL for the latest release archive.
NAME_ARCHIVE=$(curl -s $URL_PAGE | grep -oP '(?<=href=")[^"]+linux[^"]+(?=")' | sort -V | tail -n 1)
URL_ARCHIVE="${URL_PAGE}${NAME_ARCHIVE}"
echo "Latest is $URL_ARCHIVE"

NAME_FOLDER=$(basename $NAME_ARCHIVE .tar.xz)
DOWNLOAD_ARCHIVE="$DIRECTORY_DOWNLOAD/$NAME_ARCHIVE"
DOWNLOAD_FOLDER="$DIRECTORY_DOWNLOAD/$NAME_FOLDER"
INSTALL_FOLDER="$DIRECTORY_INSTALL/$NAME_FOLDER"

# Exit if the version is already installed.
if [[ -d $INSTALL_FOLDER ]]; then
    echo "$INSTALL_FOLDER is already installed."
    exit
fi

# Download the latest version.
if ! [[ -f $DOWNLOAD_ARCHIVE ]]; then
    echo "Downloading $URL_ARCHIVE..."
    curl -L -o $DOWNLOAD_ARCHIVE $URL_ARCHIVE
    if [[ -f $DOWNLOAD_ARCHIVE ]]; then
        echo "Downloaded $DOWNLOAD_ARCHIVE"
    else
        echo "Failed to download Blender. Please check the URL or network connection."
    fi
else
    echo "$DOWNLOAD_ARCHIVE has already been downloaded."
fi

# Shut down Blender.
killall blender

# Extract and remove the archive.
echo "Extracting $DOWNLOAD_ARCHIVE..."
cd $DIRECTORY_DOWNLOAD
tar -xf $DOWNLOAD_ARCHIVE
echo "Removing $DOWNLOAD_ARCHIVE"
rm $DOWNLOAD_ARCHIVE
sudo mv $DOWNLOAD_FOLDER $DIRECTORY_INSTALL
echo "Moved folder to $INSTALL_FOLDER"

# Update the GNOME desktop entry.
cp "$INSTALL_FOLDER/blender.desktop" "$HOME/.local/share/applications/blender.desktop"
update-desktop-database "$HOME/.local/share/applications/"
echo "Updated $HOME/.local/share/applications/blender.desktop"

# Update the symbolic link.
sudo ln -sf "$INSTALL_FOLDER/blender" "$DIRECTORY_RUN/blender"
echo "Updated symbolic link $DIRECTORY_RUN/blender -> $INSTALL_FOLDER/blender"
