

# Determining the size of the problem ...

# On CeR VMs ...
path <- "/course/ASADataExpo2009/Data/"
filename <- paste0(path, "2008.csv")

system(paste0("ls -lh ", filename))
system(paste0("du -sh ", path))
system(paste0("wc -l ", filename))
system(paste0("head ", filename))

system("free -h")
system("df -h")

## Thrashing
## (3 terminals on my "spare" desktop)
## ssh paul@130.216.38.59
## (get process ID for R so can kill it)
## ps aux | grep R
## (top in another terminal)
## (R in a third terminal)
## The vector lengths we are going to generate
1000*2^(1:20)
x <- numeric(1000)
for (i in 1:20) { print(i); x <- c(x, x) }
## (Run R again to show the slow recovery)

# Reasoning about object sizes in R 
# Integer versus numeric
object.size(integer(1000))
# Size of numeric vectors
object.size(numeric(1000))
# numeric value does not matter
object.size(1:1000*1.0)
object.size(numeric(10000))
object.size(numeric(100000))
object.size(numeric(1000000))
# Matrix versus numeric
# NOTE only a little overhead
object.size(integer(10000))
object.size(matrix(1:10000, ncol=100))
# Data frame versus numeric
# NOTE only a little overhead
object.size(integer(10000))
object.size(data.frame(x=1:10000))
# Character vectors are interesting because they are actually
# pointers (8-bytes) to the CHARSXP cache!
object.size(letters)
object.size(rep("a", 26))
object.size(rep("a", 1000))
# Character versus factor
# Factor is *integer* (4-bytes) vector, plus levels
object.size(factor(rep("a", 1000)))
object.size(rep(letters, 1000))
object.size(factor(rep(letters, 1000)))
# Calculating exact storage is a bit tricky ...
# This should get close
# (8 times length of vector, PLUS
#  number-of-unique-values times 40 + number of characters in longest value
#  [rounded up to next highest power of 2])
stringSize <- function(x) {
    vecSize <- 8*length(x) + 40
    ux <- unique(x)
    uSize <- max(pmax(48, 40 + 2^ceiling(log(sapply(ux, nchar) + 1, 2))))
    cacheSize <- length(ux)*uSize
    vecSize + cacheSize
}

# R's memory usage
# Baseline (watch the Vcells used)
gc()
# Allocate memory for 'x'
x <- sample(1e6)
object.size(x)
gc()
# Release memory from 'x'
rm(x)
gc()
# Create 'x' again
x <- sample(1e6)
gc()
# Copy of 'x' (not yet modified)
y <- x
gc()
# Modify 'y', but ONLY 'y' (memory allocated - more than you might expect!)
y[1] <- 0
x[1:10]
y[1:10]
gc()
# 'y' is bigger than 'x' ...
object.size(y)
# ... because 'x' is integer, but 'y' is numeric
class(x)
class(y)

## From R 3.5.0, simple integer sequences are stored just as (start, end)
## UNTIL the actual values are required
rm(x)
gc()
x <- seq(1e6)
gc()
y <- x + 1
gc()

## MAXIMUM memory usage
# gc()
# 1. Using (and resetting) "max used"
# 2. Inside and outside functions
# Baseline (watch the Vcells max used)
gc()
x <- rnorm(1000000)
gc()
rm(x)
gc()
gc(reset=TRUE)
f <- function() {
    x <- rnorm(1000000)
    NULL
}
f()
gc()
# Watch out for .Last.value !!!
gc(reset=TRUE)
f <- function() {
    x <- rnorm(1000000)
}
f()
gc()
gc()

# Estimating the memory required for large CSV
f2008sample <- read.csv(filename, nrow=2)
table(sapply(f2008sample, class))
system(paste("wc -l", filename))
7009729*29*4

# Should use up a lot of RAM
gc()
f2008 <- read.csv(filename)
object.size(f2008)
gc()

## Exploring object allocations within functions
## Memory profiling
## https://cran.r-project.org/web/packages/profmem/vignettes/profmem.html
f <- function() {
    x <- integer(1000000)
    Y <- matrix(rnorm(n = 10000000), nrow = 100)
}
gc(reset=TRUE)
f()
gc()
library("profmem")
## NOTE that the result from profmem() is a data frame
## (so we can subset() it, etc)
options(profmem.threshold = 1000000)
p <- profmem(f())
p

p <- profmem({
    x <- matrix(nrow = 1000, ncol = 1000)
    x[1, 1] <- 0
})
print(p, expr = FALSE)

p <- profmem({
    x <- matrix(NA_real_, nrow = 1000, ncol = 1000)
    x[1, 1] <- 0
})
print(p, expr = FALSE)

p <- profmem(f2008 <- read.csv(filename))
print(p, expre=FALSE)

## Model matrices
x1 <- runif(1000000)
x2 <- runif(1000000)
gnum <- rep(1:5, each=200000)
g <- factor(gnum)
y <- x1 + x2 + gnum + rnorm(1000000)

## Single continuous variable
fit <- lm(y ~ x1)
profmem(lm(y ~ x1))
head(model.matrix(y ~ x1))

## Two continuous variables
fit <- lm(y ~ x1 + x2)
profmem(lm(y ~ x1 + x2), threshold=1000)
head(model.matrix(y ~ x1 + x2))

## Add a categorical variable (5 levels)
fit <- lm(y ~ x1 + x2 + g)
profmem(lm(y ~ x1 + x2 + g), threshold=1000)
head(model.matrix(y ~ x1 + x2 + g), 30)

## An example of a large model matrix
lm(DepDelay ~ Origin, f2008, subset=1:10000)
nrow(f2008)
length(unique(f2008$Origin))
## (be careful where you run the next line !)
mm <- model.matrix(DepDelay ~ Origin, f2008)

## Measuring memory usage in the shell
## time --format="%M" (gives resident memory usage in KB)
## Use /usr/bin/time (else get bash built-in 'time' command)
## Baseline R memory use 
/usr/bin/time -f "%M" Rscript -e 'invisible(NULL)'
## Generate an 8MB R structure
/usr/bin/time -f "%M" Rscript -e 'invisible(rnorm(1000000))'
## Generate an 80MB R structure
/usr/bin/time -f "%M" Rscript -e 'invisible(rnorm(10000000))'

## R vs wc
/usr/bin/time -f "%M" Rscript -e 'length(readLines("/course/ASADataExpo2009/Data/2008.csv"))'
/usr/bin/time -f "%M" wc -l /course/ASADataExpo2009/Data/2008.csv
