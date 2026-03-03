#!/bin/bash

########################################################
### Collect results
########################################################

cd /mnt/archgen/users/xiaowen/Kamenice/1024/schmutzi/0226_mt

of1="KNC.mt.020226.consensus.summary.txt"
#of1="KNC.RM.191024.cont.summary.txt"


#####################################
## Extract qpAdm key summary data  ##
idf1="/mnt/archgen/users/xiaowen/Kamenice/1024/schmutzi/0226_mt/cmd_mtcont_commands.txt"


while read line; do
    tfn1="/mnt/archgen/users/xiaowen/Kamenice/1024/schmutzi/0226_mt/KNC.mt.020226.MTconsensus_Haplogroups.txt"
    #tfn1="/mnt/archgen/users/xiaowen/Kamenice/1024/schmutzi/191024/KNC.RM.191024.MTcont_Haplogroups.txt"    
    iid=($(echo ${line} | awk '{print $2}'))
    #lid=($(echo ${line} | awk '{print $3}'))
    Y=($(cat ${tfn1} | grep -w "${iid}.q30" | tail -1 | awk '{print $1":"$3":"$5}' ))  
    echo ${Y} | sed s/":"/" "/g >> ${of1}
    #echo ${iid} >> ${of1}
done < <(awk '$3 != "NA"' ${idf1})

