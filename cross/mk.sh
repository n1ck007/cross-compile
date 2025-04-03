#!/usr/bin/bash

if [[ "$(basename $(pwd))" != "cross" ]]; then
  printf "$(basename $0): This script must called from the directory it resides in.\n"
  exit 1
fi

# set the project directory
rootdir=$(pwd)

# setup the target root file system
mkdir -p $rootdir/rootfs/usr/local

# 
# zLib
# 
# wget --no-clobber https://github.com/madler/zlib/archive/refs/tags/v1.2.11.tar.gz -O zlib/zlib-1.2.11.tar.gz
cd zlib
tar -xf zlib-1.2.11.tar.gz

# Configure
# Reading the configure script helps and calling `./configure --help` us understand what args we should pass it.
# Notes: 
#   - In "/home/nick/.bashrc" the prefix is "/home/nick" see commands `dirname` and `basename`
#   - Remember the "install", "include", and "library" paths are all different locations
#   - By placing the shell parameter, in this case "CC", before command we modify the command's enviroment.
#   - "These assignment statements affect only the environment seen by that command." (Bash Manual 3.7.4)
#   - Use `cat configure.log` and make sure the prefix is correct to avoid install files on your own system.
# Arguments:
#   CC          specifies the cross-compiler
#   --prefix    specifies the install directory
cd zlib-1.2.11
mkdir -p $rootdir/rootfs/usr/local

printf "\n### Configure ###\n"
CC=arm-linux-gnueabi-gcc ./configure --prefix=$rootdir/rootfs/usr/local

printf "\n### Make ###\n"
make

printf "\n### Install ###\n"
make install
cd $rootdir

# 
# OpenSSL
# 
# wget --no-clobber https://github.com/openssl/openssl/releases/download/OpenSSL_1_1_1/openssl-1.1.1.tar.gz -O openssl/openssl-1.1.1.tar.gz
cd openssl
tar -xf openssl-1.1.1.tar.gz

