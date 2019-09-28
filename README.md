# nf-100GMX-variant-summarizer
Nextflow pipeline used to count variants for the 100GMX project

===
'nf-100GMX-variant-summarizer' is a pipeline tool that counts variants in a VEPextended annotated VCF file. This pipeline generates 3 outputs: 1) a tsv file with the total number of SNV and indels; 2) a tsv file with per sample counts for variants of type SNV, indel, novel, worldwide singletons, clinvar, gwascat and pharmgkb; 3) a pdf file with the number of discernible variants in sample groups of interest.

Important note: input file must be previously annotated by https://github.com/Iaguilaror/nf-VEPextended

---

### Features
  **-v 0.0.1**

* Supports vcf compressed files as input.
* VCF input must be previously annotated by https://github.com/Iaguilaror/nf-VEPextended
* Results include a tsv with total SNV and indels
* Results include a tsv with per sample counts
* Results include a pdf with number of discernible variants in sample groups
* Scalability and reproducibility via a Nextflow-based framework.

---

## Requirements
#### Compatible OS*:
* [Ubuntu 18.04.03 LTS](http://releases.ubuntu.com/18.04/)
* [Ubuntu 16.04 LTS](http://releases.ubuntu.com/16.04/)

\* nf-100GMX-variant-summarizer may run in other UNIX based OS and versions, but testing is required.

#### Software:
| Requirement | Version  | Required Commands * |
|:---------:|:--------:|:-------------------:|
| [bcftools](https://samtools.github.io/bcftools/) | 1.9-220-gc65ba41 | bcftools |
| [htslib](http://www.htslib.org/download/) | 1.9 | tabix, bgzip |
| [filter_vep](http://www.ensembl.org/info/docs/tools/vep/script/vep_download.html) | 96 & 97 | vep |
| [Nextflow](https://www.nextflow.io/docs/latest/getstarted.html) | 19.04.1.5072 | nextflow |
| [Plan9 port](https://github.com/9fans/plan9port) | Latest (as of 10/01/2019 ) | mk \** |
| [R](https://www.r-project.org/) | 3.4.4 | Rscript |

\* These commands must be accessible from your `$PATH` (*i.e.* you should be able to invoke them from your command line).  

\** Plan9 port builds many binaries, but you ONLY need the `mk` utility to be accessible from your command line.

---

### Installation
Download nf-100GMX-variant-summarizer from Github repository:  
```
git clone https://github.com/Iaguilaror/nf-100GMX-variant-summarizer
```

---

#### Test
To test nf-100GMX-variant-summarizer's execution using test data, run:
```
./runtest.sh
```

Your console should print the Nextflow log for the run, once every process has been submitted, the following message will appear:
```
======
VCF summarizer: Basic pipeline TEST SUCCESSFUL
======
```

nf-100GMX-variant-summarizer results for test data should be in the following file:
```
nf-100GMX-variant-summarizer/test/results/VCFsummarizer-results
```

---

### Usage
To run nf-100GMX-variant-summarizer go to the pipeline directory and execute:
```
nextflow run summarize-vcf.nf --vcffile <path to input 1> --metadata <path to input 2> --nsamples <integer> --group_minaf <numeric> --outgroup_maxaf <numeric> [--output_dir path to results ]
```

For information about options and parameters, run:
```
nextflow run summarize-vcf.nf --help
```

---

### Pipeline Inputs
* A compressed vcf file with extension '.vcf.gz'; the VCF must be previously annotated with https://github.com/Iaguilaror/nf-VEPextended

Example line(s):
```
##fileformat=VCFv4.2
#CHROM  POS     ID      REF     ALT     QUAL    FILTER  INFO
chr21	5101724	.	G	A	.	PASS	AC=1;AF=0.00641;AN=152;DP=903;ANN=A|intron_variant|MODIFIER|GATD3B|ENSG00000280071|Transcript|ENST00000624810.3|protein_coding||4/5|ENST00000624810.3:c.357+19987C>T|||||||||-1|cds_start_NF&cds_end_NF|SNV|HGNC|HGNC:53816||5|||ENSP00000485439||A0A096LP73|UPI0004F23660|||||||chr21:g.5101724G>A||||||||||||||||||||||||||||2.079|0.034663||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
chr21	5102165	rs1373489291	G	T	.	PASS	AC=1;AF=0.00641;AN=140;DP=853;ANN=T|intron_variant|MODIFIER|GATD3B|ENSG00000280071|Transcript|ENST00000624810.3|protein_coding||4/5|ENST00000624810.3:c.357+19546C>A|||||||rs1373489291||-1|cds_start_NF&cds_end_NF|SNV|HGNC|HGNC:53816||5|||ENSP00000485439||A0A096LP73|UPI0004F23660|||||||chr21:g.5102165G>T||||||||||||||||||||||||||||5.009|0.275409||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
```

* `*.tsv` : A metadata file, relating every sample ID (as registered in the VCF file) and a sample group in column format.

Example line(s):
```
sample	group
SM-3MG5L	Chinanteco
SM-3MG5F	Chocholteco
SM-3MG46	Kanjobal
```

---

### Pipeline Results
* A tsv file with `*.total_variants.tsv` extension.

Example line(s):
```
# Variants in project sample.vcf.gz
number of SNPs: 8769
number of indels:       1231
```

* A tsv file with `*.persample_counts.tsv` extension.

Example line(s):
```
sample SNV indel total_variants tstv_ratio missing_sites heterozygosity_ratio novel_total_variants worldwide_singletons clinvar_pato_likelypato_and_riskfactor_variants variants_in_gwascat variants_in_pgkb
SM-3MG3L 3183 444 3627 2.196 4 1.091 1 10 0 6 0
SM-3MG3M 3100 450 3550 2.173 1 1.115 1 13 0 5 0
```

* a tsv file named `private_variants_per_group.tsv`

Example line(s):
```
group variant_type number
Nahua snv 0
Nahua indel 0
Seri snv 2
Seri indel 0
```
---

#### References
Under the hood nf-vcf-table-description separates variants from different dabatases and uses some coding tools, please include the following ciations in your work:

* McLaren, W., Gil, L., Hunt, S. E., Riat, H. S., Ritchie, G. R., Thormann, A., ... & Cunningham, F. (2016). The ensembl variant effect predictor. Genome biology, 17(1), 122.
* Narasimhan, V., Danecek, P., Scally, A., Xue, Y., Tyler-Smith, C., & Durbin, R. (2016). BCFtools/RoH: a hidden Markov model approach for detecting autozygosity from next-generation sequencing data. Bioinformatics, 32(11), 1749-1751.
* Team, R. C. (2017). R: a language and environment for statistical computing. R Foundation for Statistical Computing, Vienna. http s. www. R-proje ct. org.

---

### Contact
If you have questions, requests, or bugs to report, please email
<iaguilaror@gmail.com>

#### Dev Team
Israel Aguilar-Ordonez <iaguilaror@gmail.com>   
