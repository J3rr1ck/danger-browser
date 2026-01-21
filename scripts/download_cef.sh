#!/bin/bash
set -e

CEF_VERSION="130.1.2+g48f3ef6+chromium-130.0.6723.44"
CEF_PLATFORM="linux64"
CEF_URL="https://cef-builds.spotifycdn.com/cef_binary_${CEF_VERSION}_${CEF_PLATFORM}.tar.bz2"

TARGET_DIR="linux/cef/sdk"
mkdir -p $TARGET_DIR

if [ ! -f "$TARGET_DIR/DONE" ]; then
    echo "Downloading CEF SDK..."
    curl -L $CEF_URL -o cef_sdk.tar.bz2
    echo "Extracting..."
    tar -xjf cef_sdk.tar.bz2 -C $TARGET_DIR --strip-components=1
    rm cef_sdk.tar.bz2
    touch "$TARGET_DIR/DONE"
    echo "CEF SDK downloaded and extracted to $TARGET_DIR"
else
    echo "CEF SDK already exists."
fi
