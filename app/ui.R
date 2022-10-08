
if (!require("shiny")) {
  install.packages("shiny")
  library(shiny)
}
if (!require("shinyWidgets")) {
  install.packages("shinyWidgets")
  library(shinyWidgets)
}
if (!require("shinythemes")) {
  install.packages("shinythemes")
  library(shinythemes)
}
if (!require("leaflet")) {
  install.packages("leaflet")
  library(leaflet)
}
if (!require("leaflet.extras")) {
  install.packages("leaflet.extras")
  library(leaflet.extras)
}

# Define UI for application that draws a histogram
shinyUI(
  navbarPage(strong("Rodents in New York",style="color: white;"), 
             theme=shinytheme("flatly"), # select your themes https://rstudio.github.io/shinythemes/
             #------------------------------- tab panel - Homepage ---------------------------------
             tabPanel("Homepage",
                      icon = icon("house-user"),
                      fluidPage(
                            tags$h2("Summary"),
                            setBackgroundImage(src = "https://images6.alphacoders.com/105/1051726.jpg")
                          )
                
                    ),
             
             #------------------------------- tab panel - Maps ---------------------------------
             tabPanel("Map",
                      icon = icon("map-location-dot"), #choose the icon for
                      div(class = 'outer',
                          # side by side plots
                          fluidRow(
                            splitLayout(cellWidths = c("50%", "50%"), 
                                        plotOutput("left_map",width="100%",height=800),
                                        plotOutput("right_map",width="100%",height=800))),
                          #control panel on the left
                          absolutePanel(id = "control", class = "panel panel-default", fixed = TRUE, draggable = TRUE,
                                        top = 200, left = 50, right = "auto", bottom = "auto", width = 250, height = "auto",
                                        tags$h4('Rodents Inspection Comparison'), 
                                        tags$br(),
                                        tags$h5('Pre-covid(Left) Post-covid(Right)'), 
                                        prettyRadioButtons(
                                          inputId = "inspection_type",
                                          label = "Inspection type:", 
                                          choices = c("Overall", 
                                                      "BAIT", 
                                                      "Compliance",
                                                      "Initial",
                                                      "CLEAN_UPS",
                                                      "STOPPAGE"),
                                          inline = TRUE, 
                                          status = "danger",
                                          fill = TRUE
                                        ),
                                                    
                                        # selectInput('adjust_weather',
                                        #             label = 'Adjust for Weather',
                                        #             choices = c('Yes','No'), 
                                        #             selected = 'Yes'
                                        #             ),
                                        style = "opacity: 0.80"
                                        
                          ), #Panel Control - Closing
                      ) #Maps - Div closing
             ), #tabPanel maps closing
             
             #------------------------------- tab panel - Maps ---------------------------------
             tabPanel("Bar plot", 
                     fluidPage(
                              titlePanel("Bar Plot"),
                              sidebarLayout(
                               
                               sidebarPanel(
                                 selectInput(inputId = "Borough",
                                             label = "Borough:",
                                             choices = c("Manhattan", 
                                                         "Bronx",
                                                         "Brooklyn", 
                                                         "Queens", 
                                                         "Staten Island")),
                                 
                                 selectInput(inputId = "Inspection_type",
                                             label = "Inspection type:",
                                             choices = c("Overall", 
                                                         "BAIT", 
                                                         "Compliance",
                                                         "Initial",
                                                         "CLEAN_UPS",
                                                         "STOPPAGE")),
                                 numericInput("obs", "lines", 5)
                                 
                               ),
                               
                              mainPanel(
                                  
                                )
                             )
                )
             ),
             
             
  ) #navbarPage closing  
) #Shiny UI closing    
