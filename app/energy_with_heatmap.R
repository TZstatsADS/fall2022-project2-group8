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


df_post_2020 = df %>% 
  filter(year(inspection_date) >= 2020,year(inspection_date) < 2021) 

df_pre_2020 = df %>% 
  filter(year(inspection_date) < 2020 ,year(inspection_date) >=2019) 

df_pre_2020$inspection_date_month_yr=format(as.Date(df_pre_2020$inspection_date), "%Y-%m")

df_post_2020$inspection_date_month_yr=format(as.Date(df_post_2020$inspection_date), "%Y-%m")


# ENERGY

if(!(file.exists(".//data//Electic_post_2018.csv"))){
  elec = read.csv("./data/Electric_Consumption.csv")
  elec_post_2018 = elec %>% 
    set_names(tolower(names(elec))) %>%
    filter(year(strptime(elec$Revenue.Month,"%Y-%M")) >= 2018) 
  
  write.csv(elec_post_2018, "./data/Electic_post_2018.csv")
}




energy = read.csv("./data/Electic_post_2018.csv")


energy_post_2020 = energy %>% 
  filter(year(strptime(energy$revenue.month,"%Y-%M")) >= 2020,year(strptime(energy$revenue.month,"%Y-%M")) < 2021)

energy_pre_2020 = energy %>% 
  filter(year(strptime(energy$revenue.month,"%Y-%M")) < 2020) 



energy_pre_2020_group=energy_pre_2020 %>%
  group_by(borough,revenue.month) %>%
  summarise(sum_consumption..kwh=sum(consumption..kwh.),sum_kwh.charges=sum(kwh.charges),
            sum_consumption..kw.=sum(consumption..kw.),
            kw.charges = sum(kw.charges))%>%
  filter(year(strptime(revenue.month,"%Y-%M")) < 2020) 

energy_post_2020_group=energy_post_2020 %>%
  group_by(borough,revenue.month) %>%
  summarise(sum_consumption..kwh=sum(consumption..kwh.),sum_kwh.charges=sum(kwh.charges),sum_consumption..kw.=sum(consumption..kw.),
            kw.charges = sum(kw.charges))


df_pre_2020_group= df_pre_2020%>%
  group_by(inspection_date_month_yr,borough)%>%count()

df_post_2020_group= df_post_2020%>%
  group_by(inspection_date_month_yr,borough)%>%count()

energy_subset_pre_2020=energy_pre_2020_group[energy_pre_2020_group$borough %in% c("BRONX"), ]
energy_subset_post_2020=energy_post_2020_group[energy_post_2020_group$borough %in% c("BRONX"), ]
df_subset_pre_2020= df_pre_2020_group[df_pre_2020_group$borough %in% c("Bronx"), ]
df_subset_post_2020= df_post_2020_group[df_post_2020_group$borough %in% c("Bronx"), ]
colnames(energy_subset_pre_2020)[which(names(energy_subset_pre_2020) == "revenue.month")] <- "date"
colnames(energy_subset_post_2020)[which(names(energy_subset_post_2020) == "revenue.month")] <- "date"
colnames(df_subset_pre_2020)[which(names(df_subset_pre_2020) == "inspection_date_month_yr")] <- "date"
colnames(df_subset_post_2020)[which(names(df_subset_post_2020) == "inspection_date_month_yr")] <- "date"
merge_subset_post_2020=merge(df_subset_post_2020 ,energy_subset_post_2020,by=c("date"))
merge_subset_pre_2020=merge(df_subset_pre_2020 ,energy_subset_pre_2020,by=c("date"))
merge_subset_pre_2020=merge_subset_pre_2020[c(1,3,5:8)]
merge_subset_post_2020=merge_subset_post_2020[c(1,3,5:8)]

#HEATMAP
merge_heatmap_data=merge_subset_pre_2020[,2:ncol(merge_subset_pre_2020)]
colnames(merge_heatmap_data)[which(names(merge_heatmap_data) == "n")] <- "Rodents_count"


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
        plotOutput("heatmap")
        
        # )
      )
    )
  )
))



s <- shinyServer(function(input, output, session) {
  output$plotgraph1 <- renderPlot({
    ggplot(df_pre_2020_group[df_pre_2020_group$borough %in% c("Bronx"), ] , aes(x =inspection_date_month_yr,y=n,group = 1)) +
      geom_line()+
      xlab("Year") +
      ylab("Count") + scale_x_discrete(guide = guide_axis(angle = 90))+
      ggtitle("Count of Rodent complains Precovid")
  })
  
  output$plotgraph2 <- renderPlot({
    ggplot(df_post_2020_group[df_post_2020_group$borough %in% c("Bronx"), ] , aes(x =inspection_date_month_yr,y=n,group = 1)) +
      geom_line()+
      xlab("Year") +
      ylab("Count") + scale_x_discrete(guide = guide_axis(angle = 90))+
      ggtitle("Count of Rodent complains Post covid")
  })
  
  output$plotgraph3 <- renderPlot({
    ggplot(energy_pre_2020_group[energy_pre_2020_group$borough %in% c("BRONX"), ] , aes(x =revenue.month,y=sum_consumption..kwh,group=1)) +geom_line()+
           xlab("Year") +
           ylab("sum_consumption..kwh") + scale_x_discrete(guide = guide_axis(angle = 90))+
           ggtitle("Electricity Precovid")
  })
  
  output$plotgraph4 <- renderPlot({
    ggplot(energy_post_2020_group[energy_post_2020_group$borough %in% c("BRONX"), ] , aes(x =revenue.month,y=sum_consumption..kwh,group=1)) +geom_line()+
           xlab("Year") +
           ylab("sum_consumption..kwh") + scale_x_discrete(guide = guide_axis(angle = 90))+
           ggtitle("Electricity Postcovid")
    
  })

  
  output$heatmap = renderPlot({
    heatmap(cor(as.matrix(cor(as.matrix(merge_heatmap_data)))),col=colorRampPalette(brewer.pal(8,"Blues"))(3))
    legend(x="left", legend=c("min", "med", "max"),fill=colorRampPalette(brewer.pal(8,"Blues"))(3))
  
})
})
  
shinyApp(u, s)




