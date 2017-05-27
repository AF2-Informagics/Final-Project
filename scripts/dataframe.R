# setwd("~/Dropbox/UW/Courses/INFO 201/Final-Project")
df <- read.csv(file = "data/schedule.csv", stringsAsFactors = FALSE)
courses <- unique(df$Course[df$Course != ""])
buildings <- unique(df$Building[df$Building != ""])