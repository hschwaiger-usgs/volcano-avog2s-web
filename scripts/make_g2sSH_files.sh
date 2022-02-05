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

# Shell script that generates SH files from gfs 0.5 degree data files for the date/time
# supplied on the command line.
# This script is called from autorun_avog2s_SH.sh and takes five command-line arguments
#   make_g2sSH_files.sh YYYY MM DD HH FCpack

INSTALLDIR="/opt/USGS"
WINDROOT="/data/WindFiles"
WWW="/data/www/vsc-ash.wr.usgs.gov/G2S"

AVOG2S=${INSTALLDIR}/AVOG2S
SHROOT={$WINDROOT}/AVOG2S
RAWROOT={$SHROOT}/RAW_SH

WRK=${AVOG2S}/wrk

rc=0

echo "make_g2sSH_files.sh:  checking input arguments"
if [ $# -ne 5 ]
then
  echo "Error: Incorrect number of command-line arguments"
  echo "Usage:  make_g2sSH_files.sh YYYY MM DD HH FCpack"
  echo "        where YYYY = year"
  echo "                MM = month"
  echo "                DD = day of month"
  echo "                HH = forecast hour (2-digit int) from start of FC package"
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

LOCWRK=${WRK}/${YYYMMDD}_${HH}
mkdir -p $(LOCWRK}
cd ${LOCWRK}

HWMPATH=${AVOG2S}/ExternalData/HWM14
export HWMPATH

gen_SC=${AVOG2S}/bin/g2s_genSC_HWM14
gen_Res=${AVOG2S}/bin/g2s_ResampleAtmos

rm -f Ap.dat F107.dat NGDC

ln -s ${AVOG2S}/ExternalData/Ap_Forecast/NGDC_NOAA_Archive   ${LOCWRK}/NGDC
ln -s ${AVOG2S}/ExternalData/Ap_Forecast/Ap.dat              ${LOCWRK}/Ap.dat
ln -s ${AVOG2S}/ExternalData/Ap_Forecast/F107.dat            ${LOCWRK}/F107.dat
ln -s ${WINDROOT}/gfs/gfs.${YYYYMMDD}${FC}/gfs.t${FC}z.pgrb2.0p50.f0${HH}   ${LOCWRK}/${YYYYMMDD}${FC}.f0${HH}.grib2

outroot=G2S_SH_${YYYYMMDD}_${HH}Z_wf20
outnc=${outroot}.nc

CTR="tmpSH_${HH}.ctr"

echo "${YYYY} ${MM} ${DD} ${HHr}"                          > ${CTR}
echo "1 4 -107.0 50.0 50.0 50.0 6367.470"                 >> ${CTR}
echo "0.5 120 "                                           >> ${CTR}
echo "55 200 2.5"                                         >> ${CTR}
echo "1"                                                  >> ${CTR}
echo "20 1 4 3"                                           >> ${CTR}
echo "0.0 60.0 1.0"                                       >> ${CTR}
echo "${YYYYMMDD}${FC}.f0${HH}.grib2"                     >> ${CTR}
echo "Ap.dat"                                             >> ${CTR}
echo "F107.dat"                                           >> ${CTR}
echo "${outnc}"                                           >> ${CTR}

# Calculate the coefficient file; gennerating $outnc}
${gen_SC} ${CTR}

# Now generate the reconstituted *.raw files
${gen_Res} ${outnc}
mv ${outroot}_T_res.raw ${RAWROOT}/${outroot}_T_res.raw
mv ${outroot}_U_res.raw ${RAWROOT}/${outroot}_U_res.raw
mv ${outroot}_V_res.raw ${RAWROOT}/${outroot}_V_res.raw

# copy file to the public website and archive location
cp -a ${outnc} ${WWW}/${outnc}
mv ${outnc} ${SHROOT}/${outnc}

#clean up the working directory
rm ${LOCWRK}/NGDC
rm ${LOCWRK}/Ap.dat
rm ${LOCWRK}/F107.dat
rm ${LOCWRK}/${YYYYMMDD}${FC}.f0${HH}.grib2
rm ${LOCWRK}/tmpSH_${HH}.ctr


