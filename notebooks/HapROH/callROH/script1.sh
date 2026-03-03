#!/usr/bin/env bash

#$ -S /bin/bash #defines bash as the shell for execution
#$ -N HapROH_0925 #Name of the command that will be listed in the queue
#$ -cwd #change to current directory
#$ -j y #join error and standard output in one file, no error file will be written
#$ -o HapROH_0925 #standard output file or directory (joined with error because of -j y)
#$ -q archgen.q #queue
#$ -pe smp 8 
#$ -l h_vmem=32G  
#$ -t 1-110
#$ -tc 60
#$ -V # load personal profile
#$ -m a # send notification if job aborts; bea=bigins,ends, aborts
# -M eirini_skourtanioti@eva.mpg.de

sed -n "${SGE_TASK_ID}p;" /mnt/archgen/users/xiaowen/Kamenice/1024/HapROH/0925/cmd_HapROH_commands.txt | bash

