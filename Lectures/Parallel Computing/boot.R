N <- 2000
betas <- numeric(N)
nrow <- nrow(mtcars)
for (i in 1:N) {
    resample <- sample(1:nrow, nrow, replace=TRUE)
    betas[i] <- lm(mpg ~ disp, mtcars[resample, ])$coef[2]
}
invisible(betas)
