#!/bin/bash
#$ -S /bin/bash #defines bash as the shell for execution
#$ -N PCA_add #Name of the command that will be listed in the queue
#$ -cwd #change to current directory
#$ -j y #join error and standard output in one file, no error file will be written
#$ -o PCA_add #standard output file or directory (joined with error because of -j y)
#$ -q archgen.q #queue
# -m e #send an email at the end of the job
# -M xiaowen_jia@eva.mpg.de #send email to this address
#$ -pe smp 8 #needs 8 CPU cores
#$ -l h_vmem=45G #request 4Gb of memory
#$ -V # load personal profile
#$ -o $JOB_NAME.o.$JOB_ID
# -tc 20

smartpca -p /mnt/archgen/users/xiaowen/Kamenice/1024/PCA/0925/pca_shrink_add.txt