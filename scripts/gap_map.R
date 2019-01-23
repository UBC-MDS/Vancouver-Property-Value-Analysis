property_data <- read_csv('data/prop_neigh_summary.csv')

monthly_payments <- property_data %>%
    select(NEIGHBOURHOOD_NAME, MEDIAN_PROP_VALUE, AVG_PROP_VALUE) %>%
    mutate(yearly_median = (MEDIAN_PROP_VALUE)/30,
           monthly_median_payment = yearly_median/12,
           yearly_avg = AVG_PROP_VALUE/30, 
           monthly_avg_payment = yearly_avg/12) %>%
    select(- contains('yearly'), - contains('value'))

social_data <- read_csv('data/socio_demographic_data.csv')

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


van_spatial <- geojson_read('data/spatial_data/vancouver_neighbourhoods.geojson', what = 'sp')

van_spatial_gap <- sp::merge(van_spatial, gap_data, by.x = 'Name', by.y = 'municipality')

saveRDS(van_spatial_gap, file = 'data/van_spatial_gap.RDS')
