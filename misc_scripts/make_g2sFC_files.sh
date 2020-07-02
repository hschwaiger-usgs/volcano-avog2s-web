#!/bin/bash

FC=$1

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

YYYY=`date  +%Y`
MM=`date  +%m`
DD=`date  +%d`
YYYYMMDD=${YYYY}${MM}${DD}

cd /home/ash3d/G2S_today

HWMPATH=/opt/USGS/AVOG2S/ExternalData/HWM14
export HWMPATH

gen_SC=/opt/USGS/AVOG2S/bin/g2s_genSC_HWM14
gen_Res=/opt/USGS/AVOG2S/bin/g2s_ResampleAtmos

rm -f nam.t00z*
rm -f Ap.dat F107.dat NGDC

ln -s /opt/USGS/AVOG2S/ExternalData/Ap_Forecast/NGDC_NOAA_Archive NGDC
ln -s /opt/USGS/AVOG2S/ExternalData/Ap_Forecast/Ap.dat
ln -s /opt/USGS/AVOG2S/ExternalData/Ap_Forecast/F107.dat
ln -s /data/WindFiles/nam/ak03km/${YYYYMMDD}_00/nam.t00z.alaskanest.hiresf${FChour}.tm00.avo.grib2 .
ln -s /data/WindFiles/nam/ak03km/${YYYYMMDD}_00/nam.t00z.alaskanest.hiresf${FChour}.tm00.avo.grib2.index .

outfile=G2S_FC_${YYYYMMDD}_${FChour}Z_wf13.nc

echo "${YYYY} ${MM} ${DD} ${FChourR}"                     >  tmp.ctr
echo "0 1 -150.0 90.0 0.933 6371.229"                     >> tmp.ctr
echo "5.950 120 -2172.922 512 -4214.803 340"              >> tmp.ctr
echo "20 200 2.5"                                         >> tmp.ctr
echo "1"                                                  >> tmp.ctr
echo "13 1 91 3"                                          >> tmp.ctr
echo "0.0 25.0 1.0"                                       >> tmp.ctr
echo "nam.t00z.alaskanest.hiresf${FChour}.tm00.avo.grib2" >> tmp.ctr
echo "Ap.dat"                                             >> tmp.ctr
echo "F107.dat"                                           >> tmp.ctr
echo "${outfile}"                                         >> tmp.ctr

${gen_SC} tmp.ctr

cp -a ${outfile} /webdata/int-vsc-ash.wr.usgs.gov/htdocs/G2S/
mv ${outfile} /data/WindFiles/nam/ak03km/${YYYYMMDD}_00/

/usr/bin/rsync -rlptDxS --ignore-errors --force /webdata/int-vsc-ash.wr.usgs.gov/htdocs/G2S/ ash3d@int-ash3d:/webdata/int-vsc-ash.wr.usgs.gov/htdocs/G2S/
#/usr/bin/rsync -az --delete /webdata/int-vsc-ash.wr.usgs.gov/htdocs/G2S/ ash3d@int-ash3d:/webdata/int-vsc-ash.wr.usgs.gov/htdocs/G2S/

