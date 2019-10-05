
profReport <- function(profFile) {
    profStats <- readLines(profFile)
    interval <- as.numeric(gsub("[^0-9]", "", profStats[1]))/1000000
    profCalls <- strsplit(gsub('"', "", profStats[-1]), " ")
    attr(profCalls, "interval") <- interval
    class(profCalls) <- "profReport"
    profCalls
}

print.profReport <- function(x, depth.max=NULL, depth.min=1) {
    if (is.null(depth.max)) {
        depth.max <- max(sapply(x, length))
    }
    if (depth.min > depth.max) {
        stop("Don't be silly")
    }
    collapse <- function(calls) {
        calls <- rev(calls)
        if (length(calls) < depth.min) {
            return(NULL)
        } 
        if (length(calls) > depth.max) {
            calls <- calls[depth.min:depth.max]
        } else {
            calls <- calls[depth.min:length(calls)]
        }
        paste(calls, collapse=" > ")
    }
    stack <- unlist(lapply(x, collapse))
    times <- table(stack)*attr(x, "interval")
    o <- order(times, decreasing=TRUE)
    labs <- names(times)
    L <- length(times)
    for (i in 1:L) {
        cat(labs[o[i]], "\n")
        cat(paste(rep("-", min(options("width")$width - 2, nchar(labs[o[i]]))),
                  collapse=""), "\n")
        cat(times[o[i]], "\n")
        if (i < L)
            cat("\n")
    }
}

