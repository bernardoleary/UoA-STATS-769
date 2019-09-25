
    trips <- subset(tripsKeep, Trip.Duration > 0 & Trip.Distance > 0)
    trips$logDuration <- log(trips$Trip.Duration)
    trips$logDistance <- log(trips$Trip.Distance)

    subset <- tripsKeep$Trip.Duration > 0 & tripsKeep$Trip.Distance > 0
    logDuration <- log(tripsKeep$Trip.Duration[subset])
    logDistance <- log(tripsKeep$Trip.Distance[subset])

    labels <- rep(1:10, length.out=length(logDuration))
    groups <- sample(labels)

    mse <- function(i, formula) {
        testSet <- groups == i
        trainSet <- groups != i
        fit <- lm(formula, 
                  data.frame(x=logDistance[trainSet], 
                  y=logDuration[trainSet]))
        pred <- predict(fit, data.frame(x=logDistance[testSet]))
        mean((pred - logDuration[testSet])^2, na.rm=TRUE)
    }

