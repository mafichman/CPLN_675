library(tidyverse)
library(sf)
library(raster)
library(terra)
library(sp)
library(mapview)
library(caret)
library(plotROC)
library(pROC)

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
flood <- raster(file.path(temp2, "midTermProject_Data/inundation")) # raster
#dem <- rast(file.path(temp2, "midTermProject_Data/calgaryDEM.ovr")) # terra
dem <- raster(file.path(temp2, "midTermProject_Data/calgaryDEM")) # raster

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

#raster::crs(flood) <- "+proj=tmerc +lat_0=0 +lon_0=-114 +k=0.9999 +x_0=0 +y_0=0 +ellps=WGS84 +units=m +no_defs"
#raster::crs(dem) <- "+proj=tmerc +lat_0=0 +lon_0=-114 +k=0.9999 +x_0=0 +y_0=0 +ellps=WGS84 +units=m +no_defs"

# Reclassifly flood raster to 1 / 0
# Floods are 2, standing water is 1

# If the raster package is used, this works:

# More on reclassifying rasters here: https://www.earthdatascience.org/courses/earth-analytics/lidar-raster-data-r/classify-raster/

plot(flood)

reclass_inundation_df <-c(0, 0, 0,
               1, 2, 1,
               2, 3, 0)

reclass_matrix_inundation <-  matrix(reclass_inundation_df, ncol = 3,
                          byrow = TRUE)

flood_rc <- reclassify(flood,
                       reclass_matrix_inundation)

plot(flood_rc)

# If you use terra, do this:

#m <- c(0, 0, 0,
#       1, 2, 1,
#       2, 3, 0)

#rclmat <- matrix(m, ncol=3, byrow=TRUE)

#flood_rc <- classify(flood, rclmat, include.lowest=TRUE)

#---- st_distance - fishnet centroids to hydrology

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

fishnet <- st_join(fishnet_centroid, inundation_sf %>% 
                       st_transform(st_crs(fishnet_centroid))) %>%
  as.data.frame () %>%
  dplyr::select(-geometry) %>%
  right_join(., fishnet) %>%
  mutate(inundation = ifelse(is.na(inundation) == TRUE, 0, inundation))

# create a slope category variable

# Reclassifly dem

# If the raster package is used, this works:

# More on slope and rasters here: https://benmarwick.github.io/How-To-Do-Archaeological-Science-Using-R/using-r-as-a-gis-working-with-raster-and-vector-data.html

plot(dem)

area_slope <- raster::terrain(dem, opt = 'slope', unit = 'degrees')

hist(area_slope)

reclass_slope_df <-c(0, 5, 0,
               5, 50, 1)

reclass_matrix_slope <-  matrix(reclass_slope_df, ncol = 3,
                          byrow = TRUE)

slope_rc <- reclassify(area_slope,
                       reclass_matrix_slope)

plot(slope_rc)

hist(slope_rc)

# join slope to dem

# alternative extract(r, sp, method='bilinear')

slope_sf <- rasterToPolygons(slope_rc, fun=function(x){x==1}) %>%
  st_as_sf()

fishnet <- st_join(fishnet_centroid, slope_sf %>% 
          st_transform(st_crs(fishnet_centroid))) %>%
  as.data.frame () %>%
  dplyr::select(-geometry) %>%
  right_join(., fishnet) %>%
  mutate(slope = (ifelse(is.na(slope) == TRUE, 0, 1))) %>%
  mutate(slope = as.factor(slope))

# call final data set flood

flood <- fishnet

# Make a simple model and validate

set.seed(3456)
trainIndex <- createDataPartition(flood$slope, p = .70,
                                  list = FALSE,
                                  times = 1)

floodTrain <- flood[ trainIndex,]
floodTest  <- flood[-trainIndex,]

floodModel <- glm(inundation ~ ., 
                     family="binomial"(link="logit"), data = floodTrain %>%
                       as.data.frame() %>%
                       dplyr::select(-geometry, -uniqueID))

summary(floodModel)

classProbs <- predict(floodModel, floodTest, type="response")

hist(classProbs)

testProbs <- data.frame(obs = as.numeric(floodTest$inundation),
                        pred = classProbs)

ggplot(testProbs, aes(x = pred, fill=as.factor(obs))) + 
  geom_density() +
  facet_grid(obs ~ .) + 
  xlab("Probability") + 
  geom_vline(xintercept = .5) +
  scale_fill_manual(values = c("dark blue", "dark green"),
                    labels = c("No Flooding","Flooding"),
                    name = "")

# See about matrix for .5 - actual is probably way lower

testProbs$predClass  = ifelse(testProbs$pred > .5 ,1,0)

caret::confusionMatrix(reference = as.factor(testProbs$obs), 
                       data = as.factor(testProbs$predClass), 
                       positive = "1")

# ROC

ggplot(testProbs, aes(d = obs, m = pred)) + 
  geom_roc(n.cuts = 50, labels = FALSE) + 
  style_roc(theme = theme_grey) +
  geom_abline(slope = 1, intercept = 0, size = 1.5, color = 'grey') 

auc(testProbs$obs, testProbs$pred)

# CV

ctrl <- trainControl(method = "cv", 
                     number = 100, 
                     savePredictions = TRUE)

cvFit <- train(as.factor(inundation) ~ .,  data = flood %>% 
                 as.data.frame() %>%
                 dplyr::select(-geometry,-uniqueID), 
               method="glm", family="binomial",
               trControl = ctrl)

cvFit

ggplot(as.data.frame(cvFit$resample), aes(Accuracy)) + 
  geom_histogram() +
  scale_x_continuous(limits = c(0, 1)) +
  labs(x="Accuracy",
       y="Count")
