########################## Initial Note #########################################
# Author: @carieklc
# Date: January, 2019
# Name: 02_property_data.R
# Description: This R script calculates the summary statistics per neighbourhood.
#################################################################################

# Load necessary libraries
library(tidyverse)
library(here)

# Function to automatically clean the individual property data
clean_prop_data <- function(){
    # Load in datasets
    ptax <- read_csv(here("data", "property_tax_report.csv"))
    neigh_code_map <- read_csv(here("data", "bca_neigh_code_map.csv"))
    
    # Labels of non-residential zones
    non_residential <- c('Commercial', 'Light Industrial', 'Industrial', 
                         'Historic Area','Limited Agricultural')
    
    # Filter out non-residential properties and those with missing zones
    res_tax <- ptax %>%
        filter(!ZONE_CATEGORY %in% non_residential) %>%
        drop_na(ZONE_CATEGORY)
    
    # Add column for total property assessment (land + improvement value),
    # and join in neighbourhood names
    neigh_tax <- res_tax %>%
        mutate(TOTAL_VALUE = CURRENT_LAND_VALUE + CURRENT_IMPROVEMENT_VALUE) %>%
        left_join(neigh_code_map, by = c("NEIGHBOURHOOD_CODE"="CODE"))
    
    return(neigh_tax)
}

# Function to produce summaries per neighbourhood
neigh_prop_summary <- function(neigh_tax){
    # Get property summary stats for each neighbourhood
    neigh_prop <- neigh_tax %>% 
        group_by(NEIGHBOURHOOD_NAME) %>%
        summarize(MEDIAN_PROP_VALUE = median(TOTAL_VALUE, na.rm = TRUE),
                  AVG_PROP_VALUE = mean(TOTAL_VALUE, na.rm =TRUE),
                  MEDIAN_PROP_AGEYRS = median(2018-YEAR_BUILT, na.rm = TRUE),
                  AVG_PROP_AGEYRS = mean(2018-YEAR_BUILT, na.rm = TRUE),
                  NUM_ONE_FAMILY_DWELL = sum(ZONE_CATEGORY=="One Family Dwelling"), 
                  NUM_LAND = sum(LEGAL_TYPE == "LAND"),
                  NUM_STRATA = sum(LEGAL_TYPE == "STRATA")) %>%
        arrange(desc(MEDIAN_PROP_VALUE))
    
    # Get property summary stats for all of Vancouver and append
    van_stats <- data.frame( 
            NEIGHBOURHOOD_NAME='Vancouver CMA',
            MEDIAN_PROP_VALUE = median(neigh_tax$TOTAL_VALUE, na.rm = TRUE),
            AVG_PROP_VALUE = mean(neigh_tax$TOTAL_VALUE, na.rm =TRUE),
            MEDIAN_PROP_AGEYRS = median(2018-neigh_tax$YEAR_BUILT, na.rm = TRUE),
            AVG_PROP_AGEYRS = mean(2018-neigh_tax$YEAR_BUILT, na.rm = TRUE),
            NUM_ONE_FAMILY_DWELL = sum(neigh_tax$ZONE_CATEGORY=="One Family Dwelling"), 
            NUM_LAND = sum(neigh_tax$LEGAL_TYPE == "LAND"),
            NUM_STRATA = sum(neigh_tax$LEGAL_TYPE == "STRATA"))
    
    neigh_prop <- rbind(neigh_prop, van_stats)

    return(neigh_prop)
}

# Executes the previous two functions and saves the neighbourhood information
cleaned_prop = clean_prop_data()
prop_summary = neigh_prop_summary(cleaned_prop)
write_csv(prop_summary, here("data", "prop_neigh_summary.csv"))
