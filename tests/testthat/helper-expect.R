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
