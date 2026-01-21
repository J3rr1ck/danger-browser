#!/bin/bash
set -e

SDK_DIR="linux/cef/sdk"
BUILD_DIR="$SDK_DIR/build"

rm -rf $BUILD_DIR
mkdir -p $BUILD_DIR
cd $BUILD_DIR

export CC=clang
export CXX=clang++

cmake .. -DCMAKE_BUILD_TYPE=Release
make -j$(nproc) libcef_dll_wrapper
