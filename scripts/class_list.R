library(dplyr)
library(stringr)

df <- read.csv("data/schedule.csv", stringsAsFactors = FALSE)
course <- unique(df$Course[df$Course != ""])
course.letter <- unique(gsub("[[:digit:]]","",course))

course.list <- list()
MakeList <- function(abbr) {
  vec <- grep(abbr, course, value = TRUE)
  return(list <- (abbr = vec))
}

course.list[[length(course.list)+1]] <- lapply(course.letter, MakeList)

# vec <- grep("MOLMED", course, value = TRUE)
