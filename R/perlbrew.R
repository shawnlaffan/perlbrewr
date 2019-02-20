
#' perlbrewr
#'
#' @param root PERLBREW_ROOT
#' @param version perl version
#' @param lib local lib name (optional)
#'
#' @return Boolean
#' @export
perlbrewr <- function(root = NULL, version = NULL, lib = NULL) {
  stopifnot(!is.null(root))
  stopifnot(!is.null(version))
  variables <- perlbrew_variables(root, version, lib)
  configure_environment(variables)
  variables$result == 0
}

#' unperlbrewr
#'
#' @param root PERLBREW_ROOT
#'
#' @return Boolean
#' @export
unperlbrewr <- function(root = NULL) {
  variables <- perlbrew_variables(root)
  configure_environment(variables)
  variables$result == 0
}

#
# configure_environment
#
configure_environment <- function(environment_variables) {

  if(length(environment_variables$unset) > 0) {
    n <- names(environment_variables$unset)
    # warning("unsetting: ", paste0(n, sep = "\n"))
    Sys.unsetenv(n)
  }

  if(length(environment_variables$export) > 0) {
    n <- names(environment_variables$export)
    # warning("setting: ", paste0(n, sep = "\n"))
    do.call("Sys.setenv", environment_variables$export)
  }

  perlbrew_set_path <- "__perlbrew_set_path; echo $PATH"
  cmd <- paste0("bash -c '", source_cmd(), perlbrew_set_path, "'")
  path <- system(cmd, intern = TRUE)
  status <- attr(path, "status")
  if(is.null(status)) {
    Sys.setenv("PATH" = path)
  }

  return(0)
}


#' perlbrew_variables
#'
#' @param root PERLBREW_ROOT
#' @param version perl version
#' @param lib local lib name (optional)
#'
#' @return list()
#'
#' @importFrom stringr str_split_fixed
#' @noRd
perlbrew_variables <- function(root = NULL, version = NULL, lib = NULL) {
  if (is.null(root)) {
    return(list(unset = list(), export = list(), result = -1))
  }
  Sys.setenv("PERLBREW_ROOT" = root)

  if (is.null(version)) { version <- ""; lib <- NULL }
  if (!is.null(lib)) {
    version <- paste0(version, "@", lib)
  }

  perlbrew_cmd <- paste0("${perlbrew_command} --quiet env ", version, "; ")
  cmd          <- paste0("bash -c '", source_cmd(), perlbrew_cmd, "'")

  env_vars <- suppressWarnings(system(cmd, intern = TRUE))
  status   <- attr(env_vars, "status")
  if(!is.null(status)) {
    warning(paste0("command was: ", cmd, " status is: ", status))
    return(list(unset = list(), export = list(), result = status))
  }

  pairs <- str_split_fixed(env_vars, "=", 2)

  unset_these <- grepl(pairs[,1], pattern = "unset")

  list(unset  = variables_to_list(pairs, unset_these),
       export = variables_to_list(pairs, !unset_these),
       result = 0)
}

source_cmd <- function() {
  return("source ${PERLBREW_ROOT}/etc/bashrc; ")
}

#' variables_to_list
#'
#' @param pairs str_split_fixed return
#' @param idx subset
#'
#' @return list()
#' @importFrom magrittr %>%
#' @noRd
variables_to_list <- function(pairs, idx) {
  variables <- as.list(pairs[idx,2]) %>%
    gsub(pattern = "^\"|\"$", replacement = "")

  names(variables) <- pairs[idx,1] %>%
    gsub(pattern = "^(unset|export) ", replacement = "")

  as.list(variables)
}
