nextflow run summarize-vcf.nf \
	--vcffile real-data/76g/76g_PASS_ANeqorgt150_autosomes_and_XY.filtered.untangled_multiallelics.anno_dbSNP_vep.vcf.gz \
	--metadata test/metadata/sample_group_relation.tsv \
	--output_dir real-data/76g/results \
	-resume \
	-with-report real-data/76g/results`date +%Y%m%d_%H%M%S`_report.html \
	-with-dag real-data/76g/results`date +%Y%m%d_%H%M%S`.DAG.html \
&& echo -e "======\n VCF summarizer: Basic pipeline TEST SUCCESSFUL \n======"
