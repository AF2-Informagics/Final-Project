source(file = "scripts/dataframe.R")
# add a temperary time for test 
# temp.time <- as.POSIXlt("2017-06-01 12:00:00 PDT")
temp.time <- Sys.time()

# the class room is empty if the current time is smaller than the starttime or the current time is bigger than the starttime
# this data frame calculated based on this logic but with duplicates
new.df <-
  df %>% mutate(availbility = StartTime_new > temp.time |
                  temp.time > EndTime_new) %>% select(Building, Room, availbility) %>% filter(Building != "", Room != "") %>% distinct()

# true df summarise all the rooms in the new.df which availability is true
true.df <-
  new.df %>% filter(availbility == TRUE) %>% select(Building, Room)

# false df summarise all the rooms in the new.df which availibility is false 
false.df <-
  new.df %>% filter(availbility == FALSE) %>% select(Building, Room)

# according to the bacis logic truth table, (T + F) = F, thus we conbine true.df and false.df, if some room is both true and false that means it is not available 
temp.df <- inner_join(true.df, false.df)

# so we remove those rooms from the true.df such that the remains are the rooms that are truly available
available.df <- setdiff(true.df, temp.df)

# this aggregates all the rooms in one building to one line for display on the web
available.df.new <- aggregate(Room ~ Building, data = available.df, paste, collapse = ", ")

# this function counts the empty rooms in a building
available.df.num <-
  available.df %>% group_by(Building) %>% summarise(num = n())
colnames(available.df.num) <- c("abbr", "num")

# add coords to the available.df.num so that can be used in the map
available.df.num.new <- inner_join(available.df.num, building)
