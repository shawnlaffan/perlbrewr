#' augment_knitr_opts_chunk
#'
#' @param opt  engine.opts or engine.path
#' @param value the value
#' @param action add or remove
#'
#' @return undefined
#' @noRd
augment_knitr_opts_chunk <- function(opt, value, action = "add") {
  opt_list <- list()
  curr <- knitr::opts_chunk$get(opt)
  action <- match.arg(action, c("add", "remove"))
  fun <- func_table[[match(opt, names(func_table), nomatch = 2)]]
  perl <- "perl"

  if(is.null(curr)) {
    ## easy
    if (action == "add") {
      x <- list()
      x[[perl]] <- value
      opt_list[[opt]] <- x
      knitr::opts_chunk$set(opt_list)
    }
  } else {
    if(class(curr) == "list") {
      curr[[perl]] <- fun(curr[[perl]], value, action)
      opt_list[[opt]] <- curr
      knitr::opts_chunk$set(opt_list)
    } else {
      if(opt == "engine.path") {
        n <- basename(curr)
      }
      # ...
      stop("do not know how to do this")
    }
  }
}

munge_engine_opts <- function(existing, update, action = "add") {
  action <- match.arg(action, c("add", "remove"))
  if (action == "add") {
    tmp <- union(shellwords(existing), shellwords(update))
  } else {
    tmp <- setdiff(shellwords(existing), shellwords(update))
  }
  return(paste0(tmp, collapse = " "))
}

set_unset <- function(existing, update, action = "add") {
  if (action == "add") { return(update) }
  return(NULL)
}

#' shellwords
#'
#' @param x command line
#'
#' @return character vector
#'
#' @importFrom stringr str_match_all
#' @noRd
shellwords <- function(x) {
  shellwords_re <-
  "(?xs:                             # 1 from Text:ParseWords
   (')                               # 2 single quote
   ((?>[^']*(?:\\.[^']*)*))'         # 3 quoted
  |
   (\")                              # 4 double quote
   ((?>[^\"]*(?:\\.[^\"]*)*))\"      # 5 quoted
  |
   (                                 # 6 unquoted
    (?:\\\\.|[^\"'\\\\])*?
   )
   (                                 # 7 followed by ...
    \\Z(?!\\n)
   |
    (?-x:\\s+)
   |
    (?!^)(?=[\"'])
   )
  )"
  xo <- str_match_all(string = x, pattern = shellwords_re)
  if (length(xo) == 0) {
    return(character(0))
  }
  for (i in seq_along(xo[[1]][,1])) {
    xo[[1]][i,7] <- NA
    if(!is.na(xo[[1]][i,6]) && xo[[1]][i,6] != "") {
      xo[[1]][i,7] <- xo[[1]][i,6]
    }
    if(!is.na(xo[[1]][i,5])) {
      xo[[1]][i,7] <- xo[[1]][i,5]
    }
    if(!is.na(xo[[1]][i,3])) {
      xo[[1]][i,7] <- xo[[1]][i,3]
    }
  }

  xo <- xo[[1]][,7]
  xo[!is.na(xo)]
}

func_table <- list(engine.opts = munge_engine_opts,
                   engine.path = set_unset)
