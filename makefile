###############################################################################
#  Makefile for AVOG2S_webtools
#
#    User-specified flags are in this top block
#
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
#      Sequence of commands:
#      "make"  compiles the fortran executables
#      "make all" builds the executables and copies to bin
#      "make install" copies the contents of branches/core_code/bin to the install location
#                        e.g. /opt/USGS/AVOG2S
#
#  SYSTEM specifies which compiler to use
#    Current available options are:
#      gfortran
#    This variable cannot be left blank
SYSTEM = gfortran
SYSINC = make_$(SYSTEM).inc
#
#  RUN specifies which collection of compilation flags that should be run
#    Current available options are:
#      DEBUG : includes debugging info and issues warnings
#      PROF  : includes profiling flags with some optimization
#      OPT   : includes optimizations flags for fastest runtime
#    This variable cannot be left blank
RUN = OPT

# This is the location of the USGS libraries and include files
USGSROOT=/opt/USGS
INSTALLDIR=/opt/USGS/AVOG2S

###############################################################################

###############################################################################
#####  END OF USER SPECIFIED FLAGS  ###########################################
###############################################################################


###############################################################################
# Import the compiler-specific include file.  Currently one of:
#  GNU Fortran Compiler
include $(SYSINC)
###############################################################################

###############################################################################
###############################################################################

all: misc_scripts/getAzRng

misc_scripts/getAzRng: misc_scripts/getAzRng.f90
	$(FC) $(FFLAGS) $(EXFLAGS) misc_scripts/getAzRng.f90 -o misc_scripts/getAzRng
	mkdir -p bin
	mv misc_scripts/getAzRng bin/getAzRng

clean:
	rm -rf misc_scripts/getAzRng

install:
	install -d $(INSTALLDIR)/bin/scripts
	install -d $(INSTALLDIR)/bin/webscripts
	install -d $(INSTALLDIR)/wrk
	install -d $(INSTALLDIR)/share
	install -m 755 bin/getAzRng                         $(INSTALLDIR)/bin/getAzRng
	install -m 755 webscripts/run_InfraTool.sh          $(INSTALLDIR)/bin/webscripts/run_InfraTool.sh
	install -m 755 webscripts/plot_Nby2D_tloss.py       $(INSTALLDIR)/bin/webscripts/plot_Nby2D_tloss.py
	install -m 755 webscripts/plot_tloss2d.m            $(INSTALLDIR)/bin/webscripts/plot_tloss2d.m
	install -m 755 webscripts/run_ModessMap_volcs.sh    $(INSTALLDIR)/bin/webscripts/run_ModessMap_volcs.sh
	install -m 755 scripts/autorun_avog2s_gfs.sh        $(INSTALLDIR)/bin/scripts/autorun_avog2s_gfs.sh
	install -m 755 scripts/make_g2sFC_files.sh          $(INSTALLDIR)/bin/scripts/make_g2sFC_files.sh
	install -m 755 scripts/autorun_avog2s_nam.sh        $(INSTALLDIR)/bin/scripts/autorun_avog2s_nam.sh
	install -m 755 scripts/make_g2sSH_files.sh          $(INSTALLDIR)/bin/scripts/make_g2sSH_files.sh
	install -m 755 share/ModMap_Volcs.txt               $(INSTALLDIR)/share/ModMap_Volcs.txt

#uninstall:
#	rm -f $(INSTALLDIR)/bin/citywriter
#	rm -f $(INSTALLDIR)/bin/convert_to_decimal
#	rm -f $(INSTALLDIR)/bin/legend_placer_ac
#	rm -f $(INSTALLDIR)/bin/legend_placer_ac_traj
#	rm -f $(INSTALLDIR)/bin/legend_placer_dp
#	rm -f $(INSTALLDIR)/bin/legend_placer_dp_mm
#	rm -f $(INSTALLDIR)/bin/makeAsh3dinput1_ac
#	rm -f $(INSTALLDIR)/bin/makeAsh3dinput1_dp
#	rm -f $(INSTALLDIR)/bin/makeAsh3dinput2_ac
#	rm -f $(INSTALLDIR)/bin/makeAsh3dinput2_dp
#	rm -f $(INSTALLDIR)/bin/makeAshArrivalTimes_ac
#	rm -f $(INSTALLDIR)/bin/makeAshArrivalTimes_dp
#	rm -f $(INSTALLDIR)/bin/scripts/GFSVolc_to_gif_ac_hysplit.sh
#	rm -f $(INSTALLDIR)/bin/scripts/GFSVolc_to_gif_ac_puff.sh
#	rm -f $(INSTALLDIR)/bin/scripts/GFSVolc_to_gif_ac_traj.sh
#	rm -f $(INSTALLDIR)/bin/scripts/GFSVolc_to_gif_dp_mm.sh
#	rm -f $(INSTALLDIR)/bin/scripts/GFSVolc_to_gif_dp.sh
#	rm -f $(INSTALLDIR)/bin/scripts/GFSVolc_to_gif_tvar.sh
#	rm -f $(INSTALLDIR)/bin/scripts/GMT_Ash3d_to_gif.sh
#	rm -f $(INSTALLDIR)/bin/scripts/gmt_test.sh
#	rm -f $(INSTALLDIR)/bin/scripts/killrun.sh
#	rm -f $(INSTALLDIR)/bin/scripts/runAsh3d_ac.sh
#	rm -f $(INSTALLDIR)/bin/scripts/runAsh3d_dp.sh
#	rm -f $(INSTALLDIR)/bin/scripts/runAsh3d.sh
#	rm -f $(INSTALLDIR)/bin/scripts/runGFS_puff.sh
#	rm -f $(INSTALLDIR)/bin/scripts/runGFS_traj.sh
#	rm -f $(INSTALLDIR)/bin/scripts/xyz2shp.py
#	rmdir $(INSTALLDIR)/bin/scripts/
#	rm -f $(INSTALLDIR)/share/post_proc/*png
#	rm -f $(INSTALLDIR)/share/post_proc/VAAC*.xy
#	rm -f $(INSTALLDIR)/share/post_proc/Ash3d*cpt
#	rm -f $(INSTALLDIR)/share/post_proc/world_cities.txt
#	rm -f $(INSTALLDIR)/share/readme.pdf
#	
#

