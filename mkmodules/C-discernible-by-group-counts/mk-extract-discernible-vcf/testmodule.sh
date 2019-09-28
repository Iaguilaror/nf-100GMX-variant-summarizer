#!/usr/bin/env bash
## This small script runs a module test with the sample data

###
## environment variable setting
export VCF_REFERENCE="test/reference/sample.world_rare.vcf"
## The resulting VCF will contain variants that were found in at least GROUP_MIN_AF of the target group,
#^ and less than NOT_IN_GROUP_MIN_AF of the rest of the 100G-MX samples
export GROUP_MIN_AF="0.1"
export NOT_IN_GROUP_MIN_AF="0.01"
###

echo "[>..] test running this module with data in test/data"
## Remove old test results, if any; then create test/reults dir
rm -rf test/results
mkdir -p test/results
echo "[>>.] results will be created in test/results"
## Execute runmk.sh, it will find the basic example in test/data
## Move results from test/data to test/results
## results files are *group_*.vcf
./runmk.sh \
&& mv test/data/group_*.vcf test/results \
&& echo "[>>>] Module Test Successful"
