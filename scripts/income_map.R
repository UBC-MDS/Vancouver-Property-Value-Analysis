library(leaflet)
library(tidyverse)
library(geojsonio)
library(scales)

van_spatial <- geojson_read('data/spatial_data/vancouver_neighbourhoods.geojson', what = 'sp')
social_data <- read_csv('data/socio_demographic_data.csv')

avg_income <- social_data %>%
    filter(variable_category == 'avg_income') %>%
    rename(avg_income = 'value') %>%
    select(-variable_category, -variable)

median_income <- social_data %>%
    filter(variable_category == 'median_income') %>%
    rename(median_income = 'value') %>%
    select(-variable_category, -variable)

pal_avg <- colorBin('YlGn', domain = avg_income$avg_income, bins = 5)
pal_median <- colorBin('YlGn', domain = median_income$median_income, bins = 5)

van_spatial_income <- sp::merge(van_spatial, avg_income, by.x = 'Name', by.y = 'municipality') %>%
    sp::merge(median_income, by.x = 'Name', by.y = 'municipality')

saveRDS(van_spatial_income, 'data/van_spatial_income.RDS')
