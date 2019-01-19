library(shiny)
library(shinythemes)

shinyUI(
    navbarPage(theme = shinytheme('yeti'),
               "Vancouver Property Analysis App",
        tabPanel('Home', icon = icon('home'),
                 fluidPage(
                     fluidRow(
                         h1(class = 'text-center', 'Vancouver Property Analysis App'),
                         column(2, 
                                h3(class = 'text-center', 'Here goes one dropdown'),
                                selectInput('municipality_input', 'Neighbourhood',
                                            c('Vancouver' = 'van', 'UBC' = 'ubc'),
                                            selected = 'ubc')),
                         column(8, 
                                tabsetPanel(
                                    tabPanel("Property Values"),
                                    tabPanel("Incomes"),
                                    tabPanel("Affordability Gap")
                                )),
                         column(2)
                         ),
                     fluidRow(
                         column(2,
                                h3(class = 'text-center', 'Here goes the second dropdown'),
                                selectInput('social_input', 'Socio-Economic Indicator',
                                            c('Age' = 'age', 'Income' = 'income'),
                                            selected = 'income')),
                         column(4, h3(class = 'text-center', 'Here goes the Vancouver plot')),
                         column(4, h3(class = 'text-center', 'Here goes the neighbourhood plot')),
                         column(2)
                     ),
                     fluidRow(
                         column(2),
                         column(8, h3(class = 'text-center', 'Here goes the table')),
                         column(2)
                     )
                    )
                 ),
        tabPanel('About', icon = icon('info-circle'))
    )
)