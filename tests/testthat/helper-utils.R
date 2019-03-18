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

which_perl <- function() {
  path <- Sys.which("perl")[["perl"]]
}

perlbrew_free_path <- function(mock_root = "") {
  ## get current PATH
  sys_path <- unlist(strsplit(Sys.getenv("PATH"), split = ":"))
  ## filter mock_root
  sys_path <- sys_path[!grepl(sys_path, pattern = mock_root)]
  ## filter any perlbrew*/bin path
  sys_path <- sys_path[!grepl(sys_path, pattern = "/perlbrew[^/]*/bin")]
  ## reconstitute
  sys_path <- paste0(sys_path, collapse = ":")
  return(sys_path)
}
