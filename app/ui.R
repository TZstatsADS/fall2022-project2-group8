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
                      fluidRow(
                        div(
                          style = "height:300px;width:100%;padding:0 300px",
                          tags$img(src = "https://wallpaperaccess.com/full/247102.jpg", height = '300px', width = '100%')
                        )
                      ),
                      fluidRow(
                        div(
                          style = "height:300px;width:100%;padding:50px 300px",
                        column(width = 6, offset = 0,
                                      div(
                                          tags$h3("Introduction",style="text-align:center"),
                                          # Content
                                          tags$p("    Our team presents a vision for a property maintenance and extermination services company that helps residents of New York City understand the impacts of rodent infestations on energy consumption and the prevalence of rodent infestations in different regions in New York City. Rodent infestations can have many negative impacts on communities and can carry diseases, affect the safety of residents, and affect various essential utilities and processes in buildings including wiring, piping, sanitation systems, and heating systems. Thus, it is essential for residents of New York City to be aware of the levels of rodent infestations in their specific neighborhoods, the frequency of inspections conducted, and how the infestations can affect their energy costs.

​​We believe that these companies should rely on data driven models for their recommendations. Using open data from New York City, we present dashboards that creatively display rodent data and correlations to energy costs to make it easier to understand for NYC residents.
",style="font-size:18px")
                                      )
                          ),
                        column(width = 6, offset = 0,
                             div(       
                               tags$h3("Conclusion",style="text-align:center"),
                               # Content
                               tags$p("In a densely populated city like New York, the presence of large numbers of rodents is a common problem. Rodent infestations can cause many problems including health hazards, spread of disease, and property damage. With the changes and fluctuations in the housing and rent markets caused by the COVID-19 pandemic, it is especially important for New York city residents to understand how their properties and residences could be affected by the presence of rodents. It is also important for consumers to understand how accurate the rodent data is by understanding how recently the inspections for rodents were conducted. 
Therefore, as an extermination and property maintenance company, we sought to provide our consumers with data to understand rodent infestations in their neighborhoods and how it can affect their energy costs. We provided an interactive map of NYC to show the areas and neighborhoods where rodent infestations are most prevalent. Similarly, we displayed an interactive map that showed the prevalence of rodent inspections in each area. We also showed barplots of this data, and barplots and heat maps showing the correlation between rodent infestations and energy costs in the boroughs of New York City.
",style="font-size:18px")
                             )
                          )
                        )
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
                                        awesomeRadio(
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
                                        ),
                                        awesomeRadio(
                                          inputId = "result",
                                          label = "Result type:", 
                                          choices = c("Overall", 
                                                      "Bait applied", 
                                                      "Rat Activity",
                                                      "Passed",
                                                      "Failed for Other R",
                                                      "Cleanup done",
                                                      "Monitoring visit",
                                                      "Stoppage done"),
                                          inline = TRUE, 
                                          status = "danger",
                                        ),

                                        style = "opacity: 0.80"
                                        
                          ), #Panel Control - Closing
                      ) #Maps - Div closing
             ), #tabPanel maps closing
             
             #------------------------------- tab panel - EDA ---------------------------------
             tabPanel("Rodents Inspection EDA", 
                      icon = icon("chart-simple"),
                      fluidPage(
                        titlePanel("Rodents Inspection EDA"),
                        sidebarLayout(
                          
                          sidebarPanel(
                            selectInput(inputId = "borough",
                                        label = "Borough:",
                                        choices = c("Overall",
                                                    "Manhattan", 
                                                    "Bronx",
                                                    "Brooklyn", 
                                                    "Queens", 
                                                    "Staten Island")),
                            
                            selectInput(inputId = "inspection_type",
                                        label = "Inspection type:",
                                        choices = c("Overall", 
                                                    "BAIT", 
                                                    "Compliance",
                                                    "Initial",
                                                    "CLEAN_UPS",
                                                    "STOPPAGE")),
                            
                            selectInput(inputId = "result",
                                        label = "Result:",
                                        choices = c("Overall", 
                                                    "Bait applied", 
                                                    "Rat Activity",
                                                    "Passed",
                                                    "Failed for Other R",
                                                    "STOPPAGE done",
                                                    "Monitoring visit",
                                                    "Cleanup done"
                                                    )),
                            dateRangeInput(
                              inputId = "inspection_date",
                              label = "Inspection Date:",
                              start = "2018-01-01",
                              end = lubridate::today()
                              
                            ),

                          ),
                          
                          mainPanel(
                            plotOutput("barPlot1"),
                            plotOutput("barPlot2"),
                            plotOutput("barPlot3"),
                          )
                        )
                      )
             ),
             #------------------------------- tab panel -  ---------------------------------
             tabPanel("Energy",
                      icon = icon("solar-panel"),
                      fluidPage(
                        titlePanel("Visualization of Pre/Post Covid Plot"),
                        sidebarLayout(
                          position = "left",
                          sidebarPanel(
                            "sidebar panel",
                            selectInput(inputId = "borough2",
                                        label = "Borough:",
                                        choices = c(
                                                    "Manhattan", 
                                                    "Bronx",
                                                    "Brooklyn", 
                                                    "Queens", 
                                                    "Staten Island"))
                          ),
                          mainPanel(
                            "main panel",
                            fluidRow(
                              # splitLayout(
                              style = "border: 1px solid silver:", cellWidths = c(100, 100, 100),
                              plotOutput("plotgraph1"),
                              plotOutput("plotgraph2"),
                              plotOutput("plotgraph3"),
                              plotOutput("plotgraph4"),
                              dataTableOutput('correlation')
                              
                              # )
                            )
                          )
                        )
                      )
              ), # End tabPanel
             
             #------------------------------- tab panel - Appendix ---------------------------------
             tabPanel("Appendix", 
                      icon = icon("circle-info"),
                      fluidPage( 
               # Data source
              div(style="text-align:center",
               HTML(
                 "<h2> Data Sources </h2>
                <h4> <p><li>NYC Rodent Inspection Data: <a href='https://data.cityofnewyork.us/Health/Rodent-Inspection/p937-wjvj'>NYC Rodent Inspection Dataset</a></li></p></h4>
                <h4> <p><li>Electric Consumption And Cost Data: <a href='https://data.cityofnewyork.us/Housing-Development/Electric-Consumption-And-Cost-2010-Feb-2022-/jr24-e7cr'>Electric Consumption And Cost Dataset</a></li></p></h4>

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
                 " <p>Xie, Peng px2143@columbia.edu</p>"))
             )) # end of tab
             
             
  ) #navbarPage closing  
) #Shiny UI closing    