## Load libraries
library("dplyr")
library("tidyr")

## Read args from command line
args = commandArgs(trailingOnly=TRUE)

## For debugging only
# args[1] <- "test/data/sample.count_block.tmp"
# args[2] <- "test/data/sample.counts.tsv"

## Load data
widedata.df <- read.table(file = args[1], header = T, sep = "\t", stringsAsFactors = F)

## Transform wide to long format
longdata.df <- gather(widedata.df, variant_type, numbers, nRefHom:nMissing, factor_key=TRUE)

## add empty column for compatibility with paneler script
longdata.df$sex <- NA
longdata.df$pop <- NA
longdata.df$chromosome <- NA

#### Finally, save tagged dataframe
write.table(x = longdata.df, file = args[2], append = F, quote = F, sep = "\t", row.names = F, col.names = T)
