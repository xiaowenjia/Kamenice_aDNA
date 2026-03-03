#!/bin/bash

#!/usr/bin/env bash

DIR=/mnt/archgen/users/xiaowen/Kamenice/1024/pmd/bam_original
OUTDIR=/mnt/archgen/users/xiaowen/Kamenice/1024/pmd/bam_filtered
REF=/mnt/archgen/Reference_Genomes/Human/hs37d5/SNPCapMasked/hs37d5_complete_1240Kmasked.fasta

# for no UDG, single-stranded capture data

for INBAM in $(ls $DIR/*.bam); do
    OUTBAM=$OUTDIR/$(basename $INBAM .bam).PMD3.bam
    LOG=$OUTDIR/$(basename $INBAM .bam).PMD3.log
    CMD="samtools calmd -u $INBAM $REF | samtools view -h -q30 |/usr/bin/X11/python /projects1/tools_new/pmd-tools/0.60/pmdtools.0.60.py --threshold 3 --header --UDGminus --ss | samtools view -bS - > $OUTBAM"
    qsub -cwd -V -b y -l h_vmem=20G -pe smp 2 -N pmdtools -j y -o ${LOG} ${CMD}
done

for INBAM in $(ls $DIR/*.bam); do
    OUTBAM=$OUTDIR/$(basename $INBAM .bam).PMD2.bam
    LOG=$OUTDIR/$(basename $INBAM .bam).PMD2.log
    CMD="samtools calmd -u $INBAM $REF | samtools view -h -q30 |/usr/bin/X11/python /projects1/tools_new/pmd-tools/0.60/pmdtools.0.60.py --threshold 2 --header --UDGminus --ss | samtools view -bS - > $OUTBAM"
    qsub -cwd -V -b y -l h_vmem=20G -pe smp 2 -N pmdtools -j y -o ${LOG} ${CMD}
done