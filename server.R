library(shiny)
library(dplyr)
library(ggplot2)
library(DT)

# setwd("~/Desktop/INFO 201/Final-Project")
source(file = "scripts/dataframe.R")


shinyServer(function(input, output) {
  
  # Filter data based on selections
  output$table <- DT::renderDataTable(DT::datatable({
    data <- df
    if (input$building != "All") {
      data <- data[data$Building == input$building,]
    }
    if (input$course != "All") {
      data <- data[data$Course == input$course,]
    }
    if (input$lecturer != "All") {
      data <- data[data$Lecturer == input$lecturer,]
    }
    data
  }))
  
})
