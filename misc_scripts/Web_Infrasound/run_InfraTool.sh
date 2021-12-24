#!/bin/bash


AVOG2S=/opt/USGS/AVOG2S
WRK=${AVOG2S}/wrk
ART2DDIR=/home/ash3d/Programs/Other/ART2D
GEOACDIR=/home/ash3d/Programs/GIT/GeoAc
NCPADIR=/home/ash3d/Programs/GIT/ncpaprop/bin
PYDIR=/home/ash3d/anaconda3/bin
TOPO=/opt/USGS/data/Topo/etopo.nc
DATA=/data/WindFiles/AVOG2S

#WRK=/media/hschwaiger/6249f4be-4861-4a90-95ea-743a7e0a0579/Infrasound/BV_runs/Autoplotting/
#AVOG2S=/opt/USGS/AVOG2S
#ART2DDIR=/home/hschwaiger/work/USGS/Ground2Space/ART2D/bin
#GEOACDIR=/home/hschwaiger/Programs/GIT/GeoAc-master/
#NCPADIR=/home/hschwaiger/work/USGS/Software_repos/GIT/ncpaprop/bin
#PYDIR=/home/hschwaiger/anaconda3/bin
#TOPO=/data/TOPO/ETOPO1/ETOPO1_Ice_c_gmt4.nc

rc=0
echo "checking input arguments"
if [ -z ${1} ]
then
  echo "Error: You must specify a directory name (no spaces)"
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

#mkdir -p ${TMPDIR}
cd ${TMPDIR}

if [[ "$MODELID" -eq 1 ]]  ; then    ## Model  1:  Art2d              (profile)
  DIM=2
  EXEC=${ART2DDIR}/art2d
fi
if [[ "$MODELID" -eq 2 ]]  ; then    ## Model  2:  GeoAcGlobal        (profile)
  DIM=1
  EXEC=${GEOACDIR}/GeoAcGlobal
fi
if [[ "$MODELID" -eq 3 ]]  ; then    ## Model  3:  GeoAcGlobal.RngDep (profile)
  DIM=3
  EXEC=${GEOACDIR}/GeoAcGlobal.RngDep
fi
if [[ "$MODELID" -eq 4 ]]  ; then    ## Model  4:  GeoAcGlobal.RngDep (sweep)
  DIM=3
  EXEC=${GEOACDIR}/GeoAcGlobal.RngDep
fi
if [[ "$MODELID" -eq 5 ]]  ; then    ## Model  5:  Modess (strat.)    (profile)
  DIM=1
  EXEC=${NCPADIR}/Modess
fi
if [[ "$MODELID" -eq 6 ]]  ; then    ## Model  6:  CModess (stra.)    (profile)
  DIM=1
  EXEC=${NCPADIR}/CModess
fi
if [[ "$MODELID" -eq 7 ]]  ; then    ## Model  7:  WMod (stra.)       (profile)
  DIM=1
  EXEC=${NCPADIR}/WMod
fi
if [[ "$MODELID" -eq 8 ]]  ; then    ## Model  8:  ModBB              (profile)
  DIM=1
  EXEC=${NCPADIR}/ModBB
fi
if [[ "$MODELID" -eq 9 ]]  ; then    ## Model  9:  ModessRD1WCM       (profile)
  DIM=2
  EXEC=${NCPADIR}/ModessRD1WCM
fi
if [[ "$MODELID" -eq 10 ]] ; then    ## Model 10:  pape               (profile)
  DIM=2
  EXEC=${NCPADIR}/pape
fi
if [[ "$MODELID" -eq 11 ]] ; then    ## Model 11:  Modess             (sweep)
  DIM=1
  EXEC=${NCPADIR}/Modess
  PATH=$PYDIR:$PATH
fi

TMPNAME=tmpdir
TMP=${WRK}/Web_Infrasound/${TMPNAME}
mkdir -p ${TMP}
cd ${TMP}

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

echo "${yyyy}"    > yyyy.dat
echo "${mm}"      > mm.dat
echo "${dd}"      > dd.dat
echo "${hh}"      > hh.dat
echo "${SRCX}"    > srcx.dat
echo "${SRCXMAP}" > srcxmap.dat
echo "${SRCY}"    > srcy.dat
echo "${SRCZ}"    > srcz.dat
echo "${AZ1}"     > az1.dat
echo "${AZ2}"     > az2.dat
echo "${DAZ}"     > daz.dat
echo "${MODELID}" > modelid.dat
echo "${RNG}"     > rng.dat
echo "${FREQ}"    > freq.dat
echo "${SRCNAME}" > srcname.dat
echo "${LONPMIN}" > lonpmin.dat
echo "${LATPMIN}" > latpmin.dat

ln -s ${WRK}/RAW_SH/G2S_SH_${YYYY}${MM}${DD}_${HH}Z_wf20_*_res.raw .
#ln -s /opt/Ash3d/data/topo/etopo.nc .

if [[ "$DIM" -eq 1 ]] ; then
  echo "${SRCX} ${SRCY}"                                  > temp.ctr
  echo "180.0 0.2"                                       >> temp.ctr
  echo "1"                                               >> temp.ctr
  echo "720 0.5 0.0"                                     >> temp.ctr
  echo "361 0.5 -90.0"                                   >> temp.ctr
  echo "26 1.0"                                          >> temp.ctr
  echo "50 1.5"                                          >> temp.ctr
  echo "50 2.0"                                          >> temp.ctr
  echo "G2S_SH_${YYYY}${MM}${DD}_${HH}Z_wf20_U_res.raw"  >> temp.ctr
  echo "G2S_SH_${YYYY}${MM}${DD}_${HH}Z_wf20_V_res.raw"  >> temp.ctr
  echo "G2S_SH_${YYYY}${MM}${DD}_${HH}Z_wf20_T_res.raw"  >> temp.ctr
  echo "Volc"                                            >> temp.ctr
  ${AVOG2S}/bin/g2s_Extract_Sonde temp.ctr
fi
if [[ "$DIM" -eq 2 ]] ; then
  ln -s ${TOPO} etopo.nc
  echo "${SRCX} ${SRCY}"                                  > temp.ctr
  echo "180.0 0.2"                                       >> temp.ctr
  echo "1"                                               >> temp.ctr
  echo "${AZ1} 47.69 0.01"                               >> temp.ctr
  echo "720 0.5 0.0"                                     >> temp.ctr
  echo "361 0.5 -90.0"                                   >> temp.ctr
  echo "26 1.0"                                          >> temp.ctr
  echo "50 1.5"                                          >> temp.ctr
  echo "50 2.0"                                          >> temp.ctr
  echo "G2S_SH_${YYYY}${MM}${DD}_${HH}Z_wf20_U_res.raw"  >> temp.ctr
  echo "G2S_SH_${YYYY}${MM}${DD}_${HH}Z_wf20_V_res.raw"  >> temp.ctr
  echo "G2S_SH_${YYYY}${MM}${DD}_${HH}Z_wf20_T_res.raw"  >> temp.ctr
  echo "Volc"                                            >> temp.ctr
  echo "ProfLonLat"                                      >> temp.ctr
  echo "etopo.nc"                                        >> temp.ctr
  ${AVOG2S}/bin/g2s_Extract_Xsec temp.ctr
fi
if [[ "$DIM" -eq 3 ]] ; then
  echo "50.0 60.0 5"                                      > temp.ctr
  echo "185.0 205.0 9"                                   >> temp.ctr
  echo "180.0 0.2"                                       >> temp.ctr
  echo "1"                                               >> temp.ctr
  echo "720 0.5 0.0"                                     >> temp.ctr
  echo "361 0.5 -90.0"                                   >> temp.ctr
  echo "26 1.0"                                          >> temp.ctr
  echo "50 1.5"                                          >> temp.ctr
  echo "50 2.0"                                          >> temp.ctr
  echo "G2S_SH_${YYYY}${MM}${DD}_${HH}Z_wf20_U_res.raw"  >> temp.ctr
  echo "G2S_SH_${YYYY}${MM}${DD}_${HH}Z_wf20_V_res.raw"  >> temp.ctr
  echo "G2S_SH_${YYYY}${MM}${DD}_${HH}Z_wf20_T_res.raw"  >> temp.ctr
  echo "Volc"                                            >> temp.ctr
  ${AVOG2S}/bin/g2s_Extract_Grid temp.ctr
fi




if [[ "$MODELID" -eq 1 ]]  ; then    ## Model  1:  Art2d              (profile)
  echo " Art2d not implemented"
fi
if [[ "$MODELID" -eq 2 ]]  ; then    ## Model  2:  GeoAcGlobal        (profile)                                       -180->180
  ${EXEC} -prop Volc0.met theta_min=-30.0 theta_max=55.0 theta_step=1.0 azimuth=${AZ1} bounces=10 lat_src=${SRCY} lon_src=${SRCX} z_src=${SRCZ} CalcAmp=False WriteAtmo=True
fi
if [[ "$MODELID" -eq 3 ]]  ; then    ## Model  3:  GeoAcGlobal.RngDep (profile)
  ${EXEC} -prop Volc Volc.loclat Volc.loclon theta_min=0.0 theta_max=55.0 theta_step=1.0 azimuth=${AZ1} bounces=10 lat_src=${SRCY} lon_src=${SRCX} z_src=${SRCZ} CalcAmp=False WriteAtmo=True
fi
if [[ "$MODELID" -eq 4 ]]  ; then    ## Model  4:  GeoAcGlobal.RngDep (sweep)
  ${EXEC} -prop Volc Volc.loclat Volc.loclon theta_min=-30.0 theta_max=55.0 theta_step=1.0 phi_min=${AZ1} phi_max=${AZ2} phi_step=${DAZ} bounces=10 lat_src=${SRCY} lon_src=${SRCX} z_src=${SRCZ} CalcAmp=False WriteAtmo=True
fi
if [[ "$MODELID" -eq 5 ]]  ; then    ## Model  5:  Modess (strat.)    (profile)
  ${EXEC} --atmosfile Volc0.met --skiplines 0 --atmosfileorder ztuvdp --azimuth ${AZ1} --freq ${FREQ} --sourceheight_km ${SRCZ} --write_2D_TLoss
  ln -s ${WRK}/plot_tloss2d.m plot_tloss2d
  ./plot_tloss2d
fi
if [[ "$MODELID" -eq 6 ]]  ; then    ## Model  6:  CModess (stra.)    (profile)
  ${EXEC} --atmosfile Volc0.met --skiplines 0 --atmosfileorder ztuvdp --azimuth ${AZ1} --freq ${FREQ} --sourceheight_km ${SRCZ} --write_2D_TLoss
  ln -s ${WRK}/plot_tloss2d.m plot_tloss2d
  ./plot_tloss2d
fi
if [[ "$MODELID" -eq 7 ]]  ; then    ## Model  7:  WMod (stra.)       (profile)
  ${EXEC} --atmosfile Volc0.met --skiplines 0 --atmosfileorder ztuvdp --azimuth ${AZ1} --freq ${FREQ} --sourceheight_km ${SRCZ} --write_2D_TLoss
  ln -s ${WRK}/plot_tloss2d.m plot_tloss2d
  ./plot_tloss2d
fi
if [[ "$MODELID" -eq 8 ]]  ; then    ## Model  8:  ModBB              (profile)
  echo " ModBB not implemented"
  exit
fi
if [[ "$MODELID" -eq 9 ]]  ; then    ## Model  9:  ModessRD1WCM       (profile)
  ${EXEC} --g2senvfile InfraAtmos01.env --atmosfileorder zuvwtdp --skiplines 0 --azimuth ${AZ1} --freq ${FREQ} --sourceheight_km ${SRCZ} --receiverheight_km 0 --maxheight_km 180 --maxrange_km 1000 --write_2D_TLoss
  ln -s ${WRK}/plot_tloss2d.m plot_tloss2d
  ./plot_tloss2d
fi
if [[ "$MODELID" -eq 10 ]] ; then    ## Model 10:  pape               (profile)
  ${EXEC} --g2senvfile InfraAtmos01.env --atmosfileorder zuvwtdp --skiplines 0 --azimuth ${AZ1} --freq ${FREQ} --sourceheight_km ${SRCZ} --receiverheight_km 0 --maxheight_km 180 --starter_type gaussian --n_pade 6 --maxrange_km 1000 --write_2D_TLoss --do_lossless
  ln -s ${WRK}/plot_tloss2d.m plot_tloss2d
  ./plot_tloss2d
fi
if [[ "$MODELID" -eq 11 ]] ; then    ## Model 11:  Modess             (sweep)
  ${EXEC} --atmosfile Volc0.met --atmosfileorder ztuvdp --skiplines 0 --freq ${FREQ} --Nby2Dprop --azimuth_start 0 --azimuth_end 360 --azimuth_step 1 --write_2D_TLoss --sourceheight_km ${SRCZ}
  ln -s ${WRK}/plot_Nby2D_tloss.py temp.py
  python temp.py
  rm ${TMP}/Nby2D_tloss_1d.lossless.nm
fi

mv temp.png ${WRK}/Web_Infrasound/temp.png
#cp *.png /webdata/int-vsc-ash.wr.usgs.gov/htdocs/G2S_Modess/

rm ${TMP}/*.dat ${TMP}/temp.* ${TMP}/G2S_SH_${YYYY}${MM}${DD}_${HH}Z_wf20_*_res.raw
cd ${WRK}/Web_Infrasound
tar -cvf ${TMPNAME}.tar ${TMPNAME}
bzip2 ${TMPNAME}.tar
rm -rf ${TMPNAME}

tfile=$(mktemp /tmp/foo.XXXXXXXXX)
mv ${TMPNAME}.tar.bz2 ${tfile}.tar.bz2



