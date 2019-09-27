#!/bin/bash

find -L . \
  -type f \
  -name "*counts_*.tsv" \
| sed "s#counts_.*\.tsv#persample_counts.tsv#" \
| sort -u \
| xargs mk
