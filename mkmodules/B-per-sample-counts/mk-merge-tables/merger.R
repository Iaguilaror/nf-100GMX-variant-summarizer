## load libraries
library("dplyr")

## Read args from command line
args = commandArgs(trailingOnly=TRUE)

## For debugging only
# args[1] <- "test/data"
# args[2] <- "test/data/sample.persample_counts.tsv"

## load file paths for tables with counts
prereqs.v <- list.files(args[1],
           pattern="counts_.*",
           all.files=F,
           full.names=T)

## create base table with first file
merged.df <- read.table(file = prereqs.v[1],
                        header = T, sep = "\t",
                        stringsAsFactors = F)

## loop through tables to merge them
for (i in 2:length(prereqs.v)) {
  message(paste0("merging table ", prereqs.v[i]) )

  ## load tmp table
  tmp.df <- read.table(file = prereqs.v[i],
                       header = T, sep = "\t",
                       stringsAsFactors = F)

  ## merge with basetable
  merged.df <- merge(merged.df, tmp.df, by = "sample")
}

## Select only columns of interest
final.df <- merged.df %>% select(sample,
                                 nofilter_SNV:nofilter_heterozygosity_ratio,
                                 novel_total_variants,
                                 worldwide_singletons_total_variants,
                                 clinvar_total_variants,
                                 gwas_total_variants,
                                 pgkb_total_variants)

## rename columns
final.df <- final.df %>% rename( "SNV" = nofilter_SNV,
                                 "indel" = nofilter_Indels,
                                 "total_variants" = nofilter_total_variants,
                                 "tstv_ratio" = nofilter_tstv_ratio,
                                 "missing_sites" = nofilter_missing,
                                 "heterozygosity_ratio" = nofilter_heterozygosity_ratio,
                                 "novel_total_variants" = novel_total_variants,
                                 "worldwide_singletons" = worldwide_singletons_total_variants,
                                 "clinvar_pato_likelypato_and_riskfactor_variants" = clinvar_total_variants,
                                 "variants_in_gwascat" = gwas_total_variants,
                                 "variants_in_pgkb" = pgkb_total_variants)

## save output file
## save data
write.table(x = final.df,
            file = args[2],
            append = F, quote = F,
            sep = "\t", row.names = F, col.names = T)
