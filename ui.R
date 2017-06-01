library(shinydashboard)
library(shiny)
library(shinyAce)
library(ggplot2)
library(leaflet)
library(dplyr)
library(DT)
library(jsonlite)
library(plyr)
library(reshape2)
library(d3Tree)
library(stringr)
library(markdown)

# setwd("~/Documents/info201_sp17/Final-Project")
source(file = "scripts/dataframe.R")

sidebar <- dashboardSidebar(
  sidebarMenu(
    menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard")),
    menuItem("Registration & Filter", icon = icon("question"), tabName = "registration"),
    menuItem("Check for empty classroom", icon = icon("eye"), tabName = "check"),
    menuItem("Class Visualization", icon = icon("bar-chart-o"), tabName = "visual"),
    menuItem("Fun Fact!", icon = icon("grav"), tabName = "fun")
  )
)

body <- dashboardBody(
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "font.css"),
    tags$style(HTML('
    body {
      font-family: "Iosevka Slab", sans-serif;
    }
    h2, h5, span {
      font-family: "Georgia", Times, "Times New Roman", serif;
    }
    .main-header .logo {
      font-family: "Georgia", Times, "Times New Roman", serif;
      font-weight: bold;
      font-size: 20px;
    }

    p {
      font-family: "Georgia", Times, "Times New Roman", serif;
      font-size: 18px;
    }

    # img {
    #   height: 198px;
    #   width: 294px;
    # }
  '))),
  tabItems(
    tabItem(tabName = "dashboard",
            h2("Class Details for UW"),
            h4("Things you may not know"),
            img(src="logo.png",align = "right"),
            includeMarkdown("illustration.md")
    ),
    tabItem(tabName = "registration",
            h2("Registration & Filter"),
            fluidPage(
              fluidRow(
                column(4,
                       selectInput("building",
                                   "Buildings:",
                                   c("All",
                                     unique(as.character(df$Building))))
                ),
                column(4,
                       selectInput("course",
                                   "Courses:",
                                   c("All",
                                     unique(as.character(df$Course))))
                ),
                column(4,
                       selectInput("lecturer",
                                   "Lecturers:",
                                   c("All",
                                     unique(as.character(df$Lecturer))))
                )
              ),
              # Create a new row for the table.
              fluidRow(
                DT::dataTableOutput("vtable")
              )
            )

    ),
    tabItem(tabName = "check",
            h2("Check for empty classroom!"),
            bootstrapPage(
              leafletOutput("map", "100%", 400)
            )

    ),
    tabItem(tabName = "visual",
            h2("Class Visualization"),
            fluidRow(
              column(7,
                     hr(),
                     selectInput('in4', 'Options', filenames, selectize=TRUE)
              ),
              column(7,
                     uiOutput("Hierarchy"),
                     # verbatimTextOutput("results"),
                     # tableOutput("clickView"),
                     d3treeOutput(outputId="d3",width = '1200px',height = '800px')
              ),
              column(5,
                     tableOutput('table')
              )
            )
    ),
    tabItem(tabName = "fun",
            
            fluidPage(
              h2("Fun Facts about the UW classes!"),
              
              includeMarkdown("funfact.md"),
              plotlyOutput('pie')
            )
    )
  )
)

# Put them together into a dashboardPage
shinyUI(dashboardPage(
  dashboardHeader(title = "Navigation Bar"),
  sidebar,
  body
))