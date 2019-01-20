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

pal_avg <- colorBin('YlGn', domain = avg_property$avg_price, bins = 5)
pal_median <- colorBin('YlGn', domain = median_property$median_price, bins = 5)

van_spatial_property <- sp::merge(van_spatial, avg_property, by.x = 'Name', by.y = 'NEIGHBOURHOOD_NAME') %>%
    sp::merge(median_property, by.x = 'Name', by.y = 'NEIGHBOURHOOD_NAME')

labels <- sprintf(
    "<strong>Municipality</strong>: %s <br/> 
    <strong>Average Value</strong>: %s <br/>
    <strong>Median Value</strong>: %s",
    van_spatial_property@data$Name, dollar(van_spatial_property@data$avg_price), dollar(van_spatial_property@data$median_price)
) %>% lapply(htmltools::HTML)

property_map <- leaflet(van_spatial_property) %>%
    addProviderTiles('OpenStreetMap.BlackAndWhite') %>%
    addPolygons(fillColor = ~pal_avg(avg_price),
                weight = 1,
                opacity = 1,
                color = "white",
                dashArray = "2",
                fillOpacity = 0.5,
                highlight = highlightOptions(weight = 5, color = "#666", dashArray = "1", fillOpacity = 0.7, bringToFront = TRUE),
                label = labels,
                labelOptions = labelOptions(style = list("font-weight" = "normal", padding = "3px 8px"), textsize = "15px", direction = "auto"), 
                group = 'Average Property Value') %>%
    addLegend(pal = pal_avg, values = ~avg_price, title = 'Average Value per House', labFormat = labelFormat(prefix = '$', between = ' - $'), 
              group = 'Average Property Value', position = 'topright') %>%
    addPolygons(fillColor = ~pal_median(median_price),
                weight = 1,
                opacity = 1,
                color = "white",
                dashArray = "2",
                fillOpacity = 0.5,
                highlight = highlightOptions(weight = 5, color = "#666", dashArray = "1", fillOpacity = 0.7, bringToFront = TRUE),
                label = labels,
                labelOptions = labelOptions(style = list("font-weight" = "normal", padding = "3px 8px"), textsize = "15px", direction = "auto"), 
                group = 'Median Property Value') %>%
    addLegend(pal = pal_median, values = ~median_price, title = 'Median Value per House', labFormat = labelFormat(prefix = '$', between = ' - $'), 
              group = 'Median Property Value', position = 'topright') %>%
    addLayersControl(overlayGroups = c('Average Property Value', 'Median Property Value'),
                     options = layersControlOptions(collapsed = FALSE, ), position = 'topright') %>%
    hideGroup('Median Property Value')

saveRDS(property_map, file = 'data/property_map.RDS')

