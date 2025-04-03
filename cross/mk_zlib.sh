#!/usr/bin/bash

if [[ "$(dirname $0)" != "." ]]; then
  printf "$(basename $0): This script must called from the directory it resides in.\n"
fi

# unzip zlib. The video uses zlib v1.2.11
cd zlib
tar -xf zlib-1.2.11.tar.gz
