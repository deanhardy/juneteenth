## Data from National Juneteenth Observance Foundation
## http://nationaljuneteenth.com/St_Holiday_Legislation.html

rm(list=ls())

library(tidycensus)
library(tidyverse)
library(tmap)
library(sf)
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

shp2 <- left_join(shp, df, by = 'state', copy = TRUE) %>%
  group_by(year) %>%
  st_transform(4326)

## export shapes to modify centroids in Arc for labeling
# shp2 %>%
#   st_centroid() %>%
#   st_write('data/st_cntrd.shp', driver = 'ESRI Shapefile')

# shp2 %>%
#   st_transform(4326) %>% 
#   st_write('data/juneteenth.geojson', driver = 'geojson')

lbl <- st_read('data/st_cntrd.shp')

# tmaptools::palette_explorer()

## plot
fig <- 
  tm_shape(shp2) +
    tm_polygons('year',
            palette = "Set3", n = 20) +
  tm_shape(lbl) +  
    tm_dots(alpha = 0) +
    tm_text('abbr', size = 0.6) +
  tm_shape(lbl) +  
    tm_dots(alpha = 0) +
    tm_text('year', size = 0.6, ymod = -0.5) +
  tm_layout(main.title = 'Juneteenth State Holiday Legislative Year',
            main.title.position = 'center',
            frame = FALSE,
            outer.margins=c(0,0,0,0),
            inner.margins=c(0,0,0,0), asp=0,
            legend.show = FALSE) +
  tm_credits('*Legislative year from the National Juneteenth Observance Foundation')
# fig

tiff('figures/juneteenth.tiff', res = 300, units = 'in',
     height = 6, width = 8, compression = 'lzw')
fig
dev.off()

png('figures/junteenth.png', res = 150, units = 'in',
    height = 6, width = 8)
fig
dev.off()
