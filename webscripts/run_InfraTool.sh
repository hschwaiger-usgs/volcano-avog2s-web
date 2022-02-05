#!/bin/bash
################################################################################
#
#      This file is a component of the volcanic infrasound monitoring software
#      written at the U.S. Geological Survey by Hans F. Schwaiger (hschwaiger@usgs.gov)
#      and Alexandra M. Iezzi (amiezzi@alaska.edu).  These programs relies on tools
#      developed for the ash transport and dispersion model Ash3d, written at the
#      U.S. Geological Survey by Hans F. Schwaiger (hschwaiger@usgs.gov), Larry G.
#      Mastin (lgmastin@usgs.gov), and Roger P. Denlinger (roger@usgs.gov).
#
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
#
#  run_InfraTool.sh
#
#  This script is a command-line tool that provides a unified interface to several
#  infrasound forward modeling software packages.  There are 15 required command-
#  line arguments, though not all arguments are actually used depending on the
#  forward model selected.  The arguments are:
#   1) name of run directory    (no white spaces).  Ideally, this is unique.
#   2) 4-char year of event     (YYYY)
#   3) 2-char month of event    (MM)
#   4) 2-char day of event      (DD)
#   5) 2-char hour of event     (HH one of 00,06,12,18,24)
#   6) longitude of source      (real valued in range 0.0-360.0)
#   7) latitude of source       (real valued in range -90.0-90.0)
#   8) altitude of source       (real valued in km)
#   9) azimuth of start profile (real valued in range 0.0-360.0)
#  10) azimuth of end profile   (real valued in range 0.0-360.0)
#  11) azimuth increment        (real valued in degrees)
#  12) model ID                 (integer)
#         ID = 1 : Art2d              (profile)
#         ID = 2 : infraga-sph        (profile)
#         ID = 3 : infraga-sph-rngdep (profile)
#         ID = 4 : infraga-sph-rngdep (sweep)
#         ID = 5 : Modess (strat.)    (profile)
#         ID = 6 : CModess (strat.)   (profile)
#         ID = 7 : WMod (strat.)      (profile)
#         ID = 8 : ModBB              (profile)
#         ID = 9 : ModessRD1WCM       (profile)
#         ID =10 : pape               (profile)
#         ID =11 : Modess             (sweep)
#  13) range of profile       (real valued (km) in range 0.0-1000.0)
#  14) frequency of source    (real valued in Hz, 0.1-1.0)
#  15) name of source/volcano (no white spaces)
#
#  This script will build the control file to extract the vertical profile
#  or the 2d transect with the assumption that the reconstructed AVO-G2S
#  atmospheric model files are in ${DATA}/RAW_SH/. These may only be available
#  for the past few days depending on your purge settings.
#  The specified forward model is then called, followed by the appropriate plot
#  script (plot_tloss2d.m or plot_Nby2D_tloss.py). The output figure is temp.png
#
#  The following example runs the Modess sweep tool (ID=11) for Cleveland volcano
#  with 1-degree increments at a frequency of 0.1 Hz and with a range of 850 km
#
# run_InfraTool.sh tmpClev 2021 12 03 00 190.055 52.8222 1.7 41 50 1 11 850.0 0.1 Cleveland
#
###############################################################################

AVOG2Suser=ash3d

AVOG2S=/opt/USGS/AVOG2S
WRK=${AVOG2S}/wrk
ART2DDIR=/home/${AVOG2Suser}/Programs/Other/ART2D
GEOACDIR=/home/${AVOG2Suser}/Programs/GIT/infraGA/bin
NCPADIR=/home/${AVOG2Suser}/Programs/GIT/ncpaprop/bin
PYDIR=/home/${AVOG2Suser}/anaconda3/bin
TOPO=/opt/USGS/data/Topo/etopo.nc
DATA=/data/WindFiles/AVOG2S

rc=0
echo "---------------------------------------------------------------"
echo "  run_InfraTool.sh"
echo "   Standardized interface to Art2d, infraGA, and ncpaprop tools."
echo "---------------------------------------------------------------"

echo "checking input arguments"
if [ -z ${1} ]
then
  echo "Error: No command-line areguments detected."
  echo "Usage: run_InfraTool.sh work_dir YYYY MM DD HH Srcx Srcy Srcz Az1 Az2 delAz ModelID Range Freq Volc"
  echo "  run_InfraTool.sh tmpClev 2021 12 03 00 190.055 52.8222 1.7 41 50 1 11 850.0 0.1 Cleveland"
  exit 1
fi
if [ -z $2 ]
then
  echo "Error: You must specify a year (YYYY)"
  exit 1
fi
if [ -z $3 ]
then
  echo "Error: You must specify a month (MM)"
  exit 1
fi
if [ -z $4 ]
then
  echo "Error: You must specify a day (DD)"
  exit 1
fi
if [ -z $5 ]
then
  echo "Error: You must specify an hour (HH=00,06,12,18,24)"
  exit 1
fi
if [ -z $6 ]
then
  echo "Error: You must specify a source longitude (degrees 0->360)"
  exit 1
fi
if [ -z $7 ]
then
  echo "Error: You must specify a source latitude (degrees -80->80)"
  exit 1
fi
if [ -z $8 ]
then
  echo "Error: You must specify a source height (km)"
  exit 1
fi
if [ -z $9 ]
then
  echo "Error: You must specify an azimuth1 (0->360)"
  exit 1
fi
if [ -z ${10} ]
then
  echo "Error: You must specify an azimuth2 (0-360)"
  exit 1
fi
if [ -z ${11} ]
then
  echo "Error: You must specify an azimuth increment (degrees)"
  exit 1
fi
if [ -z ${12} ]
then
  echo "Error: You must specify a model ID"
  exit 1
fi
if [ -z ${13} ]
then
  echo "Error: You must specify a range (km 0->1000)"
  exit 1
fi
if [ -z ${14} ]
then
  echo "Error: You must specify a frequency (Hz 0.1->1.0)"
  exit 1
fi
if [ -z ${15} ]
then
  echo "Error: You must specify a volcano name (no spaces)"
  exit 1
fi

TMPDIR=${1}     # No spaces
YYYY=$2         # Date should be: today-3 days < date < today
MM=$3           #
DD=$4           #
HH=$5           # 00,06,12,18,24
SRCX=$6         # longitude should be in range 0 -> 360
SRCY=$7         # latitude (-80 -> 80)
SRCZ=$8         # in km (0<= z < 50)
AZ1=$9          # degrees (0 < az1 < 360)
AZ2=${10}          # degrees (0 < az2 < 360)
DAZ=${11}       # degrees (0 < daz < 180)
MODELID=${12}   # 1-11 (1,3,4,8 not implemented)
RNG=${13}       # km (0 < rng < 1000)
FREQ=${14}      # Hz (0.1 < freq < 2.0)
SRCNAME=${15}   # No spaces

echo "Command-line arguments successfully read"
echo "   working directory = ${TMPDIR}"
echo "   YYYY              = ${YYYY}"
echo "   MM                = ${MM}"
echo "   DD                = ${DD}"
echo "   HH                = ${HH}"
echo "   Source long       = ${SRCX}"
echo "   Source lat.       = ${SRCY}"
echo "   Source alt.       = ${SRCZ}"
echo "   Start Azim.       = ${AZ1}"
echo "   End Azim.         = ${AZ2}"
echo "   Azim. step        = ${DAZ}"
echo "   Model ID          = ${MODELID}"
echo "   Range             = ${RNG}"
echo "   Freq.             = ${FREQ}"
echo "   Source name       = ${SRCNAME}"

echo "---------------------------------------------------------------"
echo " Creating work directory ${WRK}/${TMPDIR}"
echo "---------------------------------------------------------------"

mkdir -p ${WRK}/${TMPDIR}
cd ${WRK}/${TMPDIR}

if [[ "$MODELID" -eq 1 ]]  ; then    ## Model  1:  Art2d              (profile)
  echo "Model 1 selected (Art2d): 2d transect along $AZ1"
  DIM=2
  EXEC=${ART2DDIR}/art2d
fi
if [[ "$MODELID" -eq 2 ]]  ; then    ## Model  2:  infraga-sph        (profile)
  echo "Model 2 selected (infraga-sph): 1d stratified transect along $AZ1"
  DIM=1
  EXEC=${GEOACDIR}/infraga-sph
fi
if [[ "$MODELID" -eq 3 ]]  ; then    ## Model  3:  infraga-sph-rngdep (profile)
  echo "Model 3 selected (infraga-sph-rngdep): 2d profile transect along $AZ1"
  DIM=3
  EXEC=${GEOACDIR}/infraga-sph-rngdep
fi
if [[ "$MODELID" -eq 4 ]]  ; then    ## Model  4:  infraga-sph-rngdep (sweep)
  echo "Model 4 selected (infraga-sph-rngdep sweep): 2d profile transects along $AZ1 to $AZ2 with a step of $DAZ"
  DIM=3
  EXEC=${GEOACDIR}/infraga-sph-rngdep
fi
if [[ "$MODELID" -eq 5 ]]  ; then    ## Model  5:  Modess (strat.)    (profile)
  echo "Model 5 selected (Modess): 1d stratified transect along $AZ1"
  DIM=1
  EXEC=${NCPADIR}/Modess
fi
if [[ "$MODELID" -eq 6 ]]  ; then    ## Model  6:  CModess (stra.)    (profile)
  echo "Model 6 selected (CModess): 1d stratified transect along $AZ1"
  DIM=1
  EXEC=${NCPADIR}/CModess
fi
if [[ "$MODELID" -eq 7 ]]  ; then    ## Model  7:  WMod (stra.)       (profile)
  echo "Model 7 selected (WMod): 1d stratified transect along $AZ1"
  DIM=1
  EXEC=${NCPADIR}/WMod
fi
if [[ "$MODELID" -eq 8 ]]  ; then    ## Model  8:  ModBB              (profile)
  echo "Model 8 selected (ModDD): 1d stratified transect along $AZ1"
  DIM=1
  EXEC=${NCPADIR}/ModBB
fi
if [[ "$MODELID" -eq 9 ]]  ; then    ## Model  9:  ModessRD1WCM       (profile)
  echo "Model 9 selected (ModessRD1WCM): 2d transect along $AZ1"
  DIM=2
  EXEC=${NCPADIR}/ModessRD1WCM
fi
if [[ "$MODELID" -eq 10 ]] ; then    ## Model 10:  pape               (profile)
  echo "Model 10 selected (pape): 2d transect along $AZ1"
  DIM=2
  EXEC=${NCPADIR}/pape
fi
if [[ "$MODELID" -eq 11 ]] ; then    ## Model 11:  Modess             (sweep)
  echo "Model 11 selected (Modess sweep): 2d profile transects along $AZ1 to $AZ2 with a step of $DAZ"
  DIM=1
  EXEC=${NCPADIR}/Modess
  PATH=$PYDIR:$PATH
fi

yyyy=`date --utc -d "00:00 ${MM}/${DD}/${YYYY} + ${HH} hours" +"%Y"`
mm=`  date --utc -d "00:00 ${MM}/${DD}/${YYYY} + ${HH} hours" +"%m"`
dd=`  date --utc -d "00:00 ${MM}/${DD}/${YYYY} + ${HH} hours" +"%d"`
hh=`  date --utc -d "00:00 ${MM}/${DD}/${YYYY} + ${HH} hours" +"%H"`
# We might need to adjust srcx since it is expected to be in range 0->360
st=`echo "$SRCX < 0.0" | bc`
if [ $st -eq 1 ]; then
  SRCX=`echo "$SRCX + 360.0" | bc`
fi

st=`echo "$SRCX > 180.0" | bc`
if [ $st -eq 1 ]; then
  SRCXMAP=`echo "$SRCX - 360.0" | bc`
else
  SRCXMAP=$SRCX
fi
LONPMIN=`echo "x = ${SRCXMAP}-10; scale = 0; x / 1" | bc -l`
LATPMIN=`echo "x = ${SRCY}-8; scale = 0; x / 1" | bc -l`

echo "${yyyy}"    > ${WRK}/${TMPDIR}/yyyy.dat
echo "${mm}"      > ${WRK}/${TMPDIR}/mm.dat
echo "${dd}"      > ${WRK}/${TMPDIR}/dd.dat
echo "${hh}"      > ${WRK}/${TMPDIR}/hh.dat
echo "${SRCX}"    > ${WRK}/${TMPDIR}/srcx.dat
echo "${SRCXMAP}" > ${WRK}/${TMPDIR}/srcxmap.dat
echo "${SRCY}"    > ${WRK}/${TMPDIR}/srcy.dat
echo "${SRCZ}"    > ${WRK}/${TMPDIR}/srcz.dat
echo "${AZ1}"     > ${WRK}/${TMPDIR}/az1.dat
echo "${AZ2}"     > ${WRK}/${TMPDIR}/az2.dat
echo "${DAZ}"     > ${WRK}/${TMPDIR}/daz.dat
echo "${MODELID}" > ${WRK}/${TMPDIR}/modelid.dat
echo "${RNG}"     > ${WRK}/${TMPDIR}/rng.dat
echo "${FREQ}"    > ${WRK}/${TMPDIR}/freq.dat
echo "${SRCNAME}" > ${WRK}/${TMPDIR}/srcname.dat
echo "${LONPMIN}" > ${WRK}/${TMPDIR}/lonpmin.dat
echo "${LATPMIN}" > ${WRK}/${TMPDIR}/latpmin.dat

echo "---------------------------------------------------------------"
echo " Linking avo-g2s data files"
ln -s ${DATA}/RAW_SH/G2S_SH_${YYYY}${MM}${DD}_${HH}Z_wf20_U_res.raw ${WRK}/${TMPDIR}/G2S_SH_${YYYY}${MM}${DD}_${HH}Z_wf20_U_res.raw
ln -s ${DATA}/RAW_SH/G2S_SH_${YYYY}${MM}${DD}_${HH}Z_wf20_V_res.raw ${WRK}/${TMPDIR}/G2S_SH_${YYYY}${MM}${DD}_${HH}Z_wf20_V_res.raw
ln -s ${DATA}/RAW_SH/G2S_SH_${YYYY}${MM}${DD}_${HH}Z_wf20_T_res.raw ${WRK}/${TMPDIR}/G2S_SH_${YYYY}${MM}${DD}_${HH}Z_wf20_T_res.raw
echo " Generating atmospheric files"

if [[ "$DIM" -eq 1 ]] ; then
  echo "${SRCX} ${SRCY}"                                  > ${WRK}/${TMPDIR}/temp.ctr
  echo "180.0 0.2"                                       >> ${WRK}/${TMPDIR}/temp.ctr
  echo "1"                                               >> ${WRK}/${TMPDIR}/temp.ctr
  echo "720 0.5 0.0"                                     >> ${WRK}/${TMPDIR}/temp.ctr
  echo "361 0.5 -90.0"                                   >> ${WRK}/${TMPDIR}/temp.ctr
  echo "26 1.0"                                          >> ${WRK}/${TMPDIR}/temp.ctr
  echo "50 1.5"                                          >> ${WRK}/${TMPDIR}/temp.ctr
  echo "50 2.0"                                          >> ${WRK}/${TMPDIR}/temp.ctr
  echo "G2S_SH_${YYYY}${MM}${DD}_${HH}Z_wf20_U_res.raw"  >> ${WRK}/${TMPDIR}/temp.ctr
  echo "G2S_SH_${YYYY}${MM}${DD}_${HH}Z_wf20_V_res.raw"  >> ${WRK}/${TMPDIR}/temp.ctr
  echo "G2S_SH_${YYYY}${MM}${DD}_${HH}Z_wf20_T_res.raw"  >> ${WRK}/${TMPDIR}/temp.ctr
  echo "Volc"                                            >> ${WRK}/${TMPDIR}/temp.ctr
  ${AVOG2S}/bin/g2s_Extract_Sonde temp.ctr
  echo "#% 1, Z, KM"       > Volc0.tmp
  echo "#% 2, T, DEGK"    >> Volc0.tmp
  echo "#% 3, U, MPS"     >> Volc0.tmp
  echo "#% 4, V, MPS"     >> Volc0.tmp
  echo "#% 5, RHO, GPCM3" >> Volc0.tmp
  echo "#% 6, P, MBAR"    >> Volc0.tmp
  cat Volc0.tmp Volc0.met  > Volc0.dat

fi
if [[ "$DIM" -eq 2 ]] ; then
  ln -s ${TOPO} etopo.nc
  echo "${SRCX} ${SRCY}"                                  > ${WRK}/${TMPDIR}/temp.ctr
  echo "180.0 0.2"                                       >> ${WRK}/${TMPDIR}/temp.ctr
  echo "1"                                               >> ${WRK}/${TMPDIR}/temp.ctr
  echo "${AZ1} 47.69 0.01"                               >> ${WRK}/${TMPDIR}/temp.ctr
  echo "720 0.5 0.0"                                     >> ${WRK}/${TMPDIR}/temp.ctr
  echo "361 0.5 -90.0"                                   >> ${WRK}/${TMPDIR}/temp.ctr
  echo "26 1.0"                                          >> ${WRK}/${TMPDIR}/temp.ctr
  echo "50 1.5"                                          >> ${WRK}/${TMPDIR}/temp.ctr
  echo "50 2.0"                                          >> ${WRK}/${TMPDIR}/temp.ctr
  echo "G2S_SH_${YYYY}${MM}${DD}_${HH}Z_wf20_U_res.raw"  >> ${WRK}/${TMPDIR}/temp.ctr
  echo "G2S_SH_${YYYY}${MM}${DD}_${HH}Z_wf20_V_res.raw"  >> ${WRK}/${TMPDIR}/temp.ctr
  echo "G2S_SH_${YYYY}${MM}${DD}_${HH}Z_wf20_T_res.raw"  >> ${WRK}/${TMPDIR}/temp.ctr
  echo "Volc"                                            >> ${WRK}/${TMPDIR}/temp.ctr
  echo "ProfLonLat"                                      >> ${WRK}/${TMPDIR}/temp.ctr
  echo "etopo.nc"                                        >> ${WRK}/${TMPDIR}/temp.ctr
  ${AVOG2S}/bin/g2s_Extract_Xsec temp.ctr
fi
if [[ "$DIM" -eq 3 ]] ; then
  echo "50.0 60.0 5"                                      > ${WRK}/${TMPDIR}/temp.ctr
  echo "185.0 205.0 9"                                   >> ${WRK}/${TMPDIR}/temp.ctr
  echo "180.0 0.2"                                       >> ${WRK}/${TMPDIR}/temp.ctr
  echo "1"                                               >> ${WRK}/${TMPDIR}/temp.ctr
  echo "720 0.5 0.0"                                     >> ${WRK}/${TMPDIR}/temp.ctr
  echo "361 0.5 -90.0"                                   >> ${WRK}/${TMPDIR}/temp.ctr
  echo "26 1.0"                                          >> ${WRK}/${TMPDIR}/temp.ctr
  echo "50 1.5"                                          >> ${WRK}/${TMPDIR}/temp.ctr
  echo "50 2.0"                                          >> ${WRK}/${TMPDIR}/temp.ctr
  echo "G2S_SH_${YYYY}${MM}${DD}_${HH}Z_wf20_U_res.raw"  >> ${WRK}/${TMPDIR}/temp.ctr
  echo "G2S_SH_${YYYY}${MM}${DD}_${HH}Z_wf20_V_res.raw"  >> ${WRK}/${TMPDIR}/temp.ctr
  echo "G2S_SH_${YYYY}${MM}${DD}_${HH}Z_wf20_T_res.raw"  >> ${WRK}/${TMPDIR}/temp.ctr
  echo "Volc"                                            >> ${WRK}/${TMPDIR}/temp.ctr
  ${AVOG2S}/bin/g2s_Extract_Grid temp.ctr
fi
echo "---------------------------------------------------------------"
echo "Now running the forward model"

####################################################################################
##  ART2D software (no public source found, legacy code)
if [[ "$MODELID" -eq 1 ]]  ; then    ## Model  1:  Art2d              (profile)
  echo " Art2d not implemented"
  exit
fi
####################################################################################
##  infraGA software (https://github.com/LANL-Seismoacoustics/infraGA)
if [[ "$MODELID" -eq 2 ]]  ; then    ## Model  2:  infraga-sph        (profile)                                       -180->180
  echo "CALLING:   ${EXEC} -prop Volc0.met theta_min=-30.0 theta_max=55.0 theta_step=1.0 azimuth=${AZ1} bounces=10 lat_src=${SRCY} lon_src=${SRCX} z_src=${SRCZ} CalcAmp=False WriteAtmo=True"
  INCLMIN=1.0
  INCLMAX=55.0
  INCLSTEP=1.0
  NBOUNCES=10
  echo ${INCLMIN}  > inclmin.dat
  echo ${INCLMAX}  > inclmax.dat
  echo ${INCLSTEP} > inclstep.dat
  echo "CALLING:   ${EXEC} -prop Volc0.met incl_min=${INCLMIN} incl_max=${INCLMAX} incl_step=${INCLSTEP} azimuth=${AZ1} bounces=${NBOUNCES} src_lat=${SRCY} src_lon=${SRCX} src_alt=${SRCZ} write_atmo=True"
  ${EXEC} -prop Volc0.met incl_min=${INCLMIN} incl_max=${INCLMAX} incl_step=${INCLSTEP} azimuth=${AZ1} bounces=${NBOUNCES} src_lat=${SRCY} src_lon=${SRCX} src_alt=${SRCZ} write_atmo=True
fi
if [[ "$MODELID" -eq 3 ]]  ; then    ## Model  3:  infraga-sph-rngdep (profile)
  echo "CALLING:   ${EXEC} -prop Volc Volc.loclat Volc.loclon theta_min=0.0 theta_max=55.0 theta_step=1.0 azimuth=${AZ1} bounces=10 lat_src=${SRCY} lon_src=${SRCX} z_src=${SRCZ} CalcAmp=False WriteAtmo=True"
  ${EXEC} -prop Volc Volc.loclat Volc.loclon theta_min=0.0 theta_max=55.0 theta_step=1.0 azimuth=${AZ1} bounces=10 lat_src=${SRCY} lon_src=${SRCX} z_src=${SRCZ} CalcAmp=False WriteAtmo=True
fi
if [[ "$MODELID" -eq 4 ]]  ; then    ## Model  4:  infraga-sph-rngdep (sweep)
  echo "CALLING:  ${EXEC} -prop Volc Volc.loclat Volc.loclon theta_min=-30.0 theta_max=55.0 theta_step=1.0 phi_min=${AZ1} phi_max=${AZ2} phi_step=${DAZ} bounces=10 lat_src=${SRCY} lon_src=${SRCX} z_src=${SRCZ} CalcAmp=False WriteAtmo=True"
  ${EXEC} -prop Volc Volc.loclat Volc.loclon theta_min=-30.0 theta_max=55.0 theta_step=1.0 phi_min=${AZ1} phi_max=${AZ2} phi_step=${DAZ} bounces=10 lat_src=${SRCY} lon_src=${SRCX} z_src=${SRCZ} CalcAmp=False WriteAtmo=True
fi
####################################################################################
##  ncpaprop software (old version at https://github.com/chetzer-ncpa/ncpaprop)
##                    (new version at https://github.com/chetzer-ncpa/ncpaprop-release)
if [[ "$MODELID" -eq 5 ]]  ; then    ## Model  5:  Modess (strat.)    (profile)
  # Old version format
  #echo "CALLING:   ${EXEC} --atmosfile Volc0.met --skiplines 0 --atmosfileorder ztuvdp --azimuth ${AZ1} --freq ${FREQ} --sourceheight_km ${SRCZ} --write_2d_tloss"
  #${EXEC} --atmosfile Volc0.met --skiplines 0 --atmosfileorder ztuvdp --azimuth ${AZ1} --freq ${FREQ} --sourceheight_km ${SRCZ} --write_2d_tloss
  # ncpaprop-release (current)
  echo "CALLING:   ${EXEC} --atmosfile Volc0.dat --singleprop --azimuth ${AZ1} --freq ${FREQ} --sourceheight_km ${SRCZ} --write_2d_tloss"
  ${EXEC} --atmosfile Volc0.dat --singleprop --azimuth ${AZ1} --freq ${FREQ} --sourceheight_km ${SRCZ} --write_2d_tloss

  ln -s ${AVOG2S}/bin/webscripts/plot_tloss2d.m plot_tloss2d
  echo "CALLING:   ./plot_tloss2d"
  ./plot_tloss2d
fi
if [[ "$MODELID" -eq 6 ]]  ; then    ## Model  6:  CModess (stra.)    (profile)
  # Old version format
  #echo "CALLING:   ${EXEC} --atmosfile Volc0.met --skiplines 0 --atmosfileorder ztuvdp --azimuth ${AZ1} --freq ${FREQ} --sourceheight_km ${SRCZ} --write_2d_tloss"
  #${EXEC} --atmosfile Volc0.met --skiplines 0 --atmosfileorder ztuvdp --azimuth ${AZ1} --freq ${FREQ} --sourceheight_km ${SRCZ} --write_2d_tloss
  # ncpaprop-release (current)
  echo " CModess not yet implemented"
  exit
  echo "CALLING:   ${EXEC} --atmosfile Volc0.dat --singleprop --azimuth ${AZ1} --freq ${FREQ} --sourceheight_km ${SRCZ} --write_2d_tloss"
  ${EXEC} --atmosfile Volc0.dat --singleprop --azimuth ${AZ1} --freq ${FREQ} --sourceheight_km ${SRCZ} --write_2d_tloss

  echo "CALLING:  ./plot_tloss2d"
  ln -s ${AVOG2S}/bin/webscripts/plot_tloss2d.m plot_tloss2d
  ./plot_tloss2d
fi
if [[ "$MODELID" -eq 7 ]]  ; then    ## Model  7:  WMod (stra.)       (profile)
  # Old version format
  #echo "CALLING:   ${EXEC} --atmosfile Volc0.met --skiplines 0 --atmosfileorder ztuvdp --azimuth ${AZ1} --freq ${FREQ} --sourceheight_km ${SRCZ} --write_2d_tloss"
  #${EXEC} --atmosfile Volc0.met --skiplines 0 --atmosfileorder ztuvdp --azimuth ${AZ1} --freq ${FREQ} --sourceheight_km ${SRCZ} --write_2d_tloss
  # ncpaprop-release (current)

  echo " WMod not yet implemented"
  exit
  ln -s ${AVOG2S}/bin/webscripts/plot_tloss2d.m plot_tloss2d
  echo "CALLING:  ./plot_tloss2d"
  ./plot_tloss2d
fi
if [[ "$MODELID" -eq 8 ]]  ; then    ## Model  8:  ModBB              (profile)
  echo " ModBB not implemented"
  exit
fi
if [[ "$MODELID" -eq 9 ]]  ; then    ## Model  9:  ModessRD1WCM       (profile)
  # Old version format
  echo " ModessRD1WCM not yet implemented"
  exit
  #echo "CALLING:  ${EXEC} --g2senvfile InfraAtmos01.env --atmosfileorder zuvwtdp --skiplines 0 --azimuth ${AZ1} --freq ${FREQ} --sourceheight_km ${SRCZ} --receiverheight_km 0 --maxheight_km 180 --maxrange_km 1000 --write_2d_tloss"
  #${EXEC} --g2senvfile InfraAtmos01.env --atmosfileorder zuvwtdp --skiplines 0 --azimuth ${AZ1} --freq ${FREQ} --sourceheight_km ${SRCZ} --receiverheight_km 0 --maxheight_km 180 --maxrange_km 1000 --write_2d_tloss
  #ln -s ${AVOG2S}/bin/webscripts/plot_tloss2d.m plot_tloss2d
  #echo "CALLING:  ./plot_tloss2d"
  #./plot_tloss2d
fi
if [[ "$MODELID" -eq 10 ]] ; then    ## Model 10:  pape               (profile)
  # Old version format
  #echo "CALLING:  ${EXEC} --g2senvfile InfraAtmos01.env --atmosfileorder zuvwtdp --skiplines 0 --azimuth ${AZ1} --freq ${FREQ} --sourceheight_km ${SRCZ} --receiverheight_km 0 --maxheight_km 180 --starter_type gaussian --n_pade 6 --maxrange_km 1000 --write_2d_tloss --do_lossless"
  #${EXEC} --g2senvfile InfraAtmos01.env --atmosfileorder zuvwtdp --skiplines 0 --azimuth ${AZ1} --freq ${FREQ} --sourceheight_km ${SRCZ} --receiverheight_km 0 --maxheight_km 180 --starter_type gaussian --n_pade 6 --maxrange_km 1000 --write_2d_tloss --do_lossless
  # ncpaprop-release (current)
  echo " ePape not yet implemented"
  exit
  echo "CALLING:  ${EXEC} --g2senvfile InfraAtmos01.env --atmosfileorder zuvwtdp --skiplines 0 --azimuth ${AZ1} --freq ${FREQ} --sourceheight_km ${SRCZ} --receiverheight_km 0 --maxheight_km 180 --starter_type gaussian --n_pade 6 --maxrange_km 1000 --write_2d_tloss --do_lossless"
  #${EXEC} --atmosfile2d InfraAtmos01.env --atmosfileorder zuvwtdp --skiplines 0 --azimuth ${AZ1} --freq ${FREQ} --sourceheight_km ${SRCZ} --receiverheight_km 0 --maxheight_km 180 --starter_type gaussian --n_pade 6 --maxrange_km 1000 --write_2d_tloss --do_lossless

  ln -s ${AVOG2S}/bin/webscripts/plot_tloss2d.m plot_tloss2d
  echo "CALLING:  ./plot_tloss2d"
  ./plot_tloss2d
fi
if [[ "$MODELID" -eq 11 ]] ; then    ## Model 11:  Modess             (sweep)
  # Old version format
  #echo "CALLING:  ${EXEC} --atmosfile Volc0.met --atmosfileorder ztuvdp --skiplines 0 --freq ${FREQ} --Nby2Dprop --azimuth_start 0 --azimuth_end 360 --azimuth_step 1 --write_2d_tloss --sourceheight_km ${SRCZ}"
  #${EXEC} --atmosfile Volc0.met --atmosfileorder ztuvdp --skiplines 0 --freq ${FREQ} --Nby2Dprop --azimuth_start 0 --azimuth_end 360 --azimuth_step 1 --write_2d_tloss --sourceheight_km ${SRCZ}
  # ncpaprop-release (current)
  echo "CALLING:  ${EXEC} --atmosfile Volc0.dat --multiprop --freq ${FREQ} --azimuth_start 0 --azimuth_end 360 --azimuth_step 1 --write_2d_tloss --sourceheight_km ${SRCZ}"
  ${EXEC} --atmosfile Volc0.dat --multiprop --freq ${FREQ} --azimuth_start 0 --azimuth_end 360 --azimuth_step 1 --write_2d_tloss --sourceheight_km ${SRCZ}

  ln -s ${AVOG2S}/bin/webscripts/plot_Nby2D_tloss.py temp.py
  echo "CALLING:   python temp.py"
  python temp.py
fi

