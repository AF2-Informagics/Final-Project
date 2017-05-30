library(shinydashboard)
setwd("~/Documents/info201_sp17/Final-Project")
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
              box(column(4,
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
                
              )
              
            ),
            # Create a new row for the table.
            fluidRow(
              box(DT::dataTableOutput("table"))
            )
    ),
    tabItem(tabName = "check",
            h2("Check for empty classroom!")
    ),
    tabItem(tabName = "visual",
            h2("Class Visualization")        
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