install.packages("tidyverse")
install.packages("leaflet")
install.packages("tidycensus")
library(leaflet)
library(tidyverse)
library(tidycensus)
library(sf)


#entering the API information
census_api_key("e758b8cf88c937a42cd051ff1ecfb2bb0d1fec41")

#downloading census data variables
#load_variables(year, dataset, cache)
#Setting cache to true stores the result on your computer
#for future access and using the View button in RStudio
#to interactively browse for variables

v17 <- load_variables(2017, "acs5", cache = TRUE)
census_variables <- load_variables(2017, "acs5", cache = TRUE)



#downloading census data
#get_acs(geography, variables = NULL, table = NULL,
#        cache_table = FALSE, year = 2017, endyear = NULL,
#        output = "tidy", state = NULL, county = NULL, geometry = FALSE,
#        keep_geo_vars = FALSE, shift_geo = FALSE, summary_var = NULL,
#        key = NULL, moe_level = 90, survey = "acs5", ...)
#The FIPS code for St. Louis city is 510. I added the variables so it can be the total population
stlouis_disabled <- get_acs(geography = "tract", 
                   variables = c("B18101_001", "B18101_016", "B18101_019", "B18101_035", "B18101_038"),
                   state = "MO", county = "510", geometry = TRUE, output = "wide") %>%
  mutate(totalpop = B18101_016E + B18101_019E+ B18101_035E + B18101_038E,
          percent_disb = (totalpop/B18101_001E)*100)



#adding the info to leaflet

#first I need to make a color palette
pal = colorNumeric(palette = "viridis", domain = stlouis_disabled$percent_disb)

stlouis_disabled %>%
  leaflet() %>%
  addTiles() %>%
  addPolygons(fillOpacity = 0.7, stroke = FALSE, color = ~pal(percent_disb))

#exporting the tidycensus info to a shapefile
st_write(stlouis_disabled, "stlouis_disabled.shp")
  