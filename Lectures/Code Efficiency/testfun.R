test <- function(x){
    st1 <- integer(length(x))
    temp <- x[1]
    for (i in 2:(length(x))){
        if (!is.na(x[i]) & !is.na(x[i-1]) & abs(x[i] - temp) >= 15) {
            st1[i] <- 1L
        }
        if (!is.na(x[i]))
            temp <- x[i]
    }
    return(st1)
}
