#/usr/bin/env python
'''
Date:  Nov 23, 2020 

Draw TC Track Comparison 

Zhenning LI

'''
import numpy as np
import datetime, csv
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.cm import get_cmap
import shapely.geometry as sgeom
import cartopy.crs as ccrs
import cartopy.feature as cfeature
from cartopy.mpl.gridliner import LATITUDE_FORMATTER, LONGITUDE_FORMATTER
from copy import copy

from wrf import (getvar, interplevel, to_np, latlon_coords, get_cartopy,
                 cartopy_xlim, cartopy_ylim, ALL_TIMES)
import sys
sys.path.append('../')
from lib.cfgparser import read_cfg



# Constants
BIGFONT=18
MIDFONT=14
SMFONT=10



def find_side(ls, side):
    """
 Given a shapely LineString which is assumed to be rectangular, return the
 line corresponding to a given side of the rectangle.
 """
    minx, miny, maxx, maxy = ls.bounds
    points = {'left': [(minx, miny), (minx, maxy)],
              'right': [(maxx, miny), (maxx, maxy)],
              'bottom': [(minx, miny), (maxx, miny)],
              'top': [(minx, maxy), (maxx, maxy)],}
    return sgeom.LineString(points[side])

def mct_xticks(ax, ticks):
    """Draw ticks on the bottom x-axis of a Lambert Conformal projection."""
    te = lambda xy: xy[0]
    lc = lambda t, n, b: np.vstack((np.zeros(n) + t, np.linspace(b[2], b[3], n))).T
    xticks, xticklabels = _mct_ticks(ax, ticks, 'bottom', lc, te)
    ax.xaxis.tick_bottom()
    ax.set_xticks(xticks)
    ax.set_xticklabels([ax.xaxis.get_major_formatter()(xtick) for xtick in xticklabels], fontsize=MIDFONT)
def mct_yticks(ax, ticks):
    """Draw ricks on the left y-axis of a Lamber Conformal projection."""
    te = lambda xy: xy[1]
    lc = lambda t, n, b: np.vstack((np.linspace(b[0], b[1], n), np.zeros(n) + t)).T
    yticks, yticklabels = _mct_ticks(ax, ticks, 'left', lc, te)
    ax.yaxis.tick_left()
    ax.set_yticks(yticks)
    ax.set_yticklabels([ax.yaxis.get_major_formatter()(ytick) for ytick in yticklabels], fontsize=MIDFONT)
def _mct_ticks(ax, ticks, tick_location, line_constructor, tick_extractor):
    """Get the tick locations and labels for an axis of a Lambert Conformal projection."""
    outline_patch = sgeom.LineString(ax.outline_patch.get_path().vertices.tolist())
    axis = find_side(outline_patch, tick_location)
    n_steps = 30
    extent = ax.get_extent(ccrs.PlateCarree())
    _ticks = []
    for t in ticks:
        xy = line_constructor(t, n_steps, extent)
        proj_xyz = ax.projection.transform_points(ccrs.Geodetic(), xy[:, 0], xy[:, 1])
        xyt = proj_xyz[..., :2]
        ls = sgeom.LineString(xyt.tolist())
        locs = axis.intersection(ls)
        if not locs:
            tick = [None]
        else:
            tick = tick_extractor(locs.xy)
        _ticks.append(tick[0])
    # Remove ticks that aren't visible: 
    ticklabels = copy(ticks)
    while True:
        try:
            index = _ticks.index(None)
        except ValueError:
            break
        _ticks.pop(index)
        ticklabels.pop(index)
    return _ticks, ticklabels




# ----------Get NetCDF data------------
print('Read NC...')
ncfile = Dataset("/home/dataop/data/nmodel/wrf_2doms_enlarged/2016/201607/2016070312/wrfout_d01_2016-07-04_12:00:00")

lsmask=getvar(ncfile, 'LANDMASK')
    
# Get the lat/lon coordinates
lats, lons = latlon_coords(lsmask)




print('Plot...')
# Create the figure
for ii in range(0, airp_outlen):

    # ----------seperate land/sea---------
    mindis=0.3
    lnd_lst=[]
    ocn_lst=[]
    
    for jj in range(0, airp_count):
        lsflag=get_landsea_idx_xy(lsmask.values, lats.values, lons.values, 
            lat_arr[jj, ii], lon_arr[jj,ii], mindis)
        if ( lsflag==0):
            ocn_lst.append([lat_arr[jj,ii], lon_arr[jj,ii]])
        elif (lsflag==1):
            lnd_lst.append([lat_arr[jj,ii], lon_arr[jj,ii]])
    
    lnd_arr=np.array(lnd_lst)
    ocn_arr=np.array(ocn_lst)

    # Get the map projection information
    curr_time=strt_time+datetime.timedelta(hours=ii)
    fig = plt.figure(figsize=(11,8), frameon=True)
    proj = get_cartopy(lsmask)


    ax = fig.add_axes([0.08, 0.05, 0.8, 0.94], projection=proj)

    # Download and add the states and coastlines
    ax.coastlines('50m', linewidth=0.8)

    # Add ocean, land, rivers and lakes
    ax.add_feature(cfeature.OCEAN.with_scale('50m'))
    ax.add_feature(cfeature.LAND.with_scale('50m'))
    ax.add_feature(cfeature.LAKES.with_scale('50m'))

    # *must* call draw in order to get the axis boundary used to add ticks:
    fig.canvas.draw()
    # Define gridline locations and draw the lines using cartopy's built-in gridliner:
    # xticks = np.arange(80,130,10)
    # yticks = np.arange(15,55,5)
    xticks = np.arange(80,135,5).tolist() 
    yticks =  np.arange(0,60,5).tolist() 
    #ax.gridlines(xlocs=xticks, ylocs=yticks,zorder=1,linestyle='--',lw=0.5,color='gray')

    # Label the end-points of the gridlines using the custom tick makers:
    ax.xaxis.set_major_formatter(LONGITUDE_FORMATTER) 
    ax.yaxis.set_major_formatter(LATITUDE_FORMATTER)
    mct_xticks(ax, xticks)
    mct_yticks(ax, yticks)


    # Set the map bounds
    ax.set_xlim(cartopy_xlim(lsmask))
    ax.set_ylim(cartopy_ylim(lsmask))

    ax.scatter( ocn_arr[:,1], ocn_arr[:,0],marker='.', color='blue', 
                s=4, zorder=1, alpha=0.5, transform=ccrs.Geodetic(), label='Mass Points')
    if(len(lnd_arr)>0):    
        ax.scatter( lnd_arr[:,1], lnd_arr[:,0],marker='.', color='darkred', 
                s=10, zorder=2, alpha=0.5, transform=ccrs.Geodetic(), label='Mass Points')
     
    print('%04d finished.' % ii)
    plt.title('Ocean-Sourced Mass Points Landfall Tracer @%s' % curr_time.strftime('%Y-%m-%d %H:%M:%S'),fontsize=MIDFONT)
    plt.savefig("../fig/halogen.d01.%04d.png" % ii, dpi=80, bbox_inches='tight')
    plt.close('all')

#plt.show()

  
