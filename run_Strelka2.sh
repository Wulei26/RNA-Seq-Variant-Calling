#!/bin/bash
#这个流程只适用与单样本，每一个样本只有一对illumina读数产生的PE fastq数据,Strelka2只支持双端的数据
#Strelka必须在python2的环境下运行
#Strelka2输入的bam文件时star比对出来的文件
#version: v2.9.2
ref=/public2022/wulei/GRCh38/GRCh38.primary_assembly.genome.fa
bed=/public2022/wulei/GRCh38/interval/stk_bed/GRCh38.exon.bed.gz
bam=$1
outdir=$2
sample=$3
python2.7 /public/home/wulei/BioSoftware/strelka-2.9.2.centos6_x86_64/bin/configureStrelkaGermlineWorkflow.py \
--bam $bam \
--referenceFasta $ref \
--callRegions $bed \
--runDir $outdir \
--rna
