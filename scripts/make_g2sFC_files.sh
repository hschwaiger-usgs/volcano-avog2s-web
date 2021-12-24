#!/bin/bash
##############################################################################
#  Script to generate spectral coefficient files from gfs files
###############################################################################

#      This file is a component of the volcanic infrasound monitoring software
#      written at the U.S. Geological Survey by Hans F. Schwaiger (hschwaiger@usgs.gov)
#      and Alexandra M. Iezzi (amiezzi@alaska.edu).  These programs relies on tools
#      developed for the ash transport and dispersion model Ash3d, written at the
#      U.S. Geological Survey by Hans F. Schwaiger (hschwaiger@usgs.gov), Larry G.
#      Mastin (lgmastin@usgs.gov), and Roger P. Denlinger (roger@usgs.gov).

#      The model and its source code are products of the U.S. Federal Government and therefore
#      bear no copyright.  They may be copied, redistributed and freely incorporated 
#      into derivative products.  However as a matter of scientific courtesy we ask that
#      you credit the authors and cite published documentation of this model (below) when
#      publishing or distributing derivative products.
#
#      Schwaiger, H.F., Alexandra M. Iezzi and David Fee;
#         AVO-G2S:  A modified, open-source Ground-to-Space atmospheric specifications
#           for infrasound model; Computers and Geosciences, v125, p90-97, 2019,
#           doi:10.1016/j.cageo.2018.12.013
#
#      We make no guarantees, expressed or implied, as to the usefulness of the software
#      and its documentation for any purpose.  We assume no responsibility to provide
#      technical support to users of this software.
#
###############################################################################

# Shell script that generates FC files from nam 091 3km data files for the date/time
# supplied on the command line.
# This script is called from autorun_avog2s_FC.sh and takes three command-line arguments
#   make_g2sFC_files.sh YYYYMMDD HH FCpack

INSTALLDIR="/opt/USGS"
WINDROOT="/data/WindFiles"
WWW="/data/www/vsc-ash.wr.usgs.gov/G2S"

AVOG2S=${INSTALLDIR}/AVOG2S
SHROOT={$WINDROOT}/g2s_SH
RAWROOT={$SHROOT}/RAW_SH

#WRK=/home/ash3d/G2S_today
WRK=${AVOG2S}/wrk

rc=0

echo "make_g2sFC_files.sh:  checking input arguments"
if [ $# -ne 5 ]
then
  echo "Error: Incorrect number of command-line arguments"
  echo "Usage:  make_g2sFC_files.sh YYYY MM DD HH FCpack"
  echo "        where YYYY = year"
  echo "                MM = month"
  echo "                DD = day of month"
  echo "                HH = forecast hour from start of FC package (2 digit integer)"
  echo "            FCpack = forecast package (00,06,12,18)"
  exit 1
else
  YYYY=$1
  MM=$2
  DD=$3
  HH=$4
  FC=$5

  YYYYMMDD=${YYYY}${MM}${DD}
  HHr=${HH}".0"
fi

#if [[ "$FC" -eq 0 ]] ; then
# FChour="00"
# FChourR="0.0"
#fi
#if [[ "$FC" -eq 6 ]] ; then
# FChour="06"
# FChourR="6.0"
#fi
#if [[ "$FC" -eq 12 ]] ; then
# FChour="12"
# FChourR="12.0"
#fi
#if [[ "$FC" -eq 18 ]] ; then
# FChour="18"
# FChourR="18.0"
#fi
#if [[ "$FC" -eq 24 ]] ; then
# FChour="24"
# FChourR="24.0"
#fi
#if [[ "$FC" -eq 30 ]] ; then
# FChour="30"
# FChourR="30.0"
#fi

#YYYY=`date  +%Y`
#MM=`date  +%m`
#DD=`date  +%d`
#YYYYMMDD=${YYYY}${MM}${DD}

cd ${WRK}

HWMPATH=${AVOG2S}/ExternalData/HWM14
export HWMPATH

gen_SC=${AVOG2S}/bin/g2s_genSC_HWM14
gen_Res=${AVOG2S}/bin/g2s_ResampleAtmos

rm -f Ap.dat F107.dat NGDC

ln -s ${AVOG2S}/ExternalData/Ap_Forecast/NGDC_NOAA_Archive NGDC
ln -s ${AVOG2S}/ExternalData/Ap_Forecast/Ap.dat
ln -s ${AVOG2S}/ExternalData/Ap_Forecast/F107.dat
ln -s ${WINDROOT}/nam/091/${YYYYMMDD}_00/nam.t00z.alaskanest.hiresf${FChour}.tm00.avo.grib2 .
ln -s ${WINDROOT}/nam/091/${YYYYMMDD}_00/nam.t00z.alaskanest.hiresf${FChour}.tm00.avo.grib2.index .

outfile=G2S_FC_${YYYYMMDD}_${HH}Z_wf13.nc

CTR="tmpFC_${FChour}.ctr"

echo "${YYYY} ${MM} ${DD} ${HHr}"                          >  ${CTR}
echo "0 1 -150.0 90.0 0.933 6371.229"                     >> ${CTR}
echo "5.950 120 -2172.922 512 -4214.803 340"              >> ${CTR}
echo "20 200 2.5"                                         >> ${CTR}
echo "1"                                                  >> ${CTR}
echo "13 1 91 3"                                          >> ${CTR}
echo "0.0 25.0 1.0"                                       >> ${CTR}
echo "nam.t00z.alaskanest.hiresf${HH}.tm${FC}.avo.grib2"  >> ${CTR}
echo "Ap.dat"                                             >> ${CTR}
echo "F107.dat"                                           >> ${CTR}
echo "${outfile}"                                         >> ${CTR}

# Calculate the coefficient file
${gen_SC} ${CTR}
# copy file to the public website
cp -a ${outfile} ${WWW}/${outfile}
mv ${outfile} ${SHROOT}/${outfile}

