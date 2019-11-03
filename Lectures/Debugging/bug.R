
## R CMD SHLIB bug.c
dyn.load("bug.so")

f <- function(x, i) {
    .C("f", x=as.double(x), i=as.integer(i), y=double(1))
}
