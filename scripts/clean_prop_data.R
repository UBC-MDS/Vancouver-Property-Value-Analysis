library(tidyverse)
library(here)

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
    
    # Exclude those listed as "VACANT" in street address or missing postal code? (~2600)
    #neight_prop <- neigh_prop %>%
    #    filter(STREET_NAME == 'VACANT' | is.na(PROPERTY_POSTAL_CODE)) %>%
    #    summarise(count = n())
    
    return(neigh_prop)
}

clean_prop_data()
           