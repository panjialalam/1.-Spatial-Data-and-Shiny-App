library(tidyverse)
library(sf)
library(ggplot2)

# Load the data
path <- "/Users/panjialalam/Documents/GitHub/1.-Spatial-Data-and-Shiny-App/"

boundaries <- st_read(
  file.path(path, "geo_export_57b09135-4651-4079-841b-cb0c27642621.shp"))

incentive <- read.csv(
  paste0(path, "Financial_Incentive_Projects_-_Small_Business_Improvement_Fund__SBIF__20240130.csv"))

energy <- read.csv(
  paste0(path, "Chicago_Energy_Benchmarking_20240201.csv"))

# Data cleaning
incentive  <- incentive |> select(c(COMMUNITY.AREA, INCENTIVE.AMOUNT, TOTAL.PROJECT.COST)) |>
  mutate(COMMUNITY.AREA = str_to_upper(COMMUNITY.AREA),
         Ratio = if_else(TOTAL.PROJECT.COST == 0,
                         NA_real_, INCENTIVE.AMOUNT / TOTAL.PROJECT.COST)) |>
  rename("Incentive Amount" = INCENTIVE.AMOUNT,
         "Total Cost" = TOTAL.PROJECT.COST,
         community = COMMUNITY.AREA)

energy <- energy |> select(c(Community.Area, Electricity.Use..kBtu.,
                             Natural.Gas.Use..kBtu., Total.GHG.Emissions..Metric.Tons.CO2e.)) |>
  mutate(Community.Area = str_to_upper(Community.Area)) |>
  filter(Community.Area != "") |>
  rename("Electricity_Use" = Electricity.Use..kBtu.,
         "Natural_Gas_Use" = Natural.Gas.Use..kBtu.,
         "GHG_Emissions" = Total.GHG.Emissions..Metric.Tons.CO2e.,
         community = Community.Area) |>
  group_by(community) |>
  summarize(
    "Avg Electricity Use" = mean(Electricity_Use, na.rm = TRUE),
    "Avg Natural Gas Use" = mean(Natural_Gas_Use, na.rm = TRUE),
    "Avg GHG Emissions" = mean(GHG_Emissions, na.rm = TRUE)
  )

boundaries <- st_transform(boundaries, 4269)

# Write the data to csv to create the shiny app
write_csv(incentive, paste0(path, "incentive_data_clean.csv"))
write_csv(energy, paste0(path, "energy_data_clean.csv"))

# Join the data
incentive <- incentive |>
  right_join(boundaries, by = "community")

energy <- energy |>
  right_join(boundaries, by = "community")

# Prepare for the maps
incentive_sf <- st_sf(incentive)
energy_sf <- st_sf(energy)

# Create a function to generate the choropleth map
gen_choro <- function(df, variable) {
  med <- median(df[[variable]], na.rm = TRUE)

  # Generate the choropleth map
  ggplot() +     
    geom_sf(data = df, aes(fill = .data[[variable]]), alpha = 1) +
    scale_fill_gradient2(low = "white", 
                         mid = "lightblue", 
                         high = "darkblue", 
                         midpoint = med,
                         na.value = "grey50",
                         ) +
    labs(
      title = paste0("Choropleth Map of ", variable, " in Chicago")
    ) +
    theme_minimal()
  }

# Test the function
incentive_choropleth <- gen_choro(incentive_sf, "Incentive Amount")
incentive_choropleth 

energy_choropleth <- gen_choro(energy_sf, "Avg Electricity Use")
energy_choropleth 

# Save the maps
ggsave(paste0(path, "Pic 1 Incentive Data.jpg"), plot = incentive_choropleth)
ggsave(paste0(path, "Pic 2 Energy Data.jpg"), plot = energy_choropleth)
