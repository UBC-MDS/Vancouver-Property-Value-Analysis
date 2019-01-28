########################## Initial Note #######################################
# Author: @ian-flores
# Date: January, 2019
# Name: 01_census_data.R
# Description: This R script cleans the census data available
#              for the City of Vancouver.
###############################################################################

# Loads the necessary library
library(tidyverse)

# Reads in the data
age_groups <- read_csv('data/census_vancouver_2016.csv', skip = 4, n_max = 26)

age_groups <- age_groups %>%
    filter(!str_detect(Variable, 'over'), 
           !str_detect(Variable, 'Total')) %>%
    separate(Variable, into = c('younger_year', 'older_year'), sep = ' to ') %>%
    separate(older_year, into = c('older_year', 'years_string'), sep = ' ') %>%
    mutate(age_verification = as.integer(older_year) - as.integer(younger_year)) %>%
    filter(age_verification == 4) %>%
    unite(age_group, younger_year, older_year, sep = '-') %>%
    select (- ID, -years_string, -age_verification) %>%
    gather(key = 'municipality', value = 'num_people', - age_group)

new_colnames <- unique(age_groups$municipality)

household_data <- read_csv('data/census_vancouver_2016.csv', skip = 135) %>%
    filter(!is.na(X1))

colnames(household_data)[1:2] <- c('ID', 'Variable')
colnames(household_data)[3:26] <- new_colnames

# Function to extract specific variables from the dataset
household_data_parser <- function(.data, first_id, second_id){
    
    ID <- quo('ID')
    Variable <- quo('Variable')
    
    .data %>%
        filter(ID > first_id, ID < second_id) %>%
        select(-ID) %>%
        gather(key = 'municipality', value = 'num_people', -!!Variable)
}

families_size <- household_data_parser(household_data, 127, 132)
household_size <- household_data_parser(household_data, 150, 156)
house_type <- household_data_parser(household_data, 166, 176)
avg_income <- household_data_parser(household_data, 1857, 1859)
median_income <- household_data_parser(household_data, 1858, 1860)
immigration_status <- household_data_parser(household_data, first_id = 2531, 2542)
