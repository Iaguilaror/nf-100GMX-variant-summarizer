#!/usr/bin/env bash

## find every vcf file
#find: -L option to include symlinks
find -L . \
  -type f \
  -name "*.tsv" \
  ! -name "group_*.tsv" \
| sed 's#.tsv#.PREPARE_GROUPS#' \
| xargs mk
