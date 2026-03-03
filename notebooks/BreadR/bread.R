library(BREAD)
ind_path <- '/mnt/archgen/users/xiaowen/Kamenice/1024/bread/070925/Bread_KNC_NM_0925.ind'
snp_path <- '/mnt/archgen/users/xiaowen/levant/pmr/dataset/new.snp'
geno_path <- '/mnt/archgen/users/xiaowen/Kamenice/1024/bread/070925/Bread_KNC_NM_0925.geno'
counts_example <- processEigenstrat(indfile = ind_path, snpfile = snp_path, genofile = geno_path, outfile = '/mnt/archgen/users/xiaowen/Kamenice/1024/bread/070925/bread_pmr_result.tsv')
relatedness_example <- callRelatedness(counts_example)
write.csv(relatedness_example,'/mnt/archgen/users/xiaowen/Kamenice/1024/bread/070925/bread_results.csv',row.names=FALSE)