# expect_in_environment
# simple test for difference between vars and names of variables in environment
#
expect_in_environment <- function (vars = c(), warndiff = FALSE, ...) {
  env <- Sys.getenv()
  if(warndiff) {
    warning(paste0(setdiff(vars, names(env)), sep = " | "))
  }
  expect_true(all(vars %in% names(env)), ...)
}

expect_not_in_environment <- function (vars = c(), warndiff = FALSE, ...) {
  env <- Sys.getenv()
  if(warndiff) {
    warning(paste0(setdiff(vars, names(env)), sep = " | "))
  }
  expect_true(all(!(vars %in% names(env))), ...)
}

expect_perl <- function(regexp = NULL, ...) {
  exe <- "perl"
  path <- Sys.which(exe)[[exe]]
  expect_match(object = path, regexp = regexp, ...)
  expect_true(file_test("-x", path),
              label = "executable test - which does this?")
}

expect_knitr_path_set <- function(path = "") {
  eng_path <- knitr::opts_chunk$get("engine.path")
  expect_equal(class(eng_path), "list", label = "is a list")
  expect_true("perl" %in% names(eng_path), label = "perl is a name in list")
  expect_equal(eng_path$perl, path)
}

expect_knitr_opts_match <- function(match = "") {
  opts_val <- knitr::opts_chunk$get("engine.opts")
  expect_equal(class(opts_val), "list", label = "is a list")
  expect_true("perl" %in% names(opts_val), label = "perl is a name in list")
  expect_match(opts_val$perl, regexp = "-I")
  expect_match(opts_val$perl, regexp = match)
}
