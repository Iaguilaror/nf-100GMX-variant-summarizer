echo -e "======\n Testing NF execution \n======" \
&& rm -rf test/results/ \
&& nextflow run summarize-vcf.nf \
	--vcffile test/data/sample.vcf.gz \
	--metadata test/metadata/sample_group_relation.tsv \
	--output_dir test/results \
	-resume \
	-with-report test/results/`date +%Y%m%d_%H%M%S`_report.html \
	-with-dag test/results/`date +%Y%m%d_%H%M%S`.DAG.html \
&& echo -e "======\n VCF summarizer: Basic pipeline TEST SUCCESSFUL \n======"
