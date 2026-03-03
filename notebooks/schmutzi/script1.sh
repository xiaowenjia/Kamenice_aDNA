#!/usr/bin/env bash

#$ -S /bin/bash #defines bash as the shell for execution
#$ -N schmutzi #Name of the command that will be listed in the queue
#$ -cwd #change to current directory
#$ -j y #join error and standard output in one file, no error file will be written
#$ -o schmutzi #standard output file or directory (joined with error because of -j y)
#$ -q archgen.q #queue
#$ -pe smp 4 
#$ -l h_vmem=50G  
#$ -t 1-120
#$ -tc 60
#$ -V # load personal profile
#$ -m a # send notification if job aborts; bea=bigins,ends, aborts
# -M xiaowen_jia@eva.mpg.de

sed -n "${SGE_TASK_ID}p;" /mnt/archgen/users/xiaowen/Kamenice/1024/schmutzi/0226_mt/cmd_mtcont_commands.txt | bash

