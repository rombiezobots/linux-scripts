#!/bin/bash

URL_PAGE="https://flamenco.blender.org/download/"
URL_BASE="https://flamenco.blender.org"
DIRECTORY_DOWNLOAD="$HOME/Downloads"
DIRECTORY_INSTALL="/opt/flamenco"
DIRECTORY_RUN="/usr/local/bin"

mkdir -p $DIRECTORY_INSTALL

# Construct the download URL for the latest release archive.
NAME_ARCHIVE=$(curl -s $URL_PAGE | grep -oP '(?<=href=")[^"]+linux-amd64[^"]+(?=")' | head -n 1)
URL_ARCHIVE="${URL_BASE}${NAME_ARCHIVE}"
echo "Latest is $URL_ARCHIVE"

NAME_ARCHIVE=$(basename $NAME_ARCHIVE)
NAME_FOLDER=$(basename $NAME_ARCHIVE .tar.gz)
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
        echo "Failed to download Flamenco. Please check the URL or network connection."
    fi
else
    echo "$DOWNLOAD_ARCHIVE has already been downloaded."
fi

# Shut down flamenco-worker and flamenco-manager
kill flamenco-worker
kill flamenco-manager

# Extract and remove the archive.
echo "Extracting $DOWNLOAD_ARCHIVE..."
cd $DIRECTORY_DOWNLOAD
tar -xf $DOWNLOAD_ARCHIVE
echo "Removing $DOWNLOAD_ARCHIVE"
rm $DOWNLOAD_ARCHIVE
sudo mv $DOWNLOAD_FOLDER $DIRECTORY_INSTALL
echo "Moved folder to $INSTALL_FOLDER"

# Update the symbolic links.
sudo ln -sf "$INSTALL_FOLDER/flamenco-manager" "$DIRECTORY_RUN/flamenco-manager"
echo "Updated symbolic link $DIRECTORY_RUN/flamenco-manager -> $INSTALL_FOLDER/flamenco-manager"
sudo ln -sf "$INSTALL_FOLDER/flamenco-worker" "$DIRECTORY_RUN/flamenco-worker"
echo "Updated symbolic link $DIRECTORY_RUN/flamenco-worker -> $INSTALL_FOLDER/flamenco-worker"
