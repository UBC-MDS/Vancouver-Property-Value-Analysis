library(leaflet)
library(tidyverse)
library(geojsonio)
library(scales)

van_spatial <- geojson_read('data/spatial_data/vancouver_neighbourhoods.geojson', what = 'sp')
property_data <- read_csv('data/prop_neigh_summary.csv')

avg_property <- property_data %>%
    rename(avg_price = 'AVG_PROP_VALUE') %>%
    select(NEIGHBOURHOOD_NAME, avg_price)

median_property <- property_data %>%
    rename(median_price = 'MEDIAN_PROP_VALUE') %>%
    select(NEIGHBOURHOOD_NAME, median_price)

van_spatial_property <- sp::merge(van_spatial, avg_property, by.x = 'Name', by.y = 'NEIGHBOURHOOD_NAME') %>%
    sp::merge(median_property, by.x = 'Name', by.y = 'NEIGHBOURHOOD_NAME')

saveRDS(van_spatial_property, file = 'data/van_spatial_property.RDS')

