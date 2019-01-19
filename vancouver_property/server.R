library(shiny)
library(tidyverse)
library(here)
library(leaflet)
# Load in datasets
socio <- read_csv(here("data", "socio_demographic_data.csv"))

# More readable x-axis labels for barplots
vars_name <- c('Age Group', 'Household Size')
names(vars_name) <- c('age_group', 'household_size')

shinyServer(function(input, output) {
    
    # Filter SES data dynamically based on dropdown selections
    socio_filtered <- reactive(socio %>% 
        filter(municipality == input$municipality_input, 
               variable_category == input$social_input))
    
    socio_van <- reactive(socio %>% 
        filter(municipality == "Vancouver CMA", 
        variable_category == input$social_input))
    
    output$income_map <- renderLeaflet({
        map <- readRDS('../income_map.RDS')
        map
    })
  #### Define display functions  
    
  output$distPlot <- renderPlot({
    
    x    <- faithful[, 2] 
    bins <- seq(min(x), max(x), length.out = input$bins + 1)
    
    hist(x, breaks = bins, col = 'darkgray', border = 'white')
    
  })
  
  # Creates neighbourhood-specific barplot for selected SES variable
  output$neigh_barplot <- renderPlot({
      
      socio_filtered() %>%
          ggplot(aes(x=variable, y=value)) +
          geom_bar(stat="identity") +
          xlab(vars_name[[input$social_input]]) +
          ylab("Count") +
          ggtitle(input$municipality_input) +
          theme_bw()
  })
  
  # Creates Vancouver-wide barplot for selected SES variable
  output$van_barplot <- renderPlot({
      
      socio_van() %>%
          ggplot(aes(x=variable, y=value)) +
          geom_bar(stat="identity") +
          xlab(vars_name[[input$social_input]]) +
          ylab("Count") +
          ggtitle("Vancouver") +
          theme_bw()
  })
  
})
