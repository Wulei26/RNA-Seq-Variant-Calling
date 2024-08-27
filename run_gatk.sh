#!/bin/bash
#这个流程只适用与单样本，每一个样本只有一对illumina读数产生的PE fastq数据

#工具路径
gatk=/public/home/wulei/miniconda3/envs/RNA/bin/gatk

#reference
reference=/public2022/wulei/GRCh38/GRCh38.primary_assembly.genome.fa
GATK_bundle=/public2022/wulei/GRCh38/GATK
dbsnp=Homo_sapiens_assembly38.dbsnp138.vcf
known_indels=Homo_sapiens_assembly38.known_indels.vcf.gz

samtools=/public/home/wulei/miniconda3/bin/samtools

bamdir=/public2022/wulei/RNA_fastq/align
outdir=/public2022/wulei/RNA_fastq/result/gatk


#从窗口中读取参数
RGID=lane1     #read group 单样品就用lane1代替
PL=ILLUMINA #这个值不能乱写，只能是市面上有的，默认illumina
RGLB=lib1
RGPU=unit1
sample=H460

for dir in {6,9,12,15,18}; do
        #Markduplicates，这一步不需要建立索引
        time $gatk MarkDuplicates \
            --INPUT ${bamdir}/${dir}/star_2_out/${sample}Aligned.sortedByCoord.out.bam \
            --OUTPUT ${outdir}/${dir}/${sample}.Markdup.bam \
            --CREATE_INDEX true \
            --VALIDATION_STRINGENCY SILENT \
            --METRICS_FILE ${outdir}/${dir}/${sample}.Markdup.metrics
        wait
        #SplitNCigarReads
        time $gatk SplitNCigarReads \
            -R $reference \
            -I ${outdir}/${dir}/${sample}.Markdup.bam \
            --create-output-bam-index true \
            -O ${outdir}/${dir}/${sample}.SplitN.bam
        wait
        #添加read group信息
        time $gatk AddOrReplaceReadGroups \
            -I ${outdir}/${dir}/${sample}.SplitN.bam \
            -O ${outdir}/${dir}/${sample}.split.add.bam \
            --CREATE_INDEX true \
            -ID ${RGID} \
            -LB ${RGLB} \
            -PL ${PL} \
            -PU ${RGPU} \
            -SM ${sample}
        wait
        #BQSR
        time $gatk BaseRecalibrator \
            -R ${reference} \
            -I ${outdir}/${dir}/${sample}.split.add.bam \
            --use-original-qualities \
            -O ${outdir}/${dir}/${sample}.recal_data.csv \
            --known-sites ${GATK_bundle}/${dbsnp} \
            --known-sites ${GATK_bundle}/${known_indels}
        wait

        #apply BQSR
        time $gatk ApplyBQSR \
            -R ${reference} \
            -I ${outdir}/${dir}/${sample}.split.add.bam \
            --use-original-qualities \
            -O ${outdir}/${dir}/${sample}.sorted.BQSR.bam \
            --bqsr-recal-file ${outdir}/${dir}/${sample}.recal_data.csv
        #--add-output-sam-program-record  如果添加上去的话，会给bam文件添加一个头部信息。用于追踪bam文件经过怎样的处理
        wait
        #HaplotypeCaller
        mkdir ${outdir}/${dir}/HC_out
        index=0
        for d in /public2022/wulei/GRCh38/interval/new_interval/*/; do
            echo $d
            let index+=1
            time $gatk HaplotypeCaller \
                -R ${reference} \
                -I ${outdir}/${dir}/${sample}.sorted.BQSR.bam \
                -L ${d%?}/scattered.interval_list \
                -O ${outdir}/${dir}/HC_out/${sample}.HC.${index}.vcf.gz \
                --recover-dangling-heads TRUE \
                -dont-use-soft-clipped-bases \
                --standard-min-confidence-threshold-for-calling 10 &
        done && wait

        #merge vcfs
        #用生成的vcf文件名拼接输入字段
        vcfs=""
        for z in ${outdir}/${dir}/HC_out/*.vcf.gz; do
            [[ -e "$z" ]] || break
            vcfs="-I $z $vcfs"
        done
        wait
        time $gatk MergeVcfs ${vcfs} -O ${outdir}/${dir}/HC_out/${sample}.HC.merge.vcf.gz && echo "** MergeVcfs done **"
        wait
        gunzip ${outdir}/${dir}/HC_out/${sample}.HC.merge.vcf.gz
        time $gatk VariantFiltration \
            -R ${reference} \
            -V ${outdir}/${dir}/HC_out/${sample}.HC.merge.vcf \
            -filter "FS > 30.0" --filter-name "FS" \
            -filter "QD < 2.0" --filter-name "QD" \
            -O ${outdir}/${dir}/HC_out/${sample}.HC.filter.vcf
done
