#!/bin/bash

########################################################
### Collect results
########################################################

cd /mnt/archgen/users/xiaowen/Kamenice/1024/Admixtool/qpAdm/1125/period/280126/LBA-EIA_rotating

of2="qpAdm_KNC_LBA_EIA.summary.251125.txt"

refp="Ref1s.pops"

## Target populations
targets="KNC_EIA"

rnum=($(wc -l ${refp}))
onum=($(ls OG*.pops | wc -l))


#####################################
## Extract qpAdm key summary data  ##

hv="Target OG nRef Refs Pval SSE C1 C2 C3 C4 SE1 SE2 SE3 SE4 nSNPs"; echo ${hv} > ${of2}
for P in ${targets}; do for K in $(seq 1 $onum); do for J in $(seq 1 ${rnum}); do
    tfn1="./qpAdm."${P}".OG"${K}"."${J}".log"
    refv=($(head -${J} ${refp} | tail -1))
    nref=($(echo ${refv} | awk 'BEGIN {FS=";"} {print NF}'))
    pval=($(cat ${tfn1} | grep -w "f4rank:" | tail -1 | awk '{print $14}'))  ## qpWave p-value
    coefs=($(grep "best c" ${tfn1} | awk '{print $0" NA NA"}' | awk '{print $3":"$4":"$5":"$6}'))  ## Coefficients
    SEs=($(grep -w "errors:" ${tfn1} | awk '{print $0" NA NA"}' | awk '{print $3":"$4":"$5":"$6}'))  ## SEs
    SSEs=($(awk 'BEGIN {sse=0.0} {if ($1 ~ /^dscore/) sse+=$4*$4} END {print sse}' ${tfn1}))  ## some of squared errors
    snp=($(grep "numsnps used:" ${tfn1} | cut -d ":" -f2))
    echo ${P}" OG"${K}" "${J}" "${refv}" "${pval}" "${SSEs}" "${coefs}" "${SEs}" "${snp} | sed s/":"/" "/g >> ${of2}
done; done; echo ${P}" is processed"; done