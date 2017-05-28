# setwd("~/Dropbox/UW/Courses/INFO 201/Final-Project")
library(dplyr)
library(stringr)

df <- read.csv(file = "data/schedule.csv", stringsAsFactors = FALSE)
rooms <- df %>% select(Building, Room) %>% group_by(Building) %>% filter(Building != "")
course.df <- df %>% select(Course) %>% filter(Course != "")
course.split <- data.frame(do.call('rbind', strsplit(as.character(course.df$Course), ' (?=[^ ]+$)', perl=TRUE)))
colnames(course.split) <- c("Course", "Number")

course <- unique(df$Course[df$Course != ""])
course.letter <- unique(gsub("[[:digit:]]","",course))
course.letter <- trimws(course.letter)

course.list <- list()
MakeList <- function(abbr) {
  vec <- grep(abbr, course, value = TRUE)
  mylist <- list()
  mylist[[abbr]] <- vec
  return(c(course.list, mylist))
}
RemoveEmpty <- function(data) {
  data[!apply(data == "", 1, all),]
}

RemoveEmptyNA <- function(data) {
  data <- data[!apply(is.na(data) | data == "", 1, all),]
}

GetRoom <- function(building) {
  data <- rooms %>% filter(Building == building) %>% ungroup() %>% select(Room)
  list <- list(data)
}

rooms.list <- sapply(buildings, GetRoom)
course.list <- lapply(course.letter, MakeList)

courses <- unique(df$Course[df$Course != ""])
buildings <- unique(df$Building[df$Building != ""])