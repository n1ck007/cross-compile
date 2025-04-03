#!/usr/bin/bash

if [[ "$(basename $(pwd))" != "cross" ]]; then
  printf "$(basename $0): This script must called from the directory it resides in.\n"
  exit 1
fi

rm -rf zlib/zlib-1.2.11 openssl/openssl-1.1.1 rootfs