#!/bin/bash
#这个流程只适用与单样本，每一个样本只有一对illumina读数产生的PE fastq数据
#注意输入的bam文件是比对好的用samtools排序完成的bam文件
#STAR_two_align的输出文件
#Version: 1.16 (using htslib 1.16)
#工具
bcftools=/public/home/wulei/miniconda3/envs/bcftools/bin/bcftools
#参考基因组
reference=/public2022/wulei/GRCh38/GRCh38.primary_assembly.genome.fa
#bam_in=/public2022/wulei/TC05_T/TC05_T/RNA_Seq/TC05_T_GATK/star/star_2_out/TC05_TAligned.sortedByCoord.out.bam
#oudir=/public2022/wulei/TC05_T/TC05_T/RNA_Seq/TC05_T_bcftools/default
BED=/public2022/wulei/GRCh38/interval/GRCh38.exon.bed
bam_in=$1
sample=$2
outdir=$3
#创建一个outdir
outdir=$outdir/${sample}_bcftools
if [ ! -d ${outdir} ]
then mkdir -p $outdir
fi
$bcftools mpileup -Ou -R $BED -f $reference $bam_in | bcftools call -mv > ${oudir}/bcftools.default.vcf
