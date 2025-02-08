=== CHOROPLETH MAP OF CHICAGO ===

I chose two datasets which are Financial Incentive Projects - Small Business Improvement Funds (SBIF) and Chicago Energy Benchmarking. Both datasets included a community area of Chicago as a variable to join with the geometry data. For the geometry data, I utilized the community area boundary containing each community in the city.

The first step was to clean the Chicago data sets especially selecting the required variables, reformatting the column names, and for the energy data, I calculated the mean value for each selected variable in every community. I added a ratio variable for the incentive dataset which are the share of incentive amount divided by the total cost of a project. I did the average to make the data reading faster when generating the choropleth map because this data set is large. For all the cleaned data sets, I save them in CSV format which will be utilized to create the shiny app.

To generate the maps, I constructed a function with a syntax consisting of the data frame and a specific variable as the basis for generating the gradient colors. The gradient color is based on that one variable put in the function and I utilized the scale_fill_gradient2 function which enables me to put the low, mid, and high colors for lighter and darker colors respectively. As the midpoint of color, I prepared a line of code to calculate the median of the selected variable. Finally, I saved both maps as pictures in my directory in JPEG format.

Online sources:

•	Financial Incentive data: https://data.cityofchicago.org/Community-Economic-Development/Financial-Incentive-Projects-Small-Business-Improv/etqr-sz5x/about_data

•	Energy Benchmarking data: https://data.cityofchicago.org/Environment-Sustainable-Development/Chicago-Energy-Benchmarking/xq83-jr8c/about_data

•	Scale fill gradient: https://ggplot2.tidyverse.org/reference/scale_gradient.html

-----------------------------------------------------------------------------------------------------------------------

=== A MAP-BASED SHINY APP USING INCENTIVE DATA OF CHICAGO ===

I use the financial incentive data. I plan to create an app to show a choropleth in which the colours are changed based on the specific variables that I choose, which are the Incentive Amount, the Total Cost, and the Ratio. In addition, the user can change the colour gradient type based on a colour-blindness condition. This will change the colours based on the Okabe-Ito colour palette which is color blind friendly. I prepared two palettes which are mn_palette and cb_palette to accommodate users with color-blind.

In the UI part, I used a radio button to select the type of incentives and a select input to choose between Yes and No for the condition of the colour blind. Then, I applied a dynamic mechanism in which the user must choose one type of variable first before selecting the colour-blindness condition. The main output of the shiny app is a choropleth map of Chicago which can be changed depending on two conditions.

In addition, I add a textInput function where the user can get information about the specific variable’s summary in the other tab. The user must type the correct community area using upper letter (capital) characters and perfectly correct. If it is not correct, the choropleth map of Chicago and the summary will not appear. This will result in a warning message if not correctly typed, for example writing HYDE PARK as HYDEPARK or Hyde Park.

Internet sources:

•	Okabe and Ito (2008) color palette for color blindness: https://cran.r-project.org/web/packages/ggokabeito/ggokabeito.pdf

•	City of Chicago logo: https://design.chicago.gov/all
