import sys
from hapsburg.PackagesSupport.hapsburg_run import hapsb_ind  # Need this import
indname=sys.argv[1]
hapsb_ind(iid=indname, chs=range(1,23), processes=1, 
          path_targets='/mnt/archgen/users/xiaowen/Kamenice/1024/bread/070925/genotype_data/All_070925', 
          h5_path1000g='/mnt/archgen/users/yilei/Data/1000G/1000g1240khdf5/all1240/chr', 
          meta_path_ref='/mnt/archgen/users/yilei/Data/1000G/1000g1240khdf5/all1240/meta_df_all.csv', 
          folder_out='/mnt/archgen/users/xiaowen/Kamenice/1024/HapROH/0925/output', prefix_out='', 
          e_model="haploid", p_model="Eigenstrat",
          random_allele=True, readcounts=False,
          delete=False, logfile=True, combine=True)