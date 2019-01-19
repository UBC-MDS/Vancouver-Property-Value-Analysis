library(shiny)
library(tidyverse)
library(here)
library(leaflet)
library(DT)

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

shinyServer(function(input, output) {
    
    # Filter SES data dynamically based on dropdown selections
    socio_filtered <- reactive(socio %>% 
        filter(municipality == input$municipality_input | municipality == 'Vancouver CMA', 
               variable_category == input$social_input))
    
    neighbourhood_income <- reactive(socio %>% 
        filter(municipality == input$municipality_input, 
                variable_category == "avg_income" | variable_category == "median_income"))
    
    prop_filtered <- reactive(prop %>% 
        filter(NEIGHBOURHOOD_NAME == input$municipality_input))    
    
    
    output$income_map <- renderLeaflet({
        map <- readRDS('../data/income_map.RDS')
    })
    
    output$property_map <- renderLeaflet({
        map <- readRDS('../data/property_map.RDS')
    })
    
    output$gap_map <- renderLeaflet({
        map <- readRDS('../data/gap_map.RDS')
    })
  #### Define display functions  
    
  output$distPlot <- renderPlot({
    
    x    <- faithful[, 2] 
    bins <- seq(min(x), max(x), length.out = input$bins + 1)
    
    hist(x, breaks = bins, col = 'darkgray', border = 'white')
    
  })
  
  # Creates Vancouver and neighbourhood-specific barplot for selected SES variable
  output$neigh_barplot <- renderPlot({
      
      # Special filtering required for immigration status variable only
      if (input$social_input == "num_people"){
          status_labels = c("Non-immigrants", "Immigrants", "Non-permanent residents")
          
          socio_filtered() %>%
              filter(variable %in% status_labels) %>%
              ggplot(aes(x=variable, y=value)) +
              geom_bar(stat="identity") +
              coord_flip() +
              facet_wrap(~municipality, ncol=2, scales = "free_x") +
              xlab(vars_name[[input$social_input]]) +
              ylab("Count") +
              ggtitle(paste("Distribution of", vars_name[[input$social_input]])) +
              theme(plot.title = element_text(hjust = 0.5))  

      } else{
          socio_filtered() %>%
              ggplot(aes(x=variable, y=value)) +
              geom_bar(stat="identity") +
              coord_flip() +
              facet_wrap(~municipality, ncol=2, scales = "free_x") +
              xlab(vars_name[[input$social_input]]) +
              ylab("Count") +
              ggtitle(paste("Distribution of", vars_name[[input$social_input]])) +
              theme(plot.title = element_text(hjust = 0.5))     
      }
  })
 
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
      gap <- paste('<b>','Affordability Gap (Avg.):$',format_num(neighbourhood_income()$value[1] - prop_filtered()$AVG_PROP_VALUE/30),'</b>')
      HTML(paste(gap, sep='<br/>'))
  })
  
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
