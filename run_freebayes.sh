#!/bin/bash
#这个流程只适用与单样本，freebays的数据输入由gatk经过mark duplicates add readgroup 和 sort之后的bam文件作为输入
#freebays-version:  v1.3.6
freebayes=/public/home/wulei/miniconda3/envs/RNA/bin/freebayes
ref=/public2022/wulei/GRCh38/GRCh38.primary_assembly.genome.fa
BED=/public2022/wulei/GRCh38/interval/GRCh38.exon.bed
sample=HG2
outdir=/public2022/wulei/RNA_fastq/result/freebayes

for dir in {3,6,9,12,15,18}; do
    $freebayes --fasta-reference $ref --min-coverage 3 --targets $BED /public2022/wulei/RNA_fastq/result/gatk/${dir}/${sample}.Markdup.bam >${outdir}/${dir}/${sample}.freebayes.vcf
    wait
    awk '$6 > 20' ${outdir}/${dir}/${sample}.freebayes.vcf > ${outdir}/${dir}/${sample}.freebayes.filter.vcf
    wait
done
