# Vancouver Property Analysis Application: Milestone 3 Reflection

## Main Themes
The feedback we received from our reviewers can be grouped into several themes:

1) Improve general layout by positioning relevant panels or sections closer together.
>In response to this suggestion, we moved the dropdown selections that filtered information shown on the bar plots from the left side panel to sit on top of the bar plot. This way, it is more visually clear that these selections control the bar plot and has no effect on the map. In order to do this within the constraints of a computer screen where there is more horizontal than vertical space, we moved both the dropdown selections and bar plot to the right half of the app. The map  was then placed on the left half of the screen.

2) Help user to understand terminology on visualizations by providing definitions for unfamiliar terms (e.g. "affordability gap").

>We added text defining "affordability gap" in the context of our application below the map section.

3) Aesthetic changes to improve readability, with a special focus on sizing of labels on plots.

> We increased the size of the title, and x and y axes labels in the bar plot so that users can easily see which variables are being visualized.

## Plotting Changes
One piece of feedback we received that was very helpful but did not fall into the above themes was to show a dodge bar plot instead of two separate bar plots for Vancouver and the selected neighbourhood.

Although one of our other reviewers noted that she preferred having 2 separate bar plots placed side-by-side, we plotted the dodge bar plot to explore this option and we found that the dodge bar facilitates comparisons much more easily and was what we implemented in our updated application.

## Backend Changes
Behind the scenes, we also improved our code by better encapsulating repeated code into functions. The code to show the neighbourhoods dropdown selection now reads the neighbourhood names directly from a CSV data file, so is less error-prone to potential hardcoded typos.

## Other Feedback
We also received some feedback to include data for the UBC area to the map and plot. Upon further research, we realized UBC is missing from our data sets because the Census does not consider the UBC area west of West Point Grey and Dunbar-Southlands as a "local area" of the City of Vancouver. The [City of Vancouver's website](https://vancouver.ca/news-calendar/areas-of-the-city.aspx) also does not consider UBC as a neighbourhood. Therefore, we decided to leave the app unchanged with regards to this suggestion.

## General Thoughts
Overall, the feedback we received helped to immensely improve our application, especially with regards to the layout and how we show information in the bar plot. Looking at the app now, the flow and layout makes a lot more sense and feels easier to both understand and use.
