#!/usr/bin/env bash

## find every vcf file
#find: -L option to include symlinks
find -L . \
  -type f \
  -name "*.tsv" \
| sed 's#.tsv#.vcf#' \
| xargs mk
