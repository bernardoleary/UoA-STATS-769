# Determine the bug when you run `get_climates()`

# Separate, flatten, and trim values in the vector
clean <- function(vec) {
    if (is.numeric(vec)) {
        vec <- as.character(vec)
    } 
    values <- strsplit(vec, ",")
    flat_values <- unlist(values)
    trimmed_values <- gsub("^ *| *$", "", flat_values)
    trimmed_values
}

# Clean vector and get the unique values
uniquify <- function(vec) {
    clean_values <- clean(vec)
    unique_values <- unique(clean_values)
    unique_values
}

#
get_unique <- function(column) {
    planets <- read.csv2("planets.csv", na.strings="unknown")
    uniquify(planets[, column])
    
}

# Get unique climate values
get_climates <- function() {
    get_unique("climate")
}

# This example originally used in Amanda Gadrow's excellent debugging talk at rstudio::conf 2018,
# https://github.com/ajmcoqui/debuggingRStudio/blob/b70a3575a3ff5e7867b05fb5e84568abba426c4b/error_example.R
