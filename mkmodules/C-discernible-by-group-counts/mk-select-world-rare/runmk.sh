#!/usr/bin/env bash

## find every vcf file
#find: -L option to include symlinks
find -L . \
  -type f \
  -name "*.vcf.gz" \
  ! -name "*.world_rare.vcf" \
| sed 's#.vcf.gz#.world_rare.vcf#' \
| xargs mk
