
#' cpanm
#'
#' @param installdeps Boolean to use --installdeps
#' @param test Boolean to test install
#' @param quiet Boolean to run in quiet mode
#' @param cpanfile The cpanfile to use
#'
#' @return Boolean TRUE for success
#' @export
#' @rdname cpanm
cpanm <- function(installdeps = FALSE, test = TRUE, quiet = TRUE, cpanfile = ".") {
  root <- Sys.getenv("PERLBREW_ROOT", unset = NA)
  if(!is_valid_root(root)){ stop("root argument is not valid", call. = FALSE) }

  if (cpanm_is_installed() == FALSE) {
    warning("cpanm command not available")
    return(FALSE)
  }
  command <- "cpanm"
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

#' cpanm_installdeps
#'
#' @export
#' @rdname cpanm
cpanm_installdeps <- function(cpanfile = ".") {
  cpanm(installdeps = TRUE, test = FALSE, quiet = TRUE, cpanfile = cpanfile)
}

#' perlbrew_install_cpanm
#'
#' @param force Boolean to force an install/upgrade
#'
#' @return Boolean TRUE for success
#' @export
perlbrew_install_cpanm <- function(force = FALSE) {
  if (cpanm_is_installed()) {
    if (force == FALSE) return(TRUE)
  }

  perlbrew_cmd <- "${perlbrew_command:-perlbrew} install-cpanm -f; "
  installed  <- run_perlbrew_command(perlbrew_cmd = perlbrew_cmd)
  status     <- attr(installed, "status")

  if(is.null(status)) {
    return(TRUE)
  }

  return(FALSE)
}

cpanm_is_installed <- function() {
  command <- "cpanm"
  if (Sys.which(command)[[command]] == "") {
    return(FALSE)
  }
  return(TRUE)
}
