source(file = "scripts/dataframe.R")
temp.time <- Sys.time() + 3600 * 11

new.df <-
  df %>% mutate(availbility = StartTime_new > temp.time |
                  temp.time > EndTime_new) %>% select(Building, Room, availbility) %>% filter(Building != "", Room != "") %>% distinct()

true.df <-
  new.df %>% filter(availbility == TRUE) %>% select(Building, Room)

false.df <-
  new.df %>% filter(availbility == FALSE) %>% select(Building, Room)

temp.df <- inner_join(true.df, false.df)
available.df <- setdiff(true.df, temp.df)

colnames(available.df.num) <- c("abbr", "num")

available.df.num <-
  available.df %>% group_by(Building) %>% summarise(num = n())

available.df.num.new <- inner_join(available.df.num, building)
