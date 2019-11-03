
## Useing traceback()
years <- rep(2018:2019, c(9, 2))
months <- c(4:12, 1:2)
filenames <- paste0("trips-", years, "-", months, ".csv")
files <- file.path("/course/Labs/Lab02", filenames)
tripsList <- lapply(files, read.csv)
tripsFits <- lapply(tripsList,
                    function(x)
                        lm(log(Trip.Duration) ~ log(Trip.Distance), x))
traceback()


## Using print()
## Which file produces the error ?
tripsFits <- lapply(files,
                    function(x) {
                        print(x)
                        df <- read.csv(x)
                        lm(log(Trip.Duration) ~ log(Trip.Distance), df)
                    })



## Using browser()
## Which values generate the problem ?
lmFit <- function(x) {
    logDurn <- log(x$Trip.Duration)
    logDist <- log(x$Trip.Distance)
    browser()
    lm(logDurn ~ logDist)
}
tripsFits <- lapply(tripsList, lmFit)

# ls()
# head(logDist)
# which(!is.finite(logDist))
# logDist[which(!is.finite(logDist))]
# x$Trip.Distance[which(!is.finite(logDist))]
# lm(logDurn ~ logDist, subset=x$Trip.Distance > 0)
# Q



## Using setBreakpoint()
source("01_debugging_spartan.R")
## Error!
get_climates()
## Where is the error?
## Which function AND which line number?
traceback()
## Set a breakpoint
setBreakpoint("01_debugging_spartan.R", 8)
get_climates()

# vec
# strsplit(vec, ",")
# ?strsplit
# class(vec)
# strsplit(as.character(vec), ",")
# Q

## Clear breakpoint
setBreakpoint("01_debugging_spartan.R", 8, clear=TRUE)



## Using debug()
source("01_debugging_spartan.R")
## Error!
get_climates()
## Which function
traceback()
## View function
clean
## Debug function
debug(clean)
get_climates()

# <Enter>
# vec
# vec <- as.character(vec)
# c

## Stop debugging function
undebug(clean)



## Using trace()
source("01_debugging_spartan.R")
## Error!
lapply(c("diameter", "population", "climate"), get_unique)
## Which function
traceback()
## View function source
as.list(body(clean))
## Trace function 
trace(clean, browser, at=3)
## View tracing code
body(clean)
lapply(c("diameter", "population", "climate"), get_unique)

# vec
# <Enter>
# <Enter>
# c
# vec 
# <Enter>
# <Enter>
# c
# vec
# <Enter>
# <Enter>

## Stop tracing
untrace(clean)
## Trace smarter
trace(clean, expression(if (!is.numeric(vec) && !is.character(vec)) browser()),
      at=3)
body(clean)
lapply(c("diameter", "population", "climate"), get_unique)

# vec
# Q

## Stop tracing
untrace(clean)



## Using recover()
source("01_debugging_spartan.R")
## Error!
lapply(c("diameter", "population", "climate"), get_unique)
## Trace smarter
trace(clean, expression(if (!is.numeric(vec) && !is.character(vec)) browser()),
      at=3)
lapply(c("diameter", "population", "climate"), get_unique)

# recover()
# 3
# ls()
# c
# 2
# ls()
# column
# c
# 0
# Q

## Stop tracing
untrace(clean)



## Using options(warn) and options(error)
lmFit <- function(x) {
    logDurn <- log(x$Trip.Duration)
    logDist <- log(x$Trip.Distance)
    lm(logDurn ~ logDist, subset=x$Trip.Distance > 0)
}
## Warnings
tripsFits <- lapply(tripsList, lmFit)
## Turn warnings into errors
options(warn=2)
## Error!
tripsFits <- lapply(tripsList, lmFit)
## Enter debugging browser on error
options(error=recover)
tripsFits <- lapply(tripsList, lmFit)

# 2
# ls()
# summary(log(x$Trip.Duration))
# which(is.na(log(x$Trip.Duration)))
# x$Trip.Duration[which(is.na(log(x$Trip.Duration)))]
# Q

## Normal warnings
options(warn=0)
## Normal errors
options(error=NULL)

## Fixed
lmFit <- function(x) {
    subset <- x$Trip.Duration > 0 & x$Trip.Distance > 0
    logDurn <- log(x$Trip.Duration[subset])
    logDist <- log(x$Trip.Distance[subset])
    lm(logDurn ~ logDist)
}
tripsFits <- lapply(tripsList, lmFit)



## Debugging within loop
logDurations <- function() {
    result <- vector("list", 11)
    for (i in 1:11) {
        result[[i]] <- log(tripsList[[i]]$Trip.Duration)
    }
    result
}
range(logDurations())
debug(logDurations)
range(logDurations())

# <Enter>
# <Enter>
# <Enter>
# <Enter>
# f
# do.call(rbind, lapply(result, range))
# Q

## Remove debugging
undebug(logDurations)



## Debugging R Markdown
## Instead of running in shell ...
runinshell <- function() {
    Rscript -e 'rmarkdown::render("bug.Rmd")'
}
## ... run in interactive R session
rmarkdown::render("bug.Rmd")
ls()
traceback()
debug(clean)
get_climates()

# vec
# strsplit(vec, ",")
# strsplit(as.character(vec), ",")
# Q



## Problems in C code
source("bug.R")
f(1, 0)
## Error in C code
f(1, -1)
traceback()
f
## Segfault
f(1, 2)



## Debugging parallel code
## MASTER
myboot <- function(N=2000) {
    betas <- numeric(N)
    nrow <- nrow(mtcars)
    for (i in 1:N) {
        resample <- sample(1:nrow, nrow, replace=TRUE)
        betas[i] <- lm(mpg ~ disp, mtcars[resample, ])$coef[2]
    }
    betas
}
library(parallel)
cl <- makeCluster(1, manual=TRUE)

## WORKERS
## Get PORT setting from output of above expression
## /usr/lib/R/bin/R --args MASTER=localhost OUT='/dev/null' SETUPTIMEOUT=120 TIMEOUT=2592000 XDR=TRUE PORT=
sink(NULL)
parallel:::.slaveRSOCK()

## MASTER
clusterExport(cl, "myboot")
clusterEvalQ(cl, debug(myboot))
clusterEvalQ(cl, myboot(2000))
stopCluster(cl)




