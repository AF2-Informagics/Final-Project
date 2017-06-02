# setwd("~/Documents/info201_sp17/Final-Project")
source(file = "scripts/dataframe.R")
source(file = "scripts/classroom.R")
source(file = "plot.R")

# Make the sidebar menu and corresponding icons for the shiny app
sidebar <- dashboardSidebar(sidebarMenu(
  menuItem(
    "Introduction",
    tabName = "dashboard",
    icon = icon("dashboard")
  ),
  menuItem(
    "Registration & Filter",
    icon = icon("question"),
    tabName = "registration"
  ),
  menuItem(
    "Check for empty classroom",
    icon = icon("eye"),
    tabName = "check"
  ),
  menuItem(
    "Class Visualization",
    icon = icon("bar-chart-o"),
    tabName = "visual"
  ),
  menuItem("Fun Fact!", icon = icon("grav"), tabName = "fun")
))

# Set the main panel for each tab; Change the fonts, image and select button with css
body <- dashboardBody(
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "font.css"),
    tags$style(
      HTML(
        '
        body, text {
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
        
        img {
        height: 198px;
        width: 294px;
        }
        
        .dataTables_length {
        display: none;
        }
        '
      ))),
  tabItems(
    tabItem(
      # Add two headers, an image and a markdown file for illustration for the page
      tabName = "dashboard",
      h2("Class Details for UW"),
      h4("Things you may not know"),
      img(src = "logo.png", align = "right"),
      includeMarkdown("illustration.md")
    ),
    tabItem(
      # Add one header, three select buttons and a table showing all the UW class information 
      # in autumn 2017 to the page
      tabName = "registration",
      h2("Registration & Filter"),
      fluidPage(
        fluidRow(
          column(4,
                 selectInput(
                   "building",
                   "Buildings:",
                   c("All",
                     unique(as.character(df$Building)))
                 )),
          column(4,
                 selectInput("course",
                             "Courses:",
                             c(
                               "All",
                               unique(as.character(df$Course))
                             ))),
          column(4,
                 selectInput(
                   "lecturer",
                   "Lecturers:",
                   c("All",
                     unique(as.character(df$Lecturer)))
                 ))
        ),
        fluidRow(DT::dataTableOutput("vtable"))
      )),
    tabItem(
      tabName = "check",
      # Add one header, a map and a table to the page; The map shows all the currently available 
      # buildings with different color according to the number of available classrooms inside; 
      # pop-up messages will show up as users click; Below a table with same information is attached 
      # to give the users more clear message
      h2("Check for empty classroom!"),
      bootstrapPage(leafletOutput("map", "100%", 400)),
      fluidPage(
        # Create a new row for the table.
        fluidRow(DT::dataTableOutput("maptable"))
      )
    ),
    tabItem(
      # Create a tree with all the UW department, the classes and corresponding prerequisites;
      # A table is attached to the right showing the same info; The default department is INFO (of course)
      tabName = "visual",
      h2("Class Visualization"),
      fluidRow(
        column(7,
               hr(),
               selectInput('in4', 'Options', choice = filenames, selectize = TRUE, selected = "INFO")
        ),
        column(7,
               uiOutput("Hierarchy"),
               # verbatimTextOutput("results"),
               # tableOutput("clickView"),
               d3treeOutput(
                 outputId = "d3",
                 width = '1200px',
                 height = '800px'
               )
        ),
        column(5,
               tableOutput('table'))
      )
    ),
    tabItem(tabName = "fun",
            # Add a header, a markdown file and a plot to the page showing the fun facts found about
            # the UW classes; The facts are calculated in a RMD file but copied and pasted into a markdown 
            # file
            fluidPage(
              h2("Fun Facts about the UW classes!"),
              includeMarkdown("funfact.md"),
              mainPanel(
                plotlyOutput('pie')
              )
            )))
      )

# Put them together into a dashboardPage
shinyUI(dashboardPage(dashboardHeader(title = "Menu"),
                      sidebar,
                      body))