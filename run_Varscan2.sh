#!/bin/bash
#这个流程只适用与单样本，每一个样本只有一对illumina读数产生的PE fastq数据
#注意输入的bam文件是比对好的用samtools排序完成的bam文件
#STAR_two_align的输出文件
samtools=/public/home/wulei/miniconda3/envs/RNA/bin/samtools
reference=/public2022/wulei/GRCh38/GRCh38.primary_assembly.genome.fa
BED=/public2022/wulei/GRCh38/interval/GRCh38.exon.bed

#min_coverage=$2  #default:8
#min_reads=$3   #default:2
#strand_filter=$4  #default:1
#p_value=$5 #default :0.99


#$samtools mpileup -f $reference ${bam_in} | java -jar /public/home/wulei/mysoftware/VarScan.v2.3.9.jar mpileup2cns --min-coverage ${min_coverage} --min-reads2 ${min_reads} --output-vcf 1 --strand-filter ${strand_filter} --p-value ${p_value} > $outdir/${sample}.varscan.vcf
#filter java -jar /public/home/wulei/mysoftware/VarScan.v2.3.9.jar filter --help 可对提取值进行过滤
bam_in=/public2022/wulei/RNA_fastq/align
outdir=/public2022/wulei/RNA_fastq/result/Varscan2
sample=HG2
for dir in {3,6,9,12,15,18}; do
    $samtools mpileup -f $reference --positions $BED ${bam_in}/${dir}/star_2_out/${sample}Aligned.sortedByCoord.out.bam | java -jar /public/home/wulei/mysoftware/VarScan.v2.3.9.jar mpileup2snp --output-vcf 1 > $outdir/${dir}/${sample}.varscan.snp.vcf
    $samtools mpileup -f $reference --positions $BED ${bam_in}/${dir}/star_2_out/${sample}Aligned.sortedByCoord.out.bam | java -jar /public/home/wulei/mysoftware/VarScan.v2.3.9.jar mpileup2indel --output-vcf 1 > $outdir/${dir}/${sample}.varscan.indel.vcf
    wait
done
