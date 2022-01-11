#!/bin/bash

rc=0

echo "run_modess_maps.sh:  checking input arguments"
if [ -z $1 ]
then
  echo "Error: Insufficient command-line arguments"
  echo "Usage:  run_volcs.sh FChour"
  echo "        where FChour = 6, 12, 18, or 24"
  exit 1
else
  FC=$1
fi

if [[ "$FC" -eq 6 ]] ; then
 FChour="06"
fi
if [[ "$FC" -eq 12 ]] ; then
 FChour="12"
fi
if [[ "$FC" -eq 18 ]] ; then
 FChour="18"
fi
if [[ "$FC" -eq 24 ]] ; then
 FChour="24"
fi

G2SAUTOHOME=/home/ash3d/G2S_today

yyyy=`date --utc +"%Y"`
mm=`  date --utc +"%m"`
#dd=`  date --utc +"%d"`
dd=`  date +"%d"`
hours=(06 12 18 24)
freq=(0.1 0.5)

vfile=${G2SAUTOHOME}/Volcs.txt

nfreq=2
#nhours=4
nvolc=`wc -l ${vfile} | cut -d' ' -f1`

#nfreq=1
#nhours=1
#nvolc=1

cd ${G2SAUTOHOME}/Web_Infrasound

for (( ifq=0;ifq<${nfreq};ifq++ ))
do
  fq=${freq[ifq]}
  #for (( ih=0;ih<${nhours};ih++ ))
  #do
  # hh=${hours[ih]}
    for (( iv=1;iv<=${nvolc};iv++ ))
    do
      Volc=`head -n ${iv} ${vfile} | tail -1 | cut -f1 -d':'`
      Srcx=`head -n ${iv} ${vfile} | tail -1 | cut -f2 -d':'`
      Srcy=`head -n ${iv} ${vfile} | tail -1 | cut -f3 -d':'`
      Srcz=`head -n ${iv} ${vfile} | tail -1 | cut -f4 -d':'`
  
      echo "$iv $yyyy $mm $dd ${FChour} ${Volc} ${Srcx} ${Srcy} ${Srcz}"
      ./run_InfraTool_${FChour}.sh ${yyyy} ${mm} ${dd} ${FChour} ${Srcx} ${Srcy} ${Srcz} 41 50 1 11 850.0 ${fq} ${Volc}
    done
  #done
done

cd ${G2SAUTOHOME}

#cd /home/ash3d/G2S_today/Web_Infrasound

#./run_InfraTool.sh 2018 11 26 12 190.055 52.8222 1.7 41 50 1 11 850.0 0.1 Cleveland
#./run_InfraTool.sh 2018 11 26 12 282.34 0.077 3.5 41 50 1 11 850.0 0.1 Reventador
#./run_InfraTool.sh 2018 11 26 12 175.57 -39.28 2.8 41 50 1 11 850.0 0.1 Ruapehu
#./run_InfraTool.sh 2018 11 26 12 180.25 51.929 0.8 41 50 1 11 850.0 0.1 Semisopochnoi

