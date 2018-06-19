rm(list=ls())

library(leaflet)
library(sf)
library(tidycensus)
library(tidyverse)
options(tigris_use_cache = TRUE)

## import data from NJOF
df <- read.csv('data/data.csv')

## import state shapefiles
shp <- get_decennial(geography = "state", 
                     variables = 'P0010001',
                     year = 2010, 
                     geometry = TRUE,
                     shift_geo = FALSE) %>%
  rename(state = NAME) %>%
  dplyr::select(-variable, -value)  

df <- left_join(shp, df, by = 'state', copy = TRUE) %>%
  group_by(year) %>%
  st_transform(4326)

# df <- st_read("data/juneteenth.geojson")

pal <- colorFactor(rainbow(20), df$year)

m <- leaflet() %>%
  addTiles(attribution = 'Legislative years from <a href="http://www.nationaljuneteenth.com/">National Juneteenth Observance Foundation</a>') %>%
  setView(lng = -95.7129, lat = 37.0902, zoom = 4) %>%
  addPolygons(data = df,
              fillColor = ~pal(df$year),
              fillOpacity = 0.5,
              weight = 1,
              label = ~as.character(year)) %>%
  addLegend("bottomright",
            pal = pal,
            values = df$year,
            title = "Year") %>%
  addScaleBar("bottomright")
m

### exploring exporting as html file for offline exploration
library(htmlwidgets)
saveWidget(m, 
           file="C:/Users/dhardy/Dropbox/sesync/data/R/projects/juneteenth/docs/juneteenth.html",
           title = "Juneteenth State Holiday Legislative Year")


