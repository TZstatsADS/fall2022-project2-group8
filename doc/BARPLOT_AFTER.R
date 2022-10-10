library(shiny)
library(ggplot2)
setwd("/Users/shreyasinha/Desktop/Applied_data_science/rodent_repo/fall2022-project2-group8/output")
before_covid_data <- read.csv("before_covid_data.csv")



library(shiny)
library(ggplot2)


#after_covid_data <- read.csv("after_covid_data.csv")

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
        plotOutput("plotgraph4")

        # )
      )
    )
  )
))


s <- shinyServer(function(input, output, session) {
  output$plotgraph1 <- renderPlot({
    ggplot(before_covid_data, aes(x = factor(BOROUGH)), fill = I("red")) +
      geom_bar(stat = "count", colour = "red", xlab = "Borough") +
      xlab("Borough") +
      ylab("Count") +
      ggtitle("Count of Borough")
  })

  output$plotgraph2 <- renderPlot({
    # Plot
    ggplot(before_covid_data, aes(x = factor(INSPECTION_TYPE)), col = "blue", fill = I("blue"), xlab("Inspection_type")) +
      geom_bar(stat = "count", colour = "blue") +
      xlab("Inspection_type") +
      ylab("Count") +
      ggtitle("Count of Inspection_type")
  })

  output$plotgraph3 <- renderPlot({
    # Plot
    ggplot(before_covid_data, aes(x = factor(JOB_PROGRESS)), col = "yellow", fill = I("yellow"), xlab("Job_progress")) +
      geom_bar(stat = "count", colour = "yellow") +
      xlab("Job_progress") +
      ylab("Count") +
      ggtitle("Count of Job progress")
  })

  output$plotgraph4 <- renderPlot({
    # Plot
    ggplot(after_covid_data, aes(x = factor(RESULT)), col = "green", fill = I("green"), xlab("Result")) +
      geom_bar(stat = "count") +
      xlab("Result") +
      ylab("Count") +
      ggtitle("Count of Jon progress")
  })
})

# ui <- basicPage(h1("R shiny countplot"), plotOutput("plot"))
shinyApp(u, s)