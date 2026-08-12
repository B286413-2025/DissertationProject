# Host Factors Associations with the Canine Microbiome

## Overview

This repository contains the scripts used in an MSc bioinformatics project investigating the associations between host factors and the canine microbiome. 

---

## Directory and File Descriptions

### `scripts/`

Contains all bash scripts executed on Eddie, the University of Edinburgh's high-performance computing (HPC) cluster. These scripts cover the upstream processing steps (including initial processing, trimming, OTU/ASV generation, taxonomic assignment and phylogenetic tree building).

Also included is **`full_process.txt`**, which provides an ordered record of all commands run throughout the analysis pipeline.

### `metadata/`

Contains the metadata cleaning script used to prepare the sample metadata before the statistical analysis.

### Statistical Analysis R Markdowns

Three R Markdown files contain the downstream statistical analyses performed on the processed data, each corresponding to a different method of the upstream processing:

| File | Approach | Description |
|------|----------|-------------|
| `statistical_analysis_set2_short.Rmd` | ASV Pipeline | Amplicon Sequence Variant-based analysis |
| `statistical_analysis_otu_set2.Rmd` | De-novo OTU Clustering | OTUs clustered de-novo, within the dataset |
| `statistical_analysis_otu_cr_set2.Rmd` | Closed-reference OTU Clustering | OTUs clustered against a reference database (SILVA SSURef database v138.2) |

---

## Project Context

This work was conducted as part of an MSc project at the University of Edinburgh, exploring how host-level factors (such as age, breed, or diet) are associated with the canine gut microbiome. In addition, the project set to examine if these results are robust to the bioinformatic processing choice.
