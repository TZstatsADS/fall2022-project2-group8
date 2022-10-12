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
  
  write.csv(df_post_2018, "Rodent_Inspection_post_2018.csv")
}

set.seed(5243)

df = read.csv("../data/Rodent_Inspection_post_2018.csv")
df = df %>% 
  mutate(region=as.character(zip_code)) %>%
  mutate(inspection_date = strptime(inspection_date,"%m/%d/%Y %H:%M:%S")) %>%
  mutate(year = year(inspection_date)) %>%
  mutate(month = month(inspection_date)) 
  
if(!(file.exists("../data/df_post_2020.csv"))){
  df_post_2020 = df %>% 
    filter(year(inspection_date) >= 2020) %>%
    sample_n(50000) 
  write.csv(df_post_2020, "../data/df_post_2020.csv")
}

if(!(file.exists("../data/df_pre_2020.csv"))){
df_pre_2020 = df %>% 
  filter(year(inspection_date) < 2020) %>%
  sample_n(50000)
write.csv(df_pre_2020, "../datadf_pre_2020.csv")
}

df_pre_2020 = read.csv("../data/df_pre_2020.csv")
df_pre_2020 = df_pre_2020 %>% 
  mutate(region=as.character(zip_code)) 
df_post_2020 = read.csv("../data/df_post_2020.csv")
df_post_2020 = df_post_2020 %>% 
  mutate(region=as.character(zip_code)) 


df_pre_2020$inspection_date_month_yr=format(as.Date(df_pre_2020$inspection_date), "%Y-%m")

df_post_2020$inspection_date_month_yr=format(as.Date(df_post_2020$inspection_date), "%Y-%m")

if(!(file.exists("../data/Electic_post_2018.csv"))){
  elec = read.csv("../data/Electric_Consumption.csv")
  elec_post_2018 = elec %>% 
    set_names(tolower(names(elec))) %>%
    filter(year(strptime(revenue.month,"%Y-%M")) >= 2018) 
  
  write.csv(elec_post_2018, "../data/Electic_post_2018.csv")
}


energy = read.csv("../data/Electic_post_2018.csv")


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


shinyServer(function(input, output) {
  
  ## Map Tab section
  output$left_map <- renderPlot({
    if (input$inspection_type =='Overall' & input$result=="Overall") {
      leaflet_plt_df = df_pre_2020 %>% 
        group_by(region) %>%
        summarise(
          value = n()
        ) 
    } else if(input$inspection_type != "Overall"){
      leaflet_plt_df = df_pre_2020 %>% 
        filter(inspection_type == input$inspection_type) %>%
        group_by(region) %>%
        summarise(
          value = n()
        ) 
    }else if(input$result != "Overall"){
      leaflet_plt_df = df_pre_2020 %>% 
        filter(result == input$result) %>%
        group_by(region) %>%
        summarise(
          value = n()
        ) 
    }else{
      leaflet_plt_df = df_pre_2020 %>%
        filter(inspection_type == input$inspection_type) %>%
        filter(result == input$result) %>% 
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
    if (input$inspection_type =='Overall' & input$result=="Overall") {
      leaflet_plt_df = df_post_2020 %>% 
        group_by(region) %>%
        summarise(
          value = n()
        ) 
    } else if(input$inspection_type != "Overall"){
      leaflet_plt_df = df_post_2020 %>% 
        filter(inspection_type == input$inspection_type) %>%
        group_by(region) %>%
        summarise(
          value = n()
        ) 
    }else if(input$result != "Overall"){
      leaflet_plt_df = df_post_2020 %>% 
        filter(result == input$result) %>%
        group_by(region) %>%
        summarise(
          value = n()
        ) 
    }else{
      leaflet_plt_df = df_post_2020 %>%
        filter(inspection_type == input$inspection_type) %>%
        filter(result == input$result) %>% 
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
    df_pre_covid = df_pre_2020 %>% 
      filter(inspection_date >= input$inspection_date[1] & inspection_date <= input$inspection_date[2])
    df_post_covid = df_post_2020 %>%
      filter(inspection_date >= input$inspection_date[1] & inspection_date <= input$inspection_date[2])
    
    if(input$inspection_type != "Overall"){
      df_pre_covid = df_pre_covid %>% 
        filter(inspection_type == input$inspection_type)
      df_post_covid = df_post_covid %>% 
        filter(inspection_type == input$inspection_type)
    }
    if(input$result != "Overall"){
      df_pre_covid = df_pre_covid %>% 
        filter(result == input$result)
      df_post_covid = df_post_covid %>% 
        filter(result == input$result)
    }
    
    df_pre_covid$time = "Pre-covid"
    df_post_covid$time = "Post-covid"
    df_combined = rbind(df_pre_covid, df_post_covid)
    if(input$borough == "Overall"){
      ggplot(df_combined, aes(x = as.factor(borough),fill=time)) +
        geom_bar(stat = "count",position = position_dodge()) +
        xlab("Borough") +
        ylab("Count") +
        ggtitle("Bar Chart")
    }else{
      df_combined = df_combined %>% 
        filter(borough == input$borough)
      ggplot(df_combined, aes(x = as.factor(borough),fill=time)) +
        geom_bar(stat = "count", position = position_dodge()) +
        xlab("Borough") +
        ylab("Count") +
        ggtitle("Bar Chart")
    }
  })
  
  output$barPlot2 = renderPlot({

    df_pre_covid = df_pre_2020 %>% 
      filter(inspection_date >= input$inspection_date[1] & inspection_date <= input$inspection_date[2]) 
    df_post_covid = df_post_2020 %>%
      filter(inspection_date >= input$inspection_date[1] & inspection_date <= input$inspection_date[2]) 


    if(input$inspection_type != "Overall"){
      df_pre_covid = df_pre_covid %>% 
        filter(inspection_type == input$inspection_type)
      df_post_covid = df_post_covid %>% 
        filter(inspection_type == input$inspection_type)
    }
    if(input$result != "Overall"){
      df_pre_covid = df_pre_covid %>% 
        filter(result == input$result)
      df_post_covid = df_post_covid %>% 
        filter(result == input$result)
    }
    

    if(input$borough == "Overall"){
      df_pre_covid = df_pre_covid%>% 
        group_by(year,month) %>% 
        summarise(total = n())
      df_pre_covid$x = paste(df_pre_covid$year, df_pre_covid$month,sep='-')
      
      df_post_covid = df_post_covid%>% 
        group_by(year,month) %>% 
        summarise(total = n())
      df_post_covid$x = paste(df_post_covid$year, df_post_covid$month,sep='-')
      
      df_pre_covid$time = "Pre-covid"
      df_post_covid$time = "Post-covid"
      df_combined = rbind(df_pre_covid, df_post_covid)
      
      ggplot(df_combined, aes(x = as.Date(paste(x,"-01",sep="")),y = total, color=time)) +
        geom_smooth()+
        xlab("Borough") +
        ylab("Count") +
        ggtitle("Run Chart")
    }else{
      df_pre_covid = df_pre_covid %>% 
        filter(borough == input$borough) %>%
        group_by(year,month) %>% 
        summarise(total = n())
      df_pre_covid$x = paste(df_pre_covid$year, df_pre_covid$month,sep='-')
      
      df_post_covid = df_post_covid%>% 
        filter(borough == input$borough) %>%
        group_by(year,month) %>% 
        summarise(total = n())
      df_post_covid$x = paste(df_post_covid$year, df_post_covid$month,sep='-')
      
      df_pre_covid$time = "Pre-covid"
      df_post_covid$time = "Post-covid"
      df_combined = rbind(df_pre_covid, df_post_covid)
      
      ggplot(df_combined, aes(x = as.Date(paste(x,"-01",sep="")),y = total, color=time)) +
        geom_smooth()+
        xlab("Borough") +
        ylab("Count") +
        ggtitle("Run Chart")
    }
  })
  

  
  output$plotgraph1 = renderPlot({
    tmp = df_pre_2020_group %>% 
      filter(borough == input$borough2)
    ggplot(tmp, aes(x =inspection_date_month_yr,y=n,group = 1)) +
      geom_line()+
      xlab("Year") +
      ylab("Count") + scale_x_discrete(guide = guide_axis(angle = 90))+
      ggtitle("Count of Rodent complains Precovid")
  })
  
  output$plotgraph2 <- renderPlot({
    tmp = df_post_2020_group %>% 
      filter(borough == input$borough2)
    ggplot(tmp, aes(x =inspection_date_month_yr,y=n,group = 1)) +
      geom_line()+
      xlab("Year") +
      ylab("Count") + scale_x_discrete(guide = guide_axis(angle = 90))+
      ggtitle("Count of Rodent complains Post covid")
  })
  
  output$plotgraph3 <- renderPlot({
    tmp = energy_pre_2020_group %>% 
      filter(borough == toupper(input$borough2))
    ggplot(tmp, aes(x =revenue.month,y=sum_consumption..kwh,group=1)) +geom_line()+
      xlab("Year") +
      ylab("sum_consumption..kwh") + scale_x_discrete(guide = guide_axis(angle = 90))+
      ggtitle("Electricity Precovid")
  })
  
  output$plotgraph4 <- renderPlot({
    tmp = energy_post_2020_group %>% 
      filter(borough == toupper(input$borough2))
    ggplot(tmp, aes(x =revenue.month,y=sum_consumption..kwh,group=1)) +geom_line()+
      xlab("Year") +
      ylab("sum_consumption..kwh") + scale_x_discrete(guide = guide_axis(angle = 90))+
      ggtitle("Electricity Postcovid")
    

  })
  
  output$correlation <- renderDataTable({
    energy_subset_pre_2020=energy_pre_2020_group %>% 
      filter(borough == toupper(input$borough2))
    energy_subset_post_2020=energy_post_2020_group %>% 
      filter(borough == toupper(input$borough2))
    df_subset_pre_2020= df_pre_2020_group %>% 
      filter(borough == input$borough2)
    df_subset_post_2020= df_post_2020_group%>% 
      filter(borough == input$borough2)
    colnames(energy_subset_pre_2020)[which(names(energy_subset_pre_2020) == "revenue.month")] <- "date"
    colnames(energy_subset_post_2020)[which(names(energy_subset_post_2020) == "revenue.month")] <- "date"
    colnames(df_subset_pre_2020)[which(names(df_subset_pre_2020) == "inspection_date_month_yr")] <- "date"
    colnames(df_subset_post_2020)[which(names(df_subset_post_2020) == "inspection_date_month_yr")] <- "date"
    merge_subset_post_2020=merge(df_subset_post_2020 ,energy_subset_post_2020,by=c("date"))
    merge_subset_pre_2020=merge(df_subset_pre_2020 ,energy_subset_pre_2020,by=c("date"))
    merge_subset_pre_2020=merge_subset_pre_2020[c(1,3,5:8)]
    merge_subset_post_2020=merge_subset_post_2020[c(1,3,5:8)]
    
    merge_heatmap_data=merge_subset_pre_2020[,2:ncol(merge_subset_pre_2020)]
    colnames(merge_heatmap_data)[which(names(merge_heatmap_data) == "n")] <- "Rodents_count"
    
    cor(as.matrix(merge_heatmap_data))
  })
})