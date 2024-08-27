#!/bin/bash
#此流程对于Platypus，输入的bam文件为star-2-pass的输出文件，--regions指定外显子区域
platypus=/public/home/wulei/miniconda3/envs/strelka/share/platypus-variant-0.8.1.2-0/Platypus.py
region=/public2022/wulei/GRCh38/interval/GRCh38.exon.txt
reference=/public2022/wulei/GRCh38/GRCh38.primary_assembly.genome.fa
bam_in=$1
sample=$2
outdir=$3
python2.7 $platypus callVariants --bamFiles=$bam_in --refFile=$reference --regions=$region --output=${oudir}/${sample}.vcf
