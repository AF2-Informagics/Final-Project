library(dplyr)
library(stringr)

schedule <- read.csv("data/schedule.csv", stringsAsFactors = FALSE)
course <- unique(schedule$Course)
course <- course[-2]
course.letter <- unique(gsub("[[:digit:]]","",course))

course.list <- list()
MakeList <- function(abbr) {
  vec <- grep(abbr, course, value = TRUE)
  c(course.list, eval(parse(text = "abbr")) = vec)
}

lapply(course.letter, MakeList)

# vec <- grep("MOLMED", course, value = TRUE)
