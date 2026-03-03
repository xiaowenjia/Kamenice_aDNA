#!/usr/bin/env bash
set -euo pipefail

cd /mnt/archgen/users/xiaowen/Kamenice/1024/Admixtool/qpAdm/1125/period/280126/LBA-EIA_rotating

pt1="$(pwd)/"
fn1="/mnt/archgen/users/xiaowen/Kamenice/1024/Admixtool/qpAdm/1125/new_dataset/qpadm.renamed_unbiaseddataset.030126"
fn2="/mnt/archgen/users/xiaowen/Kamenice/1024/Admixtool/qpAdm/1125/period/280126/LBA-EIA/qpadm.renamed_unbiaseddataset.251125"
tpf1="template1.par"

# -----------------------------
# Rotating sources
# -----------------------------
base_src="KNC_LBA"
rotA="SND"
rotB="Aegean_LBA"

# -----------------------------
# Outgroups
# OG1: baseline
# OG2: baseline + rotB
# OG3: baseline + rotA
# -----------------------------
og_base="Ethiopia_4500BP.SG Russia_UstIshim_IUP_snpAD.DG Russia_Kostenki14_UP.AG.BY.AA Villabruna WEHG GoyetQ116_1 Israel_Natufian.AG ANE Iran_GanjDareh_N EEHG Levant_PPN Turkey_N W.EurasiaSteppe_EnBA IronGates_HG"

og1s="${og_base}"
og2s="${og_base} ${rotB}"
og3s="${og_base} ${rotA}"

echo ${og1s} | sed 's/ /\n/g' > OG1.pops
echo ${og2s} | sed 's/ /\n/g' > OG2.pops
echo ${og3s} | sed 's/ /\n/g' > OG3.pops

# -----------------------------
# Target
# -----------------------------
targets="KNC_EIA"

# -----------------------------
# ONLY two source models
# -----------------------------
# Model 1: KNC_LBA + SND
# Model 2: KNC_LBA + Aegean_LBA
ref1s="${base_src};${rotA} ${base_src};${rotB}"
echo ${ref1s} | sed 's/ /\n/g' > Ref1s.pops

tnum1=$(wc -l < Ref1s.pops)
onum=$(ls OG*.pops | wc -l)

# -----------------------------
# Template .par
# -----------------------------
echo "genotypename: ${fn1}.geno" > ${tpf1}
echo "snpname: ${fn1}.snp" >> ${tpf1}
echo "indivname: ${fn2}.ind" >> ${tpf1}
echo "popleft: PLEFT" >> ${tpf1}
echo "popright: ${pt1}PRIGHT" >> ${tpf1}
echo -e "details: YES\nmaxrank: 7" >> ${tpf1}

# -----------------------------
# Helper: auto-drop illegal combos where any LEFT source appears in RIGHT OGs
# -----------------------------
is_illegal_combo () {
  # $1 = ref_line like "KNC_LBA;SND"
  # $2 = og_file like "OG3.pops"
  local ref_line="$1"
  local og_file="$2"

  # Split ref_line on ';' and check each token against og_file (exact line match)
  local token
  IFS=';' read -r -a toks <<< "${ref_line}"
  for token in "${toks[@]}"; do
    # skip empty just in case
    [[ -z "${token}" ]] && continue
    if grep -Fxq "${token}" "${og_file}"; then
      return 0  # illegal
    fi
  done
  return 1  # legal
}

# -----------------------------
# Generate qpWave / qpAdm files (with illegal-drop)
# -----------------------------
for P in Ref1s ${targets}; do
  for K in $(seq 1 ${onum}); do
    ogfile="OG${K}.pops"

    for J in $(seq 1 ${tnum1}); do
      # The chosen source-set (single line from Ref1s.pops)
      ref_line="$(sed -n "${J}p" Ref1s.pops)"

      # Skip if any source is in the chosen OG list
      if is_illegal_combo "${ref_line}" "${ogfile}"; then
        echo "SKIP illegal: J=${J} (${ref_line}) with ${ogfile}"
        continue
      fi

      if [[ "${P}" == "Ref1s" ]]; then
        # qpWave
        of1="${pt1}/qpWave.${P}.OG${K}.${J}"

        # left pops for qpWave = chosen sources (split ';' into lines)
        printf "%s\n" "${ref_line}" | sed 's/;/\n/g' > "${of1}.pops"

        awk -v lp="${of1}" '{
          if ($1=="popleft:") print $1, lp".pops";
          else print $0
        }' "${tpf1}" | sed "s/PRIGHT/${ogfile}/g" > "${of1}.par"

      else
        # qpAdm
        of1="${pt1}/qpAdm.${P}.OG${K}.${J}"

        # popleft = target + chosen sources
        echo "${P}" > "${of1}.pops"
        printf "%s\n" "${ref_line}" | sed 's/;/\n/g' >> "${of1}.pops"

        awk -v lp="${of1}" '{
          if ($1=="popleft:") print $1, lp".pops";
          else print $0
        }' "${tpf1}" | sed "s/PRIGHT/${ogfile}/g" > "${of1}.par"
      fi

    done
  done
  echo "${P} processed"
done

# -----------------------------
# Submit qpAdm jobs (only those created)
# -----------------------------
shopt -s nullglob
for i in qpAdm.*.OG*.par; do
  fileid="${i%.par}"
  echo "qpAdm -p ${fileid}.par > ${fileid}.log" | \
    qsub -cwd -N qpadm -V -pe smp 1 -l h_vmem=10G -j y
done
