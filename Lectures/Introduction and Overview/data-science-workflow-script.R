
## Import, Tidy, Transform
## These are the sorts of things we will talk a lot about
## BIG files => take a sample
file.size("/course/ASADataExpo2009/Data/1988.csv")
readLines("/course/ASADataExpo2009/Data/1988.csv", n=10)
## BIG files => use shell tools rather than R
## Column names
system("head -1 /course/ASADataExpo2009/Data/1988.csv | tee 1988.csv > 1989.csv")
## Sample 10000 lines from 1988
system("shuf -n10000 /course/ASADataExpo2009/Data/1988.csv >> 1988.csv")
## Sample 10000 lines from 1989
system("shuf -n10000 /course/ASADataExpo2009/Data/1989.csv >> 1989.csv")
## Check
file.size(c("1988.csv", "1989.csv"))
system("wc 1988.csv")
system("wc 1989.csv")
## Read into R
flights1988 <- read.csv("1988.csv")
flights1989 <- read.csv("1989.csv")
## Combine into single object
flights <- rbind(flights1988, flights1989)
## Subset January
flightsJan <- subset(flights, Month == 1)

## Simple summaries (including Visualisation)
## "balance" of flights across months
table(flights$Month)
barplot(table(flights$Month))
## Distribution of delays
plot(density(flights$ArrDelay, na.rm=TRUE))
plot(density(flights$DepDelay, na.rm=TRUE))
## Two plots on one page
par(mfrow=c(2, 1))
xrange <- range(flights$ArrDelay, flights$DepDelay, na.rm=TRUE)
plot(density(flights$ArrDelay, na.rm=TRUE), xlim=xrange)
plot(density(flights$DepDelay, na.rm=TRUE), xlim=xrange)
## Transform the delays
par(mfrow=c(1, 1))
plot(density(log(flights$DepDelay), na.rm=TRUE))
## Distribution of departure times
plot(density(flights$DepTime, na.rm=TRUE))
hist(flights$DepTime)
## Relationship between delays and departure times
plot(flights$DepTime, flights$DepDelay, log="y")
## Use add-on package
library(visdat)
vis_dat(flights)
vis_miss(flights)
## Cancelled flights have missing delays
table(flights$Cancelled, is.na(flights$DepDelay))

## Model (continuous)
## Always transforming and tidying
## Train on 1988 (logged delays, removing non-positive and NA's)
trainDelay <- log(flights1988$DepDelay)
trainSubset <- is.finite(trainDelay)
dim(flights1988)
sum(trainSubset)
yTrain <- trainDelay[trainSubset]
xTrain <- flights1988$DepTime[trainSubset]
fitMean <- mean(yTrain, na.rm=TRUE)
fitLM <- lm(y ~ x, data.frame(y=yTrain, x=xTrain))
## Test on 1989
testDelay <- log(flights1989$DepDelay)
testSubset <- is.finite(testDelay)
yTest <- testDelay[testSubset]
xTest <- flights1989$DepTime[testSubset]
predMean <- rep(fitMean, length(yTest))
predLM <- predict(fitLM, data.frame(x=xTest))
## Evaluate models
RMSE <- function(m, o) {
    sqrt(mean((m - o)^2))
}
RMSE(predMean, yTest)
RMSE(predLM, yTest)
## Visualise models
plot(xTest, yTest)
abline(h=predMean, col="red", lwd=3)
abline(fitLM, col="blue", lwd=3)

## Model (categorical)
## Probability of late departure
## Train on 1988
trainLateDep <- flights1988$DepDelay > 0
## Visualise relationship between prob late and departure time
plot(flights1988$DepTime, trainLateDep)
boxplot(flights1988$DepTime ~ trainLateDep)
breaks <- seq(500, 2500, 100)
trainDepBlocks <- cut(flights1988$DepTime, breaks=breaks)
trainProps <- tapply(trainLateDep, trainDepBlocks, mean)
plot(seq(550, 2450, 100), trainProps)
## Just consider the main bulk of flights (after 5am)
trainSubset <- flights1988$DepTime >= 500
yTrain <- trainLateDep[trainSubset]
xTrain <- flights1988$DepTime[trainSubset]
fitGLM <- glm(y ~ x, data.frame(x=xTrain, y=yTrain), family="binomial",
              na.action=na.exclude)
## Not necessary, but to show the nnet::multinom() equivalent
fitML <- nnet::multinom(y ~ x, data.frame(x=xTrain, y=yTrain),
                        na.action=na.exclude)
o <- order(xTrain)
lines(xTrain[o], predict(fitGLM, type="response")[o])
## Test on 1989
testLateDep <- flights1989$DepDelay > 0
testSubset <- flights1989$DepTime >= 500 & !is.na(flights1989$DepTime)
yTest <- testLateDep[testSubset]
xTest <- flights1989$DepTime[testSubset]
predProp <- mean(yTrain, na.rm=TRUE)
predGLM <- predict(fitGLM, data.frame(x=xTest), type="response")
predML <- predict(fitML, data.frame(x=xTest), type="prob")
## Visualise
testDepBlocks <- cut(flights1989$DepTime, breaks=breaks)
testProps <- tapply(testLateDep, testDepBlocks, mean)
plot(seq(550, 2450, 100), testProps)
abline(h=.5, lty="dashed")
abline(h=predProp, col="red", lwd=3)
o <- order(xTest)
lines(xTest[o], predGLM[o])
## Evaluate
table(yTest, rep(predProp > .5, length(yTest)))
table(yTest, predGLM > .5)
library(caret)
confusionMatrix(factor(rep(predProp > .5, length(yTest))),
                factor(yTest))
confusionMatrix(factor(predGLM > .5),
                factor(yTest))
confusionMatrix(factor(predML > .5),
                factor(yTest))
## Vary threshold
confusionMatrix(factor(predGLM > .4),
                factor(yTest))
## Guessing model
confusionMatrix(factor(sample(c(TRUE, FALSE), length(yTest), replace=TRUE)),
                factor(yTest))

## Communicate
## See data-science-workflow.Rmd
library(rmarkdown)
render("data-science-workflow.Rmd")
