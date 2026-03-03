#!/bin/bash

unset PERL5LIB

iid=$1      ## individual ID
#lid=$2       ## library ID
libtype=$2  ## library type (single or double) ## New option added by ES on 030322: "singleUDG"

#path2bam=/mnt/archgen/Autorun_eager/eager_outputs/RM/KNC/$iid/trimmed_bam/$iid*.bam
path2bam=/mnt/archgen/Autorun_eager/eager_outputs/RM/KNC/$iid/trimmed_bam/*.bam
#path2bam=/mnt/archgen/Autorun_eager/eager_outputs/TF/*/$iid/trimmed_bam/*_ss*.bam
path2bed1240k=/mnt/archgen/users/yilei/Data/1000G/1000g1240khdf5/all1240/1240kChrX.bed # Change this path according to your own setup
samtools index $path2bam
samtools mpileup --positions $path2bed1240k -r X -q 30 -Q 30 -o /mnt/archgen/users/xiaowen/Kamenice/1024/Hapcon/RM/result/$iid.mpileup $path2bam
/home/xiaowen_jia/anaconda3/bin/python /mnt/archgen/users/xiaowen/Kamenice/1024/Hapcon/RM/Hapcon.py $iid
