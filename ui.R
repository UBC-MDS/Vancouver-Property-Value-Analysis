########################## Initial Note #######################################
# Author: @ian-flores & @carrieklc
# Date: January, 2019
# Name: ui.R
# Description: This R script serves as the UI for the shiny application. 
###############################################################################

library(shiny)
library(shinythemes)
library(leaflet)
library(DT)

library(tidyverse)
library(here)


# Read in property CSV to get neighbourhood names for first dropdown list
prop_data <- read_csv(here("data", "prop_neigh_summary.csv"))
neigh_list <- as.list(prop_data$NEIGHBOURHOOD_NAME)
names(neigh_list) <- neigh_list

shinyUI(
    navbarPage(theme = shinytheme('yeti'),
               "Vancouver Property Analysis App",
        tabPanel('Home', icon = icon('home'),
                 fluidPage(
                     fluidRow(
                         column(6,
                                #### Maps ####
                                tabsetPanel(
                                    tabPanel("Affordability Gap", leafletOutput(height = 500, 'gap_map')),
                                    tabPanel("Property Values", leafletOutput(height = 500, 'property_map')),
                                    tabPanel("Incomes", leafletOutput(height = 500, 'income_map'))
                                ),
                                #### Afforability Gap Definition ####
                                h5(class = 'text-center', 'Affordability Gap'),
                                p(class = 'text-center', 'Affordability Gap is defined as the gap that exists between the monthly income of an individual and their monthly payment of the houses. 
                                  The monthly payment is approximated by dividing the value of the house in 30 years and then dividing that value by 12 months.')
                         ),
                         column(6,
                                fluidRow(
                                    #### Neighbourhood Dropdown ####
                                    column(6,
                                           selectInput('municipality_input', 'Neighbourhood',
                                                       choices = neigh_list,
                                                       selected = 'Downtown')),
                                    
                                    #### Social Variable Dropdown ####
                                    column(6,
                                       selectInput('social_input', 'Socio-Demographic Variable',
                                                   c('Age' = 'age_group',
                                                     'Household Size' = 'household_size',
                                                     'House Type' = 'house_type',
                                                     'Immigration Status' = 'num_people'),
                                                   selected = 'age_group'))
                                    ),

                                fluidRow(
                                    column(12,
                                         #### Dodgeplot ####
                                         h3(class = 'text-center', plotOutput("dodgeplot"))
                                    )
                                ),
                                fluidRow(
                                    #### Summary Statistics Icons ####
                                    column(6,
                                           h6(icon("exclamation-circle"), uiOutput("van_gap"),align = "center"),
                                           h6(icon("home"), uiOutput("van_value"),align = "center"),
                                           h6(icon("money-bill-wave"), uiOutput("van_income"),align = "center")),
                                    column(6,
                                           h6(icon("exclamation-circle"), uiOutput("neigh_gap"),align = "center"),
                                           h6(icon("home"), uiOutput("neigh_value"),align = "center"),
                                           h6(icon("money-bill-wave"), uiOutput("neigh_income"),align = "center"))
                                )
                                )
                         )
                    )
                 ),
        tabPanel('Individual Level Data', icon = icon('table'),
                 fluidPage(
                     #### DataTable ####
                     DTOutput('property_table')
                 )),
        tabPanel('About', icon = icon('info'),
                 fluidPage(
                     fluidRow(
                         column(4),
                         column(4,
                                h2(class = 'text-center', 'Overview'),
                                h5(class = 'text-center', 
                                  'With home prices in Vancouver at record 
                                  highs over recent years, many are concerned 
                                  about housing affordability, especially the 
                                  gap between property values and the income 
                                  of people currently living in Vancouver. 
                                  If we can compare property values of homes 
                                  in different neighbourhoods of Vancouver 
                                  and the socio-economic background of people 
                                  who reside in those areas, we can identify 
                                  neighbourhoods where the affordability gap 
                                  is particularly severe. To do this, we built
                                  this application that allows users to visually
                                  explore property values and socio-economic data
                                  geographically mapped to Vancouver neighbourhoods.'),
                                br(),
                                h2(class = 'text-center', 'Our Data'),
                                h5(class = 'text-center',
                                  'To build this application we used two datasets 
                                  provided by the City of Vancouver in their Open
                                  Data Catalogue. The first of these datasets is 
                                  the Property Tax Report Data for the year 2018. 
                                  Based on this data, we created the visualizations 
                                  about property value. the second datasets is the 
                                  Census Local Area Profile for 2016, which includes 
                                  socio-economic data for each neighbourhood.'),
                                img(src = 'vancouver_downtown.jpg', align = 'middle', height = 400),
                                p('Downtown Vancouver')
                                ),
                         column(4)
                     )
                 ))
    )
)
