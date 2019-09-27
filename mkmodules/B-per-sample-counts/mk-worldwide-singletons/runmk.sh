#!/bin/bash

find -L . \
  -type f \
  -name "*.vcf.gz" \
| sed "s#.vcf.gz#.counts_worldwidesingletons.tsv#" \
| xargs mk
