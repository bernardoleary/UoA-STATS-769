
################################################################################
## Import

# Flat text files
csvData <- read.csv("example.csv")
csvData <- read.table("example.csv", sep=",", header=TRUE)

fwfData <- read.fwf("fwf.txt", widths=c(5, 6, rep(7, 6)), skip=7,
                    colClasses=c("character", "NULL", rep("numeric", 6)))
colnames <- scan("fwf.txt", what=character(), skip=5, nlines=1)
colnames(fwfData) <- c("latitude", colnames)

# Binary files
saveRDS(fwfData, file="fwf.rds")
readRDS("fwf.rds")

# Spreadsheets
library(gdata)
xlsData <- read.xls("surftemp-view.xls")

# Databases
library(RSQLite)
con <- dbConnect(SQLite(), dbname="surftemp.sqlite")
dbListTables(con)
temperatures <- dbGetQuery(con, "SELECT * FROM surftemp")

# HTML and XML
library(XML)
html <- readHTMLTable("donations.html")
xml <- xmlParse("donations.html", isHTML=TRUE)

################################################################################
## Tidy and Transform

# Data structures
class(colnames)
class(fwfData)
class(html)

# Subsetting
colnames[1]
colnames[2:6]
colnames[-1]
fwfData[, 2]
fwfData[2, ]
fwfData[2]
fwfData[[2]]
fwfData[["latitude"]]
fwfData["latitude"]
fwfData$latitude

# Control flow
if (runif(1) < .5) {
    cat("heads\n")
} else {
    cat("tails\n")
}

for (i in 1:10) {
    if (runif(1) < .5) {
        cat("heads\n")
    } else {
        cat("tails\n")
    }
}

# Vectorisation
flips <- runif(10)
ifelse(flips < .5, "heads", "tails")

# Functions
flip <- function() {
    if (runif(1) < .5) {
        cat("heads\n")
    } else {
        cat("tails\n")
    }
}
flip()

for (i in 1:10) {
    flip()
}

flipn <- function(n) {
    flips <- runif(n)
    ifelse(flips < .5, "heads", "tails")
}
flipn(10)
flipn(100)

# Data processing
max(fwfData[-1])
lapply(fwfData[-1], max)
sapply(fwfData[-1], max)
lat <- rep(fwfData$latitude, 6)
long <- rep(colnames(fwfData)[-1], each=5)
temps <- unlist(fwfData[-1])
longData <- data.frame(lat, long, temps, row.names=NULL)
table(lat)
table(lat, long)
tapply(longData$temps, longData$long, max)
a1 <- aggregate(longData["temps"], list(long=longData$long), max)
a2 <- aggregate(longData["temps"], list(long=longData$long), min)
merge(a1, a2, by="long")
lapply(fwfData[-1], range)
do.call(rbind, lapply(fwfData[-1], range))

## Reshaping
library(reshape2)
head(airquality)
dim(airquality)
aqlong <- melt(airquality, id=c("Month", "Day"))
head(aqlong)
dim(aqlong)
aqwide <- dcast(aqlong, Day ~ Month + variable)
head(aqwide)
dim(aqwide)

# Text processing
grep("T21:", csvData$origintime)
as.POSIXct(csvData$origintime) # drops time
as.POSIXct(gsub("T", " ", csvData$origintime))
bits <- strsplit(as.character(csvData$publicid), "p")
year <- lapply(bits, function(x) x[1])
id <- lapply(bits, function(x) x[2])
paste(year, "p", id)
paste(year, "p", id, sep="")

## Dates
today <- as.Date("2019-07-29")
as.numeric(today)
today <- as.Date("07/29/19", format="%m/%d/%y")
?strptime
today + 1
format(today, format="%A %d %B %Y")
seq(today, by="week", length.out=10)
seq(today, by="week", length.out=10)[c(TRUE, FALSE)]
seq(today, by="month", length=7)
seq(today, by="month", length=7) > today + 100
diff(seq(today, by="month", length=7))
Sys.time()
as.numeric(Sys.time())
datetime <- as.POSIXlt(Sys.time())
unclass(datetime)

# Debugging
a <- function(x) {
    x + 1
}
b <- function(x) {
    if (!is.numeric(x))
        warning("This might not be a good idea")
    a(x) + 1
}
c <- function(x) {
    2*b(x)
}
c(1)
c("test")
traceback()
debug(a)
c("test")
options(warn=2)
c("test")
options(warn=0)
undebug(a)
options(error=recover)
c("test")
options(error=NULL)
check <- function(x) {
    if (!is.numeric(x))
        browser()
}
trace(c, quote(check(x)))
c
body(c)
c(1)
c("test")

