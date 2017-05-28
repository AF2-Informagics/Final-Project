# setwd("~/Dropbox/UW/Courses/INFO 201/Final-Project")
library(dplyr)

RemoveEmpty <- function(data) {
  data[!apply(data == "", 1, all),]
}

RemoveEmptyNA <- function(data) {
  data <- data[!apply(is.na(data) | data == "", 1, all),]
}

rooms <- df %>% select(Building, Room) %>% group_by(Building) %>% RemoveEmpty() 

MakeList <- function(building, df) {
  data <- df %>% filter(Building == building) %>% ungroup() %>% select(Room)
  list <- list(data)
}

rooms.list <- sapply(buildings, MakeList, df = rooms)

df <- read.csv(file = "data/schedule.csv", stringsAsFactors = FALSE)
courses <- unique(df$Course[df$Course != ""])
buildings <- unique(df$Building[df$Building != ""])