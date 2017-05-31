setwd("~/Documents/info201_sp17/Final-Project/")
library(dplyr)
library(stringr)
library(jsonlite)

df <- read.csv(file = "data/schedule_new.csv", stringsAsFactors = FALSE)
building <- read.csv(file = "data/building.csv", stringsAsFactors = FALSE)

df$StartTime_new <- ifelse((df$StartTime < 700 | grepl("P",df$EndTime)), df$StartTime + 1200, df$StartTime)
df$EndTime_new <- ifelse((df$StartTime < 700 | (df$StartTime <= 1200 & as.integer(gsub("([0-9]+).*$", "\\1", df$EndTime)) < df$StartTime) | grepl("P", df$EndTime) | df$StartTime > 1200), as.integer(gsub("([0-9]+).*$", "\\1", df$EndTime)) + 1200, suppressWarnings(as.integer(df$EndTime)))
df$StartTime_new <- as.POSIXct(sprintf("%04.0f", df$StartTime_new), format='%H%M')
df$EndTime_new <- as.POSIXct(sprintf("%04.0f", df$EndTime_new), format='%H%M')
df <- df %>% mutate(time_diff = df$EndTime_new - df$StartTime_new)

building_info <- fromJSON("data/parse.json")
# building_info <- as.data.frame(building_info, stringsAsFactors = FALSE)

rooms <- df %>% select(Building, Room) %>% group_by(Building) %>% filter(Building != "")
courses.df <- df %>% select(Course) %>% filter(Course != "")

# split the courses name by the final space, e.g. 'SOC W 308' to 'SOC W' and '308'
courses.split <- data.frame(do.call('rbind', strsplit(as.character(courses.df$Course), ' (?=[^ ]+$)', perl=TRUE)), stringsAsFactors = FALSE)
df.new <- within(df, Course<-data.frame(do.call('rbind', strsplit(as.character(Course), ' (?=[^ ]+$)', perl=TRUE)), stringsAsFactors =  FALSE))

colnames(courses.split) <- c("Course", "Number")

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

# write.csv(df, file = "data/df_new.csv", row.names = FALSE)

df_for_table <- df %>% 
  select(Course, SLN, Section, Day, StartTime_new, EndTime_new, Building, Room, Lecturer, CR.NC)
df_for_table$StartTime_new <- substr(df_for_table$StartTime_new, 12, 16)
df_for_table$EndTime_new <- substr(df_for_table$EndTime_new,12, 16)
colnames(df_for_table)[5] <- "Start Time"
colnames(df_for_table)[6] <- "End Time"
colnames(df_for_table)[10] <- "CR/NC"
