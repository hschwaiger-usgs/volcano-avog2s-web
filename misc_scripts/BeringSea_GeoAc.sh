#!/bin/bash

rc=0

echo "BeringSea_GeoAc.sh:  checking input arguments"
if [ -z $1 ]
then
  echo "Error: Insufficient command-line arguments"
  echo "Usage:  BeringSea_GeoAc.sh YYYY MM DD FChour"
  echo "   e.g. BeringSea_GeoAc.sh 2018 03 09 12"
  exit 1
else
  YYYY=$1
fi

if [ -z $2 ]
then
  echo "Error: Insufficient command-line arguments"
  echo "Usage:  BeringSea_GeoAc.sh YYYY MM DD FChour"
  echo "   e.g. BeringSea_GeoAc.sh 2018 03 09 12"
  exit 1
else
  MM=$2
fi

if [ -z $3 ]
then
  echo "Error: Insufficient command-line arguments"
  echo "Usage:  BeringSea_GeoAc.sh YYYY MM DD FChour"
  echo "   e.g. BeringSea_GeoAc.sh 2018 03 09 12"
  exit 1
else
  DD=$3
fi

if [ -z $4 ]
then
  echo "Error: Insufficient command-line arguments"
  echo "Usage:  BeringSea_GeoAc.sh YYYY MM DD FChour"
  echo "   e.g. BeringSea_GeoAc.sh 2018 03 09 12"
  exit 1
else
  FChour=$4
fi

nvolcs=`wc -l Volcs.txt | cut -c1-2`
nv=1
Volc=`head -n ${nv} Volcs.txt | tail -1 | cut -f1 -d':'`

YYYYMMDD=${YYYY}${MM}${DD}

cd Proc_${FChour}

# We need to know if we must prefix all gmt commands with 'gmt', as required by version 5
GMTv=5
type gmt >/dev/null 2>&1 || { echo >&2 "Command 'gmt' not found.  Assuming GMTv4."; GMTv=4;}
GMTpre=("-" "-" "-" "-" " "   "gmt ")
GMTelp=("-" "-" "-" "-" "ELLIPSOID" "PROJ_ELLIPSOID")
GMTnan=("-" "-" "-" "-" "-Ts" "-Q")
GMTrgr=("-" "-" "-" "-" "grdreformat" "grdconvert")

mapscale="6i"

lonw=183.0
lats=51.0
lone=202.0
latn=59.5

PROJp=-JM195.5/55.0/${mapscale}

AREAp="-R${lonw}/${lone}/${lats}/${latn}"
DETAILp=-Dh
COASTp="-G220/220/220 -W"
COASTp="-Ggrey90 -W -Slightsteelblue1"

zmin=0.0
zmax=3600.0
dz=25.0
cpt=/home/ash3d/G2S_today/GMT_seis.cpt
makecpt -C${cpt} -T${zmin}/${zmax}/${dz} > tt.cpt

${GMTpre[GMTv]} pscoast $AREAp $PROJp $DETAILp $COASTp -K > temp.ps
# Filter results to strip out 'inf', blank lines and the header
grep '[0-9]' ${YYYYMMDD}/Bering_results.dat | grep -v '#' | grep -v inf > results.dat
# Plot bounce points colored by travel-time
awk '{print $5, $4, $6}' results.dat | ${GMTpre[GMTv]} psxy $AREAp $PROJp -K -O -Sc1.5p -Ctt.cpt  >> temp.ps

# Add colorbar

# Plot all the infrasound arrays
Clevx=-169.94
Clevy=52.822
SndPtx=-160.49
SndPty=55.337
Aktx=-165.99
Akty=54.133
Okx=-168.1750
Oky=53.468
Dilx=-158.51
Dily=59.047
Adkx=-176.6581
Adky=51.88
echo "${Clevx} ${Clevy} 1.0"   | ${GMTpre[GMTv]} psxy $AREAp $PROJp -K -O  -Ss10.0p -Gblack -W0.5,0/0/0  >> temp.ps
echo "${SndPtx} ${SndPty} 1.0" | ${GMTpre[GMTv]} psxy $AREAp $PROJp -K -O  -Ss10.0p -Gblack -W0.5,0/0/0  >> temp.ps
echo "${Aktx} ${Akty} 1.0"     | ${GMTpre[GMTv]} psxy $AREAp $PROJp -K -O  -Ss10.0p -Gblack -W0.5,0/0/0  >> temp.ps
echo "${Okx} ${Oky} 1.0"       | ${GMTpre[GMTv]} psxy $AREAp $PROJp -K -O  -Ss10.0p -Gblack -W0.5,0/0/0  >> temp.ps
echo "${Dilx} ${Dily} 1.0"     | ${GMTpre[GMTv]} psxy $AREAp $PROJp -K -O  -Ss10.0p -Gblack -W0.5,0/0/0  >> temp.ps
echo "${Adkx} ${Adky} 1.0"     | ${GMTpre[GMTv]} psxy $AREAp $PROJp -K -O  -Ss10.0p -Gblack -W0.5,0/0/0  >> temp.ps

psscale -D2.75i/-0.4i/4i/0.15ih -Ctt.cpt -B600f600/:"Travel Time (s)": -O -K >> temp.ps

${GMTpre[GMTv]} psbasemap -B5g5:."${Volc} ${YYYY}-${MM}-${DD}+${FChour}": $AREAp $PROJp -O >> temp.ps
ps2epsi temp.ps
epstopdf temp.epsi
mv temp.pdf ${Volc}_${YYYYMMDD}_${FChour}_GeoAc.pdf
convert -density 400 temp.epsi -rotate 90 -resize x750 -background white -flatten temp1.png

cp  ${YYYYMMDD}/Bering_raypaths.dat raypaths.dat
./load_and_3plot
montage -tile 1x3 -geometry 750x250 DLL.png SnP.png Adk.png  temp2.png
convert +append temp1.png temp2.png ${Volc}_${YYYYMMDD}_${FChour}_GeoAc.png

cp ${Volc}_${YYYYMMDD}_${FChour}_GeoAc.png /webdata/int-vsc-ash.wr.usgs.gov/htdocs/G2S/
