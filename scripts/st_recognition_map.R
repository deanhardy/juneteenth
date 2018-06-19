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
               shift_geo = TRUE) %>%
  rename(state = NAME) %>%
  dplyr::select(-variable, -value)  

shp2 <- left_join(shp, df, by = 'state', copy = TRUE) %>%
  group_by(year)

# tmaptools::palette_explorer()

## plot
fig <- 
  tm_shape(shp2) +
    tm_fill('year',
            palette = "Set3", n = 20) +
    tm_text('abbr', size = 0.5, col = 'black', auto.palette.mapping = F) +
  tm_shape(shp2) +  
    tm_borders() +
    tm_text('year', size = 0.5, ymod = -0.5) +
  tm_layout(main.title = 'Year Juneteenth Recognized',
            main.title.position = 'center',
            frame = FALSE,
            outer.margins=c(0,0,0,0),
            inner.margins=c(0,0,0,0), asp=0,
            legend.show = FALSE)
fig

tiff('figures/juneteenth.tiff', res = 300, units = 'in',
     height = 6, width = 8, compression = 'lzw')
fig
dev.off()
