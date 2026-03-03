#!/bin/bash

########################################################
### Collect results
########################################################

cd /mnt/archgen/users/xiaowen/Kamenice/1024/Hapcon/RM

of1="Hapcon.summary.txt"
idf="/mnt/archgen/users/xiaowen/Kamenice/1024/Hapcon/RM/cmd_Hapcon_commands.txt"


#####################################
## Extract qpAdm key summary data  ##

while read line; do
    iid=($(echo ${line} | awk '{print $2}'))
    tfn1="/mnt/archgen/users/xiaowen/Kamenice/1024/Hapcon/RM/result/"${iid}".hapCon.txt"
    Y=($(cat ${tfn1} | tail -1 | awk '{print $6":"$7$8$9}' ))  
    #echo ${iid} >> ${of1}
    echo ${iid} ${Y} | sed s/":"/" "/g >> ${of1}
done < <(awk '$3 != "NA"' ${idf})
