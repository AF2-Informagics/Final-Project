library(shinydashboard)
library(shiny)
library(shinyAce)

setwd("~/Documents/info201_sp17/Final-Project")
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
  tabItems(
    tabItem(tabName = "dashboard",
            h2("Dashboard tab content")
    ),
    
    tabItem(tabName = "registration",
            h2("Registration & Filter"),
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
              DT::dataTableOutput("table")
            )
    ),
    tabItem(tabName = "check",
            h2("Check for empty classroom!")
    ),
    tabItem(tabName = "visual",
            h2("Class Visualization"),
            tags$head(
              tags$script(type="text/javascript", src = "d3.v3.js"),
              tags$script(type="text/javascript", src ="d3.tip.js"),
              tags$script(type="text/javascript", src ="ggtree.js"),
              tags$link(rel = 'stylesheet', type = 'text/css', href = 'ggtree.css')
            ),
            
            fluidRow(
              column(width = 6,
                     selectInput("d3layout", "Choose a layout:", 
                                 choices = c("Radial" = "radial",
                                             "Collapsed" = "collapse",
                                             "Cartesian" = "cartesian")),
                     HTML("<div id=\"d3\" class=\"d3plot\"><svg /></div>")
              ),
              column(width = 6,
                     aceEditor("code", 
                               value="# Enter code to generate a ggplot here \n# Then click 'Send Code' when ready
                               p <- ggplot(mtcars, aes(mpg, wt)) + \n geom_point(colour='grey50', size = 4) + \n geom_point(aes(colour = cyl)) + facet_wrap(~am, nrow = 2)
                               # Visualize the 'built' version -- this is optional\nggplot_build(p)",
                               mode = "r", theme = "chrome", height = "100px", fontSize = 10),
                     actionButton("send", "Send code"),
                     plotOutput(outputId = "ggplot")
              )
            )
    ),
    tabItem(tabName = "fun",
            h2("Fun Facts about the UW classes!")
    )
  )
)

# Put them together into a dashboardPage
dashboardPage(
  dashboardHeader(title = "Navigation Bar"),
  sidebar,
  body
)