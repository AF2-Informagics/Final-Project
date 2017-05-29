library(shiny)
library(ggplot2)
library(DT)

shinyUI(fluidPage(
  titlePanel("Final Project"),
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
))
