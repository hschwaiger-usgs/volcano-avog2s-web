#!/bin/bash

WRK=/home/ash3d/G2S_today
AVOG2S=/opt/USGS/AVOG2S

GFS_retain=3

find ${WRK}/2019*nc -type f -mtime +${GFS_retain} -exec rm '{}' \;


