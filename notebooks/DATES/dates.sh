dates="/home/eirini_skourtanioti/miniconda3/envs/dates_env/DATES_v4010/dates"
echo "$dates -p Dates.par > Dates_1108.log" | qsub -cwd -N qpadm -V -pe smp 2 -l h_vmem=20G -j y