#setwd("")

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
if (!require("RColorBrewer")) install.packages("RColorBrewer")
library(RColorBrewer)

library(lubridate)
library(tidyr)

if(!(file.exists("./data/Rodent_inspection_post_2018.csv"))){
  df = read.csv("./data/Rodent_inspection.csv")
  df_post_2018 = df %>% 
    set_names(tolower(names(df))) %>%
    drop_na() %>%
    filter(year(strptime(inspection_date,"%m/%d/%Y %H:%M:%S")) >= 2018) %>% 
    filter(zip_code > 0) 
  
  write.csv(df_post_2018, "./data/Rodent_inspection_post_2018.csv")
}

set.seed(5243)

df = read.csv("./data/Rodent_inspection_post_2018.csv")
df = df %>% 
  mutate(region=as.character(zip_code)) %>%
  mutate(inspection_date = strptime(inspection_date,"%m/%d/%Y %H:%M:%S"))


df_post_2020_1 = df %>% 
  filter(year(inspection_date) >= 2020)
         #,year(inspection_date) < 2021) 

df_pre_2020_1 = df %>% 
  filter(year(inspection_date) < 2020)
         #,year(inspection_date) >=2019) 

df_pre_2020_1$inspection_date_month_yr=format(as.Date(df_pre_2020_1$inspection_date), "%Y-%m")

df_post_2020_1$inspection_date_month_yr=format(as.Date(df_post_2020_1$inspection_date), "%Y-%m")


#   RENTAL

if(!(file.exists(".//data//rentalIndex_post_2018.csv"))){
  ren = read.csv("./data/rentalIndex.csv")
  elec_post_2018 = ren %>% 
    set_names(tolower(names(ren))) %>%
    filter(year(strptime(ren$Month,"%Y-%M-%d")) >= 2018) 
  
  write.csv(Rental_post_2018, "./data/rentalIndex_post_2018.csv")
}




rental = read.csv("./data/rentalIndex_post_2018.csv")


rental_post_2020 = rental %>% 
  filter(year(strptime(month,"%Y-%M-%d")) >= 2020)

rental_pre_2020 = rental %>% 
  filter(year(strptime(month,"%Y-%M-%d")) < 2020) 






df_pre_2020_group_1= df_pre_2020_1%>%
  group_by(inspection_date_month_yr,borough)%>%count()

df_post_2020_group_1= df_post_2020_1%>%
  group_by(inspection_date_month_yr,borough)%>%count()

rental_subset_pre_2020=rental_pre_2020[,c(2,4)]
rental_subset_post_2020=rental_post_2020[,c(2,4)]
rental_subset_pre_2020$month=format(as.Date(rental_subset_pre_2020$month), "%Y-%m")
rental_subset_post_2020$month=format(as.Date(rental_subset_post_2020$month), "%Y-%m")

# Rodents
df_subset_pre_2020_1= df_pre_2020_group_1[df_pre_2020_group_1$borough %in% c("Manhattan"), ]
df_subset_post_2020_1= df_post_2020_group_1[df_post_2020_group_1$borough %in% c("Manhattan"), ]
colnames(df_subset_pre_2020_1)[which(names(df_subset_pre_2020_1) == "inspection_date_month_yr")] <- "date"
colnames(df_subset_post_2020_1)[which(names(df_subset_post_2020_1) == "inspection_date_month_yr")] <- "date"


# Rent
colnames(rental_subset_pre_2020)[which(names(rental_subset_pre_2020) == "month")] <- "date"
colnames(rental_subset_post_2020)[which(names(rental_subset_post_2020) == "month")] <- "date"

merge_rent_post_2020=merge(df_subset_post_2020_1 ,rental_subset_post_2020,by=c("date"))[c(1,3,4)]
merge_rent_pre_2020=merge(df_subset_pre_2020_1 ,rental_subset_pre_2020,by=c("date"))[c(1,3,4)]
##changing names
colnames(merge_rent_pre_2020)[which(names(merge_rent_pre_2020) == "n")] <- "Rodent_count"
colnames(merge_rent_pre_2020)[which(names(merge_rent_pre_2020) == "manhattan")] <- "Rent"
colnames(merge_rent_post_2020)[which(names(merge_rent_post_2020) == "n")] <- "Rodent_count"
colnames(merge_rent_post_2020)[which(names(merge_rent_post_2020) == "manhattan")] <- "Rent"

#HEATMAP
#merge_heatmap_data=merge_subset_pre_2020[,2:ncol(merge_subset_pre_2020)]
#colnames(merge_heatmap_data)[which(names(merge_heatmap_data) == "n")] <- "Rodents_count"


u <- shinyUI(fluidPage(
  titlePanel("Visualization of After Covid(2020-2022) Plot"),
  sidebarLayout(
    position = "left",
    sidebarPanel(
      "sidebar panel",
      checkboxInput("do2", "Make 2 plots", value = T)
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
        dataTableOutput('heatmap_table_pre_2020'),
        dataTableOutput('heatmap_table_post_2020')
        
        # )
      )
    )
  )
))



s <- shinyServer(function(input, output, session) {
  output$plotgraph1 <- renderPlot({
    ggplot(merge_rent_pre_2020 , aes(x =date,y=Rodent_count,group = 1)) +
      geom_line()+
      xlab("Year") +
      ylab("Count") + scale_x_discrete(guide = guide_axis(angle = 90))+
      ggtitle("Count of Rodent complains Precovid")
  })
  
  output$plotgraph2 <- renderPlot({
    ggplot(merge_rent_post_2020 , aes(x =date,y=Rodent_count,group = 1)) +
      geom_line()+
      xlab("Year") +
      ylab("Count") + scale_x_discrete(guide = guide_axis(angle = 90))+
      ggtitle("Count of Rodent complains Post covid")
  })
  
  output$plotgraph3 <- renderPlot({
    ggplot(merge_rent_pre_2020 , aes(x =date,y=Rent,group = 1)) +
      geom_line()+
      xlab("Year") +
      ylab("Count") + scale_x_discrete(guide = guide_axis(angle = 90))+  ggtitle("Rent Precovid")
  })
  
  output$plotgraph4 <- renderPlot({
    ggplot(merge_rent_post_2020 , aes(x =date,y=Rent,group = 1)) +
      geom_line()+
      xlab("Year") +
      ylab("Count") + scale_x_discrete(guide = guide_axis(angle = 90))+  ggtitle("Rent Postcovid")
  })
  
  output$heatmap_table_post_2020 = renderTable({cor(as.matrix(merge_rent_pre_2020[,c(2,3)] ))})
  output$heatmap_table_post_2020 = renderTable({cor(as.matrix(merge_rent_post_2020[,c(2,3)] ))})
 
  
    
 
})

shinyApp(u, s)

