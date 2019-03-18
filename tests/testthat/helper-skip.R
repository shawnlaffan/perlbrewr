# 2.0.0.999 testthat code
skip_if_offline <- function(host = "r-project.org") {
  skip_if_not_installed("curl")
  has_internet <- !is.null(curl::nslookup(host, error = FALSE))
  if (!has_internet) {
    skip("offline")
  }
}

# skip if running under covr::package_coverage()
skip_if_covr <- function() {
  if (Sys.getenv("R_COVR", unset = "false") == "true") {
    skip("covr")
  }
}
