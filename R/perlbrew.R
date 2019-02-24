
#' perlbrew
#'
#' @param root PERLBREW_ROOT
#' @param version perl version
#' @param lib local lib name (optional)
#'
#' @return Boolean
#' @export
perlbrew <- function(root = perlbrewr_perlbrew_root(),
                      version = NULL, lib = NULL) {
  if(!is_valid_root(root)){ stop("root argument is not valid", call. = FALSE) }
  if(is.null(version)) { stop("version argument is not valid", call. = FALSE) }
  variables <- perlbrew_variables(root, version, lib)
  configure_environment(variables)
  variables$result == 0
}

#' perlbrew_lib_create
#'
#' @param root PERLBREW_ROOT
#' @param version perl version
#' @param lib new local lib name
#'
#' @return Boolean TRUE for success
#' @export
perlbrew_lib_create <- function(root = perlbrewr_perlbrew_root(),
                                version = NULL, lib = NULL) {
  if(!is_valid_root(root)){ stop("root argument is not valid", call. = FALSE) }
  lib_name <- perlbrew_id(version, lib)
  res <- run_perlbrew_command(paste0("${perlbrew_command:-perlbrew} lib create ", lib_name))
  status <- attr(res, "status")
  if(is.null(status)) {
    expected <- paste0(lib_name, "' is created")
    return(all(grepl(x = res, pattern = expected)))
  }
  return(FALSE)
}

#' perlbrew_list
#'
#' @param root PERLBREW_ROOT
#'
#' @return character vector
#' @export
perlbrew_list <- function(root = perlbrewr_perlbrew_root()) {
  if(!is_valid_root(root)){ stop("root argument is not valid", call. = FALSE) }

  perls_libs <- run_perlbrew_command("${perlbrew_command:-perlbrew} list; ")
  status     <- attr(perls_libs, "status")

  if(!is.null(status)) {
    return(c())
  }

  active <- grepl(perls_libs, pattern = "^\\* ")
  perls_libs <- perls_libs %>%
    gsub(pattern = "^(\\*| ) ", replacement = "")
  attr(perls_libs, "active") <- perls_libs[active]
  return(perls_libs)
}

#' perlbrew_off
#'
#' @param root PERLBREW_ROOT
#'
#' @return Boolean
#' @export
perlbrew_off <- function(root = perlbrewr_perlbrew_root()) {
  # might need to Sys.unsetenv("PERLBREW_LIB")
  variables <- perlbrew_variables(root)
  configure_environment(variables)
  variables$result == 0
}

#' configure_environment
#'
#' @param environment_variables list of lists
#'
#' @return 0
#' @noRd
configure_environment <- function(environment_variables) {
  if(environment_variables$result != 0) {
    return(environment_variables$result)
  }
  if(length(environment_variables$unset) > 0) {
    n <- names(environment_variables$unset)
    if("PERL5LIB" %in% n) {
      knitr::opts_chunk$set(engine.opts = list(perl = ""))
    }
    # warning("unsetting: ", paste0(n, sep = "\n"))
    Sys.unsetenv(n)
  }

  if(length(environment_variables$export) > 0) {
    n <- names(environment_variables$export)
    if("PERL5LIB" %in% n) {
      parts <- unlist(strsplit(environment_variables$export$PERL5LIB, ":"))
      knitr::opts_chunk$set(
        engine.opts = list(perl = paste("-I", parts, collapse = " ", sep = ""))
      )
    }
    # warning("setting: ", paste0(n, sep = "\n"))
    do.call("Sys.setenv", environment_variables$export)
  }

  path <- run_perlbrew_command("__perlbrew_set_path; echo $PATH")
  status <- attr(path, "status")
  if(is.null(status)) {
    Sys.setenv("PATH" = path)
    knitr::opts_chunk$set(
      engine.path = list(perl = Sys.which("perl")[["perl"]])
    )
  }

  return(0)
}

#' is_valid_root
#'
#' @param root PERLBREW_ROOT
#'
#' @return Boolean
#' @importFrom utils file_test
#' @noRd
is_valid_root <- function(root) {
  # basics
  if (is.null(root))     { return(FALSE) }
  if (is.na(root))       { return(FALSE) }
  if (!dir.exists(root)) { return(FALSE) }
  # structure
  if (!dir.exists(file.path(root, "bin")))                  { return(FALSE) }
  if (!file_test("-x", file.path(root, "bin", "perlbrew"))) { return(FALSE) }
  if (!dir.exists(file.path(root, "etc")))                  { return(FALSE) }
  if (!file_test("-f", file.path(root, "etc", "bashrc")))   { return(FALSE) }
  return(TRUE)
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

  version      <- perlbrew_id(version, lib)
  perlbrew_cmd <- paste0("${perlbrew_command:-perlbrew} --quiet env ", version, "; ")

  env_vars <- run_perlbrew_command(perlbrew_cmd = perlbrew_cmd)
  status   <- attr(env_vars, "status")
  if(!is.null(status)) {
    warning(env_vars)
    return(list(unset = list(), export = list(), result = status))
  }

  pairs <- str_split_fixed(env_vars, "=", 2)

  unset_these <- grepl(pairs[,1], pattern = "unset")

  list(unset  = variables_to_list(pairs, unset_these),
       export = variables_to_list(pairs, !unset_these),
       result = 0)
}

#' run_perlbrew_command
#'
#' @param perlbrew_cmd
#'
#' @return output of command
#' @noRd
run_perlbrew_command <- function(perlbrew_cmd) {
  cmd <- paste0("bash --norc --noprofile -c '", source_cmd(), perlbrew_cmd, "' 2>&1")
  result <- system(cmd, intern = TRUE)
  status <- attr(result, "status")
  if(!is.null(status)) {
    # warning(paste0("command was: ", cmd, " status is: ", status))
  }
  return(result)
}

source_cmd <- function() {
  return("source ${PERLBREW_ROOT:-/fail}/etc/bashrc; ")
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

#' perlbrew_id
#'
#' @param version perl version
#' @param lib local lib name
#'
#' @return perl name
#' @noRd
perlbrew_id <- function(version = NULL, lib = NULL) {
  if (is.null(version) || is.na(version)) {
    version <- ""; lib <- NULL
  }
  if (!is.null(lib) && !is.na(lib) && lib != "") {
    version <- paste0(c(version, lib), collapse = "@")
  }
  return(version)
}
