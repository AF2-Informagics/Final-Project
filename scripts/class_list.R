library(dplyr)
library(stringr)

df <- read.csv("data/schedule.csv", stringsAsFactors = FALSE)
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

course.list <- lapply(course.letter, MakeList)

# vec <- grep("MOLMED", course, value = TRUE)

