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

labels <- sprintf(
    "<strong>Municipality</strong>: %s <br/> 
    <strong>Average Income</strong>: %s <br/>
    <strong>Median Income</strong>: %s",
    van_spatial_income@data$Name, dollar(van_spatial_income@data$avg_income), dollar(van_spatial_income@data$median_income)
) %>% lapply(htmltools::HTML)


income_map <- leaflet(van_spatial_income) %>%
    addProviderTiles('OpenStreetMap.BlackAndWhite') %>%
    addPolygons(fillColor = ~pal_avg(avg_income),
                weight = 1,
                opacity = 1,
                color = "white",
                dashArray = "2",
                fillOpacity = 0.5,
                highlight = highlightOptions(weight = 5, color = "#666", dashArray = "1", fillOpacity = 0.7, bringToFront = TRUE),
                label = labels,
                labelOptions = labelOptions(style = list("font-weight" = "normal", padding = "3px 8px"), textsize = "15px", direction = "auto"), 
                group = 'Average Income') %>%
    addLegend(pal = pal_avg, values = ~avg_income, title = 'Average Income per Person', labFormat = labelFormat(prefix = '$', between = ' - $'), 
              group = 'Average Income', position = 'topright') %>%
    addPolygons(fillColor = ~pal_median(median_income),
                weight = 1,
                opacity = 1,
                color = "white",
                dashArray = "2",
                fillOpacity = 0.5,
                highlight = highlightOptions(weight = 5, color = "#666", dashArray = "1", fillOpacity = 0.7, bringToFront = TRUE),
                label = labels,
                labelOptions = labelOptions(style = list("font-weight" = "normal", padding = "3px 8px"), textsize = "15px", direction = "auto"), 
                group = 'Median Income') %>%
    addLegend(pal = pal_median, values = ~median_income, title = 'Median Income per Person', labFormat = labelFormat(prefix = '$', between = ' - $'), 
              group = 'Median Income', position = 'topright') %>%
    addLayersControl(overlayGroups = c('Average Income', 'Median Income'),
                     options = layersControlOptions(collapsed = FALSE, ), position = 'topright') %>%
    hideGroup('Median Income')

saveRDS(income_map, file = 'data/income_map.RDS')


