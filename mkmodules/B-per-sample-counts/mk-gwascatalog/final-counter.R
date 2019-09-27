## Load libraries
library("dplyr")
# library("tidyr")

## Read args from command line
args = commandArgs(trailingOnly=TRUE)

## For debugging only
# args[1] <- "test/data/sample.count_block.tmp"
# args[2] <- "test/data/sample.counts_nofilter.tsv"

## Load data
rawdata.df <- read.table(file = args[1], header = T, sep = "\t", stringsAsFactors = F)

## calculate values of interest
rawdata.df$tstv_ratio <- rawdata.df$nTransitions / rawdata.df$nTransversions

## reformat number
rawdata.df$tstv_ratio <- prettyNum(rawdata.df$tstv_ratio, digits = 4)

## total SNVs as sum of nonRef Hom sites and nHet sites
rawdata.df$SNV <- rawdata.df$nNonRefHom + rawdata.df$nHets

# total variants as sum of SNV and indels
rawdata.df$total_variants <- rawdata.df$SNV + rawdata.df$nIndels

# The heterozygosity ratio is the number of heterozygous sites in an individual divided by the number of nonreference homozygous sites
# as described in https://www.genetics.org/content/204/3/893
rawdata.df$heterozygosity_ratio <- rawdata.df$nHets / rawdata.df$nNonRefHom

## reformat number
rawdata.df$heterozygosity_ratio <- prettyNum(rawdata.df$heterozygosity_ratio, digits = 4)

# Select useful columns
final.df <- rawdata.df %>%
  select(sample, SNV, nIndels, total_variants, tstv_ratio, nMissing, heterozygosity_ratio) %>%
  ## rename columns
  rename("gwas_SNV" = SNV,
         "gwas_Indels" = nIndels,
         "gwas_total_variants" = total_variants,
         "gwas_tstv_ratio" = tstv_ratio,
         "gwas_missing" = nMissing,
         "gwas_heterozygosity_ratio" = heterozygosity_ratio )

#### Finally, save tagged dataframe
write.table(x = final.df,
            file = args[2],
            append = F, quote = F,
            sep = "\t", row.names = F, col.names = T)
