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

pal_avg <- colorBin('PRGn', domain = gap_data$avg_gap, bins = 5)
pal_median <- colorBin('PRGn', domain = gap_data$median_gap, bins = 5)

van_spatial_gap <- sp::merge(van_spatial, gap_data, by.x = 'Name', by.y = 'municipality')

labels <- sprintf(
    "<strong>Municipality</strong>: %s <br/> 
    <strong>Average Gap</strong>: %s <br/>
    <strong>Median Gap</strong>: %s",
    van_spatial_gap@data$Name, dollar(van_spatial_gap@data$avg_gap), dollar(van_spatial_gap@data$median_gap)
) %>% lapply(htmltools::HTML)

property_map <- leaflet(van_spatial_gap) %>%
    addProviderTiles('OpenStreetMap.BlackAndWhite') %>%
    addPolygons(fillColor = ~pal_avg(avg_gap),
                weight = 1,
                opacity = 1,
                color = "white",
                dashArray = "2",
                fillOpacity = 0.5,
                highlight = highlightOptions(weight = 5, color = "#666", dashArray = "1", fillOpacity = 0.7, bringToFront = TRUE),
                label = labels,
                labelOptions = labelOptions(style = list("font-weight" = "normal", padding = "3px 8px"), textsize = "15px", direction = "auto"), 
                group = 'Average Gap') %>%
    addLegend(pal = pal_avg, values = ~avg_gap, title = 'Average Gap between Income and Property Value', labFormat = labelFormat(prefix = '$', between = ' - $'), 
              group = 'Average Gap', position = 'topright') %>%
    addPolygons(fillColor = ~pal_median(median_gap),
                weight = 1,
                opacity = 1,
                color = "white",
                dashArray = "2",
                fillOpacity = 0.5,
                highlight = highlightOptions(weight = 5, color = "#666", dashArray = "1", fillOpacity = 0.7, bringToFront = TRUE),
                label = labels,
                labelOptions = labelOptions(style = list("font-weight" = "normal", padding = "3px 8px"), textsize = "15px", direction = "auto"), 
                group = 'Median Gap') %>%
    addLegend(pal = pal_median, values = ~median_gap, title = 'Median Gap between Income and Property Value', labFormat = labelFormat(prefix = '$', between = ' - $'), 
              group = 'Median Gap', position = 'topright') %>%
    addLayersControl(overlayGroups = c('Average Gap', 'Median Gap'),
                     options = layersControlOptions(collapsed = FALSE, ), position = 'topright') %>%
    hideGroup('Median Gap')

saveRDS(property_map, file = 'data/gap_map.RDS')
