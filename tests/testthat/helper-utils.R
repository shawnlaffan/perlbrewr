# warn_perlbrew_envvars
# simply report, via warnings, the names and values of perlbrew related
# environment variables.
warn_perlbrew_envvars <- function () {
  e <- Sys.getenv()
  n <- names(e)
  p <- n[n %>% grep(pattern = '^PERL', ignore.case = TRUE)]

  warning(paste0(p, sep = "\n"))
  warning(paste0(e[p], sep = "\n"))
}
