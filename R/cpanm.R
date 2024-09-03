
#' cpanm
#'
#' @param installdeps Boolean to use --installdeps
#' @param test Boolean to test install
#' @param quiet Boolean to run in quiet mode
#' @param dist The directory to find a cpanfile, or an arhive file to use
#'
#' @return Boolean TRUE for success
#' @export
#' @rdname cpanm
cpanm <- function(installdeps = FALSE, test = TRUE, quiet = TRUE, dist = ".") {
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

  if(!is.perl_dist(dist)){
    warning(paste(dist, "does not appear to be a distribution"))
    return(FALSE)
  }

  command <- paste(c(command, dist), collapse = " ")
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
#' @param cpanfile Path to cpanfile or a directory to find one
#' @export
#' @rdname cpanm
cpanm_installdeps <- function(cpanfile = ".") {
  if(basename(cpanfile) == "cpanfile") { cpanfile <- dirname(cpanfile) }
  cpanm(installdeps = TRUE, test = FALSE, quiet = TRUE, dist = cpanfile)
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

#' cpanm_install_github
#'
#' @param repo The name of the repository - parsed with remotes::parse_github_repo_spec
#' @param test Boolean whether to test the dist
#' @param quiet Boolean whether to keep quiet
#'
#' @return Boolean
#' @export
#' @importFrom remotes parse_github_repo_spec
#' @import rlang
#' @import devtools
#' @import utils
cpanm_install_github <- function(repo, test = FALSE, quiet = TRUE) {
  meta <- tryCatch(expr = remotes::parse_github_repo_spec(repo), error = function(e) e)
  if (inherits(meta, "simpleError")) {
    warning(meta$message)
    return(FALSE)
  }
  tar_file <- download_github(repo = meta$repo, user = meta$user, ref = meta$ref %||% "master")
  if(file.exists(tar_file)) {
    return(cpanm(test = test, quiet = quiet, dist = tar_file))
  }
  return(FALSE)
}

download_github <- function(repo, user, ref = "master"){
  remote <- structure(
    list(host   = "api.github.com",
         repo     = repo,
         subdir   = NULL,
         username = user,
         ref      = ref,
         sha      = NULL,
         ),
    class = c("github_remote", "remote"))
  fun <- getAnywhere("remote_download.github_remote")[1]
  dest <- fun(remote)
  dest
}


cpanm_is_installed <- function() {
  command <- "cpanm"
  if (Sys.which(command)[[command]] == "") {
    return(FALSE)
  }
  return(TRUE)
}

is.perl_dist <- function(x) {
  dist_files <- c("cpanfile", "Makefile.PL", "BUILD.PL")

  if (isTRUE(file.info(x)$isdir)) {
    return(any(is.perl_dist(c(file.path(x, dist_files)))))
  }
  if (!all(basename(x) %in% dist_files) &&
      !all(grepl(pattern = "\\.tar\\.gz$", x))) {
    return(FALSE)
  }
  return(file.exists(x))
}
