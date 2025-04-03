#!/usr/bin/bash

if [[ "$(basename $(pwd))" != "cross" ]]; then
  printf "$(basename $0): This script must called from the directory it resides in.\n"
  exit 1
fi