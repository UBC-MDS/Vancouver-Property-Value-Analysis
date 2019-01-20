library(rgdal)
library(geojsonio)
library(magrittr)

readOGR(dsn = 'data/spatial_data/neighbourhoods_shapefiles/', verbose = FALSE) %>%
    geojson_json() %>%
    geojson_write(file = 'data/spatial_data/vancouver_neighbourhoods.geojson')
