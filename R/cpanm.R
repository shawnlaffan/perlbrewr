
#' cpanm
#'
#' @param installdeps Boolean to use --installdeps
#' @param test Boolean to test install
#' @param quiet Boolean to run in quiet mode
#' @param cpanfile THe cpanfile to use
#'
#' @return string
#' @export
cpanm <- function(installdeps = FALSE, test = TRUE, quiet = TRUE, cpanfile = ".")
{
  root <- Sys.getenv("PERLBREW_ROOT", unset = NA)
  if(!is_valid_root(root)){ stop("root argument is not valid", call. = FALSE) }

  command <- "cpanm"
  if (Sys.which(command)[[command]] == "") {
    warning("cpanm command not available")
    return(FALSE)
  }
  if (installdeps)   { command <- c(command, "--installdeps") }
  if (test == FALSE) { command <- c(command, "-n") }
  if (quiet == TRUE) { command <- c(command, "-q") }

  cpanfile_dir <- dirname(cpanfile)
  cpanfile_base <- basename(cpanfile)
  if (cpanfile_base == ".") { cpanfile_base <- "cpanfile" }

  if (!file.exists(file.path(cpanfile_dir, cpanfile_base))) {
    warning(paste("A cpanfile does not exist at", cpanfile))
    return(FALSE)
  }

  command <- paste(c(command, cpanfile_dir), collapse = " ")

  res <- system(command, intern = TRUE)

  status <- attr(res, "status")
  if (is.null(status)) {
    message(paste(res, collapse = "\n"))
    return(TRUE)
  }
  return(FALSE)
}

cpanm_installdeps <- function(cpanfile = ".")
{
  cpanm(installdeps = TRUE, test = FALSE, quiet = TRUE, cpanfile = cpanfile)
}
