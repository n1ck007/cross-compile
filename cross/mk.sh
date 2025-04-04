#!/usr/bin/bash

if [[ "$(basename $(pwd))" != "cross" ]]; then
  printf "$(basename $0): This script must called from the directory it resides in.\n"
  exit 1
fi

# set the project directory
# project_dir=/home/nick/src/cross-compile/cross
project_dir=$(pwd)

# setup the target root file system
mkdir -p $project_dir/rootfs/usr/local

# 
# zLib
# 
# wget --no-clobber https://github.com/madler/zlib/archive/refs/tags/v1.2.11.tar.gz -O zlib/zlib-1.2.11.tar.gz
printf "\n\nzLib\n"
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
printf "\n### Configure ###\n"
cd zlib-1.2.11
CC=arm-linux-gnueabi-gcc ./configure --prefix=$project_dir/rootfs/usr/local

printf "\n### Make ###\n"
make

printf "\n### Install ###\n"
make install
cd $project_dir

# 
# OpenSSL
# 
# wget --no-clobber https://github.com/openssl/openssl/releases/download/OpenSSL_1_1_1/openssl-1.1.1.tar.gz -O openssl/openssl-1.1.1.tar.gz
printf "\n\nOpenSSL\n"
cd openssl
tar -xf openssl-1.1.1.tar.gz
cd openssl-1.1.1

# Examine the `INSTALL` file 
#   - `make test` will attept to compile and execute some simple .c file using the compile you specified. 
#     Since we're cross-compiling it will fail.
#   - Make sure to look overthe Configuration Options section.
# Looking at line 9 of the `config` script we see "# OpenSSL config: determine the operating system and run ./Configure".
# Since we're cross compiling, we just want to run `./Configure` and determine the OS ourselves.
# If you don't include `linux-armv4` as an argument, you will get an error and a list of architectures to choose from.
# 
printf "\n### Configure ###\n"
./Configure \
  --cross-compile-prefix=arm-linux-gnueabi- \
  --openssldir=$project_dir/rootfs/usr/local/ssl \
  --prefix=$project_dir/rootfs \
  --with-zlib-include=$project_dir/rootfs/usr/local/include \
  --with-zlib-lib=$project_dir/rootfs/usr/local/lib \
  zlib-dynamic \
  linux-armv4

# After the make use `file file libcrypto.so.1.1` to make use 
# Compare these libraries, the first compiled and the second cross-compiled
# file ~/src/cross-compile/shared/real/libmath.so.1.2.3 && file ~/src/cross-compile/cross/openssl/openssl-1.1.1/libcrypto.so.1.1
printf "\n### Make ###\n"
make

# printf "\n### Install ###\n"
make install
cd $project_dir
