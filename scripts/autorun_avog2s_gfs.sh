#!/bin/bash
##############################################################################
#  Script to initial the creation of spectral coefficient (gfs) files for today
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
# This script is called from autorun_avog2s_SH.sh and takes two command-line arguments
#   autorun_avog2s_gfs.sh 0p25 0 for the 0.25 degree 00 forecast package

INSTALLDIR="/opt/USGS"
AVOG2S=${INSTALLDIR}/AVOG2S
SCRIPTDIR=${AVOG2S}/bin/scripts

echo "autorun_avog2s_gfs.sh:  checking input arguments"
if [ $# -ne 2 ]
  then
  echo "Error: Incorrect number of command-line arguments"
  echo "Usage: autorun_gfs.sh Resolution FCpackage"
  echo "       where Resolution = 1p00, 0p50, or 0p25"
  echo "             FCpackage  = 0, 6, 12, 18 or 24"
  exit
fi

GFS=$1
FC=$2

case ${GFS} in
 0p25)
  echo "GFS 0.25 degree"
  ;;
 0p50)
  echo "GFS 0.50 degree"
  ;;
 1p00)
  echo "GFS 1.00 degree"
  ;;
 *)
  echo "GFS product not recognized"
  echo "Valid values: 0p25, 0p50, 1p00"
  exit
esac

case ${FC} in
 0)
  FChour="00"
  FChourR="0.0"
  ;;
 6)
  FChour="06"
  FChourR="6.0"
  ;;
 12)
  FChour="12"
  FChourR="12.0"
  ;;
 18)
  FChour="18"
  FChourR="18.0"
  ;;
 24)
  FChour="24"
  FChourR="24.0"
  ;;
 *)
  echo "GFS forecast package not recognized"
  echo "Valid values: 0, 6, 12, 18, 24"
  exit
esac

#yearmonthday=`date -u +%Y%m%d`
YYYY=`date -u +%Y`
MM=`date -u +%m`
DD=`date -u +%d`
# Here you can over-ride the date if need be
#yearmonthday="20200610"

echo "------------------------------------------------------------"
echo "running autorun_avog2s_gfs ${GFS} ${FChour} script"
echo "------------------------------------------------------------"

#script that actually builds the g2s file
#  For 00
echo "  Calling ${SCRIPTDIR}/make_g2sSH_files.sh ${YYYY} ${MM} ${DD} 00 ${FChour}"
${SCRIPTDIR}/make_g2sSH_files.sh ${YYYY} ${MM} ${DD} 00 ${FChour}

#  For 06
echo "  Calling ${SCRIPTDIR}/make_g2sSH_files.sh ${YYYY} ${MM} ${DD} 06 ${FChour}"
${SCRIPTDIR}/make_g2sSH_files.sh ${YYYY} ${MM} ${DD} 06 ${FChour}

#  For 00
echo "  Calling ${SCRIPTDIR}/make_g2sSH_files.sh ${YYYY} ${MM} ${DD} 12 ${FChour}"
${SCRIPTDIR}/make_g2sSH_files.sh ${YYYY} ${MM} ${DD} 12 ${FChour}

#  For 00
echo "  Calling ${SCRIPTDIR}/make_g2sSH_files.sh ${YYYY} ${MM} ${DD} 18 ${FChour}"
${SCRIPTDIR}/make_g2sSH_files.sh ${YYYY} ${MM} ${DD} 18 ${FChour}

#  For 24
echo "  Calling ${SCRIPTDIR}/make_g2sSH_files.sh ${YYYY} ${MM} ${DD} 24 ${FChour}"
${SCRIPTDIR}/make_g2sSH_files.sh ${YYYY} ${MM} ${DD} 24 ${FChour}

