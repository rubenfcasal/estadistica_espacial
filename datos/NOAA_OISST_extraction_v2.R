# Filename: NOAA_OISST_extraction.R
# 
# Author: Luke Miller   Mar 1, 2011
# http://lukemiller.org/
# Modified by: Ruben Fernandez-Casal Ap 20, 2012 (sp, spacetime classes)
###############################################################################
# library(sp)
library(spacetime)
library(ncdf)  # NetCDF (Network Common Data Form) http://www.unidata.ucar.edu/software/netcdf/

# For info on the NOAA Optimum Interpolated Sea Surface Temperature V2 (OISST):
# http://www.esrl.noaa.gov/psd/data/gridded/data.noaa.oisst.v2.html

# This script works on the OISST sea surface temperature netCDF file called 
# sst.wkmean.1990-present.nc, which must be downloaded into the current 
# working directory (file size is >135MB currently)

# The OISST grid layout is 1 degree latitudes from 89.5 to -89.5 degrees north.
# The longitude grid is 1 degree bins, 0.5 to 359.5 degrees east.
# The SST values are given in degrees Celsius.
# Time values are "days since 1800-1-1 00:00", starting from 69395
# Time delta_t is 0000-00-07 00:00, indices range from 0 to 1103 currently
# The time values in the sst field give the 1st day of the week for each 
# weekly temperature value (though the data are meant to be centered on 
# Wednesday of that week), starting at 69395 = 12/31/1989.
# Use as.Date(69395,origin = '1800-1-1') to convert the netCDF day value to a 
# human readable form. 

lats = seq(89.5,-89.5,-1) #generate set of grid cell latitudes (center of cell)
lons = seq(0.5,359.5,1) #generate set of grid cell longitudes (center of cell)

##Ask user to enter the boundaries of the search area
#cat("Enter longitude of western edge of search area (degrees east 0 to 359)\n")
#lon1 = scan(what = numeric(0),n = 1)
#cat("Enter longitude of eastern edge of search area (degrees east 0 to 359)\n")
#lon2 = scan(what = numeric(0),n = 1)
#cat("Enter latitude of northern edge\n")
#cat("of search area (degrees north, 89.5 to -89.5\n")
#lat1 = scan(what = numeric(0),n = 1)
#cat("Enter latitude of southern edge\n")
#cat("of search area (degrees north, 89.5 to -89.5\n")
#lat2 = scan(what = numeric(0),n = 1)

lon1 = 0
lon2 = 360
lat1 = 90
lat2 = -90

#lon1 = -11 + 360
#lon2 = -7 + 360
#lat1 = 45
#lat2 = 40

lon1a = which.min(abs(lon1 - lons)) #get index of nearest longitude value
lon2a = which.min(abs(lon2 - lons)) #get index of nearest longitude value
lat1a = which.min(abs(lat1 - lats)) #get index of nearest latitude value
lat2a = which.min(abs(lat2 - lats)) #get index of nearest latitude value
#The lon/lat 1a/2a values should now correspond to indices in the netCDF file
#for the desired grid cell. 
nlon = (lon2a - lon1a) + 1 #get number of longitudes to extract
nlat = (lat2a - lat1a) + 1 #get number of latitudes to extract

##Ask the user to enter the dates of interest
#cat("Enter the starting date in the form: 1990-1-31\n")
#date1 = scan(what = character(0),n = 1)
#cat("Enter the ending date in the form: 1990-1-31\n")
#date2 = scan(what = character(0),n = 1)

date1 = '2012-04-15'  # date1 = '2012-02-05'
date2 = '2012-04-15'

date1 = as.Date(date1, format = "%Y-%m-%d") #convert to Date object
date2 = as.Date(date2, format = "%Y-%m-%d") #convert to Date object

#Open the netCDF file for reading. 
nc = open.ncdf("sst.wkmean.1990-present.nc")
#print.ncdf(nc) will show info about the structure of the netCDF file

#Extract available dates from netCDF file
ncdates = nc$dim$time$vals
ncdates = as.Date(ncdates,origin = '1800-1-1') #available time points in nc

date1a = which.min(abs(date1 - ncdates)) #get index of nearest time point
date2a = which.min(abs(date2 - ncdates)) #get index of nearest time point
ndates = (date2a - date1a) + 1 #get number of time steps to extract

#Extract the data from the netCDF file to a matrix or array called 'sstout'. 
sstout = get.var.ncdf(nc, varid = 'sst', start = c(lon1a,lat1a,date1a),
		count = c(nlon,nlat,ndates))
#If you only retrieve one time point, sstout will be a 2D matrix with 
#longitudes running down the rows, and latitudes across the columns. 
#For example, Column 1, sstout[1:nrow(sstout),1], will contain sst values for 
#each of the longitude values at the northern-most latitude in your search 
#area, with the first row, sstout[1,1], being the western-most longitude, and 
#the last row being the eastern edge of your search area.
#If you retrieve multiple time points, sstout will be a 3D array, where time is
#the 3rd dimension. Lat/lon will be arranged the same as the 2D case. 

#The vector 'datesout' will hold the Date values associated with each set of 
#sst values in the sstout array, should you need to access them.
datesout = ncdates[date1a:date2a]

###############################################################################
###############################################################################
# The NOAA OISST files contain sea surface temperatures for the entire globe,
# including on the continents. This clearly isn't right, so they also supply a
# land-sea mask file in netCDF format at the website listed at the start of 
# this script. 
# We use the values (0 or 1) stored in the mask file to turn all of the 
# continent areas into NA's. 

nc2 = open.ncdf('lsmask.nc') #open land-sea mask
mask = get.var.ncdf(nc2, varid = "mask",start = c(lon1a,lat1a,1),
		count = c(nlon,nlat,1)) #get land-sea mask values (0 or 1)

mask = ifelse(mask == 0,NA,1) #replace 0's with NA's

goodlons = lons[lon1a:lon2a]
goodlats = lats[lat1a:lat2a]
index <- goodlons > 191 # Atlantic "view"
# index <- FALSE for Pacific "view"
goodlons[index] <- goodlons[index] - 360

llCRS <- CRS("+proj=longlat +ellps=WGS84")
cellcentre <- c(min(goodlons),min(goodlats))
cellsize <- c(1,1)
sstout.grid <- GridTopology( cellcentre.offset=cellcentre, cellsize=cellsize, cells.dim=c(length(goodlons),length(goodlats)))

jet.colors <- colorRampPalette(c("#00007F", "blue", "#007FFF", "cyan", "#7FFF7F", "yellow", "#FF7F00", "red", "#7F0000"))

if (is.matrix(sstout)) { 
#if there is only 1 time point (2D matrix) -> sp::SpatialGridDataFrame
	sstout = sstout * mask #all masked values become NA	
  sstdf <- data.frame(sst=as.numeric(rbind(sstout[index,],sstout[!index,])))
  attr(sstdf,"label") <- datesout
  sstsp <-  SpatialGridDataFrame(sstout.grid, sstdf, proj4string=llCRS)
  # save(sstsp,file="sstsp.rda")
  image(sstsp, col=jet.colors(128), axes=TRUE)
  title(attr(sstsp@data,"label"))
  # Importar datos de paquetes
  #  library(maps)
  #  library(maptools)
  #  world <- map("world", fill=TRUE, plot = FALSE)   # Hay un mapa con mayor resolución en mapdata::worldHires
  #  world_pol <- map2SpatialPolygons(world, world$names, CRS("+proj=longlat +ellps=WGS84"))
  #  plot(world_pol, col='white', add=TRUE)
} else {
#if ssout is a 3D matrix  -> spacetime::STFDF
	dims = dim(sstout)
	sstdf <- c()
	for (i in 1:dims[3]){
		sstout[,,i] = sstout[,,i] * mask #all masked values become NA
		sstdf <- cbind(sstdf, as.numeric(rbind(sstout[index,,i],sstout[!index,,i])))
	}
  stfdf <- STFDF(SpatialGrid(sstout.grid, proj4string=llCRS), as.POSIXct(datesout), 
                data.frame(sst=as.vector(sstdf)))
  # save(stfdf,file="sstst.rda")
  library(lattice)
  stplot(stfdf[,c(1,2,dims[3]-1,dims[3])],col.regions=jet.colors(128))

}
