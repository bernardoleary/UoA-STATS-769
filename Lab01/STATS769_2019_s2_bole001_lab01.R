# import the data
trips201807 <- read.csv("trips-2018-7.csv")
trips201808 <- read.csv("trips-2018-8.csv")
trips201809 <- read.csv("trips-2018-9.csv")
trips <- rbind(trips201807, trips201808, trips201809)

# look at duration
barplot(table(trips$duration))
barplot(table(trips$distance))

# look at distribution of distance 
plot(density(trips$distance))

# look at the logged distribution to get a better perspective
plot(density(log(trips$distance)))

# use the plyr library to split the records evenly and take samples
# https://www.rdocumentation.org/packages/plyr/versions/1.8.4/topics/dlply
# https://stackoverflow.com/questions/18258690/take-randomly-sample-based-on-groups
# https://stackoverflow.com/questions/18942792/training-and-test-set-with-respect-to-group-affiliation
library(plyr)
split_set = dlply(trips, .(month), function(.) { s = sample(1:nrow(.), trunc(nrow(.) * 0.8)); list(.[s, ], .[-s,]) } )

# train/test split
# https://www.rdocumentation.org/packages/plyr/versions/1.8.4/topics/ldply
training_set = ldply(split_set, function(.) .[[1]])
test_set = ldply(split_set, function(.) .[[2]])

# make the model
y_train = training_set$duration
x_train = training_set$distance
fit_mean = mean(y_train)
fit_lm <- lm(y ~ x, data.frame(y=y_train, x=x_train))

# test results
y_test <- test_set$distance
x_test <- test_set$duration
pred_mean <- rep(fit_mean, length(y_test))
pred_lm <- predict(fit_lm, data.frame(x=x_test))

# define RMSE function
RMSE <- function(m, o) {
    sqrt(mean((m - o)^2))
}

# get the RMSE
RMSE(pred_mean, y_test)
RMSE(pred_lm, y_test)

# plot the results
plot(x_test, y_test)
abline(h=pred_mean, col="red", lwd=3)
abline(fit_lm, col="blue", lwd=3)