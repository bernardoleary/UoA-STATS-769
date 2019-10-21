
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

system.time(result <- mclapply(rep(2000, 3), myboot, mc.cores=3))


