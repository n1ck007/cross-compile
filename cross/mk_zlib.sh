#!/usr/bin/bash

if [[ "$(dirname $0)" != "." ]]; then
  printf "$(basename $0): This script must called from the directory it resides in.\n"
  exit 1
fi

rootdir=$(pwd)

# unzip zlib. The video uses zlib v1.2.11
cd zlib
tar -xf zlib-1.2.11.tar.gz

# Configure zLib
# Reading the configure script helps and calling `./configure --help` us understand what args we should pass it.
# Notes: 
#   - In "/home/nick/.bashrc" the prefix is "/home/nick" see commands `dirname` and `basename`
#   - Remember the "install", "include", and "library" paths are all different locations
#   - By placing the shell parameter, in this case "CC", before command we modify the command's enviroment.
#   - "These assignment statements affect only the environment seen by that command." (Bash Manual 3.7.4)
# Arguments:
#   CC          specifies the cross-compiler
#   --prefix    specifies the install directory
cd zlib-1.2.11
mkdir -p $rootdir/rootfs/usr/local
CC=arm-linux-gnueabi-gcc ./configure --prefix=/repos/personal/learn/cross-compile/cross/rootfs/usr/local
