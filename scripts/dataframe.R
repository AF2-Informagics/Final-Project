# setwd("~/Documents/info201_sp17/Final-Project/")
# load all the package required
library(dplyr)
library(stringr)
library(stringi)
library(jsonlite)

# This function removes the row that only contains empty strings from a dataframe
RemoveEmpty <- function(data) {
  data[!apply(data == "", 1, all), ]
}

# This function removes the row that only contains empty strings and NAs from a dataframe
RemoveEmptyNA <- function(data) {
  data <- data[!apply(is.na(data) | data == "", 1, all), ]
}

# add a function to allow rearrange of the columns in the dataframe
ArrangeCol <- function(data, vars) {
  stopifnot(is.data.frame(data))
  data.nms <- names(data)
  var.nr <- length(data.nms)
  var.nms <- names(vars)
  var.pos <- vars
  stopifnot(!any(duplicated(var.nms)),!any(duplicated(var.pos)))
  stopifnot(is.character(var.nms),
            is.numeric(var.pos))
  stopifnot(all(var.nms %in% data.nms))
  stopifnot(all(var.pos > 0),
            all(var.pos <= var.nr))
  out.vec <- character(var.nr)
  out.vec[var.pos] <- var.nms
  out.vec[-var.pos] <- data.nms[!(data.nms %in% var.nms)]
  stopifnot(length(out.vec) == var.nr)
  data <- data[, out.vec]
  return(data)
}

# df the the uw course status schedule data
df <-
  read.csv(file = "data/schedule_new.csv", stringsAsFactors = FALSE)

# rmp is the rating data fetched from ratemyprofessor
rmp <- read.csv(file = "data/RMP.csv", stringsAsFactors = FALSE)

# building is the building data with coords fethched from google map
building <-
  read.csv(file = "data/building.csv", stringsAsFactors = FALSE)

# this takein the original df data and change the time to 24 hour format and change all the numbers for processing
df$StartTime_new <-
  ifelse((df$StartTime < 700 |
            grepl("P", df$EndTime)), df$StartTime + 1200, df$StartTime)
df$EndTime_new <-
  ifelse((
    df$StartTime < 700 |
      (df$StartTime <= 1200 &
         as.integer(gsub(
           "([0-9]+).*$", "\\1", df$EndTime
         )) < df$StartTime) |
      grepl("P", df$EndTime) |
      df$StartTime > 1200
  ),
  as.integer(gsub("([0-9]+).*$", "\\1", df$EndTime)) + 1200,
  suppressWarnings(as.integer(df$EndTime))
  )

# this two process the time to be the POSIX time format
df$StartTime_new <-
  as.POSIXct(sprintf("%04.0f", df$StartTime_new), format = '%H%M')
df$EndTime_new <-
  as.POSIXct(sprintf("%04.0f", df$EndTime_new), format = '%H%M')

# Add a new column to have the class interval
df <- df %>% mutate(time_diff = df$EndTime_new - df$StartTime_new)

# Make the lecturer data to be title case so that match ratemyprofessor data
df$Lecturer <- stri_trans_totitle(df$Lecturer)
df <- left_join(df, rmp) %>% ArrangeCol(c("rating" = 12))

# load the building info as a list
building_info <- fromJSON(txt = "data/parse.json")

# Add a single dataframe to contain all the class rooms
rooms <-
  df %>% select(Building, Room) %>% group_by(Building) %>% filter(Building != "")
courses.df <- df %>% select(Course) %>% filter(Course != "")

# split the courses name by the final space, e.g. 'SOC W 308' to 'SOC W' and '308'
courses.split <-
  data.frame(do.call('rbind', strsplit(
    as.character(courses.df$Course), ' (?=[^ ]+$)', perl = TRUE
  )), stringsAsFactors = FALSE)

# Change the column names
colnames(courses.split) <- c("Course", "Number")


# split the courses name by the final space, e.g. 'SOC W 308' to 'SOC W' and '308' in original data frame
df.new <-
  within(df, Course <-
           data.frame(do.call(
             'rbind', strsplit(as.character(Course), ' (?=[^ ]+$)', perl = TRUE)
           ), stringsAsFactors =  FALSE))

# get the room with building name provided
GetRoom <- function(building) {
  data <-
    rooms %>% filter(Building == building) %>% ungroup() %>% select(Room)
  list <- list(data)
}

# get the course number with the department name provided
GetCourse <- function(course) {
  data <-
    courses.split %>% filter(Course == course) %>% select(Number)
  list <- list(data)
}

# courses is a list of all courses
courses <- unique(df$Course[df$Course != ""])

# buildings is a list of all buildings
buildings <- unique(df$Building[df$Building != ""])

# departments is a list of all departments
departments <-
  unique(courses.split$Course[courses.split$Course != ""])

# rooms.list contains a list that each building points to its rooms
rooms.list <- sapply(buildings, GetRoom)

# course.list contains a list that each department points to its courses
courses.list <- sapply(departments, GetCourse)

# this is the table that we need to show on the actual UI
df_for_table <- df %>%
  select(
    Course,
    SLN,
    Section,
    Day,
    StartTime_new,
    EndTime_new,
    Building,
    Room,
    Lecturer,
    rating,
    CR.NC
  )

# Remove the date of the time in the original data
df_for_table$StartTime_new <-
  substr(df_for_table$StartTime_new, 12, 16)
df_for_table$EndTime_new <- substr(df_for_table$EndTime_new, 12, 16)
colnames(df_for_table)[5] <- "Start Time"
colnames(df_for_table)[6] <- "End Time"
colnames(df_for_table)[11] <- "CR/NC"

# this get all the filenames in the prereq directory
filenames <- gsub("\\.csv$", "", dir(path = "data/prereq/csv/"))

# this for loop creates all the dataframes with the prereq csvs
for (i in filenames) {
  assign(
    i,
    read.csv(
      paste0("data/prereq/csv/", i, ".csv"),
      na.strings = c(""),
      stringsAsFactors = FALSE,
      header = FALSE
    ) %>% `colnames<-`(c("Course", "Prereq")) %>%
      mutate(Level = stri_extract_first_regex(Course, "[0-9]")) %>% ArrangeCol(c("Level" = 1))
  )
}

# These lines finally get a dataframe that contains the credits and the courses number that are that much credits
improved.df <- df
improved.df$new.additional <- substring(improved.df$Additional, 2)
improved.df$new.additional <-
  ifelse(improved.df$new.additional != "", as.numeric(gsub(",", "", improved.df$new.additional)), 0)

improved.df$credits <- as.numeric(improved.df$Sub.Credit)
new.improved.credit <-
  improved.df %>% select(Course, credits) %>% filter(!is.na(credits),!credits == 0.0) %>% distinct()

data <-
  new.improved.credit %>% group_by(credits) %>% summarise(num = n())
