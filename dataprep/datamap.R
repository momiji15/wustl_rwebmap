#neccessary packages to load
library(tidyverse) #neccessary to use specific code
library(leaflet) #for the mapping
library(rgdal) #to load the shapefiles

#set the working directory before anything else
setwd("~/Documents/Workshops/Geography Awareness Week 2019/Making Web Maps Using R/Data/R_Project/dataprep")

#adding the census api in order to use tidycensus
census_api_key("e758b8cf88c937a42cd051ff1ecfb2bb0d1fec41")


########### GETTING THE SHAPEFILES ##########
#loading the points shapefile
#long term care facilities in St. Louis
ltc_facilities <- readOGR("SLC_LTC_Facilities/slc_ltc_facilities.shp")
#adult day care facilities in St. Louis
adult_daycare <- readOGR("STL_AdultDayCare/stl_adultdaycare.shp")
#St Louis disabled population
st_louis_disabled2 <- readOGR("STL_disabled/stlouis_disabled.shp")

#get shapefile for the disabled population in st louis
stlouis_disabled <- get_acs(geography = "tract", 
                            variables = c("B18101_001", "B18101_016", "B18101_019", "B18101_035", "B18101_038"),
                            state = "MO", county = "510", geometry = TRUE, output = "wide") %>%
  mutate(totalpop = B18101_016E + B18101_019E+ B18101_035E + B18101_038E,
         percent_disb = (totalpop/B18101_001E)*100)


########## MAPPING THE STUFF ###########
#adding adult day care facilities to the map
leaflet(adult_daycare) %>%
  addTiles() %>%
  addCircles(lng = ~LONGITUDE, lat = ~LATITUDE, color = "blue")

#adding long term care facilities to the map. used a different way to load the data
leaflet() %>%
  addTiles() %>%
  addCircles(data = ltc_facilities, lng = ~LONGITUDE, lat = ~LATITUDE, color = "green")

#now we want to add both adult day care facilities and long term care facilities
leaflet() %>%
  addTiles() %>%
  addCircles(data = ltc_facilities, lng = ~LONGITUDE, lat = ~LATITUDE, color = "green") %>%
  addCircles(data = adult_daycare, lng = ~LONGITUDE, lat = ~LATITUDE, color = "blue")

#now lets add the stlouis_disabled shapefile to the mix
#since we are going to add polygons, we need to a color palette
pal = colorNumeric(palette = "viridis", domain = stlouis_disabled$percent_disb)

leaflet() %>%
  addTiles() %>%
  addCircles(data = ltc_facilities, lng = ~LONGITUDE, lat = ~LATITUDE, color = "green") %>%
  addCircles(data = adult_daycare, lng = ~LONGITUDE, lat = ~LATITUDE, color = "blue") %>%
  addPolygons(data = stlouis_disabled, fillOpacity = 0.7, stroke = FALSE, color = ~pal(percent_disb))

#Lets add some interactivity so you can turn the layers on and off
map <- leaflet() %>%
  addTiles() %>%
  addMarkers(data = ltc_facilities, lng = ~LONGITUDE, lat = ~LATITUDE, label = ltc_facilities$FACILITY,
             group = "Long Term Care Facilities") %>%
  addPolygons(data = stlouis_disabled, fillOpacity = 0.4, stroke = FALSE, color = ~pal(percent_disb),
              group = "Percentage of Population") %>%
  #We will add the layer control here
  addLayersControl(
    overlayGroups = c("Long Term Care Facilities", "Percentage of Population"),
    options = layersControlOptions(collapsed = FALSE))
map



map <- leaflet() %>%
  addTiles() %>%
  addCircles(data = ltc_facilities, lng = ~LONGITUDE, lat = ~LATITUDE, color = "green", 
             group = "Long Term Care Facilities") %>%
  addCircles(data = adult_daycare, lng = ~LONGITUDE, lat = ~LATITUDE, color = "blue", 
             group = "Adult Daycare") %>%
  #We will add the layer control here
  addLayersControl(
    overlayGroups = c("Long Term Care Facilities", "Adult Daycare"),
    options = layersControlOptions(collapsed = FALSE))
map
