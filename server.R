library(shiny)
library(dplyr)
library(DT)
library(ggplot2)
library(shinyAce)
library(jsonlite)
library(leaflet)
library(plyr)

setwd("~/Documents/info201_sp17/Final-Project")
source(file = "scripts/dataframe.R")


shinyServer(function(input, output) {
  output$map <- renderLeaflet({
    leaflet() %>% 
      addProviderTiles(providers$Esri.NatGeoWorldMap) %>% 
      addMarkers(lng = building$long, lat = building$lat, popup = building$name)
  })
  
  # Filter data based on selections
  output$table <- DT::renderDataTable(DT::datatable({
    data <- df_for_table
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