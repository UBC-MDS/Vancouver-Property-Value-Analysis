########################## Initial Note #######################################
# Author: @ian-flores & @carieklc
# Date: January, 2019
# Name: server.R
# Description: This R script serves the server for the shiny application. 
###############################################################################'

# Loads packages
library(shiny)
library(leaflet)
library(DT)

library(tidyverse)
library(forcats)
library(here)


# Load in datasets
socio <- read_csv(here("data", "socio_demographic_data.csv"))
prop <- read_csv(here("data", "prop_neigh_summary.csv"))
property_indv <- read_csv(here("data", "clean_individual.csv"))

# Refactor ordering of neighbourhood factors so plots ordering is as desired
socio$municipality <- socio$municipality %>% fct_relevel("Vancouver CMA", "Vancouver CSD")
socio$variable <- socio$variable %>% fct_relevel("0-4", "5-9")

# Static filtered datasets for displaying non-changing summary stats
vancouver_income <- socio %>%
    filter(municipality == "Vancouver CMA", 
           variable_category == "avg_income" | variable_category == "median_income")

vancouver_prop <- prop %>%
    filter(NEIGHBOURHOOD_NAME == "Vancouver CMA")

# More readable x-axis labels for barplots
vars_name <- c('Age Group', 'Household Size', 'House Type', 'Immigration Status')
names(vars_name) <- c('age_group', 'household_size', 'house_type', 'num_people')

##### Define helper functions
# Puts thousand separators into numbers
format_num <- function(x){
    return(formatC(as.numeric(x), format="f", big.mark = ",", digits=0))
}

# Creates dodgeplot comparing Vancouver to a neighbourhood on SES variable
draw_dodgeplot <- function(socio_data, input){
    socio_data %>%
        ggplot(aes(x=variable, y=prop, fill=municipality)) +
        geom_bar(stat="identity", position='dodge2') +
        scale_fill_manual(values = c("#615E59", "#80BD79")) + 
        coord_flip() +
        xlab(vars_name[[input$social_input]]) +
        ylab("Proportion") +
        ggtitle(paste("Distribution of", vars_name[[input$social_input]])) +
        theme(plot.title = element_text(hjust = 0.5, size=15), 
              axis.title.x=element_text(size = 15), 
              axis.title.y=element_text(size = 15),
              axis.text.x=element_text(size=10),
              axis.text.y=element_text(size=10),
              legend.position = c(0.85, 0.85)) +  
        guides(fill=guide_legend(title="Neighbourhood"))
}

# Surround a string with quotes
neigh_name_formatter <- function(name){
    return(paste(dQuote(name), "=", dQuote(name)))
}

#### Server Definition ####
shinyServer(function(input, output) {
    
    # Filter SES data dynamically based on dropdown selections
    socio_filtered <- reactive(socio %>% 
                                   filter(municipality == input$municipality_input | municipality == 'Vancouver CMA', variable_category == input$social_input) %>%
                                   group_by(municipality) %>%
                                   mutate(total = sum(value, na.rm = TRUE)) %>%
                                   mutate(prop = value/total))
    
    neighbourhood_income <- reactive(socio %>% 
                                         filter(municipality == input$municipality_input, 
                                                variable_category == "avg_income" | variable_category == "median_income"))
    
    prop_filtered <- reactive(prop %>% 
                                  filter(NEIGHBOURHOOD_NAME == input$municipality_input))    
    
    #### Income Map ####
    output$income_map <- renderLeaflet({
        
        # Reads in data
        van_spatial_income <- readRDS(here('data', 'van_spatial_income.RDS'))
        
        # Creates labels for the hovering in the plot
        labels <- sprintf(
            "<strong>Municipality</strong>: %s <br/> 
            <strong>Average Income</strong>: %s <br/>
            <strong>Median Income</strong>: %s",
            van_spatial_income@data$Name, dollar(van_spatial_income@data$avg_income), dollar(van_spatial_income@data$median_income)
        ) %>% lapply(htmltools::HTML)
        
        # Creates functions to colour the variable
        pal_avg <- colorBin('YlGn', domain = van_spatial_income$avg_income, bins = 5)
        pal_median <- colorBin('YlGn', domain = van_spatial_income$median_income, bins = 5)
        
        # Creates interactive map
        leaflet(van_spatial_income) %>%
            addProviderTiles('Stamen.TonerLite') %>%
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
        })
    
    #### Property Map #### 
    output$property_map <- renderLeaflet({
        # Reads in data
        van_spatial_property <- readRDS(here('data', 'van_spatial_property.RDS'))

        # Creates labels for the hovering in the plot
        labels <- sprintf(
            "<strong>Municipality</strong>: %s <br/> 
            <strong>Average Value</strong>: %s <br/>
            <strong>Median Value</strong>: %s",
            van_spatial_property@data$Name, dollar(van_spatial_property@data$avg_price), dollar(van_spatial_property@data$median_price)
        ) %>% lapply(htmltools::HTML)
        
        # Creates functions to colour the variable
        pal_avg <- colorBin('YlGn', domain = van_spatial_property$avg_price, bins = 5)
        pal_median <- colorBin('YlGn', domain = van_spatial_property$median_price, bins = 5)
        
        # Creates interactive map
        leaflet(van_spatial_property) %>%
            addProviderTiles('Stamen.TonerLite') %>%
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
        })
    
    #### Gap Map #### 
    output$gap_map <- renderLeaflet({
        
        # Reads in data
        van_spatial_gap <- readRDS(here('data', 'van_spatial_gap.RDS'))

        # Creates functions to colour the variable
        pal_avg <- colorBin('PRGn', domain = van_spatial_gap$avg_gap, bins = 5)
        pal_median <- colorBin('PRGn', domain = van_spatial_gap$median_gap, bins = 5)
        
        # Creates labels for the hovering in the plot
        labels <- sprintf(
            "<strong>Municipality</strong>: %s <br/> 
            <strong>Average Gap</strong>: %s <br/>
            <strong>Median Gap</strong>: %s",
            van_spatial_gap@data$Name, dollar(van_spatial_gap@data$avg_gap), dollar(van_spatial_gap@data$median_gap)
        ) %>% lapply(htmltools::HTML)
        
        # Creates interactive map
        property_map <- leaflet(van_spatial_gap) %>%
            addProviderTiles('Stamen.TonerLite') %>%
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
        })
    
    #### Dodgeplot ####
    # Creates Vancouver and neighbourhood-specific barplot for selected SES variable
    output$dodgeplot <- renderPlot({
        data <- socio_filtered()
        
        # Special filtering required for immigration status variable only
        if (input$social_input == "num_people"){
            
            status_labels = c("Non-immigrants", "Immigrants", "Non-permanent residents")
            data <- socio_filtered() %>%
                filter(variable %in% status_labels) 
        } 
        draw_dodgeplot(data, input)
    })
    
    #### Summary variables about Neighbourhood ####
    output$neigh_income <- renderUI({
        avg <- paste('Avg. Annual Income: $',format_num(neighbourhood_income()$value[1]))
        med <- paste('Median Annual Income: $', format_num(neighbourhood_income()$value[2]))
        HTML(paste(avg, med, sep='<br/>'))
    })
    
    output$neigh_value <- renderUI({
        prop_avg <- paste('Avg. Property Value: $',format_num(prop_filtered()$AVG_PROP_VALUE))
        prop_med <- paste('Median Property Value: $',format_num(prop_filtered()$MEDIAN_PROP_VALUE))
        HTML(paste(prop_avg, prop_med, sep='<br/>'))
    })
    
    output$van_income <- renderUI({
        avg <- paste('Avg. Annual Income: $',format_num(vancouver_income$value[1]))
        med <- paste('Median Annual Income: $', format_num(vancouver_income$value[2]))
        HTML(paste(avg, med, sep='<br/>'))
    })
    
    output$van_value <- renderUI({
        prop_avg <- paste('Avg. Property Value: $',format_num(vancouver_prop$AVG_PROP_VALUE))
        prop_med <- paste('Median Property Value: $',format_num(vancouver_prop$MEDIAN_PROP_VALUE))
        HTML(paste(prop_avg, prop_med, sep='<br/>'))
    })
    
    output$van_gap <- renderUI({
        gap <- paste('<b>','Affordability Gap (Avg.): $',format_num(vancouver_income$value[1] - vancouver_prop$AVG_PROP_VALUE/30),'</b>')
        HTML(paste(gap, sep='<br/>'))
    })
    
    output$neigh_gap <- renderUI({
        gap <- paste('<b>','Affordability Gap (Avg.): $',format_num(neighbourhood_income()$value[1] - prop_filtered()$AVG_PROP_VALUE/30),'</b>')
        HTML(paste(gap, sep='<br/>'))
    })
    
    #### DataTable ####
    output$property_table <- DT::renderDT({
        datatable(property_indv, 
                  colnames = c('Postal Code', 'Land Value', 'Improvement Value', 'Year Built', 'Taxes Payed', 'Total Value', 'Neighbourhood'),
                  filter = 'top', 
                  options = list(
                      pageLength = 50,
                      lengthMenu = c(5, 10, 15, 20, 25, 50, 100, 150),
                      initComplete = JS(
                          "function(settings, json) {",
                          "$(this.api().table().header()).css({'background-color': '#696969', 'color': '#fff'});",
                          "}")
                  ))
    }, server = TRUE)
    
})
