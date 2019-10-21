

## Apache Hadoop
## See Hadoop/Docker/ for set up
## Demo R 'rmr2' interface
library(rmr2)
## Sys.setenv(JAVA_HOME="/usr/lib/jvm/default-java")
Sys.setenv(JAVA_HOME = "/usr/lib/jvm/java-8-openjdk-amd64/")
Sys.setenv(HADOOP_CMD="/course/hadoop/hadoop-3.2.0/bin/hadoop")
Sys.setenv(HADOOP_STREAMING="/course/hadoop/hadoop-3.2.0/share/hadoop/tools/lib/hadoop-streaming-3.2.0.jar")
## Data into and out of Hadoop
small.ints <- to.dfs(1:1000)
object.size(1:1000)
object.size(small.ints)
kv.ints <- from.dfs(small.ints)
class(kv.ints)
names(kv.ints)
kv.ints$key
head(kv.ints$val)
object.size(kv.ints)
## Simple Map
## When running within UNI_HOME/ on VMs, must temporarily work
## in temporary directory (because symbolic links are generated).
oldwd <- setwd(tempdir())
result <- mapreduce(input=small.ints,
                    map=function(k, v) cbind(v, v^2),
                    verbose=FALSE)
setwd(oldwd)
kv.result <- from.dfs(result)
kv.result$key
head(kv.result$val)
tail(kv.result$val)
## Simple MapReduce
x <- rbinom(32, n=50, prob=0.4)
x
groups <- to.dfs(x)
kv.groups <- from.dfs(groups)
kv.groups$key
kv.groups$val
oldwd <- setwd(tempdir())
result <- mapreduce(input=groups,
                    map=function(k, v) keyval(v, 1),
                    reduce=function(k, vv) keyval(k, length(vv)),
                    verbose=FALSE)
setwd(oldwd)
kv.result <- from.dfs(result)
kv.result$key
kv.result$val
## MapReduce aggregation
## CSV file straight from file system
flightCSV <- make.input.format("csv", sep=",", skip=1, stringsAsFactors=FALSE,
                             col.names=c("Year","Month","DayofMonth","DayOfWeek","DepTime","CRSDepTime","ArrTime","CRSArrTime","UniqueCarrier","FlightNum","TailNum","ActualElapsedTime","CRSElapsedTime","AirTime","ArrDelay","DepDelay","Origin","Dest","Distance","TaxiIn","TaxiOut","Cancelled","CancellationCode","Diverted","CarrierDelay","WeatherDelay","NASDelay","SecurityDelay","LateAircraftDelay"))
map <- function(k, v) {
    subset <- !is.na(v$DepTime)
    depHour <- v$DepTime %/% 100
    timeOfDay <- ifelse(depHour >= 12, "afternoon", "morning")
    keyval(timeOfDay[subset], v$DepDelay[subset])
}
reduce <- function(k, v) {
    keyval(k, length(v)) ## (v, na.rm=TRUE))
}
oldwd <- setwd(tempdir())
flight_result <- mapreduce(input="/course/ASADataExpo2009/Data/1987.csv",
                           input.format=flightCSV,
                           map=map,
                           reduce=reduce,
                           verbose=FALSE)
setwd(oldwd)
flights <- from.dfs(flight_result)
flights$key
flights$val
## Standard R equivalent
flights <- read.csv("/course/ASADataExpo2009/Data/1987.csv")
subset <- !is.na(flights$DepTime)
depHour <- flights$DepTime %/% 100
timeOfDay <- ifelse(depHour >= 12, "afternoon", "morning")
aggregate(flights$DepDelay[subset], list(timeOfDay[subset]), mean)

## Apache Spark
## See Spark/Docker/ for set up
library(sparklyr)
## On desktop
## sc <- spark_connect(master = "local")
Sys.setenv(JAVA_HOME = "/usr/lib/jvm/java-8-openjdk-amd64/")
sc <- spark_connect(master = "local",
                    spark_home="/course/spark/spark-2.1.0-bin-hadoop2.7")
## Data into Spark
flights_tbl <- copy_to(sc, nycflights13::flights, "flights")
## Tidy, Transform, and aggregate
library(dplyr)
delay_result <- flights_tbl %>% 
  group_by(tailnum) %>%
  summarise(count = n(), dist = mean(distance), delay = mean(arr_delay)) %>%
  filter(count > 20, dist < 2000, !is.na(delay))
delay_result
object.size(delay_result)
delay <- collect(delay_result)
delay
object.size(delay)
## Once back in R can use standard R stuff
notrun <- function() {
    library(ggplot2)
    ggplot(delay, aes(dist, delay)) +
        geom_point(aes(size = count), alpha = 1/2) +
        geom_smooth() +
        scale_size_area(max_size = 2)
}
## Spark linear regression
lmFit <- flights_tbl %>%
    filter(!is.na(dep_delay) & !is.na(dep_time)) %>%
    ml_linear_regression(dep_delay ~ dep_time)
lmFit
## Show (the horror of) an error
lmFit <- flights_tbl %>%
    ml_linear_regression(dep_delay ~ dep_time)

## NeSI
## Copy files to NeSI (from office desktop)
## scp test.* mahuika:/nesi/project/uoa02826/
## scp serial.* mahuika:/nesi/project/uoa02826/
## scp parallel.* mahuika:/nesi/project/uoa02826/
## From office desktop
## ssh pmur002@lander02.nesi.org.nz
## ssh login.mahuika.nesi.org.nz
ssh mahuika
## Run R interactively (just to explore or install an R package)
module load R/3.5.0-gimkl-2017a
R
## Run a batch job on SLURM
sbatch /nesi/project/uoa02826/test.sl
## Run a serial job on SLURM
sbatch /nesi/project/uoa02826/serial.sl
## Run a parallel job on SLURM
sbatch /nesi/project/uoa02826/parallel.sl
## Check that parallel job got allocated multiple CPUs
sacct --format="JobID,JobName,Alloc" | grep "serial\|parallel\|Rscript"

## GPUs
## sudo apt-get install opencl-headers
## sudo apt-get install nvidia-opencl-dev
## Demo R interface (on desktop machine)
library(gpuR)
detectGPUs()
test.data <- function(dim, num, seed=17) { 
    set.seed(seed) 
    matrix(rnorm(dim * num), nrow=num) 
}
m <- test.data(120, 4500)
system.time(dist(m))
gpuM <- gpuMatrix(m)
system.time(dist(gpuM))

## ONLY on desktop
## keras container
##   docker run --cpus=4 -t -i --rm pmur002/stat769-keras /bin/bash
## keras-gpu container
##   docker run -t -i --rm --runtime=nvidia pmur002/stat769-keras-gpu /bin/bash
##   'nvidia-smi -l 1' to monitor
kerasDemo <- function(gpu=FALSE) {
    library(keras)
    mnist <- dataset_mnist()
    x_train <- mnist$train$x
    y_train <- mnist$train$y
    x_test <- mnist$test$x
    y_test <- mnist$test$y
                                        # reshape
    x_train <- array_reshape(x_train, c(nrow(x_train), 784))
    x_test <- array_reshape(x_test, c(nrow(x_test), 784))
                                        # rescale
    x_train <- x_train / 255
    x_test <- x_test / 255
    y_train <- to_categorical(y_train, 10)
    y_test <- to_categorical(y_test, 10)
    model <- keras_model_sequential() 
    model %>% 
        layer_dense(units = 256, activation = 'relu', input_shape = c(784)) %>% 
        layer_dropout(rate = 0.4) %>% 
        layer_dense(units = 128, activation = 'relu') %>%
        layer_dropout(rate = 0.3) %>%
        layer_dense(units = 10, activation = 'softmax')
    if (gpu) {
        model <- multi_gpu_model(model, gpus=2)
    }
    model %>% compile(
                  loss = 'categorical_crossentropy',
                  optimizer = optimizer_rmsprop(),
                  metrics = c('accuracy')
              )
    history <- model %>% fit(
                             x_train, y_train, 
                             epochs = 30, batch_size = 60000, # 128,
                             validation_split = 0.2
                         )
    model %>% evaluate(x_test, y_test)
    model %>% predict_classes(x_test)
}


