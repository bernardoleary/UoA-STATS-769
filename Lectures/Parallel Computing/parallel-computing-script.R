
# Make something go faster
# Bootstrap interval for linear regression coefficient
system.time(source("boot.R"))
head(betas)
plot(density(betas))

# Manual parallel processing (3 worker R sessions)
# Three times the work done in the same amount of time
# (because each R session gets run by the OS on different CPU core)
system("Rscript boot.R", wait=FALSE)
system("Rscript boot.R", wait=FALSE)
system("Rscript boot.R", wait=FALSE)
# Some questions:
# - how do I know when they have all finished ?
# - how do I get 'betas' back from each worker ?

# Function version
myboot <- function(N=2000) {
    betas <- numeric(N)
    nrow <- nrow(mtcars)
    for (i in 1:N) {
        resample <- sample(1:nrow, nrow, replace=TRUE)
        betas[i] <- lm(mpg ~ disp, mtcars[resample, ])$coef[2]
    }
    betas
}
system.time(betas <- myboot())
head(betas)
# Why doesn't this work ?
# ... because the worker R session does not know about myboot()
# ... in previous examples, worker sessions have shared the same
#     file system, but they do not share the same RAM
system("Rscript -e 'myboot()'", wait=FALSE)
# Some questions:
# - how do I get information to each worker ?

## Run R on only 4 CPUs (for demonstration purposes)
## taskset --cpu-list 0-3 R

# Use multiple cores via mclapply() 
library(parallel)
# How many cores do I have ?
numCores <- detectCores()
numCores
timer <- function(x) Sys.sleep(.5)
# Serial
system.time(
    lapply(1:10, timer)
    )
# Parallel (on Linux)
# NOTE the effect of num calls versus num cores
system.time(
    mclapply(1:3, timer, mc.cores=numCores)
    )
system.time(
    mclapply(1:10, timer, mc.cores=4)
    )
system.time(
    mclapply(1:5, timer, mc.cores=4)
    )

# Back to the bootstrap example
system.time({
    threeBoots <- mclapply(1:3, function(i) source("boot.R"), mc.cores=3)
})
# The result is a list 
class(threeBoots)
length(threeBoots)
head(threeBoots[[1]]$value)
# Using the function ALSO works because we pass the function object
# as an argument to mclapply()
threeBoots <- mclapply(rep(2000, 3), myboot, mc.cores=3)
head(threeBoots[[1]])
# AND the following also works ...
threeBoots <- mclapply(1:3, function(i) myboot(), mc.cores=3)
head(threeBoots[[1]])
# ... because the worker R sessions are FORKs of the current R session,
# so they can see the function myboot()

# Shared resources between forked R sessions
fp <- file("test.txt", "w")
mclapply(1:3, function(i) for (j in 1:(i*1000)) cat(i, file=fp), mc.cores=3)
close(fp)
readLines("test.txt")

# Use multiple cores via makeCluster()
# NOTE the startup time for makeCluster() getting 'numCores' R sessions started
cl <- makeCluster(4)
system.time(
    parLapply(cl, 1:10, timer)
    )
system.time(
    parLapply(cl, 1:5, timer)
    )
stopCluster(cl)

# Back to the bootstrap example
system.time({
    ## NOTE the overhead of starting up several new R sessions
    cl <- makeCluster(3)
    threeBoots <- parLapply(cl, 1:3, function(i) source("boot.R"))
    ## (almost) NONE of the work is done in THIS R session
})
head(threeBoots[[1]]$value)
# Using the function works because we pass the function object
# as an argument to parLapply()
# NOTE that we can reuse the cluster
threeBoots <- parLapply(cl, rep(2000, 3), myboot)
head(threeBoots[[1]])
# BUT the following does NOT work ...
threeBoots <- parLapply(cl, 1:3, function(i) myboot())
# ... because the worker R sessions are independent and communicating via
# sockets, so they do not know about myboot()
# BUT we can make it work by sending the myboot() function to the worker
# R sessions.
clusterExport(cl, "myboot")
threeBoots <- parLapply(cl, 1:3, function(i) myboot())
head(threeBoots[[1]])
# Clean up
stopCluster(cl)

# Demonstration of parallel code running SLOWER
# Serial
system.time(oneBoot <- myboot(6000))
# Good parallel
system.time({
    cl <- makeCluster(3)
    threeBoots <- parLapply(cl, rep(2000, 3), myboot)
    stopCluster(cl)
})
# Bad parallel
system.time({
    cl <- makeCluster(30)
    thirtyBoots <- parLapply(cl, rep(200, 30), myboot)
    stopCluster(cl)
})

## Allow for different R versions to correspond
Sys.setenv("R_DEFAULT_SAVE_VERSION"=2,
           "R_DEFAULT_SERIALIZE_VERSION"=2)

# Use multiple machines via makeCluster()
# One R session on local machine, two on remote machines
# NOTE that not only are the worker R sessions independent and
# communicating via sockets, BUT they no longer share
# the same file system either!
# This means there is even more set up required.
# R must be installed, R packages must be installed, files must copied ...

## RUN FROM desktop !!!  (socket connections blocked on VMs?)

system("scp boot.R paul@130.216.38.59:boot.R")
cl <- makeCluster(c(rep("localhost", 2),
                    "paul@130.216.38.59"),
                  master="130.216.38.21",
                  user="pmur002",
                  homogeneous=FALSE,
                  Rscript="/usr/bin/Rscript")
threeBoots <- parLapply(cl, 1:3, function(i) source("boot.R"))
head(threeBoots[[1]]$value)
# NOTE that we can reuse the cluster
# Using the function works because we pass the function object
# as an argument to parLapply()
threeBoots <- parLapply(cl, rep(2000, 3), myboot)
head(threeBoots[[1]])
# And we can again export the function to the worker R sessions if
# we need to
clusterExport(cl, "myboot")
threeBoots <- parLapply(cl, 1:3, function(i) myboot())
head(threeBoots[[1]])
# Clean up
stopCluster(cl)

## BACK TO VMs

# Random number generation
set.seed(123)
sample(1:10)
# Same "random" sequence
set.seed(123)
sample(1:10)
# Extreme demonstration of synchronized RNGs
coin <- function(x) {
    ifelse(runif(5) < .5, "H", "T")
}
reprocoin <- function(x) {
    set.seed(1)
    coin()
}
mclapply(1:5, coin, mc.cores=3)
mclapply(1:5, reprocoin, mc.cores=3)
# Reproducible parallel random number streams
# NOTE that it relies on jobs being allocated in the same order
RNGkind("L'Ecuyer-CMRG")
set.seed(123)
mclapply(1:5, coin, mc.cores=3)
set.seed(123)
mclapply(1:5, coin, mc.cores=3)
# Same thing with cluster
cl <- makeCluster(3)
clusterSetRNGStream(cl, 123)
parLapply(cl, 1:5, coin)
clusterSetRNGStream(cl, 123)
parLapply(cl, 1:5, coin)
stopCluster(cl)

# Load balancing/chunking
# NOTE order of chunks matters (do big jobs first)
variableTimer <- function(x) Sys.sleep(x/2)

system.time(
    mclapply(1:10, variableTimer, mc.cores=4)
    )
system.time(
    mclapply(1:10, variableTimer, mc.cores=4, mc.preschedule=FALSE)
    )
system.time(
    mclapply(10:1, variableTimer, mc.cores=4)
    )
system.time(
    mclapply(10:1, variableTimer, mc.cores=4, mc.preschedule=FALSE)
    )

cl <- makeCluster(4)
system.time(
    parLapply(cl, 1:10, variableTimer)
    )
system.time(
    parLapplyLB(cl, 10:1, variableTimer)
    )
stopCluster(cl)

# Abstraction
library(foreach)
system.time(
    feBoot <- foreach (i = rep(2000, 3)) %do% myboot(i)
)
system.time(
    feBoot <- foreach (i = rep(2000, 3)) %dopar% myboot(i)
)
library(doParallel)
registerDoParallel(cores=3)
system.time(
    feBoot <- foreach (i = rep(2000, 3)) %dopar% myboot(i)
)
cl <- makeCluster(3)
registerDoParallel(cl)
system.time(
    feBoot <- foreach (i = rep(2000, 3)) %dopar% myboot(i)
)
stopCluster(cl)

# Implicit parallelism
library(boot) 
betafun <- function(data, b) {  
    d <- data[b, ] 
    lm(d$mpg ~ d$disp)$coef[2]
}
system.time(bootBeta <- boot(data=mtcars, statistic=betafun, R=6000))
plot(bootBeta)
system.time(bootBetaParallel <- boot(data=mtcars, statistic=betafun, R=6000,
                                     parallel="multicore", ncpus=3))
plot(bootBeta)

## SHELL CODE BELOW

## backgrounding and niceing processes
Rscript -e 'for (i in 1:3) { Sys.sleep(1); print(i) }'
echo done

Rscript -e 'for (i in 1:3) { Sys.sleep(1); print(i) }' &
echo done

time -p taskset -c 0 Rscript -e 'invisible(rnorm(100000000))' &
time -p taskset -c 0 Rscript -e 'invisible(rnorm(100000000))' &
               
time -p taskset -c 0 Rscript -e 'invisible(rnorm(100000000))' &
time -p taskset -c 0 nice -n19 Rscript -e 'invisible(rnorm(100000000))' &

time -p taskset -c 0 nice -n19 Rscript -e 'invisible(rnorm(100000000))' &
time -p taskset -c 0 nice -n19 Rscript -e 'invisible(rnorm(100000000))' &

time -p Rscript -e 'invisible(rnorm(100000000))' &
time -p Rscript -e 'invisible(rnorm(100000000))' &

time -p Rscript -e 'invisible(rnorm(100000000))' &
time -p nice -n19 Rscript -e 'invisible(rnorm(100000000))' &

## GNU parallel
time -p (for i in /course/ASADataExpo2009/Data/198*.csv
do
    filename=$(basename $i)
    shuf -n100 $i > $filename
done)

time -p (parallel -j3 'shuf -n100 {} > {/}' ::: /course/ASADataExpo2009/Data/198*.csv)
  
