
library(jsonlite)
data <- fromJSON(readLines("2015-json-sample.json")
data

library(jsonlite)
filenames <- paste0("trip-", 1:10, ".json")
trips <- do.call(rbind, lapply(filenames, fromJSON))

                 
