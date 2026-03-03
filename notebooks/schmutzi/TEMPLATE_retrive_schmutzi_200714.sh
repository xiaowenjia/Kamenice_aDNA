#!/bin/bash
#$ -S /bin/bash #defines bash as the shell for execution
#$ -N Retrive_schmutzi #Name of the command that will be listed in the queue
#$ -cwd #change to current directory
#$ -j y #join error and standard output in one file, no error file will be written
#$ -q archgen.q #queue
# -m e #send an email at the end of the job
# -M xiaowen_jia@eva.mpg.de #send email to this address
# -pe smp 2 #needs 8 CPU cores
#$ -l h_vmem=45G #request 4Gb of memory
#$ -V # load personal profile
#$ -o $JOB_NAME.o.$JOB_ID
# -tc 20

cd /mnt/archgen/users/xiaowen/Kamenice/1024/schmutzi/0226_mt/NM

nbtch=$1 # provide the batch number
seqtyp=$2 # capture, capture2, capture3
libtyp=$3 # double dsLib, single for ssLib
dt=($(date +"%Y%m%d" | cut -c 3-8))

pt1=($(pwd)"/")
idf="/mnt/archgen/users/xiaowen/Kamenice/1024/schmutzi/0226_mt/NM/cmd_mtcont_commands.txt"
of1="NM.mt.schmutzi."${dt}".txt"
#pt2="/mnt/archgen/MHAAM/DataProcessing/eager/"
#scf="../Schmutzi_run_script_180903.sh"

## Retrieve the number of reads, mean coverage and Schmutzi output
echo -e 'ID\tnr.MT.only\tmn.cov.MT.only\tcont.nolen\tcont.nolen.lb\tcont.nolen.ub' > ${of1}
while read line; do
    iid=($(echo ${line} | awk '{print $2}'))
    bam=($(ls ./${iid}/circularMT/*.MD.bam))

    tnum1=($(samtools view -c ${bam}))
    tnum2=($(samtools depth -a -q30 -Q30 ${bam} | awk 'BEGIN {ns=0; nr=0} {if ($1 == "NC_012920.1") ns+=1; nr+=$3} END {print nr/ns}'))

    tcf1="./"${iid}"/schmutzi/"${iid}".circmapper_nolen_final.cont.est"
    if [ -f $tcf1 ]; then
        cont=($(awk '{if ($3 == "") print $1":"$2":NA"; else print $1":"$2":"$3}' ${tcf1}))
    else cont="NA:NA:NA"; fi
    echo -e ${iid}"\t"${tnum1}"\t"${tnum2}"\t"${cont} | sed s/":"/"\t"/g >> ${of1}
done < <(awk '$3 != "NA"' ${idf})

## Retrieve consensus sequences
faout1="NM.mt.020226.MTconsensus.schmutzi.nolen.fasta"
faout2="NM.mt.020226.MTcont.schmutzi.nolen.fasta"

rm $faout1 $faout2  ##added on 04.03.22 by ES

while read line; do
    iid=($(echo ${line} | awk '{print $2}'))
    logf1="./"${iid}"/schmutzi/"${iid}".circmapper_nolen_final_endo.log" ## log file for endogenous seq
    logf2="./"${iid}"/schmutzi/"${iid}".circmapper_nolen_final_cont.log" ## log file for contaminant seq

    for J in 10 20 30; do hv=">"${iid}".q"${J}
        if [ -f "$logf1" ]; then
            echo ${hv} >> ${faout1}; /projects1/tools/schmutzi/log2fasta -q ${J} ${logf1} | tail -n +2 >> ${faout1}
        fi
        if [ -f "$logf2" ]; then
            echo ${hv} >> ${faout2}; /projects1/tools/schmutzi/log2fasta -q ${J} ${logf2} | tail -n +2 >> ${faout2}
        fi
    done
done < <(awk '$3 != "NA"' ${idf})

#rm slurm.*; rm slurm-*; rm ../slurm-*
rm summary_mtcont*
