# ScottishLabData
The SQL script for transferring regional Safe Haven data structure into the proposed structure for each Safe Haven, as well as R scripts for laboratory data harmonisation.

# GoDb - a hybrid genomic data store for multiple SNP panels
## Background
For single institution bio-resources genotyping of subjects may have taken place in phases over a period of some years and on differing SNP assay platforms, resulting in multiple data sets belonging to different *SNP panels* or *assaytype*s. While genotype data sets can reside in file system files, possibly in different genotype formats (PLINK BED, Oxford .gen, VCF or BCF, for example), this project is aimed at VCF files compressed using bgzip and indexed using tabix.


## Requirements
The over-arching requirement is the provision of a simple data management architecture and the software to bring together multi SNP panel genomic data for a single cohort.

### Functional
Some additional functional requirements are:
* Curation of genomic data from multiple SNP panels.
* Provision of the means to query data using well-known SNP identifiers (dbSNP rsids). 
* Maximising sample size via the automatic combination of genotype records across assay platforms, resolving overlaps in sample sets on demand.
* Adding genotype data from new assays as they become available.   
 
### Non-Functional
Two non-functional requirements were also identified:
* Operate in an environment where compute resources may be limited.
* Allow for scaling up of the size of the data, in particular sample-size, with little performance degradation   

## Description
The data store was designed and built using MongoDb to hold collections of variant, sample and file-location data, with genotype data retained in VCF files.

Software was developed to take advantage of the rapid access times offered by both MongoDb for storing variant id (rsid) vs genomic co-ordinates, and tabix indexing for random access to compressed VCF files via genomic co-ordinates. This includes a prototype web application for querying of the data store by variant_id(s), plus a collection of command line tools for use in bulk data extraction.

### This repository 
Repository sub-directories:

- *cfg/* Config files containing environment variables to locate data, software and the MongoDb database host 

- *load/py/* Python scripts to load the data store.

- *load/pl/* Single perl script for data directory navigation and variant load script execution

- *load/pm/* Perl modules for data directory navigation

- *load/sh/* Data store load bash wrapper scripts.

- *webapp/* All Python code, templates, java script, css and image files related to the web application.

- *extract/py/* Command-line Python code for genotype data extract, from lists of SNPs. 

- *extract/src/* Root directory for Go(lang) source code to build command-line data extraction tools. There is also library code to handle MongoDb and tabix-indexed file access plus VCF file parsing and metrics (for example calculation of MAF, HWEP, CR).

- *extract/sh/* bash scripts, wrappers for command-line extract tools.

- *lib/py/* Python library code, including the python godb API layer, VCFrecord field access and production of metrics (MAF, HWEP, CR) for genotype records.

- *godbassoc/* Experimental webapp written in Golang, includes code to allow the upload, saving and selection of phenotype files (both binary and continuous) and to make a call-out to PLINK (if installed) for association testing. TODO: use cases and example phenotype data for association testing

### Running database load scripts
Scripts located in *load/sh*, *load/py* and *load/pl*.
All scripts rely on the files in the *cfg* directory to find both data and the MongoDb database, there are examples for five different assay platforms in the *cfg* directory.

Once the cfg files are set up and, assuming the MongoDb collections listed in the next section are either non-existent or do not already contain data for the assay type in question with all indexes dropped three scripts can be run from the *load/sh* directory:

- load_variants_from_vcf_files.sh \<full path to assay platform cfg file\> 

- load_samples.sh \<full path to assay platform cfg file\> 

- load_filepaths.sh \<full path to assay platform cfg file\> 

NOTES:
- *assay type* is an assigned tag which must be unique for each assay type (SNP Panel) - assaytype examples in use in the current implementation are: "affy", "illumina", "broad", "metabo".


### MongoDb Collections - example documents
variants - one document per variant per SNP panel (assaytype):
```
{
	"_id" : ObjectId("5dee1245d5d298277178bcfb"),
	"assaytype" : "metabo",
	"ref_maf" : 0.6,
	"rsid" : "rs7294904",
	"info" : 1,
	"alleleB" : "C",
	"position" : 199532,
	"alleleA" : "T",
	"chromosome" : "12"
}
```

samples - one document per sample per SNP panel (assaytype):
```
{
	"_id" : ObjectId("5decf26e64b5031da4b9c5cd"),
	"assaytype" : "affy",
	"list_posn" : 0,
	"sample_id" : "006561"
}
```

filepaths - one document per SNP panel (assaytype):
```
{
	"_id" : ObjectId("5decf307339f134beefc2419"),
	"assaytype" : "affy",
	"files" : [
		{
			"CHROM" : "12",
			"filename" : "chr12.vcf.gz"
		},
		{
			"CHROM" : "02",
			"filename" : "chr02.vcf.gz"
		},
		{
			"CHROM" : "06",
			"filename" : "chr06.vcf.gz"
		},
		{
			"CHROM" : "22",
			"filename" : "chr22.vcf.gz"
		},
		{
			"CHROM" : "01",
			"filename" : "chr01.vcf.gz"
		},
		{
			"CHROM" : "19",
			"filename" : "chr19.vcf.gz"
		}
	],
	"fpath_prefix" : "<data root>/godb",
	"filepath" : "<data root>/affy/",
	"fpath_suffix" : "affy/"
}
```

## Dependencies
- MongoDb community edition (version 3 upwards, tested to 4.2.1)
- Tabix (0.2.5)
- pysam python library (0.15.3)
- pymongo python library (3.9.0)
- gopkg.in/mgo.v2 golang library
- gopkg.in/mgo.v2/bson golang library
- github.com/brentp/bix golang library for tabix index access
- github.com/brentp/irelate/intercases golang library for tabix index access

## Index Web-Page
Front page displayed by the prototype web-application

![](images/godb_webapp.jpg)
 
## Data Store Architecture 
High-level architecture diagram of the data store and software, showing application level, godb library and third-party library layers.

![](images/godb_architecture.png)


## Combining genotype records 
Genotype records are combined in both Python and Golang code, with sample overlaps resolved according to the indicated genotype resolution rules.If there were no sample overlaps this would be a matter of concatenating the genotype arrays and writing the combined record. Sample overlaps mean that the genotype for every sample must be checked across the record sets. This is explained further below and summarised in the figure.

![](images/combining_geno_data.png)

The figure shows in-memory arrays built prior to writing the output. Data for each of the input arrays is copied to expanded intermediate arrays, in the same order as the combined array, before comparison is done, followed by a final copy step to the output array. 


## Performance
Performance for extracting and combining genotype records for one SNP (rs7412, present on all platforms) for 100 iterations

![](images/extraction_performance.png)

The 'X' axis is sample-size, the 'Y' axis time in seconds. Tests were run on an iMAC i7 with 16Gb of memory and 4 cores. As the numbers of samples rises, so does the number of SNP panels involved meaning parallel I/O in the Go paralell version (red-line) confers more of an advantage.


 
## Acknowledgments

Early versions of this software were developed as part of a UK Medical Research Council funded PhD

