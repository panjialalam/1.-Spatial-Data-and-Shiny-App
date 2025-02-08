library(tidyverse)
library(shiny)
library(shinyFeedback)
library(plotly)
library(sf)
library(RColorBrewer)

# Input list for the amount of incentive
select.amount <- c("Incentive Amount", "Total Cost", "Ratio")
all_communities <- neighborhoods <- c(
  "LOGAN SQUARE", "PORTAGE PARK", "WEST LAWN", "WEST RIDGE", 
  "ROGERS PARK", "BEVERLY", "CLEARING", "NORTH CENTER", 
  "AVONDALE", "BELMONT CRAGIN", "IRVING PARK", "AVALON PARK", 
  "HERMOSA", "AUSTIN", "SOUTH LAWNDALE", "ALBANY PARK", 
  "LAKE VIEW", "WEST TOWN", "SOUTH SHORE", "NORTH LAWNDALE", 
  "EDGEWATER", "LINCOLN SQUARE", "UPTOWN", "GARFIELD RIDGE", 
  "LOWER WEST SIDE", "NEW CITY", "NEAR NORTH SIDE", "NORTH PARK", 
  "NEAR WEST SIDE", "ARCHER HEIGHTS", "CHATHAM", "ASHBURN", 
  "WEST ENGLEWOOD", "HUMBOLDT PARK", "WASHINGTON PARK", "WEST PULLMAN", 
  "JEFFERSON PARK", "AUBURN GRESHAM", "MCKINLEY PARK", "MOUNT GREENWOOD", 
  "EAST GARFIELD PARK", "HYDE PARK", "WEST GARFIELD PARK", "BRIDGEPORT", 
  "GRAND BOULEVARD", "SOUTH CHICAGO", "WEST ELSDON", "EAST SIDE", 
  "OAKLAND", "GREATER GRAND CROSSING", "WOODLAWN", "ENGLEWOOD", 
  "LINCOLN PARK", "BURNSIDE", "BRIGHTON PARK", "DUNNING", 
  "ROSELAND", "DOUGLAS", "NEAR SOUTH SIDE", "FOREST GLEN", 
  "KENWOOD", "CALUMET HEIGHTS", "MORGAN PARK", "SOUTH DEERING", 
  "FULLER PARK", "MONTCLARE", "ARMOUR SQUARE", "NORWOOD PARK", 
  "LOOP", "PULLMAN", "RIVERDALE", "HEGEWISCH", 
  "GAGE PARK", "CHICAGO LAWN", "WASHINGTON HEIGHTS", "OHARE", 
  "EDISON PARK"
)

ui <- fluidPage(
  
  titlePanel("Financial Incentive Projects - Small Business Improvement Fund (SBIF)"),
  
  useShinyFeedback(),
  sidebarLayout(
    sidebarPanel(
      img(src = "https://design.chicago.gov/assets/img/seals/1990-color.png",
          height = 100,
          width = 100),
      radioButtons(inputId = "incentive",
                   label = "Choose the amount you want to know.",
                   choices = select.amount,
                   selected = "0"),
      selectInput(inputId = "colorblind",
                  label = "Do you have any color blindness issues?",
                  choices = NULL),
      textInput(inputId = "communities",
                label = "Write one community name with all capital letter (UPPER)",
                placeholder = "HYDE PARK")
    ), 
    
    mainPanel(
      
      tabsetPanel(
        tabPanel("Map", plotOutput("choro")),
        tabPanel("Summary", verbatimTextOutput("summary"))
      )
    )
  )
)

server <- function(input, output) {
  path <- "/Users/panjialalam/Documents/GitHub/1.-Spatial-Data-and-Shiny-App/"
  
  data <- read_csv(
    paste0(path, "incentive_data_clean.csv"))
  boundaries <- st_read(
    paste0(path, "geo_export_57b09135-4651-4079-841b-cb0c27642621.shp")) |>
    st_transform(4269)
  
  data_updated <- reactive({
    data |>
      right_join(boundaries, by = "community") |>
      select(input$incentive, community, geometry)
  })
  
  # Add a dynamic detail
  observeEvent(req(input$incentive %in% names(data_updated())), {
    cblind_status <- c("No", "Yes")
    updateSelectInput(inputId = "colorblind",
                      choices = cblind_status)
  })
  
  data_sf <- reactive({
    st_sf(data_updated())
  })
  
  # Create the color palettes
  mn_palette <- c("lightblue", "blue", "darkblue")
  
  cb_palette <- c(palette.colors(palette = "Okabe-Ito"))
  
  selected_palette <- reactive({
    if (input$colorblind == "Yes") {
      cb_palette
    } else {
      mn_palette
    }
  })
  
  chosen_community <- reactive({
    is_correct <- input$communities %in% all_communities
    feedbackWarning("communities", !is_correct, "Please enter a correct community area name")
    req(is_correct)
    
    comm_filter <- data_sf() |> filter(community == input$communities)
    summary(comm_filter)
  })
  
  # Output choropleth
  output$choro <- renderPlot({
    req(input$incentive %in% names(data_sf()))
    req(input$communities %in% all_communities)
    
    ggplot() +
      geom_sf(data = data_sf(), aes(fill = .data[[input$incentive]])) +
      scale_fill_gradientn(colors = selected_palette()) +
      labs(
        title = paste0("Choropleth Map of ", input$incentive, " in Chicago")
      )
  })
  
  output$summary <- renderPrint({
    chosen_community()
  })
  
}

shinyApp(ui = ui, server = server)
