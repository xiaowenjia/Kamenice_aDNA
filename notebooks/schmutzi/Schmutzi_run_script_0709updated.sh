#!/bin/bash

unset PERL5LIB

iid=$1     ## individual ID
#lid=$2       ## library ID
libtype=$2  ## library type (single or double) ## New option added by ES on 030322: "singleUDG"

cd /mnt/archgen/users/xiaowen/Kamenice/1024/schmutzi/0226_mt

pt1=($(pwd)"/")
MTref1="/mnt/archgen/users/xiaowen/tools/schmutzi/share/schmutzi/refs/human_MT_renamed.fasta" ## updated on 211008 (from /projects1/)
#MTref2="/mnt/archgen/Reference_Genomes/Human/HG19/hg19_MT_500.fasta"  ## updated on 211008 (from /projects1/)
MTref2="/mnt/archgen/users/xiaowen/tools/schmutzi/share/schmutzi/refs/human_MT_wrapped_renamed_500.fasta"  ## updated on 211008 (from /projects1/)

mkdir $iid
rg="@RG\tID:"${iid}"\tSM:"${iid}"\tLB:"${iid}"\tPL:illumina"
of1=${iid}".circmapper"
bam1=${of1}".rmdup.q30.MD.small.bam"

cd ${pt1}${iid}
mkdir -p ./fastq
samtools fastq /mnt/archgen/users/xiaowen/Kamenice/1024/schmutzi/0226_mt/eager/results/deduplication/"${iid}"/*.bam > ./fastq/"${iid}"_rmdup.bam.fastq.gz
mkdir -p ./circularMT; mkdir -p ./schmutzi; cd ./circularMT/

## Align data to wrapped MT genome: keep only mapped reads
#fq1=$(echo ${fq} | sed s/','/' '/g)  ##added
fq1="../fastq/"${iid}"_rmdup.bam.fastq.gz"

bwa aln -t 4 -n 0.01 -l 32 ${MTref2} ${fq1} > ${of1}.0.sai   ## originally 'bwa aln -t 4 -n 0.01 -l 32 ${MTref2} ${fq} > ${of1}.0.sai'
bwa samse -r ${rg} ${MTref2} ${of1}.0.sai ${fq1} | samtools view -bh -F 0x0004 -o ${of1}.0.bam -
## originally 'bwa samse -r ${rg} ${MTref2} ${of1}.0.sai ${fq}'

## Run circular realigner and sort the output: here use unwrapped reference
java -Xmx4000m -jar /projects1/tools/circularmapper/RealignSAMFilev1.1.jar -e 500 -i ${of1}.0.bam -r ${MTref1}

samtools sort -@ 4 ${of1}.0_realigned.bam -o ${of1}.1.bam
samtools view -bh -F 0x0004 -o ${of1}.bam ${of1}.1.bam
samtools index ${of1}.bam

## Remove duplicates and apply MAPQ >= 30 filter
## then, remove temporary files
dedup -m -i ${of1}.bam -o ./
mv ${of1}_rmdup.bam ${of1}.rmdup.bam
samtools index ${of1}.rmdup.bam
samtools view -q30 -o ${of1}.rmdup.q30.bam ${of1}.rmdup.bam
samtools index ${of1}.rmdup.q30.bam
samtools fillmd -b ${of1}.rmdup.q30.bam ${MTref1} > ${of1}.rmdup.q30.MD.bam
samtools index ${of1}.rmdup.q30.MD.bam

## Downsample reads to run Schmutzi easily (capped to 30,000 reads)
nr1=($(samtools view -c ${of1}.rmdup.q30.MD.bam))
pr1=($(echo ${nr1} | awk '{printf "%.3f\n", 30000/$1}'))
if [ "$nr1" -le 30000 ]; then
    cp ${of1}.rmdup.q30.MD.bam ${of1}.rmdup.q30.MD.small.bam
    samtools index ${of1}.rmdup.q30.MD.small.bam
else
    samtools view -bh -s ${pr1} -o ${of1}.rmdup.q30.MD.small.bam ${of1}.rmdup.q30.MD.bam
    samtools index ${of1}.rmdup.q30.MD.small.bam
fi

## Remove temporary files
rm ${of1}.0*; rm ${of1}.1*

## Move into Schmutzi directory
cd ../schmutzi/

## Run contDeam (Schmutzi step 1) and schmutzi (Schmutzi step 2)
if [[ "$libtype" == "single" ]]; then
    contDeam --library single --lengthDeam 20 --out ./${of1}_nolen ${MTref1} ../circularMT/${bam1}
    schmutzi -t 4 --notusepredC --lengthDeam 20 --ref ${MTref1} ./${of1}_nolen /projects1/tools/schmutzi/alleleFreqMT/197/freqs/ ../circularMT/${bam1}
elif [[ "$libtype" == "singleUDG" ]]; then
    contDeam --library single --lengthDeam 2 --out ./${of1}_nolen ${MTref1} ../circularMT/${bam1}
    schmutzi -t 4 --notusepredC --lengthDeam 2 --ref ${MTref1} ./${of1}_nolen /projects1/tools/schmutzi/alleleFreqMT/197/freqs/ ../circularMT/${bam1}
else
    contDeam --library double --lengthDeam 2 --out ./${of1}_nolen ${MTref1} ../circularMT/${bam1}
    schmutzi -t 4 --notusepredC --lengthDeam 2 --ref ${MTref1} ./${of1}_nolen /projects1/tools/schmutzi/alleleFreqMT/197/freqs/ ../circularMT/${bam1}
fi