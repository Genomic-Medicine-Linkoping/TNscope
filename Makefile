SHELL = /bin/bash
.ONESHELL:
#.SHELLFLAGS := -eu -o pipefail -c
.SHELLFLAGS := -e -o pipefail -c
.DELETE_ON_ERROR:
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules

CURRENT_CONDA_ENV_NAME = TNscope
# Note that the extra "conda activate" is needed to ensure that the activate floats env to the front of PATH
CONDA_ACTIVATE = source $$(conda info --base)/etc/profile.d/conda.sh ; conda activate ; conda activate $(CURRENT_CONDA_ENV_NAME)

# Sample name for transcript exon coverage barplots
IN_FILE = exp/create_barplot/cov/results_PVAL_65_S1.tsv
NCBI_NAME = NM_000110.4
COMMON_NAME = DPYD
SAMPLE_NAME = PVAL_65_S1
OUT_DIR = res/

CPUS = 90
# In the CLI add after "make" 
# ARGS=--forceall

.PHONY: all, report, multiqc, exon_covs, help

all:
	@($(CONDA_ACTIVATE) ; \
	rm -f exon_cov_analysis/bar_plot_all_samples.html ; \
	snakemake --cores $(CPUS) --config cpus=$(CPUS) $(ARGS))

## multiqc: Create a multiqc report from all the pipeline results
multiqc:
	$(CONDA_ACTIVATE) ; \
	multiqc . -f \
	--verbose \
	--ignore .snakemake \
	--ignore all_target_segments_covered_by_probes_combined_merged_probe_file_combined \
	--ignore exp \
	--ignore fastq-temp \
	--ignore logs \
	--ignore MergedProbe_ROstergotland_Onco_v2_TE-94002956_hg19 \
	--ignore res \
	--ignore temp

## report: Create a snakemake report of the pipeline
report:
	$(CONDA_ACTIVATE) ; \
	snakemake --cores 1 --report report.html

## exon_covs: Make barplots of all exons in a sample
exon_covs:
	$(CONDA_ACTIVATE) ; \
	Rscript bin/exon_covs.R $(IN_FILE) $(NCBI_NAME) $(COMMON_NAME) $(SAMPLE_NAME) $(OUT_DIR)

## help: show this message
help:
	@grep '^##' ./Makefile
