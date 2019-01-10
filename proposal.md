## Vancouver Property Value Analysis

### 1: Overview

With home prices in Vancouver at record highs over recent years, many are concerned about housing affordability, especially [the gap](https://globalnews.ca/news/4444324/metro-vancouver-home-prices-incomes/) between property values and the income of people currently living in Vancouver. If we can compare property values of homes in different neighborhoods of Vancouver and the socio-economic background of people who reside in those areas, we can identify neighborhoods where the affordability gap is particularly severe. To do this, we propose building a data visualization application that allows city lawmakers to visually explore property value and socio-economic data geographically mapped to Vancouver neighborhoods. Our app will show the distribution of property values across the city and allow users to filter on a specific neighborhood in order to compare property values with various socio-economic statistics for that neighborhood.

### 2: Description of data

For this project, we will be using two datasets provided by the City of Vancouver in their Open Data Catalogue. The first of these datasets is the [Property Tax Report Data](https://data.vancouver.ca/datacatalogue/propertyTax.htm) for the year 2018 and we can calculate the total home price by adding the land value plus the improvement value. (Property value = Land value + Improvement value) We will visualize the home price in the first dataset by plotting a choropleth map displaying a summary statistic about the home value per neighbourhood. Moving to the second dataset, we will be using the [Census Local Area Profile for 2016](https://data.vancouver.ca/datacatalogue/censusLocalAreaProfiles2016.htm), which includes data for each neighbourhood about the age, income, number of people living per house and the proportions per immigrant status of the people living there.


### 3: Usage Scenario and Tasks

The Ministry of Municipal Affairs and Housing of British Columbia is interested in understanding what are the factors
driving the gap between income of people and the prices of their homes to enable public policy solutions. They want to be
able to [identify] areas that need faster intervention because the gap is higher than in the rest of the city. However, they
want to be able to [compare] neighbourhoods and [explain] why in certain areas it might be worse than others. When they
login, they will see a map of Vancouver with its 22 neighbourhoods displaying a summary statistic about the property value
for each neighbourhood. If they wish to explore more in-depth a specific neighbourhood, they will be able to select the one
of interest from a dropdown menu. Once the user has choosen their neighbourhood, they can go ahead and [explore] how the
socio-economic variables are distributed in that neighbourhood and how it compares to Vancouver in general.  To the moment,
they hypothesize that neighbourhoods with lower incomes might be the ones with a bigger gap.


### 4: Description of App and Initial Sketch

![](mockup.png)

Note: This mockup uses a modified version of the choropleth graphic from this [blog](http://blogs.ubc.ca/katerynabaranovasgis/cartography/). The histograms are also clipped from the [ggplot2 tutorials](http://www.sthda.com/english/wiki/ggplot2-histogram-plot-quick-start-guide-r-software-and-data-visualization).
