library(dplyr)
library(stringr)
library(plotly)
library(ggplot2)

source("scripts/dataframe.r")

improved.df <- df
improved.df$new.additional <- substring(improved.df$Additional, 2)
improved.df$new.additional <- ifelse(improved.df$new.additional != "", as.numeric(gsub(",", "", improved.df$new.additional)), 0)

#Select the most expensive additional class
most.expensive.additional <- improved.df %>% filter(new.additional == max(new.additional))

#Longest time of the class
longest.time.class <- improved.df %>% filter(is.na(time_diff) == FALSE) %>% filter(time_diff == max(time_diff))

#Most Capacity
most.capacity <- improved.df %>% filter(is.na(Capacity) == FALSE) %>% filter(Capacity == max(Capacity))

#very expensive small capacity class
expensive.smallest.capacity <- improved.df %>% filter(is.na(Capacity) == FALSE & Capacity != 0) %>% filter(Capacity < 5 & new.additional > 1000)

improved.df$credits <- as.numeric(improved.df$Sub.Credit)
new.improved.credit <- improved.df %>% filter(is.na(credits) == FALSE)


pie <- ggplot(new.improved.credit, aes(x = factor(1), fill = factor(new.improved.credit$credits))) +  geom_bar(width = 1) 
p <- pie + coord_polar(theta = "y")
p