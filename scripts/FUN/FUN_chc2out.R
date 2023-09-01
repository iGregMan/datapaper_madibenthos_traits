chc2Out <- function(chc, skip, names) {
  # read the file and break spaces
  chc <- readLines(chc)
  chc <- strsplit(chc, " ")
  # retrieve the first columns and create a fac
  df <- sapply(chc, function(x) x[1:skip])
  fac <- data.frame(t(df))
  # nice fac names
  if (!missing(names)){
    if (length(names)!=skip) {
      cat(" * names and skip length differ\n")
      names <- paste0("col", 1:skip)
    }
  } else {
    names <- paste0("col", 1:skip)
  }
  colnames(fac) <- names
  # remove these columns from the chc
  chc <- lapply(chc, function(x) x[-(1:skip)])
  # loop over the list: remove the (last) -1, pass it to chc2pix
  coo <- lapply(chc, function(x) chc2pix(as.numeric(x[-length(x)])))
  # prepare and return an Out
  names(coo) <- fac[, 1]
  Out(coo, fac=fac)
}
