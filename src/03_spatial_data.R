########################## Initial Note #######################################
# Author: @ian-flores
# Date: January, 2019
# Name: 03_spatial_data.R
# Description: This R script converts from shapefile to geojson and adds info
#               about property value, income and the gap statistic to the
#               geojson object. It then saves the geojson as an `.RDS` file.
###############################################################################

# Load the libraries
library(rgdal)
library(leaflet)
library(tidyverse)
library(geojsonio)
library(scales)

#### Spatial Data Format Conversion ####

# Reads in shapefile and converts to geojson
readOGR(dsn = 'data/spatial_data/neighbourhoods_shapefiles/', verbose = FALSE) %>%
    geojson_json() %>%
    geojson_write(file = 'data/spatial_data/vancouver_neighbourhoods.geojson')

# Reads in spatial data frame with Vancouver Neighbourhoods
van_spatial <- geojson_read('data/spatial_data/vancouver_neighbourhoods.geojson', what = 'sp')

#### Property Value Spatial ####
property_data <- read_csv('data/prop_neigh_summary.csv')

avg_property <- property_data %>%
    rename(avg_price = 'AVG_PROP_VALUE') %>%
    select(NEIGHBOURHOOD_NAME, avg_price)

median_property <- property_data %>%
    rename(median_price = 'MEDIAN_PROP_VALUE') %>%
    select(NEIGHBOURHOOD_NAME, median_price)

# Merges the spatial dataframe and the tidyverse tibble
van_spatial_property <- sp::merge(van_spatial, avg_property, by.x = 'Name', by.y = 'NEIGHBOURHOOD_NAME') %>%
    sp::merge(median_property, by.x = 'Name', by.y = 'NEIGHBOURHOOD_NAME')

saveRDS(van_spatial_property, file = 'data/van_spatial_property.RDS')

#### Income Spatial ####
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

# Merges the spatial dataframe and the tidyverse tibble
van_spatial_income <- sp::merge(van_spatial, avg_income, by.x = 'Name', by.y = 'municipality') %>%
    sp::merge(median_income, by.x = 'Name', by.y = 'municipality')

saveRDS(van_spatial_income, 'data/van_spatial_income.RDS')

#### Gap Spatial ####
monthly_payments <- property_data %>%
    select(NEIGHBOURHOOD_NAME, MEDIAN_PROP_VALUE, AVG_PROP_VALUE) %>%
    mutate(yearly_median = (MEDIAN_PROP_VALUE)/30,
           monthly_median_payment = yearly_median/12,
           yearly_avg = AVG_PROP_VALUE/30, 
           monthly_avg_payment = yearly_avg/12) %>%
    select(- contains('yearly'), - contains('value'))

monthly_avg_income <- social_data %>%
    filter(variable_category == 'avg_income') %>%
    select(municipality, value) %>%
    rename(avg_income = 'value') %>%
    mutate(monthly_avg_income = avg_income/12) %>%
    select(-avg_income)

monthly_median_income <- social_data %>%
    filter(variable_category == 'median_income') %>%
    select(municipality, value) %>%
    rename(median_income = 'value') %>%
    mutate(monthly_median_income = median_income/12) %>%
    select(-median_income)

gap_data <- left_join(monthly_avg_income, monthly_median_income, by = 'municipality') %>%
    left_join(monthly_payments, by = c('municipality' = 'NEIGHBOURHOOD_NAME')) %>%
    mutate(avg_gap = monthly_avg_income - monthly_avg_payment,
           median_gap = monthly_median_income - monthly_median_payment) %>%
    select(municipality, contains('gap'))

# Merges the spatial dataframe and the tidyverse tibble
van_spatial_gap <- sp::merge(van_spatial, gap_data, by.x = 'Name', by.y = 'municipality')

saveRDS(van_spatial_gap, file = 'data/van_spatial_gap.RDS')

