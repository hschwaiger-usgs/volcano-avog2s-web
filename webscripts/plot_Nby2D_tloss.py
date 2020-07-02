import os
import numpy as np
from netCDF4 import Dataset
#from matplotlib.mlab import griddata
from scipy.interpolate import griddata
import matplotlib.pyplot as plt
import math
import cartopy.crs as ccrs

plt.switch_backend('agg')

file = open('srcname.dat','r')
Volcano = file.read().strip()
file.close()
file = open('srcxmap.dat','r')
num=file.readline()
srclon = float(num)
file.close()
file = open('srcy.dat','r')
num=file.readline()
srclat = float(num)
file.close()
file = open('freq.dat','r')
num=file.readline()
freq = float(num)
file.close()

file = open('yyyy.dat', 'r')
YYYY = file.read().strip()
file.close()
file = open('mm.dat', 'r')
MM = file.read().strip()
file.close()
file = open('dd.dat', 'r')
DD = file.read().strip()
file.close()
file = open('hh.dat', 'r')
HH = file.read().strip()
file.close()

file = open('lonpmin.dat', 'r')
num=file.readline()
lonpmin = float(num)
file.close()
file = open('latpmin.dat', 'r')
num=file.readline()
latpmin = float(num)
file.close()

lonpmin=srclon-10.0
latpmin=srclat-8.0

lonpmax=lonpmin + 20.0
latpmax=latpmin + 16.0
InfraDetx=(-176.6581, -169.940, -168.175, -165.990, -160.490, -158.510)
InfraDety=(  51.88  ,   52.822,   53.468,   54.133,   55.337,   59.047)

if lonpmin < -180.0:
  # The domain straddles the antimeridian
  periomap = True
  lonpmin = lonpmin + 360.0
  lonpmax = lonpmax + 360.0
  srclon  = srclon  + 360.0
  clon=180.0
elif lonpmin < 180.0 and lonpmax > 180.0:
  # also straddles the antimeridian
  # we do not need to remap, but we need to adjust the central lon of projection
  periomap = False
  clon=180.0
else:
  periomap = False
  clon=0.0

Re=6371.0
infile='Nby2D_tloss_1d.nm'

f = open(infile, 'r')
na=0
nr=0
for line in f:
    line = line.strip()
    try:
      columns = line.split()
      dist = float(columns[0])
      nr = nr + 1
    except:
      na = na + 1
nr = np.int(nr/na)
f.seek(0)

R1 = np.zeros((na,nr))
AZ1= np.zeros((na,nr))
TL1= np.zeros((na,nr))
ia=0
ir=0
for line in f:
    line = line.strip()
    try:
      columns = line.split()
      dist = float(columns[0])
      azim = float(columns[1])
      TL_Re = float(columns[2])
      TL_Im = float(columns[3])
      Inco  = float(columns[4])
      R1[ia,ir] = dist
      AZ1[ia,ir]= azim
      TL1[ia,ir]=10.0*np.log10(TL_Re**2.0 + TL_Im**2.0);
      ir = ir + 1
    except:
      ir = 0
      ia = ia + 1
f.close()

lat1 = math.radians(srclat)
lon1 = math.radians(srclon)
outdat=np.zeros((nr*na,3))
for ia in range(0,na):
 for ir in range(0,nr):
   ii = nr*ia+ir
   d= R1[ia,ir]
   b=math.radians(AZ1[ia,ir])

   # This scheme assumes a spherical Earth
   # https://stackoverflow.com/questions/7222382/get-lat-long-given-current-point-distance-and-bearing
   lat2 = math.asin( math.sin(lat1)*math.cos(d/Re) + math.cos(lat1)*math.sin(d/Re)*math.cos(b))
   lon2 = lon1 + math.atan2(math.sin(b)*math.sin(d/Re)*math.cos(lat1),
             math.cos(d/Re)-math.sin(lat1)*math.sin(lat2))

   lat2 = math.degrees(lat2)
   lon2 = math.degrees(lon2)
   if periomap and lon2 < 0.0:
     lon2 = lon2 + 360.0

   outdat[ii,0] = lon2
   outdat[ii,1] = lat2
   outdat[ii,2] = TL1[ia,ir]

nlon=1501
nlat=1001
lons=np.linspace(lonpmin,lonpmax,nlon)
lats=np.linspace(latpmin,latpmax,nlat)
xq, yq = np.meshgrid(lons,lats,sparse=True)
#  Using matplotlib.mlab   Note, this is depreciated and will be removed from matplotlib soon
#tl=griddata(outdat[:,0],outdat[:,1],outdat[:,2],lons,lats,interp='linear')
#  Using scipy.interpolate.griddata
grid_x, grid_y = np.meshgrid(lons,lats)
tl=griddata((outdat[:,0],outdat[:,1]),outdat[:,2],(grid_x, grid_y),method='linear')

###############################################################################
#  This section uses an intermediate netCDF file
#    first write it
#fname = 'tloss.nc'
#dataset = Dataset(fname, 'w',  format='NETCDF4_CLASSIC') 
#lat = dataset.createDimension('lat', nlat)
#lon = dataset.createDimension('lon', nlon) 
#latitudes = dataset.createVariable('lat', np.float32,   ('lat',))
#longitudes = dataset.createVariable('lon', np.float32,  ('lon',)) 
#temp = dataset.createVariable('tloss', np.float32, ('lat','lon')) 
#latitudes[:] = lats
#longitudes[:] = lons
#temp[:,:] = tl[:,:]
#dataset.close()
##   now read it
#dataset = Dataset(fname)
#tl = dataset.variables['tloss'][:, :]
#lats = dataset.variables['lat'][:]
#lons = dataset.variables['lon'][:]
###############################################################################

ef, ax = plt.subplots(1,1,figsize=(10,8),subplot_kw={'projection': ccrs.PlateCarree(central_longitude=clon)})
ef.subplots_adjust(hspace=0.2,wspace=0.0,top=0.925,left=0.08)

cbar_min=-170
cbar_max=-70
nlev = 50
img_extent = (lonpmin,lonpmax,latpmin,latpmax)

CS=plt.contourf(lons, lats, tl, nlev,
             transform=ccrs.PlateCarree(central_longitude=0),
             vmin=cbar_min, vmax=cbar_max,
             cmap='jet')
# hot,inferno, winter, bone
ax.coastlines(resolution='50m', color='black', linewidth=1)
ax.scatter(InfraDetx,InfraDety,50,marker='o',color='m')
ax.set_extent(img_extent)

title = '%s Stratified-Modess, %s/%s/%s %sZ: freq=%.1f' % (Volcano,YYYY,MM,DD,HH,freq)
print(title)
ax.set_title(title)
gl = ax.gridlines(crs=ccrs.PlateCarree(), draw_labels=True,
                  linewidth=1, color='grey', alpha=1.0, linestyle='-')
gl.xlabels_top = False
gl.ylabels_right = False

#get size and extent of axes:
axpos = ax.get_position()
pos_x = axpos.x0+axpos.width + 0.01# + 0.25*axpos.width
pos_y = axpos.y0
cax_width = 0.02
cax_height = axpos.height
pos_cax = ef.add_axes([pos_x,pos_y,cax_width,cax_height])
cbar=plt.colorbar(CS, cax=pos_cax)
cbarlabels = np.linspace(np.floor(cbar_min), np.ceil(cbar_max), num=6, endpoint=True)
cbar.set_ticks(cbarlabels)
cbar.set_ticklabels(cbarlabels)
cbar.set_label('Transmission loss (dB)')

ax.set_aspect('auto', adjustable=None)

# Save the plot by calling plt.savefig() BEFORE plt.show()
ofileroot='%s_Ev_tloss2d_%s%s%s_%sZ_fr%.1f' % (Volcano,YYYY,MM,DD,HH,freq)
ofilepng='%s.png' % (ofileroot)
plt.savefig(ofilepng)
plt.savefig('temp.png')
#plt.show()

