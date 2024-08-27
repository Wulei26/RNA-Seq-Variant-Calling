#!/bin/bash
#这个流程只适用与单样本，deepvariant的数据输入由star-two-pass之后的bam文件作为输入
#docker pull google/deepvariant:deeptrio-1.4.0
bedtools=/public2022/wulei/Biotools/bedtools2/bin/bedtools
mosdepth=/public/home/wulei/miniconda3/envs/deepvariant/bin/mosdepth
model=/public2022/wulei/deep/model/model.ckpt
bed=/public2022/wulei/deep/GRCh38_exon.bed

sample=$1
bam_in=$2
outdir=$3

outdir=$outdir/${sample}_deepvariant
if [ ! -d ${outdir}/data ]
then mkdir -p $outdir/data
fi
if [ ! -d ${outdir}/output ]
then mkdir -p $outdir/output
fi
#Generate a 3x coverage file,这个值可以自己设定，这里默认是3
$mosdepth --threads 20 $outdir/data/${sample}_coverage $bam_in
min_coverage=3
gzip -dc ${outdir}/data/${sample}_coverage.per-base.bed.gz | egrep -v 'GL|KI' | \  #这里去除了参考基因组中的一些contigs，只留下染色体chr1...chrM
awk -v OFS="\t" -v min_coverage=${min_coverage} '$4 >= min_coverage { print }' | \
$bedtools merge -d 1 -c 4 -o mean -i - > data/${sample}_${min_coverage}x.bed   ##-d 1表示只有相邻的区域才会被合并 -c 4 表示对于合并的区域，将会对第四列的值进行计算 -o mean 表示计算平均值

#Intersect coverage with exon regions,就是对3x_coverage的文件进行筛选，使得3x_coverage的文件全部落在外显子区域内
$bedtools intersect -a data/${sample}_${min_coverage}x.bed -b $bed > $outdir/data/${sample}_exon_${min_coverage}x.bed
#此时生成了既位于外显子区域，又在该区域上覆盖度为3的bed文件，此文件作为deepvariant的输入文件
#RNA_model:这里使用的是deepvariant团队训练出来的模型
