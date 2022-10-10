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
                        tags$h2("Summary")
                        #setBackgroundImage(src = "https://images6.alphacoders.com/105/1051726.jpg")
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
                            plotOutput("barPlot1"),
                            plotOutput("barPlot2"),
                            plotOutput("barPlot3"),
                          )
                        )
                      )
             ),
             
             tabPanel("Appendix", 
                      icon = icon("circle-info"),
                      fluidPage( 
               # Data source
               HTML(
                 "<h2> Data Sources </h2>
                <h4> <p><li>NYC Rodent Inspection Data: <a href='https://data.cityofnewyork.us/Health/Rodent-Inspection/p937-wjvj'>NYC Rodent Inspection Dataset</a></li></p></h4>
                 "
               ),
               
               titlePanel("Disclaimers"),
               
               # Summary
               HTML(
                 " <p>We drew our business insights from NYC Open data.</p>",
                ),
               
               titlePanel("Acknowledgement  "),
               
               HTML(
                 " <p>This application is built using R shiny app.</p>",
                 "<p>The following R packages were used in to build this RShiny application:</p>
                <li>Shinytheme</li>
                <li>Tidyr</li>
                <li>ggplot2</li>
                <li>choroplethrZip</li>"
               ),
               
               titlePanel("Contacts"),
               
               HTML(
                 " <p>For more information please feel free to contact</p>",
                 " <p>Kim, Woonsup wk2371@columbia.edu </p>",
                 " <p>Limaye, Dhruv djl2187@columbia.edu</p>",
                 " <p>Sinha, Shreya ss6415@columbia.edu </p>",
                 " <p>Tu, Zhongcheng zt2286@columbia.edu</p>",
                 " <p>Xie, Peng px2143@columbia.edu</p>")
             )) # end of tab
             
             
  ) #navbarPage closing  
) #Shiny UI closing    