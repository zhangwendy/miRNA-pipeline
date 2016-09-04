#!/bin/bash
#$ -cwd
#$ -j y
#$ -l h_vmem=10G
#$ -pe shm 1
#$ -l h_rt=5:00:00
module load bowtie/1.1.1
module load cutadapt/1.8.1

# Biceps_2, Biceps_3, ... is sample prefix, modifiy this list according to your sample names.

for one in Biceps_2  Biceps_3 Biceps_4 Biceps_5  SSCAP_1 SSCAP_2 SSCAP_3 SSCAP_4 SSCAP_5 SSPIN_1 SSPIN_2 SSPIN_3 SSPIN_4 SSPIN_5 Synovium_2 Synovium_3 Synovium_5

do

# step 1, trim adapter, adatper.fa is the fasta file saving one or multiple adaper sequences, modify this file according to your adaper sequence.
# $one.fastq.gz is your raw fastq file name 
cutadapt --discard-untrimmed -N -a file:adatper.fa -e 0.125 -m 17 --info-file $one.info -o $one.good.fq $one.fastq.gz 

# step 2, collapse trimmed reads, sorted by abandance 
perl /path/to/script/collapse_fastq_sort_by_read.pl  $one.good.fq >$one.good.fa

# step 3, map with ribosome RNA 
bowtie --quiet -v 0 -k 1  --norc  /path/to/database/riboRNA  -f $one.good.fa  $one.good.riboRNA  --un $one.good.riboRNA.un --suppress 6,7

# step 4, map with tRNA
bowtie --quiet -v 0 -k 1  --norc  /path/to/database/tRNA  -f $one.good.riboRNA.un  $one.good.tRNA  --un $one.good.tRNA.un --suppress 6,7

# step 5, map with snoRNA
bowtie --quiet -v 0 -k 1  --norc  /path/to/database/snoRNA  -f $one.good.tRNA.un  $one.good.snoRNA  --un $one.good.snoRNA.un --suppress 6,7

# step 6, map with miRNA precursor, report all mappable locations
bowtie --quiet -v 0 -a --best --norc  /path/to/database/miRNA  -f $one.good.snoRNA.un  $one.good.miRNA  --un $one.good.miRNA.un --suppress 6,7

# step 7, dealing with multiple mapping reads. multiple mapping reads are evenly distributed among all mappable locations. 
perl  /pathA/to/script/divide_bt_for_multimatch.pl   $one.good.miRNA 

done

#step 8, make summary table about mature miRNA expression.
perl /path/to/script/mergy_mirna_single_exp_5p_3p.pl /path/to/database/miRNA.str > summary_table






