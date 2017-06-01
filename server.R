library(shiny)
library(dplyr)
library(DT)
library(ggplot2)
library(shinyAce)
library(jsonlite)
library(leaflet)
library(plyr)
library(reshape2)
library(d3Tree)
library(stringr)

setwd("~/Documents/info201_sp17/Final-Project")
source(file = "scripts/dataframe.R")
# a <- read.csv(file = "~/Documents/test.csv", na.strings=c(""), stringsAsFactors = FALSE)
# m <- 
shinyServer(function(input, output) {
  m <- reactive({
    pa <- "data/prereq/csv/aa.csv"
    a <- read.csv(file = pa, na.strings=c(""), stringsAsFactors = FALSE)
    x <- a%>%data.frame%>%mutate(Prereq = replace(Prereq,is.na(Prereq),"None"))%>%mutate(NEWCOL=NA)%>%distinct
  })
  
  output$Hierarchy <- renderUI({
    Hierarchy=names(m())
    Hierarchy=head(Hierarchy,-1)
    selectizeInput("Hierarchy","Tree Hierarchy",
                   choices = Hierarchy,multiple=T,selected = Hierarchy,
                   options=list(plugins=list('drag_drop','remove_button')))
  })

  network <- reactiveValues()

  observeEvent(input$d3_update,{
    network$nodes <- unlist(input$d3_update$.nodesData)
    activeNode<-input$d3_update$.activeNode
    if(!is.null(activeNode)) network$click <- jsonlite::fromJSON(activeNode)
  })

  observeEvent(network$click,{
    output$clickView<-renderTable({
      as.data.frame(network$click)
    },caption='Last Clicked Node',caption.placement='top')
  })


  TreeStruct=eventReactive(network$nodes,{
    df=m()
    if(is.null(network$nodes)){
      df=m()
    }else{

      x.filter=tree.filter(network$nodes,m())
      df=ddply(x.filter,.(ID),function(a.x){m()%>%filter_(.dots = list(a.x$FILTER))%>%distinct})
    }
    df
  })

  observeEvent(input$Hierarchy,{
    output$d3 <- renderD3tree({
      if(is.null(input$Hierarchy)){
        p=m()
      }else{
        p=m()%>%select(one_of(c(input$Hierarchy,"NEWCOL")))%>%unique
      }

      d3tree(data = list(root = df2tree(struct = p,rootname = 'A A'), layout = 'collapse'),activeReturn = c('name','value','depth','id'),height = 18)
    })
  })

  observeEvent(network$nodes,{
    output$results <- renderPrint({
      str.out=''
      if(!is.null(network$nodes)) str.out=tree.filter(network$nodes,m())
      return(str.out)
    })
  })
  
  output$table <- renderTable(expr = {
    TreeStruct()%>%select(-NEWCOL)
  })
  
  output$map <- renderLeaflet({
    leaflet() %>%
      addProviderTiles(providers$Esri.NatGeoWorldMap) %>%
      setView(lat = 47.656721, lng = -122.309054, zoom = 16) %>%
      addMarkers(lng = building$long, lat = building$lat, popup = building$full_name)
  })

  # Filter data based on selections
  output$vtable <- DT::renderDataTable(DT::datatable({
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
