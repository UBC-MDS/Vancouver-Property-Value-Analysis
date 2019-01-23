library(shiny)
library(shinythemes)
library(leaflet)
library(shinydashboard)
library(DT)
library(scales)

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
                         #h1(class = 'text-center', 'Vancouver Property Analysis App'),
                         column(6,
                                tabsetPanel(
                                    tabPanel("Affordability Gap", leafletOutput(height = 500, 'gap_map')),
                                    tabPanel("Property Values", leafletOutput(height = 500, 'property_map')),
                                    tabPanel("Incomes", leafletOutput(height = 500, 'income_map')),
                                    tabPanel("Affordability Gap", leafletOutput(height = 500, 'gap_map'))
                                )),
                         column(6,
                                fluidRow(
                                    column(6,
                                           selectInput('municipality_input', 'Neighbourhood',
                                                       choices = neigh_list,
                                                       selected = 'Downtown')),
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
                                         h3(class = 'text-center', plotOutput("dodgeplot"))
                                    )
                                ),
                                fluidRow(
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
                     DTOutput('property_table')
                 ))
    )
)
