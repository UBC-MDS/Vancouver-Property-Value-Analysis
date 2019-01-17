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
                                selectInput('municipality_input', 'Municipality',
                                            c('Vancouver' = 'Vancouver CMA', 
                                              'UBC' = 'UBC',
                                              'Arbutus-Ridge' = 'Arbutus-Ridge',
                                              'Downtown' = 'Downtown',
                                              'Dunbar-Southlands' = 'Dunbar-Southlands',
                                              'Fairview' = 'Fairview',
                                              'Grandview-Woodland' = 'Grandview-Woodland',
                                              'Hastings-Sunrise' = 'Hastings-Sunrise',
                                              'Kensington-Cedar Cottage' = 'Kensington-Cedar Cottage',
                                              'Kerrisdale' = 'Kerrisdale',
                                              'Kitsilano' = 'Kitsilano',
                                              'Marpole' = 'Marpole',
                                              'Mount Pleasant' = 'Mount Pleasant',
                                              'Oakridge' = 'Oakrdige',
                                              'Renfrew-Collingwood' = 'Renfrew-Collingwood',
                                              'Riley Park' = 'Riley Park',
                                              'Shaughnessy' = 'Shaughnessy',
                                              'South Cambie' = 'South Cambie',
                                              'Strathcona' = 'Strathcona',
                                              'Sunset' = 'Sunset',
                                              'Victoria-Fraserview' = 'Victoria-Fraserview',
                                              'West End' = 'West End',
                                              'West Point Grey' = 'West Point Grey'
                                              ),
                                            selected = 'Downtown')),
                         column(8, 
                                tabsetPanel(
                                    tabPanel("Price"),
                                    tabPanel("Income"),
                                    tabPanel("Gap")
                                )),
                         column(2)
                         ),
                     fluidRow(
                         column(2,
                                h3(class = 'text-center', 'Here goes the second dropdown'),
                                selectInput('social_input', 'Socio-Demographic Variable',
                                            c('Age' = 'age_group', 'Household Size' = 'household_size'),
                                            selected = 'age_group')),
                         column(4, h3(class = 'text-center', plotOutput("van_barplot"))),
                         column(4, h3(class = 'text-center', plotOutput("neigh_barplot"))),
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