if (!require("shiny")) {
  install.packages("shiny")
  library(shiny)
}
if (!require("leaflet")) {
  install.packages("leaflet")
  library(leaflet)
}
if (!require("leaflet.extras")) {
  install.packages("leaflet.extras")
  library(leaflet.extras)
}
if (!require("dplyr")) {
  install.packages("dplyr")
  library(dplyr)
}
if (!require("magrittr")) {
  install.packages("magrittr")
  library(magrittr)
}
if (!require("mapview")) {
  install.packages("mapview")
  library(mapview)
}
if (!require("leafsync")) {
  install.packages("leafsync")
  library(leafsync)
}
if (!require("choroplethr")) install.packages("choroplethr")
if (!require("devtools")) install.packages("devtools")

library(devtools)

if (!require("choroplethrZip")) 
  devtools::install_github('arilamstein/choroplethrZip@v1.5.0')

if (!require("ggplot2")) devtools::install_github("hadley/ggplot2")
if (!require("ggmap")) devtools::install_github("dkahle/ggmap")

library(lubridate)
library(tidyr)

if(!(file.exists("../data/Rodent_Inspection_post_2018.csv"))){
  df = read.csv("../data/Rodent_Inspection.csv")
  df_post_2018 = df %>% 
    set_names(tolower(names(df))) %>%
    drop_na() %>%
    filter(year(strptime(inspection_date,"%m/%d/%Y %H:%M:%S")) >= 2018) %>% 
    filter(zip_code > 0) 
  
  write.csv(df_post_2018, "../data/Rodent_Inspection_post_2018.csv")
}

set.seed(5243)

df = read.csv("../data/Rodent_Inspection_post_2018.csv")
df = df %>% 
  mutate(region=as.character(zip_code)) %>%
  mutate(inspection_date = strptime(inspection_date,"%m/%d/%Y %H:%M:%S"))


df_post_2020 = df %>% 
  filter(year(inspection_date) >= 2020) %>%
  sample_n(50000)

df_pre_2020 = df %>% 
  filter(year(inspection_date) < 2020) %>%
  sample_n(50000)


shinyServer(function(input, output) {
  
  ## Map Tab section
  output$left_map <- renderPlot({
    
    #adjust for weekday/weekend effect
    if (input$inspection_type =='Overall') {
      leaflet_plt_df = df_pre_2020 %>% 
        group_by(region) %>%
        summarise(
          value = n()
        ) 
    } 
    
    else{
      leaflet_plt_df = df_pre_2020 %>%
        filter(inspection_type == input$inspection_type) %>%
        group_by(region) %>%
        summarise(
          value = n()
        )
    }
    
    
    zip_choropleth(leaflet_plt_df,
                   title       = "Pre Covid Rodents Inspection",
                   legend      = "Number of inspections",
                   county_zoom = 36061)
    
    
    
  }) #left map plot
  
  output$right_map <- renderPlot({
    #adjust for weekday/weekend effect
    if (input$inspection_type =='Overall') {
      leaflet_plt_df = df_post_2020 %>% 
        group_by(region) %>%
        summarise(
          value = n()
        ) 
    } 
    
    else{
      leaflet_plt_df = df_post_2020 %>%
        filter(inspection_type == input$inspection_type) %>%
        group_by(region) %>%
        summarise(
          value = n()
        )
    }
    #initial the map to plot on
    
    
    zip_choropleth(leaflet_plt_df,
                   title       = "Post Covid Rodents Inspection",
                   legend      = "Number of inspections",
                   county_zoom = 36061)
    
  }) #right map plot
  
  
  ## Bar Plot
  output$barPlot1 = renderPlot({
    
  })
})