import sys
from hapsburg.PackagesSupport.hapsburg_run import hapCon_chrom_BFGS
indname=sys.argv[1]
path2bed1240k="/mnt/archgen/users/yilei/Data/1000G/1000g1240khdf5/all1240/1240kChrX.bed" # Change this path according to your own setup
path2ref1240k="/mnt/archgen/users/yilei/Data/1000G/1000g1240khdf5/all1240/chrX.hdf5" # Change this path according to your own setup
path2meta="/mnt/archgen/users/yilei/Data/1000G/1000g1240khdf5/all1240/meta_df_all.csv" # Change this path according to your own setup
hapCon_chrom_BFGS(iid=indname, mpileup="/mnt/archgen/users/xiaowen/Kamenice/1024/Hapcon/RM/result/"+indname+".mpileup",
    h5_path1000g = path2ref1240k, meta_path_ref = path2meta)
