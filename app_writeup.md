# Vancouver Property Analysis Application Summary

![](screenshots/app_main.png)

The main page of the app features a map of Vancouver with individual neighbourhoods colour-coded based on the size of an affordability gap in that region (please see our proposal for a definition of "affordability gap"). We chose a choropleth map because it clearly highlights differences across various regions of the city.

 Neighbourhoods can be colour-coded based on a different metric (property value or income), by clicking one of the other tabs above the map.

For example, in the screenshot below, we changed the map to colour neighbourhoods based on property value. Using this view, we can easily see the areas of the city with the highest property values in dark green. If we mouse over a neighbourhood, we can see more details in the hover box, including the name of the neighbourhood, and the average and median property values (in CAD $) in that region.

![](screenshots/prop_val_map.png)

To further explore a neighbourhood in detail, users can select a neighbourhood from the first dropdown on the left, which updates the bar plots and summary statistics below the map.

![](screenshots/city_dropdown.png)

 The bar plot on the right is neighbhourhood-specific and shows the distribution of a certain socio-demographic variable that can be selected by the user in the second dropdown. The bar plot on the left is Vancouver-wide and shows the same information as summarized for all regions in the Vancover Central Metropolitan Area ("Vancouver CMA").

 ![](screenshots/barplots.png)

By presenting these 2 sections side-by-side, users can clearly see and compare age and other household demographics of a specific neighbhourhood with the rest of Vancouver. This helps to answer questions like:

* Are homes in West Point Grey more expensive than homes in the rest of Vancouver on average?
* How big is this difference?
* What is the average/median income of people living in Downtown versus the rest of Vancouver?
* How large of an affordability gap is there specifically in South Cambie? Is this gap worse than generally in Vancouver?

To facilitate these comparisons, we facet on location but keep the formatting in this section consistent as the user changes other selections, like the socio-econonic or neighbourhood variables.

One deviation from our initial app mockup is that instead of showing the individual property records in a table at the bottom of the app's main page, we moved this view to a high-level tab that can be selected.

 ![](screenshots/records_tab.png)

The rationale for this change is that if the table were located near the bottom, it will likely be missed by most users. Also, not all users may find this level of detail useful so instead of placing it on the main screen, we still provide the option to see this view in a separate tab.
