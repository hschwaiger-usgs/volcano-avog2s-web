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
#         AVO-G2S:  A modified Ground-to-Space model for volcano monitoring in Alaska,
#         submitted. 

#      We make no guarantees, expressed or implied, as to the usefulness of the software
#      and its documentation for any purpose.  We assume no responsibility to provide
#      technical support to users of this software.
#
#      Sequence of commands:
#      "make"  compiles the Ash3d executable
#      "make all" builds the executables and copies to bin
#      "make install" copies the contents of branches/core_code/bin to the install location
#                        e.g. /opt/USGS/Ash3d
#
#  SYSTEM specifies which compiler to use
#    Current available options are:
#      gfortran , ifort
#    This variable cannot be left blank
SYSTEM = gfortran
#
#  RUN specifies which collection of compilation flags that should be run
#    Current available options are:
#      DEBUG : includes debugging info and issues warnings
#      PROF  : includes profiling flags with some optimization
#      OPT   : includes optimizations flags for fastest runtime
#      OMPOPT: includes optimizations flags for fastest runtime and OpenMP directives
#              To run, enter: env OMP_NUM_THREADS=4 Ash3d input_file.inp
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
###############################################################################


###############################################################################
##########  GNU Fortran Compiler  #############################################
ifeq ($(SYSTEM), gfortran)

    FCHOME=/usr
    FC=/usr/bin/gfortran

    COMPINC = -I$(FCHOME)/include -I$(FCHOME)/lib64/gfortran/modules
    COMPLIBS = -L$(FCHOME)/lib -L$(FCHOME)/lib64

    LIBS = $(COMPLIBS) $(USGSLIBDIR) $(USGSINC) $(COMPINC) $(USGSLIB) $(DATALIBS)

# Debugging flags
ifeq ($(RUN), DEBUG)
    FFLAGS =  -O0 -g3 -Wall -fbounds-check -pedantic -fbacktrace -fimplicit-none -Wunderflow -Wuninitialized -ffpe-trap=invalid,zero,overflow -fdefault-real-8
    ASH3DEXEC=Ash3d_debug
endif
ifeq ($(RUN), DEBUGOMP)
    FFLAGS =  -g3 -pg -Wall -fbounds-check -pedantic -fimplicit-none -Wunderflow -Wuninitialized -Wmaybe-uninitialized -ffpe-trap=invalid,zero,overflow -fdefault-real-8 -fopenmp -lgomp
    ASH3DEXEC=Ash3d_debugOMP
endif
# Profiling flags
ifeq ($(RUN), PROF)
    FFLAGS = -g -pg -w -fno-math-errno -funsafe-math-optimizations -fno-trapping-math -fno-signaling-nans -fcx-limited-range -fno-rounding-math -fdefault-real-8
    ASH3DEXEC=Ash3d_prof
endif
# Production run flags
ifeq ($(RUN), OPT)
    FFLAGS = -O3 -w -fno-math-errno -funsafe-math-optimizations -fno-trapping-math -fno-signaling-nans -fcx-limited-range -fno-rounding-math -fdefault-real-8
    ASH3DEXEC=Ash3d
endif
ifeq ($(RUN), OMPOPT)
    FFLAGS = -O3 -w -ffast-math -fdefault-real-8 -fopenmp -lgomp
    ASH3DEXEC=Ash3d_omp
endif

      # Preprocessing flags
    FPPFLAGS =  -x f95-cpp-input $(VERBFPPFLAG)
      # Extra flags
    #EXFLAGS = -xf95
    EXFLAGS =
endif
###############################################################################
##########  Intel Fortran Compiler  #############################################
ifeq ($(SYSTEM), ifort)
    FCHOME = $(HOME)/intel
    FC = $(FCHOME)/bin/ifort
    COMPLIBS = -L$(FCHOME)/lib
    COMPINC = -I$(FCHOME)/include
    LIBS = $(COMPLIBS) $(DATALIBS) $(PROJLIBS) $(COMPINC) -llapack -lblas -lirc -limf
# Debugging flags
ifeq ($(RUN), DEBUG)
    FFLAGS = -g2 -pg -warn all -check all -real-size 64 -check uninit -traceback
    ASH3DEXEC=Ash3d_debug
endif
ifeq ($(RUN), DEBUGOMP)
    FFLAGS = -g2 -pg -warn all -check all -real-size 64 -check uninit -openmp
    ASH3DEXEC=Ash3d_debugOMP
endif
# Profiling flags
ifeq ($(RUN), PROF)
    FFLAGS = -g2 -pg
    ASH3DEXEC=Ash3d_prof
endif
# Production run flags
ifeq ($(RUN), OPT)
    FFLAGS = -O3 -ftz -w -ipo
    ASH3DEXEC=Ash3d
endif
ifeq ($(RUN), OMPOPT)
    FFLAGS = -O3 -ftz -w -ipo -openmp
    ASH3DEXEC=Ash3d_omp
endif

      # Preprocessing flags
    FPPFLAGS =  -fpp -Qoption,fpp $(VERBFPPFLAG) 
      # Extra flags
    EXFLAGS =
endif
###############################################################################

all: misc_scripts/getAzRng

bin/getAzRng: misc_scripts/getAzRng.f90
	$(FC) $(FFLAGS) $(EXFLAGS) misc_scripts/getAzRng.f90 -o getAzRng
	mkdir -p ../bin
	mv getAzRng ../bin

clean:
	rm -rf misc_scripts/getAzRng

install:
	install -d $(INSTALLDIR)/bin/webscripts/              $(INSTALLDIR)/wrk
	install -m 755 ../bin/citywriter                       $(INSTALLDIR)/bin/
	install -m 755 ../bin/convert_to_decimal               $(INSTALLDIR)/bin/
#	install -m 755 ../bin/legend_placer_ac                 $(INSTALLDIR)/bin/
#	install -m 755 ../bin/legend_placer_ac_traj            $(INSTALLDIR)/bin/
#	install -m 755 ../bin/legend_placer_dp                 $(INSTALLDIR)/bin/
#	install -m 755 ../bin/legend_placer_dp_mm              $(INSTALLDIR)/bin/
#	install -m 755 ../bin/makeAsh3dinput1_ac               $(INSTALLDIR)/bin/
#	install -m 755 ../bin/makeAsh3dinput1_dp               $(INSTALLDIR)/bin/
#	install -m 755 ../bin/makeAsh3dinput2_ac               $(INSTALLDIR)/bin/
#	install -m 755 ../bin/makeAsh3dinput2_dp               $(INSTALLDIR)/bin/
#	install -m 755 ../bin/makeAshArrivalTimes_ac           $(INSTALLDIR)/bin/
#	install -m 755 ../bin/makeAshArrivalTimes_dp           $(INSTALLDIR)/bin/
#	install -m 755 ../bin/ncGFS4_2_pf                      $(INSTALLDIR)/bin/
#	install -m 755 ../scripts/GFSVolc_to_gif_ac_hysplit.sh $(INSTALLDIR)/bin/scripts/
#	install -m 755 ../scripts/GFSVolc_to_gif_ac_puff.sh    $(INSTALLDIR)/bin/scripts/
#	install -m 755 ../scripts/GFSVolc_to_gif_ac_traj.sh    $(INSTALLDIR)/bin/scripts/
#	install -m 755 ../scripts/GFSVolc_to_gif_dp_mm.sh      $(INSTALLDIR)/bin/scripts/
#	install -m 755 ../scripts/GFSVolc_to_gif_dp.sh         $(INSTALLDIR)/bin/scripts/
#	install -m 755 ../scripts/GFSVolc_to_gif_tvar.sh       $(INSTALLDIR)/bin/scripts/
#	install -m 755 ../scripts/GMT_Ash3d_to_gif.sh          $(INSTALLDIR)/bin/scripts/
#	install -m 755 ../scripts/gmt_test.sh                  $(INSTALLDIR)/bin/scripts/
#	install -m 755 ../scripts/killrun.sh                   $(INSTALLDIR)/bin/scripts/
#	install -m 755 ../scripts/runAsh3d_ac.sh               $(INSTALLDIR)/bin/scripts/
#	install -m 755 ../scripts/runAsh3d_dp.sh               $(INSTALLDIR)/bin/scripts/
#	install -m 755 ../scripts/runAsh3d.sh                  $(INSTALLDIR)/bin/scripts/
#	install -m 755 ../scripts/runGFS_puff.sh               $(INSTALLDIR)/bin/scripts/
#	install -m 755 ../scripts/runGFS_traj.sh               $(INSTALLDIR)/bin/scripts/
#	install -m 755 ../scripts/xyz2shp.py                   $(INSTALLDIR)/bin/scripts/
#	install -m 644 ../share/GlobalAirports_ewert.txt   $(INSTALLDIR)/share/
#	install -m 644 ../share/readme.pdf                 $(INSTALLDIR)/share/
#	install -m 644 ../share/post_proc/*cpt             $(INSTALLDIR)/share/post_proc/
#	install -m 644 ../share/post_proc/*png             $(INSTALLDIR)/share/post_proc/
#	install -m 644 ../share/post_proc/*xy              $(INSTALLDIR)/share/post_proc/
#	install -m 644 ../share/post_proc/world_cities.txt $(INSTALLDIR)/share/post_proc/
#	install -m 755 ../bin/ncGFS4_2_pf                  $(USGSROOT)/bin/
#
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

