!##############################################################################
!##############################################################################
      program getAzRng

      implicit none

      real(kind=4), parameter :: DEG2RAD   = 1.74532925e-2
      real(kind=4), parameter :: Re        = 6371.229

      integer             :: iargc, nargs
      integer             :: status
      character (len=100) :: arg
      real(kind=4)        :: inlon1,inlat1 ! Input coords in degrees for point 1
      real(kind=4)        :: inlon2,inlat2 ! Input coords in degrees for point 2
      real(kind=4)        :: lon1,lat1     ! Input coords in rad for point 1
      real(kind=4)        :: lon2,lat2     ! Input coords in rad for point 2
      real(kind=4)        :: dlon,dlat
      real(kind=4)        :: Az,Rng
      real(kind=4)        :: a,c

      nargs = iargc()
      if (nargs.lt.4) then
        write(6,*)"ERROR: Invalid usage"
        write(6,*)"  getAzRng inlon1 inlat1 inlon2 inlat2"
        stop 1
      else
        call get_command_argument(1, arg, status)
        read(arg,*)inlon1
        if(inlon1.lt.-360.0)then
          write(6,*)"ERROR: Longitude1 must be gt -360"
          stop 1
        endif
        if(inlon1.lt.0.0_4.or.inlon1.gt.360.0_4)inlon1=mod(inlon1+360.0_4,360.0_4)
        call get_command_argument(2, arg, status)
        read(arg,*)inlat1
        if(inlat1.lt.-90.0.or.inlat1.gt.90.0)then
          write(6,*)"ERROR: Latitude1 must be between -90 and 90"
          stop 1
        endif
        call get_command_argument(3, arg, status)
        read(arg,*)inlon2
        if(inlon2.lt.-360.0)then
          write(6,*)"ERROR: Longitude2 must be gt -360"
          stop 1
        endif
        if(inlon2.lt.0.0_4.or.inlon2.gt.360.0_4)inlon2=mod(inlon2+360.0_4,360.0_4)
        call get_command_argument(4, arg, status)
        read(arg,*)inlat2
        if(inlat2.lt.-90.0.or.inlat2.gt.90.0)then
          write(6,*)"ERROR: Latitude2 must be between -90 and 90"
          stop 1
        endif
        lon1 = DEG2RAD * inlon1
        lat1 = DEG2RAD * inlat1
        lon2 = DEG2RAD * inlon2
        lat2 = DEG2RAD * inlat2
        dlon = lon2 - lon1
        dlat = lat2 - lat1
        a = sin(0.5*dlat)**2.0 + cos(lat1)*cos(lat2)*sin(0.5*dlon)**2.0
        c = 2.0*atan2(sqrt(a),sqrt(1.0-a))
        Rng = Re * c
        Az = atan2(sin(dlon)*cos(lat2),cos(lat1)*sin(lat2)-sin(lat1)*cos(lat2)*cos(dlon))
        if (Az.lt.0.0) then
          Az = Az + 360.0
        endif
        write(6,'(2f15.4)') Az/DEG2RAD, Rng
      endif

      end program getAzRng
