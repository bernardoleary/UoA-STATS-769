
## Killing a runaway process
while (TRUE) {}


# Measuring execution time
# Mostly user time
# (repeat a few times to show variation in times)
system.time(rnorm(1000000))
system.time({
    rnorm(1000000)
    rnorm(1000000)
    rnorm(1000000)
    rnorm(1000000)
    rnorm(1000000)
})
# (replicate() introduces time to the measurement)
system.time(replicate(5, rnorm(1000000)))
# Introduce some system time (file I/O)
system.time(for (i in 1:1000) writeLines(as.character(i), "out.txt"))
## Elapsed longer (waiting for network)
system.time(download.file("https://www.stat.auckland.ac.nz", "stats.html"))
## ALL wall time
system.time(Sys.sleep(3))

# Examine load using top, free, who, ...
system("free")
system("who")
system("top")
system("top -d .5")
system("top -d .5 -o %MEM")


# Example based on
# https://stat.ethz.ch/pipermail/r-help/2015-March/426442.html
# The idea is to remove data with a too big difference with the previous value
# (allowing for NAs in the sequence of values).

set.seed(1234)
x <- sample(1:50, 1000000, replace=TRUE)
x[sample(1:1000000, 1000)] <- NA
head(x, 50)
matrix(head(x, 50), ncol=10, byrow=TRUE)

# Disable just-in-time compilation (we will come back to this)
compiler::enableJIT(0)

test <- function(x) {
    st1 <- integer(length(x))
    temp <- x[1]
    for (i in 2:(length(x))){
        if (!is.na(x[i]) & !is.na(x[i-1]) & abs(x[i] - temp) >= 15) {
            st1[i] <- 1L
        }
        if (!is.na(x[i]))
            temp <- x[i]
    }
    return(st1)
}
result <- test(x)
head(result, 50)
matrix(head(result, 50), ncol=10, byrow=TRUE)

# Estimating time taken
system.time(test(x))
system.time(replicate(5, test(x)))
library(microbenchmark)
microbenchmark(test(x), times=5)

# Profiling
Rprof("test.out")
invisible(replicate(5, test(x)))
Rprof(NULL)
summaryRprof("test.out")

source("profReport.R")
p <- profReport("test.out")
p
print(p, depth.max=3)
print(p, depth.min=5)

# Line profiling
source("testfun.R")
Rprof("test-line.out", line.profiling=TRUE)
invisible(replicate(5, test(x)))
Rprof(NULL)
summaryRprof("test-line.out", lines="show")

library(profvis)
# Save profile to a web apge
p <- profvis(test(x))
htmlwidgets::saveWidget(p, "profile.html")
# To make sure you see individual line behaviour
notrun <- function() {
    source("testfun.R")
    profvis({
        st1 <- integer(length(x))
        temp <- x[1]
        for (i in 2:(length(x))){
            if (!is.na(x[i]) & !is.na(x[i-1]) & abs(x[i] - temp) >= 15) {
                st1[i] <- 1L
            }
            if (!is.na(x[i]))
                temp <- x[i]
        }
    })
}

# Replace & with &&
testAmpersand <- function(x){
    st1 <- integer(length(x))
    temp <- x[1]
    for (i in 2:(length(x))){
        if (!is.na(x[i]) && !is.na(x[i-1]) && abs(x[i] - temp) >= 15) {
            st1[i] <- 1L
        }
        if (!is.na(x[i]))
            temp <- x[i]
    }
    return(st1)
}
resultAmpersand <- testAmpersand(x)
identical(result, resultAmpersand)
system.time(replicate(5, testAmpersand(x)))
microbenchmark(testAmpersand(x), times=5)

## If there is time, tell the 'gridSVG' story
## rects-profile.R
## rects.svg
## rects-profile.html
## rects-library.R

# Compilation
library(compiler)
testcmp <- cmpfun(test)
# Get a look at the low-level compiled code
disassemble(testcmp)
resultCMP <- testcmp(x)
identical(result, resultCMP)
system.time(replicate(5, testcmp(x)))

## Turn automatic compilation back on
compiler::enableJIT(3)

## Show compilation happening automatically (on first use)
test <- function(x) {
    st1 <- integer(length(x))
    temp <- x[1]
    for (i in 2:(length(x))){
        if (!is.na(x[i]) & !is.na(x[i-1]) & abs(x[i] - temp) >= 15) {
            st1[i] <- 1L
        }
        if (!is.na(x[i]))
            temp <- x[i]
    }
    return(st1)
}
## Uncompiled
test
result <- test(x)
## Compiled
test

# Algorithms
m <- matrix(x, ncol=1000)
system.time(replicate(20, apply(m, 2, mean, na.rm=TRUE)))
system.time(replicate(20, colMeans(m, na.rm=TRUE)))

# Matrix vs data frame
system.time(replicate(20, apply(as.data.frame(m), 2, mean, na.rm=TRUE)))

# Pre-allocation (or lack thereof)
testDumb <- function(x) {
    st1 <- 0L
    temp <- x[1]
    for (i in 2:(length(x))){
        if (!is.na(x[i]) & !is.na(x[i-1]) & abs(x[i] - temp) >= 15) {
            st1 <- c(st1, 1L)
        } else {
            st1 <- c(st1, 0L)
        }
        if (!is.na(x[i]))
            temp <- x[i]
    }
    return(st1)
}
# We do not have enough time in the lecture to demonstrate the next two lines
# resultDumb <- testDumb(x)
# identical(result, resultDumb)
# Need to reduce size of 'x' by factor of 10 to get the time down
# (and even then do NOT want to replicate)
system.time(testDumb(x[1:100000]))

# Vectorisation
testVec <- function(x) {
    diffs <- diff(x)
    big <- !is.na(diffs) & abs(diffs) >= 15
    c(0L, big)
}

## Show small function automatically compiled on SECOND call
testVec
resultVec <- testVec(x)
testVec
resultVec <- testVec(x)
testVec

resultVec <- testVec(x)
identical(result, resultVec)
system.time(replicate(5, testVec(x)))


path <- "/course/ASADataExpo2009/Data/"
filename <- paste0(path, "2008.csv")

# Giving read.csv() some hints
system.time(f2008 <- read.csv(filename))
system.time(
    f2008 <- read.csv(filename,
                      colClasses=c(rep("integer", 8),
                                   "character",
                                   "integer",
                                   "character",
                                   rep("integer", 5),
                                   "character",
                                   "character",
                                   rep("integer", 4),
                                   "character",
                                   rep("integer", 6)),
                      stringsAsFactors=FALSE)
)

# Binary version
# saveRDS(f2008, "2008.rds")
binfilename <- paste0(path, "2008.rds")
system(paste("ls -lh", filename))
system(paste("ls -lh", binfilename))
system.time(f2008 <- readRDS(binfilename))


## 'data.table'
system.time(f2008DT <- data.table::fread(filename))

system.time({
    md <- aggregate(f2008$DepDelay,
                    list(Month=f2008$Month),
                    mean, na.rm=TRUE)
    f2008Plus <- merge(f2008, md)
})

system.time({
    f2008DT[, monthDelay := mean(DepDelay, na.rm=TRUE), by=Month]
})


## measuring time in the shell
runinshell <- function() {
    time -p \
    wc -l /course/ASADataExpo2009/Data/2008.csv
}
runinshell <- function() {
    time -p \
    Rscript -e 'length(readLines("/course/ASADataExpo2009/Data/2008.csv"))'
}
## Piped shell commands run in parallel!
runinshell <- function() {
    time -p \
    (awk -F, -e 'NR > 1 { print($16) }' /course/ASADataExpo2009/Data/2008.csv | \
     Rscript -e 'x <- scan("stdin"); mean(x, na.rm=TRUE)')
}
runinshell <- function() {
    time -p \
    (awk -F, -e 'NR > 1 { print($16) }' /course/ASADataExpo2009/Data/2008.csv > DepDelay.txt && \
     Rscript -e 'x <- scan("DepDelay.txt"); mean(x, na.rm=TRUE)')
}

