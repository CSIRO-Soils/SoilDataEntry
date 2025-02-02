check.numeric <- function (v = NULL, na.rm = FALSE, only.integer = FALSE, exceptions = c(""), 
          ignore.whitespace = TRUE) 
{
  {
    if (!is.logical(only.integer) | length(only.integer) != 
        1) {
      stop("The parameter \"only.integer\" should be either TRUE or FALSE.")
    }
    if (is.null(v)) {
      stop("The parameter \"v\" is not defined. It can be character vector, numeric vector, factor vector or logical vector.")
    }
    else if (!inherits(v, c("character", "factor"))) {
      if (!inherits(v, c("numeric", "integer", "logical"))) {
        stop("The parameter \"v\" can only be a character vector, numeric vector, factor vector or logical vector.")
      }
      else {
        if (only.integer) {
          v <- as.character(v)
        }
        else {
          return(rep(x = TRUE, length(v)))
        }
      }
    }
    {
      if (!is.logical(na.rm) | length(na.rm) != 1) {
        stop("The parameter \"na.rm\" should be either TRUE or FALSE.")
      }
    }
    {
      if (!is.logical(ignore.whitespace) | length(ignore.whitespace) != 
          1) {
        stop("The parameter \"ignore.whitespace\" should be either TRUE or FALSE.")
      }
    }
  }
  {
    if (inherits(v, "factor")) {
      v <- as.character(v)
    }
    if (na.rm) {
      v <- stats::na.omit(v)
    }
    if (ignore.whitespace) {
      v <- gsub("^\\s+|\\s+$", "", v)
    }
  }
  {
    if (only.integer) {
      regexp_pattern <- "(^(-|\\+)?\\d+$)|(^(-|\\+)?(\\d*)e(-|\\+)?(\\d+)$)"
    }
    else {
      regexp_pattern <- "(^(-|\\+)?((\\.?\\d+)|(\\d+\\.\\d+)|(\\d+\\.?))$)|(^(-|\\+)?((\\.?\\d+)|(\\d+\\.\\d+)|(\\d+\\.?))e(-|\\+)?(\\d+)$)"
    }
    output <- grepl(pattern = regexp_pattern, x = v)
    exception_index <- is.element(v, exceptions)
    if (any(exception_index)) {
      output[exception_index] <- TRUE
    }
    if (!na.rm) {
      output[is.na(v)] <- TRUE
    }
    return(output)
  }
}