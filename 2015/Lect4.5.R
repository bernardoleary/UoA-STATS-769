# R code for Lecture 4


#  first part illustrates use of the functions crossval and 
#  bootpred in the package bootstrap

# first load package

library(bootstrap)

# load data and standardize (using function scale)

library(MASS)
data(Boston)
Boston = data.frame(scale(Boston))
x = as.matrix(Boston[,-14])
y = Boston[,14]

# Try linear predictor as a benchmark. We need to define functions
# theta.fit to fit the model, with arguments x and y, and 
# theta.predict,  a function to predict from the fitted model, 
# with arguments fit (the object returned by theta.fit) and x
# (the new data)



theta.fit <- function(x,y){
lsfit(x, y)
}
theta.predict <- function(fit,x){
  cbind(1,x)%*%fit$coef
}

get.PE(x,y,theta.fit, theta.predict)
[1] 0.2588448 0.2809358 0.2802022 0.2841580 0.2774947

#  Above is in-sample, err+opt, 0.632, CV5, CV10

# try a neural network

library(nnet)
nn.fit4 = nnet(medv ~ ., data=Boston, linout=TRUE, size=4, maxit=500)
in.sample.err = mean(residuals(nn.fit4)^2)
in.sample.err
[1] 0.03698914

nn.fit6 = nnet(medv ~ ., data=Boston, linout=TRUE, size=8, maxit=1000)
in.sample.err = mean(residuals(nn.fit6)^2)
in.sample.err
0.03868946

nn.fit8 = nnet(medv ~ ., data=Boston, linout=TRUE, size=8, maxit=1000)
in.sample.err = mean(residuals(nn.fit8)^2)
in.sample.err

> in.sample.err
[1] 0.03744024

# cross validation calculation, size=8
library(bootstrap)

theta.fit <- function(x,y){
nnet(x, y,size = 8, decay = 0.001, trace=FALSE, linout=TRUE)
}


theta.predict <- function(fit,x){
  predict(fit, newdata=x)
}

# It is convenient to package all this up as a function:
######################################################
#
# A function to calculate PE

get.PE = function(x,y,theta.fit, theta.predict){

# x: matrix of inputs
# y: vector of inputs
# theta.fit: a function to fit the model, with arguments x and y
# theta.predict: a function to predict from the fitted model,
  			 with arguments fit ( the object returned by 			 theta.fit) and x (the new data)

sq.err <- function(y,yhat) { (y-yhat)^2}
results.bs <- bootpred(x,y,nboot=100,theta.fit,theta.predict,
    err.meas=sq.err)
CV5 = crossval(x,y,theta.fit, theta.predict, ngroup=5)
CV10 = crossval(x,y,theta.fit, theta.predict, ngroup=10)

# record results
c(results.bs[[1]], results.bs[[1]]+results.bs[[2]], results.bs[[3]],
mean((y-CV5$cv.fit)^2), mean((y-CV10$cv.fit)^2))
}

# use it like this

result = get.PE(x,y,theta.fit, theta.predict)

> result
[1] 0.05744158 0.13398679 0.16794571 0.17894093 0.21157786





# boosting trees

library(gbm)
fit = gbm( medv~ ., data=Boston, distribution = "gaussian",
n.trees = 5000,
interaction.depth = 4,
shrinkage = 0.01,
cv.folds = 5,
train.fraction=1.0)
gbm.perf(fit, method="cv")
best.cv.boost1= min(fit$cv.error)

library(mboost)
fit = blackboost(medv~., data = Boston,
control = boost_control(mstop = 500, nu = 0.01),
tree_controls = ctree_control(maxdepth = 6))
cv.fit=cvrisk(fit)
plot(cv.fit)
best.cv.boost2 = min(apply(cv.fit,2,mean))
> best.cv.boost2
[1] 0.1876871


#############################################################

library(randomForest)
fit = randomForest(medv ~ ., data=Boston, ntree=200, mtry=5,
importance=TRUE)
plot(fit)
best.cv.rf = min(fit$mse)
> best.cv.rf
[1] 0.1065476


############################################################
# using caret with neural net



library(caret)

data = data.frame(y,x)
my.grid <- expand.grid(.decay = c(0.001), .size = c(4,6,8))
nn.CV <- train(y~., data = data,
    method = "nnet", 
    maxit = 1000, 
    tuneGrid = my.grid, 
    trace = FALSE, 
    linout = 1,
    trControl = trainControl(method="cv", number=5, repeats=100)) 

> nn.CV
Neural Network 

506 samples
 13 predictor

No pre-processing
Resampling: Cross-Validated (5 fold) 

Summary of sample sizes: 406, 404, 404, 406, 404 

Resampling results across tuning parameters:

  size  RMSE       Rsquared   RMSE SD     Rsquared SD
  4     0.4668978  0.7958817  0.04385887  0.04329087 
  6     0.4225104  0.8283087  0.03570130  0.03385240 
  8     0.4351782  0.8161357  0.06491708  0.05684980 

Tuning parameter 'decay' was held constant at a value of 0.001
RMSE was used to select the optimal model using  the smallest value.
The final values used for the model were size = 6 and decay = 0.001. 

# 0.4225104^2 = 0.178515 agrees well with value from crossval (0.1789409)

nn.boot <- train(y~., data = data,
    method = "nnet", 
    maxit = 1000, 
    tuneGrid = my.grid, 
    trace = FALSE, 
    linout = 1,
    trControl = trainControl(method="boot", number=50)) 

> nn.boot
Neural Network 

506 samples
 13 predictor

No pre-processing
Resampling: Bootstrapped (50 reps) 

Summary of sample sizes: 506, 506, 506, 506, 506, 506, ... 

Resampling results across tuning parameters:

  size  RMSE       Rsquared   RMSE SD     Rsquared SD
  4     0.4625912  0.7933239  0.05936446  0.04630865 
  6     0.4814134  0.7782601  0.06544664  0.05956942 
  8     0.5032828  0.7676097  0.08404598  0.06465511 

Tuning parameter 'decay' was held constant at a value of 0.001
RMSE was used to select the optimal model using  the smallest value.
The final values used for the model were size = 4 and decay = 0.001.

#  caret with random forest, with ntree=200, mtry=3,5,7,9

data = data.frame(y,x)
my.grid <- expand.grid(.mtry = c(3,5,7,9))
rf.CV <- train(y~., data = data,
    method = "rf", 
    maxit = 1000, 
    tuneGrid = my.grid, 
    ntree = 200,
    trControl = trainControl(method="cv", number=5, repeats=100)) 

> rf.CV
Random Forest 

506 samples
 13 predictor

No pre-processing
Resampling: Cross-Validated (5 fold) 

Summary of sample sizes: 405, 405, 406, 404, 404 

Resampling results across tuning parameters:

  mtry  RMSE       Rsquared   RMSE SD     Rsquared SD
  3     0.3542382  0.8820647  0.05360321  0.04717207 
  5     0.3396554  0.8861268  0.06121101  0.05111333 
  7     0.3374525  0.8855383  0.06177212  0.05089563 
  9     0.3358493  0.8863945  0.05331542  0.04490193 

RMSE was used to select the optimal model using  the smallest value.
The final value used for the model was mtry = 9. 

# 0.3358493^2 = 0.1127948  this is a bit more than the figure of  0.1065476
# obtained from the randomForest function but agrees reasonably well.

Random forests would seem to predict the Boston houses better than
linear methods or neural networks

#########################################################
# using caret with boosted trees

my.grid <- expand.grid(.mstop = c(500,1000,1500), .maxdepth = c(2,3,5,6,7))
boost.CV <- train(y~., data = data,
    method = "blackboost", 
    tuneGrid = my.grid,
    trControl = trainControl(method="cv", number=5, repeats=100)) 
Boosted Tree 

506 samples
 13 predictor

No pre-processing
Resampling: Cross-Validated (5 fold) 

Summary of sample sizes: 405, 405, 404, 405, 405 

Resampling results across tuning parameters:

  maxdepth  mstop  RMSE       Rsquared   RMSE SD     Rsquared SD
  2          500   0.4447354  0.8037539  0.05798251  0.05853623 
  2         1000   0.4447354  0.8037539  0.05798251  0.05853623 
  2         1500   0.4447354  0.8037539  0.05798251  0.05853623 
  3          500   0.4102556  0.8286729  0.05489925  0.05783302 
  3         1000   0.4102556  0.8286729  0.05489925  0.05783302 
  3         1500   0.4102556  0.8286729  0.05489925  0.05783302 
  5          500   0.3965928  0.8388459  0.05033249  0.05299480 
  5         1000   0.3965928  0.8388459  0.05033249  0.05299480 
  5         1500   0.3965928  0.8388459  0.05033249  0.05299480 
  6          500   0.3951785  0.8393017  0.05071995  0.05445623 
  6         1000   0.3951785  0.8393017  0.05071995  0.05445623 
  6         1500   0.3951785  0.8393017  0.05071995  0.05445623 
  7          500   0.3953989  0.8395136  0.05042271  0.05455887 
  7         1000   0.3953989  0.8395136  0.05042271  0.05455887 
  7         1500   0.3953989  0.8395136  0.05042271  0.05455887 

RMSE was used to select the optimal model using  the smallest value.
The final values used for the model were mstop = 500 and maxdepth = 6. 

> 0.3951785^2 = 0.156166  Compare with 0.1876871 for blackboost above.


