library(tidyverse)
library(sf)
library(raster)
library(terra)
library(sp)
library(mapview)

# Calgary hydrology

hydrology <- st_read("https://data.calgary.ca/api/geospatial/5fk8-xqeu?method=export&format=GeoJSON")

# Load inundation data, boundary

temp <- tempfile()
download.file("",temp)
data <- (unz(temp, "midTermProject_Data/CALGIS_CITYBOUND_LIMIT/CALGIS_CITYBOUND_LIMIT.shp"))
unlink(temp)

url <-"https://github.com/mafichman/CPLN_675/raw/main/Week_7_10/data/midTermProject_Data.zip"

temp <- tempfile()
temp2 <- tempfile()

download.file(url, temp)
unzip(zipfile = temp, exdir = temp2)
boundary <- st_read(file.path(temp2, "midTermProject_Data/CALGIS_CITYBOUND_LIMIT/CALGIS_CITYBOUND_LIMIT.shp"))
#flood <- rast(file.path(temp2, "midTermProject_Data/inundation.ovr")) # terra
flood <- raster(file.path(temp2, "midTermProject_Data/inundation.ovr")) # raster
#dem <- rast(file.path(temp2, "midTermProject_Data/calgaryDEM.ovr")) # terra
dem <- raster(file.path(temp2, "midTermProject_Data/calgaryDEM.ovr")) # raster

unlink(c(temp, temp2))

# Create Fishnet

fishnet <- 
  st_make_grid(boundary,
               cellsize = 1000, 
               square = TRUE) %>%
  .[boundary] %>%            # clips the grid to the boundary file
  st_sf() %>%
  mutate(uniqueID = as.character(rownames(.)))


# Adjust projections

#hydrology <- hydrology %>%
#  st_transform(crs = st_crs(boundary))

# WHAT PROJECTION IS THIS STUFF SUPPOSED TO BE IN???

raster::crs(flood) <- "+proj=tmerc +lat_0=0 +lon_0=-114 +k=0.9999 +x_0=0 +y_0=0 +ellps=WGS84 +units=m +no_defs"
raster::crs(dem) <- "+proj=tmerc +lat_0=0 +lon_0=-114 +k=0.9999 +x_0=0 +y_0=0 +ellps=WGS84 +units=m +no_defs"

# Reclassifly flood raster to 1 / 0
# Floods are 2, standing water is 1

# If the raster package is used, this works:

# More on reclassifying rasters here: https://www.earthdatascience.org/courses/earth-analytics/lidar-raster-data-r/classify-raster/

plot(flood)

reclass_df <-c(0, 0, 0,
               1, 2, 1,
               2, 3, 0)

reclass_matrix <-  matrix(reclass_df, ncol = 3,
                          byrow = TRUE)

flood_rc <- reclassify(flood,
                      reclass_matrix)

plot(flood_rc)

# If you use terra, do this:

m <- c(0, 0, 0,
       1, 2, 1,
       2, 3, 0)

rclmat <- matrix(m, ncol=3, byrow=TRUE)

flood_rc <- classify(flood, rclmat, include.lowest=TRUE)

# st_distance - fishnet centroids to hydrology

fishnet_centroid <- fishnet %>%
  st_centroid()

water_dist <- fishnet_centroid %>% 
  st_distance(hydrology %>% 
                st_transform(st_crs(fishnet_centroid))) %>%
  as.data.frame() %>%
  mutate(uniqueID = as.character(row_number())) %>%
  gather(-uniqueID, key = "variable", value = "value") %>%
  dplyr::select(-variable) %>%
  group_by(uniqueID) %>%
  summarize(water_dist = min(value))

fishnet <- left_join(fishnet, water_dist)

# summarize a DEM by fishnet?

# https://rpubs.com/timothyfraser/mapping_raster_data_in_the_tidyverse
# More ideas here - use the 'terra' package?

#test <- raster::extract(x = flood_rc, y = fishnet, fun= mean, na.rm = TRUE)

#test = terra::extract(x = dem, y = vect(fishnet_centroid %>% st_transform(crs(dem))), 
#                      mean, na.rm = TRUE)

# Raster to polygon in R

inundation_sf <- rasterToPolygons(flood_rc, fun=function(x){x==1}) %>%
  st_as_sf()

# Join fishnet to inundation

test_join <- st_join(fishnet_centroid, inundation_sf %>% 
                       st_transform(st_crs(fishnet_centroid)))


# Make a simple model and validate

set.seed(3456)
trainIndex <- createDataPartition(df$factor_data, p = .70,
                                  list = FALSE,
                                  times = 1)

preserveTrain <- preserve[ trainIndex,]
preserveTest  <- preserve[-trainIndex,]