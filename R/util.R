# is_windows <- function() {
#   identical(.Platform$OS.type, "windows")
# }
#
# is_osx <- function() {
#   Sys.info()["sysname"] == "Darwin"
# }

perlbrewr_system_file <- function(...) {
  system.file(..., package = "perlbrewr")
}

perlbrewr_perlbrew_root <- function() {
  root <- Sys.getenv("PERLBREW_ROOT", unset = NA)
  if(!is.na(root)){ return(root) }

  ## perlbrew in PATH, but PERLBREW_ROOT not set...
  path_pb <- Sys.which("perlbrew")[["perlbrew"]]
  if (path_pb != "") {
    ## get root by steam
    root <- dirname(dirname(path_pb))
    Sys.setenv("PERLBREW_ROOT"=root)
    return(path.expand(root))
  }

  root <- perlbrewr_system_file("perlbrew")
  if(!getOption("perlbrewr.use_bundled", default = FALSE)) { return(NULL) }
  if(file.access(root, mode = 2) == -1) { return(NULL) }
  Sys.setenv("PERLBREW_ROOT"=root)
  Sys.setenv("perlbrew_command"=perlbrewr_perlbrew_command())
  warning("Using bundled perlbrew root from perlbrewr package.")
  init <- system("perl ${perlbrew_command} init", intern = TRUE,
                 ignore.stdout = TRUE, ignore.stderr = TRUE)
  root
}

perlbrewr_perlbrew_command <- function() {
  file.path(perlbrewr_perlbrew_root(), "bin", "perlbrew")
}

# file.path(path.expand("~"), ".perlbrew")
# file.path(here(), ".perlbrew")
# perlbrewr_perlbrew_home <- function() {
#   file.path(perlbrewr_perlbrew_root(), ".perlbrew")
# }

#
# perlbrewr_environment <- new.env()
# perlbrewr_environment$state <- list(ROOT=perlbrewr_perlbrew_root())
