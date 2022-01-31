# If you are having tons of trouble with ArcGIS field calculating your soils data,
# You can steps 5-9 in the exercise in R

# You could use this code routine to deal with SSURGO data using this routine
# In the future.

# Libraries

library(tidyverse)
library(sf)

# load the soils data (you should change this to be YOUR file path to your data)

soils <- st_read("C:/Users/mfich/Documents/Clients/MUSA_Teaching_and_Admin/CPLN_675_2022/Week3_data/Week3_data/cedar_clip_soil.shp")

glimpse(soils)

# What are our soil categories?
summary(as.factor(soils$SoilCode))

#    A  A/D    B  B/D    C  C/D    D 

soils <- soils %>%
  mutate(PctA = case_when(SoilCode == "A" ~ 100,
                          SoilCode == "A/D" ~ 50,
                          TRUE ~ 0),
         PctB = case_when(SoilCode == "B" ~ 100,
                          SoilCode == "B/D" ~ 50,
                          TRUE ~ 0),
         PctC = case_when(SoilCode == "C" ~ 100,
                          SoilCode == "C/D" ~ 50,
                          TRUE ~ 0),
         PctD = case_when(SoilCode == "D" ~ 100,
                          SoilCode %in% c("A/D", "B/D", "C/D") ~ 50,
                          TRUE ~ 0))

# Write the data out as shp or geojson

# st_write(soils, "your_file_path.shp")
