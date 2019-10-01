

path <- "/course/ASADataExpo2009/Data"


## Solution 1 ...
system(paste("ls -lh", file.path(path, "bigmemory/airline.csv")))
## Use a bigger machine
## ssh pmur002@stats769prd01.its.auckland.ac.nz
runiflotsoftime <- function() {
    airline <- read.csv(file.path(path, "bigmemory/airline.csv"))
    object.size(airline)
    ## 14330060808 bytes
    mean(airline$DepDelay, na.rm=TRUE)
    ## [1] 8.170708
}
gc(reset=TRUE)
f2008 <- read.csv(file.path(path, "2008.csv"))
object.size(f2008)
mean(f2008$DepDelay, na.rm=TRUE)
gc()


## Solution 2 ...
## Store data in database and just extract the bits we want
system(paste("ls -lh", file.path(path, "sqlite/ontime.sqlite3")))
library(RSQLite)
con <- dbConnect(SQLite(), file.path(path, "sqlite/ontime.sqlite3"))
runiflotsoftime <- function() {
    delays <- dbGetQuery(con, "SELECT DepDelay FROM ontime")
    object.size(delays)
    ## 494140616 bytes
    mean(delays$DepDelay)
    ## [1] 8.018443
}
gc(reset=TRUE)
delays <- dbGetQuery(con, "SELECT DepDelay FROM ontime WHERE Year == 2008")
object.size(delays)
mean(delays$DepDelay)
dbDisconnect(con)
gc()
## Of course, the database system still uses memory to perform the query,
## but this should typically be less than R requires to work with the
## full data set
system(paste0('/usr/bin/time -f "%M" ',
              'sqlite3 /course/ASADataExpo2009/Data/sqlite/ontime.sqlite3 ',
              '"SELECT DepDelay FROM ontime WHERE Year == 2008" ',
              "> /dev/null"))

## Storing data more compactly
## A PhD student in the department wanted to generate a 1e6x1e6 matrix
## (to solve pde numerically)
1e6*1e6*4
## TOO BIG for RAM (or even hard drive!)
## BUT the matrix was sparse (~20 non-zero values per row)
## A different storage option would take less memory
m <- diag(100)
m[1:5, 1:5]
object.size(m)
library(Matrix)
msparse <- sparseMatrix(1:100, 1:100, x=1)
msparse[1:5, 1:5]
object.size(msparse)
## Model matrices
subset <- is.finite(f2008$DepDelay)
length(unique(f2008$Origin)) * nrow(f2008) * 8
library(MatrixModels)
smm <- model.Matrix(DepDelay ~ Origin, f2008[subset,], sparse=TRUE)
dim(smm)
prod(dim(smm))*8
object.size(smm)
fit <- glm4(DepDelay ~ Origin, data=f2008[subset,], sparse=TRUE)
coef(fit)

## Sample the data
fullMeans <- aggregate(DepDelay ~ Month, f2008, mean)
sampleMeans <- aggregate(DepDelay ~ Month,
                         f2008[sample(1:nrow(f2008), 700000), ],
                         mean)
merge(fullMeans, sampleMeans, by="Month")

## Avoid R's copying semantics
## 122MB file
gc(reset=TRUE)
f2008 <- read.csv(file.path(path, "2008.csv"))
object.size(f2008)
md <- aggregate(f2008$DepDelay,
                list(Month=f2008$Month),
                mean, na.rm=TRUE)
f2008Plus <- merge(f2008, md)
head(f2008Plus)
gc()
## 'data.table'
library(data.table)
gc(reset=TRUE)
f2008DT <- fread(file.path(path, "2008.csv"), sep=",")
object.size(f2008DT)
f2008DT[, monthDelay := mean(DepDelay, na.rm=TRUE), by=Month]
head(f2008DT)
gc()

## Streaming data
## Naive reading in of data file
gc(reset=TRUE)
x <- scan("numbers.csv", sep=",")
object.size(x)
mean(as.matrix(x))
gc()
## Stream reading
## AND use a streaming algorithm to calculate the mean
gc(reset=TRUE)
con <- file("numbers.csv", "r")
sum <- 0
for (i in 1:10) {
    y <- scan(con, sep=",", nlines=1000)
    sum <- sum + sum(y)
    gc()
}
sum/1000000
close(con)
gc()
## 'biglm' package
## Linear regression
x <- read.table("numbers.csv", sep=",")
naiveFit <- lm(V1 ~ V2, x[,1:2])
summary(naiveFit)
library(biglm)
con <- file("numbers.csv", "r")
y <- read.table(con, sep=",", nrows=1000)
streamFit <- biglm(V1 ~ V2, y[,1:2])
for (i in 2:10) {
    y <- read.table(con, sep=",", nrows=1000)
    streamFit <- update(streamFit, y[,1:2])
}
summary(streamFit)
close(con)
## Logistic regression
fac <- as.numeric(x[,3] > 0)
naiveFit <- glm(fac ~ V2, x, family="binomial")
naiveFit
## Data gets fetched multiple times (fit requires iteration)
numread <- 0
dataFun <- function(reset) {
    if (reset) {
        con <<- file("naive.csv", "r")
    } else {
        if (numread >= 10000) {
            close(con)
            numread <<- 0
            NULL
        } else {
            df <- read.table(con, sep=",", nrows=1000)
            numread <<- numread + 1000
            df$fac <- as.numeric(df[,3] > 0)
            df
        }
    }
}
streamFit <- bigglm(fac ~ V2, dataFun, family=binomial())
summary(streamFit)

## Leave data on disk (NetCDF)
## Dowload ...
## ftp://ftp.cdc.noaa.gov/Datasets/icoads/2degree/std/sst.mean.nc
## ... from ...
## http://www.esrl.noaa.gov/psd/cgi-bin/db_search/DBSearch.pl?Dataset=ICOADS+2-degree+Standard&Dataset=ICOADS+2-degree+Enhanced&Variable=Sea+Surface+Temperature
## Citation:
## "ICOADS data provided by the NOAA/OAR/ESRL PSD, Boulder, Colorado,
##  USA, from their Web site at http://www.esrl.noaa.gov/psd/" 
library(ncdf4)
file.info("/course/NOAA/sst.mean.nc")
sst <- nc_open("/course/NOAA/sst.mean.nc")
sst
object.size(sst)
## Load complete variable
temps <- ncvar_get(sst, "sst")
## NOTE how much larger R object is than data on disk
object.size(temps)
dim(temps)
## Load just a "slice" of data (one time period)
tempvar <- sst$var[[1]]
varsize <- tempvar$varsize
subtemps <- ncvar_get(sst,
                      start=c(1, 1, varsize[3] - 1),
                      count=c(varsize[1], varsize[2], 1))
object.size(subtemps)
dim(subtemps)
plotit <- function() {
    varoffset <- tempvar$addOffset
    realtemp <- subtemps + varoffset
    scaletemp <- (realtemp - min(realtemp, na.rm=TRUE))/
        (max(realtemp, na.rm=TRUE) - min(realtemp, na.rm=TRUE))
    scaletemp[is.na(scaletemp)] <- 0
    library(grid)
    grid.newpage()
    grid.raster(matrix(rgb(t(scaletemp), 0, 0),
                       ncol=varsize[1], nrow=varsize[2]))
}
## bigmemory
## Demo this on "small" desktop (paul@130.216.38.59)
system("ls -lh /course/ASADataExpo2009/Data/bigmemory/airline.csv")
system("free -h")
library(bigmemory)
## To create the file-backed object
## x <- read.big.matrix("airline.csv", header=TRUE,
##                      backingfile="airline.bin",
##                      descriptorfile="airline.desc",
##                      type="integer")
gc()
x <- attach.big.matrix("/course/ASADataExpo2009/Data/bigmemory/airline.desc")
object.size(x)
library(biganalytics)
fit <- biglm.big.matrix(DepDelay ~ Month, data=x, fc="Month")
coef(fit)
gc()

## Solution 3 ...
## Do the analysis in the database
library(RSQLite)
con <- dbConnect(SQLite(), file.path(path, "sqlite/ontime.sqlite3"))
dbGetQuery(con, "SELECT AVG(DepDelay) FROM ontime WHERE Year = 2008")
dbDisconnect(con)
## Mean of the 16th column (DepDelay)
runinshell <- function() {
    /usr/bin/time -f "%M" \
    awk -F, -e 'BEGIN { sum = 0; n = 0 }; NR > 1 { if ($16 != "NA") { sum += $16; n += 1 } }; END { print(sum/n) }' /course/ASADataExpo2009/Data/2008.csv
}
runinshell <- function() {
    awk -F, -e 'NR > 1 { print($16) }' /course/ASADataExpo2009/Data/2008.csv | \
    /usr/bin/time -f "%M" \
    Rscript -e 'x <- scan("stdin"); mean(x, na.rm=TRUE)'
}
