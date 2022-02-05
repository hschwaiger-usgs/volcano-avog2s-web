#!/bin/bash

rc=0

echo "run_ModessMap_volcs.sh:  checking input arguments"
if [ -z $1 ]
then
  echo "Error: Insufficient command-line arguments"
  echo "Usage:  run_ModessMap_volcs.sh HH [YYYY MM DD]"
  echo "        where HH = 6, 12, 18, or 24"
  exit 1
else
  FC=$1
fi

if [[ "$FC" -eq 6 ]] ; then
 HH="06"
fi
if [[ "$FC" -eq 12 ]] ; then
 HH="12"
fi
if [[ "$FC" -eq 18 ]] ; then
 HH="18"
fi
if [[ "$FC" -eq 24 ]] ; then
 HH="24"
fi
# Now test for additional command-line arguments for YYYY MM DD
# If none are given, assume today
if [ -z $2 ]
  YYYY=$2
else
  YYYY=`date -u +%Y`
fi
if [ -z $3 ]
  MM=$3
else
  MM=`date -u +%m`
fi
if [ -z $4 ]
  DD=$4
else
  DD=`date -u +%d`
fi

# Now that we have YYYY MM DD HH of the event, get the actual date since HH might push
# the date to the next day
yyyy=`date --utc -d "00:00 ${MM}/${DD}/${YYYY} + ${HH} hours" +"%Y"`
mm=`  date --utc -d "00:00 ${MM}/${DD}/${YYYY} + ${HH} hours" +"%m"`
dd=`  date --utc -d "00:00 ${MM}/${DD}/${YYYY} + ${HH} hours" +"%d"`
hh=`  date --utc -d "00:00 ${MM}/${DD}/${YYYY} + ${HH} hours" +"%H"`

AVOG2S=/opt/USGS/AVOG2S
WRK=${AVOG2S}/wrk
SHARE=${AVOG2S}/share

freq=(0.1 0.5)

vfile=${SHARE}/ModMap_Volcs.txt

nfreq=2
nvolc=`wc -l ${vfile} | cut -d' ' -f1`

nfreq=1
nvolc=1

mkdir -p ${WRK}/ModessAutoMaps
cd ${WRK}/ModessAutoMaps

for (( ifq=0;ifq<${nfreq};ifq++ ))
do
  fq=${freq[ifq]}
  for (( iv=1;iv<=${nvolc};iv++ ))
  do
    Volc=`head -n ${iv} ${vfile} | tail -1 | cut -f1 -d':'`
    Srcx=`head -n ${iv} ${vfile} | tail -1 | cut -f2 -d':'`
    Srcy=`head -n ${iv} ${vfile} | tail -1 | cut -f3 -d':'`
    Srcz=`head -n ${iv} ${vfile} | tail -1 | cut -f4 -d':'`
  
    echo "$iv $yyyy $mm $dd ${hh} ${Volc} ${Srcx} ${Srcy} ${Srcz}"
    ${AVOG2S}/bin/webscripts//run_InfraTool_Web.sh AutoRuns_${hh} ${yyyy} ${mm} ${dd} ${hh} ${Srcx} ${Srcy} ${Srcz} 41 50 1 11 850.0 ${fq} ${Volc}
  done
done

cd ${WRK}/ModessAutoMaps

