AVOG2S_web
==========

AVOG2S_web is a collection of scripts to automate infrasound propagation maps using
the AVO-G2S atmospheric files and various software packages for propagation calculations.

The default installation directory is the same as with volcano-avog2s (/opt/USGS/AVOG2S/).

The only utility requiring compilation is `getAzRng.f90` which is built by typing  
`make`  
To install, type  
`make install`  
which will copy all the scripts and tools to /opt/USGS/AVOG2S.

Usage
-----

It is recommended to add the following to your crontab:  
`15 03,09,15,21     * * *   /opt/USGS/AVOG2S/ExternalData/Ap_Forecast/get_ApFC       > /home/avog2s/cron_logs/ApF.log         2>&1`  
`25 01              * * *   /opt/USGS/AVOG2S/bin/scripts/make_g2sSH_files.sh 0       > /home/avog2s/cron_logs/SH_GeoAc_00.log 2>&1`  
`30 01              * * *   /opt/USGS/AVOG2S/bin/scripts/make_g2sSH_files.sh 6       > /home/avog2s/cron_logs/SH_GeoAc_06.log 2>&1`  
`35 01              * * *   /opt/USGS/AVOG2S/bin/scripts/make_g2sSH_files.sh 12      > /home/avog2s/cron_logs/SH_GeoAc_12.log 2>&1`  
`40 01              * * *   /opt/USGS/AVOG2S/bin/scripts/make_g2sSH_files.sh 18      > /home/avog2s/cron_logs/SH_GeoAc_18.log 2>&1`  
`45 01              * * *   /opt/USGS/AVOG2S/bin/scripts/make_g2sSH_files.sh 24      > /home/avog2s/cron_logs/SH_GeoAc_24.log 2>&1`  

The first line calls a script from volcano-avog2s which retreives current Ap and F107 values.
The next five lines call the script `make_g2sSH_files.sh` for different forecast time steps which automates
the generation of the AVO-G2S atmospheric files using the GFS global forecast data.

To automatically generate infrasound transmission loss maps using Modess, you can add the
following to your crontab:  
`20 07              * * *   /opt/USGS/AVOG2S/bin/scripts/run_modess_maps.sh 06       > /home/avog2s/cron_logs/run_volcs06.log 2>&1`  
`21 07              * * *   /opt/USGS/AVOG2S/bin/scripts/run_modess_maps.sh 12       > /home/avog2s/cron_logs/run_volcs12.log 2>&1`  
`22 07              * * *   /opt/USGS/AVOG2S/bin/scripts/run_modess_maps.sh 18       > /home/avog2s/cron_logs/run_volcs18.log 2>&1`  
`23 07              * * *   /opt/USGS/AVOG2S/bin/scripts/run_modess_maps.sh 24       > /home/avog2s/cron_logs/run_volcs24.log 2>&1`  



Author
-------

Hans F. Schwaiger <hschwaiger@usgs.gov>
