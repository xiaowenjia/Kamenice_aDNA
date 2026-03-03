#!/bin/bash
#$ -S /home/xiaowen_jia/anaconda3/envs/R4.1/bin/Rscript #defines bash as the shell for execution
#$ -N bread #Name of the command that will be listed in the queue
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


source('/mnt/archgen/users/xiaowen/Kamenice/1024/bread/070925/bread.R')