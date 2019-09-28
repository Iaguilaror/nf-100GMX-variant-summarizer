## load libraries
library("dplyr")
library(ggplot2)
library("svglite")

## load data
data.df <- read.table(file = "private_variants_per_group.tsv",
                      header = T, sep = "\t", stringsAsFactors = T)

pdf(file = "private_variants_per_group.pdf")

## plot barplot for SNV
snv.df <- data.df %>% filter(variant_type == "snv")
snv.df$group <- factor(snv.df$group, levels = snv.df$group[order(snv.df$number, decreasing = T)])

SNV.p <- ggplot(snv.df, aes(x=group, y = number)) +
  geom_bar(stat = "identity") +
  geom_text(aes(label = number), vjust=-1) +
  ggtitle(label = "discernible SNV per group") +
  scale_y_continuous(name = "total variants", limits = c(0,max(snv.df$number)*1.1)) +
  scale_x_discrete(name = "group") +
  theme_classic() +
  theme(axis.text.x = element_text(angle = 90),
        legend.position = "none",
        axis.text = element_text(size = 5), axis.title = element_blank())

## print plot
SNV.p

## plot barplot for INDEL
indel.df <- data.df %>% filter(variant_type == "indel")
indel.df$group <- factor(indel.df$group, levels = indel.df$group[order(indel.df$number, decreasing = T)])

INDEL.p <- ggplot(indel.df, aes(x=group, y = number)) +
  geom_bar(stat = "identity") +
  geom_text(aes(label = number), vjust=-1) +
  ggtitle(label = "discernible INDEL per group") +
  scale_y_continuous(name = "total variants") +
  scale_x_discrete(name = "group") +
  theme_classic() +
  theme(axis.text.x = element_text(angle = 90), legend.position = "none")

## print plot
INDEL.p

dev.off()

## save as svg the SNV plot
ggsave(filename = "private_variants_per_group.svg",
       plot = SNV.p,
       device = "svg",
       width = 7.2,
       height = 7.2,
       units = "cm",
       dpi = 300)
