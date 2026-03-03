#mkdir model_PCA_outlier

cd /mnt/archgen/users/xiaowen/Kamenice/1024/Admixtool/qpAdm/1125/outlier/220226_KNC232



### Create par files
pt1=($(pwd)"/")
fn1="/mnt/archgen/users/xiaowen/Kamenice/1024/Admixtool/qpAdm/1125/new_dataset/qpadm.renamed_unbiaseddataset.030126"
fn2="/mnt/archgen/users/xiaowen/Kamenice/1024/Admixtool/qpAdm/1125/outlier/040126/qpadm.renamed_unbiaseddataset.251125"
tpf1="template1.par"
jfn="qp"

## Replace third colum to make supragroups for the OGs (and later the sources)
#gawk -i inplace '{gsub("Georgia_Satsurblia.SG","CHG", $3)}1' ${of1}.ind


og1s="Ethiopia_4500BP.SG Russia_UstIshim_IUP_snpAD.DG Russia_Kostenki14_UP.AG.BY.AA Villabruna WEHG GoyetQ116_1 Israel_Natufian.AG ANE Iran_GanjDareh_N EEHG Levant_PPN Turkey_N W.EurasiaSteppe_EnBA"
og2s="Ethiopia_4500BP.SG Russia_UstIshim_IUP_snpAD.DG Russia_Kostenki14_UP.AG.BY.AA Villabruna WEHG GoyetQ116_1 Israel_Natufian.AG ANE Iran_GanjDareh_N EEHG Levant_PPN Turkey_N W.EurasiaSteppe_EnBA IronGates_HG"
og3s="Ethiopia_4500BP.SG Russia_UstIshim_IUP_snpAD.DG Russia_Kostenki14_UP.AG.BY.AA Villabruna WEHG GoyetQ116_1 Israel_Natufian.AG ANE Iran_GanjDareh_N EEHG Levant_PPN Turkey_N W.EurasiaSteppe_EnBA CHG IronGates_HG"


echo ${og1s} | sed s/" "/"\n"/g > OG1.pops
echo ${og2s} | sed s/" "/"\n"/g > OG2.pops
echo ${og3s} | sed s/" "/"\n"/g > OG3.pops


## Target populations
targets="KNC232_ss"
ref1s="NWB_MLBA"
echo ${ref1s} | sed s/" "/"\n"/g > Ref1s.pops

#mkdir -p Ref1s; for K in ${targets}; do mkdir -p ${K}; done

## Write a template for qpWave/qpAdm parameter files
echo 'genotypename: '${fn1}'.geno' > ${tpf1}
echo 'snpname: '${fn1}'.snp' >> ${tpf1}
echo 'indivname: '${fn2}'.ind' >> ${tpf1}
echo 'popleft: PLEFT' >> ${tpf1}
echo 'popright: '${pt1}'PRIGHT' >> ${tpf1}
echo -e 'details: YES\nmaxrank: 7' >> ${tpf1}

tnum1=($(wc -l Ref1s.pops))
onum=($(ls OG*.pops | wc -l))

jfn="qp"
## Write down .par and .pops files for qpWave (Refs) and qpAdm (others)
for P in Ref1s ${targets}; do for K in $(seq 1 $onum); do for J in $(seq 1 $tnum1); do
    if [[ "$P" == "Ref1s" ]]; then
        #of1=${pt1}${P}"/qpWave."${P}".OG"${K}"."${J}
        of1=${pt1}"/qpWave."${P}".OG"${K}"."${J}
        head -${J} Ref1s.pops | tail -1 | sed s/";"/"\n"/g >> ${of1}.pops
        awk -v lp="${of1}" '{ if ($1 == "popleft:") print $1,lp".pops"; else print $0}' ${tpf1} \
        | sed s/"PRIGHT"/"OG"${K}".pops"/g > ${of1}.par
    else
        of1=${pt1}"/qpAdm."${P}".OG"${K}"."${J}
        echo ${P} > ${of1}.pops
        head -${J} Ref1s.pops | tail -1 | sed s/";"/"\n"/g >> ${of1}.pops
        awk -v lp="${of1}" '{ if ($1 == "popleft:") print $1,lp".pops"; else print $0}' ${tpf1} \
        | sed s/"PRIGHT"/"OG"${K}".pops"/g > ${of1}.par
    fi
done; done; echo ${P}" is processed"; done


#rm */qpAdm.*.OG[13].2*
#rm */qpAdm.*.OG3.1*
#rm */qpAdm.*.OG[123].5*


## Run jobs

## Run the jobs
for i in $(ls qpAdm.*.OG*par);do
    fileid=$(echo $i | sed s/'.par'/''/g)
    echo "qpAdm -p $fileid.par > $fileid.log" | qsub -cwd -N qpadm -V -pe smp 1 -l h_vmem=10G -j y
done

