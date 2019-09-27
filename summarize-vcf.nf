#!/usr/bin/env nextflow

/*================================================================
The MORETT LAB presents...

  The VCF summarizer

- A per sample, per group, and total variants counting tool

==================================================================
Version: 0.0.1
Project repository: https://github.com/Iaguilaror/nf-100GMX-variant-summarizer
==================================================================
Authors:

- Bioinformatics Design
 Israel Aguilar-Ordonez (iaguilaror@gmail.com)

- Bioinformatics Development
 Israel Aguilar-Ordonez (iaguilaror@gmail.com)

- Nextflow Port
 Israel Aguilar-Ordonez (iaguilaror@gmail.com)

=============================
Pipeline Processes In Brief:

branch A : counting total SNVs and indels in vcffile
	A1_project_counts

branch B : counting SNVs and indels per sample in vcffile, including novel, worldwide singletons, clinvar, gwascat and pharmgkb
	B1a_nofilter_counts
	B1b_novel_counts
	B1c_worldwide_singletons_counts
	B1d_clinvar_counts
	B1e_gwascatalog_counts
	B1f_pgkb_counts
	B2_merge_tables

================================================================*/

/* Define the help message as a function to call when needed *//////////////////////////////
def helpMessage() {
	log.info"""
  ==========================================
  The VCF summarizer
  - A per sample, per group, and total variants counting tool
  v${version}
  ==========================================

	Usage:

  nextflow run summarize-vcf.nf --vcffile <path to input 1> --metadata <path to input 2> [--output_dir path to results ]

	  --vcffile    <- compressed vcf file for annotation;
				vcf file must be annotated with the expanded annotation pipeline from Morett lab;
				accepted extension is .vcf.gz;
				vcf file must have a TABIX index with .tbi extension, located in the same directory as the vcf file;
	  --metadata	<- tsv file with sample - group relationship;
				tsv file must contain 2 columns: 1 = sample , 2 = group ;
				tsv file must have a header;
	  --output_dir     <- directory where results, intermediate and log files will be stored;
				default: same dir where --vcffile resides;
	  -resume	   <- Use cached results if the executed project has been run before;
				default: not activated;
				This native NF option checks if anything has changed from a previous pipeline execution.
				Then, it resumes the run from the last successful stage.
				i.e. If for some reason your previous run got interrupted,
				running the -resume option will take it from the last successful pipeline stage
				instead of starting over.
				Read more here: https://www.nextflow.io/docs/latest/getstarted.html#getstart-resume
	  --help           <- Shows Pipeline Information;
	  --version        <- Show Pipeline version;
	""".stripIndent()
}

/*//////////////////////////////
  Define pipeline version
  If you bump the number, remember to bump it in the header description at the begining of this script too
*/
version = "0.0.1"

/*//////////////////////////////
  Define pipeline Name
  This will be used as a name to include in the results and intermediates directory names
*/
pipeline_name = "VCFsummarizer"

/*
  Initiate default values for parameters
  to avoid "WARN: Access to undefined parameter" messages
*/
params.vcffile = false  //if no input path 1 is provided, value is false to provoke the error during the parameter validation block
params.metadata = false  //if no input path 2 is provided, value is false to provoke the error during the parameter validation block
params.help = false //default is false to not trigger help message automatically at every run
params.version = false //default is false to not trigger version message automatically at every run

/*//////////////////////////////
  If the user inputs the --help flag
  print the help message and exit pipeline
*/
if (params.help){
	helpMessage()
	exit 0
}

/*//////////////////////////////
  If the user inputs the --version flag
  print the pipeline version
*/
if (params.version){
	println "VCF summarizer v${version}"
	exit 0
}

/*//////////////////////////////
  Define the Nextflow version under which this pipeline was developed or successfuly tested
  Updated by iaguilar at FEB 2019
*/
nextflow_required_version = '18.10.1'
/*
  Try Catch to verify compatible Nextflow version
  If user Nextflow version is lower than the required version pipeline will continue
  but a message is printed to tell the user maybe it's a good idea to update Nextflow
*/
try {
	if( ! nextflow.version.matches(">= $nextflow_required_version") ){
		throw GroovyException('Your Nextflow version is older than Pipeline required version')
	}
} catch (all) {
	log.error "-----\n" +
			"  This pipeline requires Nextflow version: $nextflow_required_version \n" +
      "  But you are running version: $workflow.nextflow.version \n" +
			"  The pipeline will continue but some things may not work as intended\n" +
			"  You may want to run `nextflow self-update` to update Nextflow\n" +
			"============================================================"
}

/*//////////////////////////////
  INPUT PARAMETER VALIDATION BLOCK
/* Check if inpuths were provided
 * if they were not provided, they keep the 'false' value assigned in the parameter initiation block above and this test fails
*/
if ( !file(params.vcffile).exists() | !file(params.metadata).exists() ) {
  log.error "Input file does not exist\n\n" +
  "Please provide valid paths for both the --vcffile and --metadata inputs \n\n" +
  "For more information, execute: nextflow run summarize-vcf.nf --help"
  exit 1
}

/*  Check that extension of input 1 is .vcf.gz
 * to understand regexp use, and '==~' see https://www.nextflow.io/docs/latest/script.html#regular-expressions
*/
if ( !(file(params.vcffile).getName() ==~ /.+\.vcf\.gz$/) ) {
	log.error " --vcffile must have .vcf.gz extension \n\n" +
	"For more information, execute: nextflow run summarize-vcf.nf --help"
  exit 1
}

/* ///////////////////////////////////
Output directory definition
Default value to create directory is the parent dir of --vcffile
*/
params.output_dir = file(params.vcffile).getParent()

/*
  Results and Intermediate directory definition
  They are always relative to the base Output Directory
  and they always include the pipeline name in the variable (pipeline_name) defined by this Script

  This directories will be automatically created by the pipeline to store files during the run
*/
results_dir = "${params.output_dir}/${pipeline_name}-results/"
intermediates_dir = "${params.output_dir}/${pipeline_name}-intermediate/"

/*//////////////////////////////
  LOG RUN INFORMATION
*/
log.info"""
==========================================
The VCF summarizer
- A per sample, per group, and total variants counting tool
v${version}
==========================================
"""
log.info "--Nextflow metadata--"
/* define function to store nextflow metadata summary info */
def nfsummary = [:]
/* log parameter values beign used into summary */
/* For the following runtime metadata origins, see https://www.nextflow.io/docs/latest/metadata.html */
nfsummary['Resumed run?'] = workflow.resume
nfsummary['Run Name']			= workflow.runName
nfsummary['Current user']		= workflow.userName
/* string transform the time and date of run start; remove : chars and replace spaces by underscores */
nfsummary['Start time']			= workflow.start.toString().replace(":", "").replace(" ", "_")
nfsummary['Script dir']		 = workflow.projectDir
nfsummary['Working dir']		 = workflow.workDir
nfsummary['Current dir']		= workflow.launchDir
nfsummary['Launch command'] = workflow.commandLine
log.info nfsummary.collect { k,v -> "${k.padRight(15)}: $v" }.join("\n")
log.info "\n\n--Pipeline Parameters--"
/* define function to store Pipeline summary info */
def pipelinesummary = [:]
/* log parameter values being used into summary */
pipelinesummary['VCF file']			= params.vcffile
pipelinesummary['METADATA file']			= params.metadata
pipelinesummary['Results Dir']		= results_dir
pipelinesummary['Intermediate Dir']		= intermediates_dir
/* print stored summary info */
log.info pipelinesummary.collect { k,v -> "${k.padRight(15)}: $v" }.join("\n")
log.info "==========================================\nPipeline Start"

/* ///////////////////////////////
Useful functions definition
*/
// /* define a function for extracting the file name from a full path
// * The full path will be the one defined by the user to indicate where the reference file is located */
// def get_baseName(f) {
// 	/* find where is the last appearance of "/", then extract the string +1 after this last appearance */
//   	f.substring(f.lastIndexOf('/') + 1);
// }

/*//////////////////////////////
  PIPELINE START A
	* branch A : counting total SNVs and indels in vcffile
*/

/*
	READ INPUTS
*/

/* Load vcf files and tabix index into channel */
Channel
  .fromPath("${params.vcffile}*")
	.toList()
  .set{ vcf_inputs_for_A1 }

/* A1_project_counts */
/* Read mkfile module files */
Channel
	.fromPath("${workflow.projectDir}/mkmodules/A-general-counts/mk-project-counts/*")
	.toList()
	.set{ mkfiles_A1 }

process A1_project_counts {

	publishDir "${results_dir}/A1_project_counts/",mode:"copy"

	input:
	file vcf from vcf_inputs_for_A1
	file mkfiles from mkfiles_A1

	output:
	file "*.total_variants.tsv"

	"""
	bash runmk.sh
	"""

}

/*//////////////////////////////
  PIPELINE START A
	* branch B : counting SNVs and indels per sample in vcffile,
	* including novel, worldwide singletons, clinvar, gwascat and pharmgkb
*/

/*
	READ INPUTS
*/

/* Load vcf files and tabix index into channel */
Channel
  .fromPath("${params.vcffile}*")
	.toList()
  .into{ vcf_inputs_for_B1a; vcf_inputs_for_B1b; vcf_inputs_for_B1c; vcf_inputs_for_B1d; vcf_inputs_for_B1e; vcf_inputs_for_B1f }

/* B1a_nofilter_counts */
/* Read mkfile module files */
Channel
	.fromPath("${workflow.projectDir}/mkmodules/B-per-sample-counts/mk-no-filter/*")
	.toList()
	.set{ mkfiles_B1a }

process B1a_nofilter_counts {

	publishDir "${intermediates_dir}/B1a_nofilter_counts/",mode:"symlink"

	input:
	file vcf from vcf_inputs_for_B1a
	file mkfiles from mkfiles_B1a

	output:
	file "*.tsv" into results_from_B1a

	"""
	bash runmk.sh
	"""

}

/* B1b_novel_counts */
/* Read mkfile module files */
Channel
	.fromPath("${workflow.projectDir}/mkmodules/B-per-sample-counts/mk-novel/*")
	.toList()
	.set{ mkfiles_B1b }

process B1b_novel_counts {

	publishDir "${intermediates_dir}/B1b_novel_counts/",mode:"symlink"

	input:
	file vcf from vcf_inputs_for_B1b
	file mkfiles from mkfiles_B1b

	output:
	file "*.tsv" into results_from_B1b

	"""
	bash runmk.sh
	"""

}

/* B1c_worldwide_singletons_counts */
/* Read mkfile module files */
Channel
	.fromPath("${workflow.projectDir}/mkmodules/B-per-sample-counts/mk-worldwide-singletons/*")
	.toList()
	.set{ mkfiles_B1c }

process B1c_worldwide_singletons_counts {

	publishDir "${intermediates_dir}/B1c_worldwide_singletons_counts/",mode:"symlink"

	input:
	file vcf from vcf_inputs_for_B1c
	file mkfiles from mkfiles_B1c

	output:
	file "*.tsv" into results_from_B1c

	"""
	bash runmk.sh
	"""

}

/* B1d_clinvar_counts */
/* Read mkfile module files */
Channel
	.fromPath("${workflow.projectDir}/mkmodules/B-per-sample-counts/mk-clinvar/*")
	.toList()
	.set{ mkfiles_B1d }

process B1d_clinvar_counts {

	publishDir "${intermediates_dir}/B1d_clinvar_counts/",mode:"symlink"

	input:
	file vcf from vcf_inputs_for_B1d
	file mkfiles from mkfiles_B1d

	output:
	file "*.tsv" into results_from_B1d

	"""
	bash runmk.sh
	"""

}

/* B1e_gwascatalog_counts */
/* Read mkfile module files */
Channel
	.fromPath("${workflow.projectDir}/mkmodules/B-per-sample-counts/mk-gwascatalog/*")
	.toList()
	.set{ mkfiles_B1e }

process B1e_gwascatalog_counts {

	publishDir "${intermediates_dir}/B1e_gwascatalog_counts/",mode:"symlink"

	input:
	file vcf from vcf_inputs_for_B1e
	file mkfiles from mkfiles_B1e

	output:
	file "*.tsv" into results_from_B1e

	"""
	bash runmk.sh
	"""

}

/* B1f_pgkb_counts */
/* Read mkfile module files */
Channel
	.fromPath("${workflow.projectDir}/mkmodules/B-per-sample-counts/mk-pgkb/*")
	.toList()
	.set{ mkfiles_B1f }

process B1f_pgkb_counts {

	publishDir "${intermediates_dir}/B1f_pgkb_counts/",mode:"symlink"

	input:
	file vcf from vcf_inputs_for_B1f
	file mkfiles from mkfiles_B1f

	output:
	file "*.tsv" into results_from_B1f

	"""
	bash runmk.sh
	"""

}

/* B2_merge_tables */
/* gather every B1* results */
results_from_B1a
	.mix(results_from_B1b,results_from_B1c,results_from_B1d,results_from_B1e,results_from_B1f)
	.toList()
	.set{ inputs_for_B2 }

/* Read mkfile module files */
Channel
	.fromPath("${workflow.projectDir}/mkmodules/B-per-sample-counts/mk-merge-tables/*")
	.toList()
	.set{ mkfiles_B2 }

process B2_merge_tables {

	publishDir "${results_dir}/B2_merge_tables/",mode:"copy"

	input:
	file tables from inputs_for_B2
	file mkfiles from mkfiles_B2

	output:
	file "*.tsv"

	"""
	bash runmk.sh
	"""

}
