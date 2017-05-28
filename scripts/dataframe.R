# setwd("~/Dropbox/UW/Courses/INFO 201/Final-Project")
library(dplyr)
df <- read.csv(file = "data/schedule.csv", stringsAsFactors = FALSE)
rooms <- df %>% select(Building, Room) %>% group_by(Building) %>% filter(Building != "")
course.df <- df %>% select(Course) %>% filter(Course != "")
course.split <- data.frame(do.call('rbind', strsplit(as.character(course.df$Course), ' (?=[^ ]+$)', perl=TRUE)))
colnames(course.split) <- c("Course", "Number")

RemoveEmpty <- function(data) {
  data[!apply(data == "", 1, all),]
}

RemoveEmptyNA <- function(data) {
  data <- data[!apply(is.na(data) | data == "", 1, all),]
}

MakeList <- function(building, df) {
  data <- df %>% filter(Building == building) %>% ungroup() %>% select(Room)
  list <- list(data)
}

MakeList2 <- function(course) {
  data <- course.split %>% select(Number)
  list <- list(data)
}

rooms.list <- sapply(buildings, MakeList, df = rooms)
course.list <- sapply(course.split$Course, MakeList2)

courses <- unique(df$Course[df$Course != ""])
buildings <- unique(df$Building[df$Building != ""])