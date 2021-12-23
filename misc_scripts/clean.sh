#!/bin/bash

AVOG2S=/opt/USGS/AVOG2S
WRK=${AVOG2S}/wrk

GFS_retain=3

find ${WRK}/2021*nc -type f -mtime +${GFS_retain} -exec rm '{}' \;


