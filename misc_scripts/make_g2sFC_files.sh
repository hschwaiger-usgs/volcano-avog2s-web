#!/bin/bash

INSTALLDIR="/opt/USGS"
WINDROOT="/data/WindFiles"
WWW="/data/www/vsc-ash.wr.usgs.gov/G2S"

AVOG2S=${INSTALLDIR}/AVOG2S
SHROOT={$WINDROOT}/g2s_SH
RAWROOT={$SHROOT}/RAW_SH

#WRK=/home/ash3d/G2S_today
WRK=${AVOG2S}/wrk

rc=0

echo "make_g2sSH_files.sh:  checking input arguments"
if [ -z $1 ]
then
  echo "Error: Insufficient command-line arguments"
  echo "Usage:  make_g2sSH_files.sh FChour"
  echo "        where FChour = 0, 6, 12, or 18"
  exit 1
else
  FC=$1
fi

if [[ "$FC" -eq 0 ]] ; then
 FChour="00"
 FChourR="0.0"
fi
if [[ "$FC" -eq 6 ]] ; then
 FChour="06"
 FChourR="6.0"
fi
if [[ "$FC" -eq 12 ]] ; then
 FChour="12"
 FChourR="12.0"
fi
if [[ "$FC" -eq 18 ]] ; then
 FChour="18"
 FChourR="18.0"
fi
if [[ "$FC" -eq 24 ]] ; then
 FChour="24"
 FChourR="24.0"
fi
if [[ "$FC" -eq 30 ]] ; then
 FChour="30"
 FChourR="30.0"
fi

YYYY=`date  +%Y`
MM=`date  +%m`
DD=`date  +%d`
YYYYMMDD=${YYYY}${MM}${DD}

cd ${WRK}

HWMPATH=${AVOG2S}/ExternalData/HWM14
export HWMPATH

gen_SC=${AVOG2S}/bin/g2s_genSC_HWM14
gen_Res=${AVOG2S}/bin/g2s_ResampleAtmos

#rm -f nam.t00z*
rm -f Ap.dat F107.dat NGDC

ln -s ${AVOG2S}/ExternalData/Ap_Forecast/NGDC_NOAA_Archive NGDC
ln -s ${AVOG2S}/ExternalData/Ap_Forecast/Ap.dat
ln -s ${AVOG2S}/ExternalData/Ap_Forecast/F107.dat
ln -s ${WINDROOT}/nam/091/${YYYYMMDD}_00/nam.t00z.alaskanest.hiresf${FChour}.tm00.avo.grib2 .
ln -s ${WINDROOT}/nam/091/${YYYYMMDD}_00/nam.t00z.alaskanest.hiresf${FChour}.tm00.avo.grib2.index .

outfile=G2S_FC_${YYYYMMDD}_${FChour}Z_wf13.nc

CTR="tmpFC_${FChour}.ctr"

echo "${YYYY} ${MM} ${DD} ${FChourR}"                     >  ${CTR}
echo "0 1 -150.0 90.0 0.933 6371.229"                     >> ${CTR}
echo "5.950 120 -2172.922 512 -4214.803 340"              >> ${CTR}
echo "20 200 2.5"                                         >> ${CTR}
echo "1"                                                  >> ${CTR}
echo "13 1 91 3"                                          >> ${CTR}
echo "0.0 25.0 1.0"                                       >> ${CTR}
echo "nam.t00z.alaskanest.hiresf${FChour}.tm00.avo.grib2" >> ${CTR}
echo "Ap.dat"                                             >> ${CTR}
echo "F107.dat"                                           >> ${CTR}
echo "${outfile}"                                         >> ${CTR}

# Calculate the coefficient file
${gen_SC} ${CTR}
# copy file to the public website
cp -a ${outfile} ${WWW}/${outfile}
mv ${outfile} ${SHROOT}/${outfile}

