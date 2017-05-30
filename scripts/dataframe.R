# setwd("~/Dropbox/UW/Courses/INFO 201/Final-Project")
library(dplyr)
library(stringr)

df <- read.csv(file = "data/schedule_new.csv", stringsAsFactors = FALSE)
# mutate(df, test = ifelse(grepl("P",df$EndTime), StartTime + 1200, StartTime))
# mutate(df, test2 = ifelse(df$StartTime < 700, df$StartTime + 1200, df$StartTime))
df$StartTime_new <- ifelse((df$StartTime < 700 | grepl("P",df$EndTime)), df$StartTime + 1200, df$StartTime)
df$EndTime_new <- ifelse((df$StartTime < 700 | (df$StartTime <= 1200 & as.integer(gsub("([0-9]+).*$", "\\1", df$EndTime)) < df$StartTime) | grepl("P", df$EndTime) | df$StartTime > 1200), as.integer(gsub("([0-9]+).*$", "\\1", df$EndTime)) + 1200, suppressWarnings(as.integer(df$EndTime)))
rooms <- df %>% select(Building, Room) %>% group_by(Building) %>% filter(Building != "")
courses.df <- df %>% select(Course) %>% filter(Course != "")
# split the courses name by the final space, e.g. 'SOC W 308' to 'SOC W' and '308'
courses.split <- data.frame(do.call('rbind', strsplit(as.character(courses.df$Course), ' (?=[^ ]+$)', perl=TRUE)), stringsAsFactors = FALSE)
colnames(courses.split) <- c("Course", "Number")

# 
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

GetCourse <- function(course) {
  data <- courses.split %>% filter(Course == course) %>% select(Number)
  list <- list(data)
}

courses <- unique(df$Course[df$Course != ""])
buildings <- unique(df$Building[df$Building != ""])
departments <- unique(courses.split$Course[courses.split$Course != ""])

rooms.list <- sapply(buildings, GetRoom)
courses.list <- sapply(departments, GetCourse)

df$StartTime_new <- substr(as.POSIXct(sprintf("%04.0f", df$StartTime_new), format='%H%M'),12,16)
df$EndTime_new <- substr(as.POSIXct(sprintf("%04.0f", df$EndTime_new), format='%H%M'),12,16)
