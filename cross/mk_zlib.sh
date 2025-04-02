#!/usr/bin/bash

wkdir=$(pwd)

# unzip zlib
cd zlib
tar -xf zlib-1.3.1.tar.gz

# Configure zLib
# Reading the configure script helps and calling `./configure --help` us understand what args we should pass it.
# Notes: 
#   - In "/home/nick/.bashrc" the prefix is "/home/nick" see commands `dirname` and `basename`
#   - Remember the "install", "include", and "library" paths are all different locations
# Arguments:
#   CC          specifies the cross-compiler
#   --prefix    specifies the install directory
cd zlib-1.3.1
./configure \
    CC=arm-linux-gnueabi-gcc \
    --prefix /home/nick/src/cross-compile/cross/rootfs \
