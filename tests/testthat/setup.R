
author_dbg <- FALSE

as.version_string <- function(fmt = "", vstring = "5.26.0") {
  vstring <- gsub(vstring, pattern = "^(perl-|v)", replacement = "")
  v <- as.integer(unlist(strsplit(vstring, "\\.")))
  sprintf(fmt, v[1], v[2], v[3])
}

as.perlbrew_version <- function(vstring = "5.26.0") {
  as.version_string("perl-%d.%d.%d", vstring = vstring)
}

as.perl_verbose_version <- function(vstring = "5.26.0") {
  as.version_string("perl %d, version %d, subversion %d", vstring = vstring)
}

as.perl_version <- function(vstring = "5.26.0") {
  as.version_string("%d.%03d%03d", vstring = vstring)
}

as.perl_vversion <- function(vstring = "5.26.0") {
  as.version_string("v%d.%d.%d", vstring = vstring)
}

init_mock <- function(perlbrew_root = file.path(getwd(), "mock"))
{
  if (dir.exists(file.path(perlbrew_root, ".perlbrew"))) {
    unlink(file.path(perlbrew_root, ".perlbrew"), recursive = TRUE)
  }
  required_envvars <-
    list("PERLBREW_ROOT"    = perlbrew_root,
         "PERLBREW_HOME"    = file.path(perlbrew_root, ".perlbrew"),
         "perlbrew_command" = file.path(perlbrew_root, "bin", "perlbrew"))
  do.call("Sys.setenv", required_envvars)
  # initialise perlbrew from mock directory
  init <- system("perl ${perlbrew_command} init", intern = TRUE,
              ignore.stdout = TRUE, ignore.stderr = !author_dbg)
  status <- attr(init, "status")
  if(!is.null(status) && author_dbg) {
    warning(paste0("perlbrew init failed status=", status))
  }
  mock_installed_perl(root = perlbrew_root, "5.24.0")
  mock_installed_perl(root = perlbrew_root, "5.26.0")

  # create a local lib
  lib_create <- suppressWarnings({
    system("perl ${perlbrew_command} lib create 5.26.0@random", intern = TRUE,
           ignore.stdout = TRUE, ignore.stderr = !author_dbg)
  })
  status <- attr(lib_create, "status")
  if(!is.null(status) && author_dbg) {
    warning(paste0("perlbrew lib create failed status=", status))
  }
  required_envvars
}

mock_installed_perl <- function(root = NULL, mock_version = "perl-5.26.0") {
  # create a directory for a version of perl
  five_two_x <- file.path(root, "perls", as.perlbrew_version(mock_version))
  if( !dir.exists(five_two_x) ) {
    dir.create(five_two_x, recursive = TRUE)
  }
  # write .version file
  text <- c(as.perl_version(mock_version))
  writeLines(text = text, con = file.path(five_two_x, ".version"), sep = "\n")
  # create a bin directory
  five_two_x <- file.path(five_two_x, "bin")
  if( !dir.exists(five_two_x) ) {
    dir.create(five_two_x)
  }
  write_mock_perl(path = file.path(five_two_x, "perl"),
                  mock_version = mock_version)
}

write_mock_perl <- function (path = NULL, mock_version = "5.26.0") {
  text <- c(
    "#!/bin/sh",
    "",
    "cat - <<'EOF'",
    paste0("This is ", as.perl_verbose_version(mock_version),
           " (", as.perl_vversion(mock_version), ") built for x86_64-linux"),
    "(with 1 registered patch, see perl -V for more detail)",
    "",
    "Copyright 1987-2018, Larry Wall",
    "",
    "Perl may be copied only under the terms of either the Artistic License or the",
    "GNU General Public License, which may be found in the Perl 5 source kit.",
    "",
    "Complete documentation for Perl, including FAQ lists, should be found on",
    'this system using "man perl" or "perldoc perl".  If you have access to the',
    "Internet, point your browser at http://www.perl.org/, the Perl Home Page.",
    "EOF"
    )
  writeLines(text = text, con = path, sep = "\n")
  Sys.chmod(path, mode = "0755")
}

test_system_perl <- Sys.which("perl")[["perl"]]

## N.B. travis perlbrew has 5.24.0, but not 5.26.0
test_perl_version <- "perl-5.26.0"

Sys.unsetenv("PERLBREW_ROOT")

test_required_envvars <- init_mock()

test_unset_envvars <-
  list("PERLBREW_MANPATH"    = NA,
       "PERLBREW_PATH"       = NA,
       "PERLBREW_PERL"       = NA,
       "PERLBREW_LIB"        = NA,
       "PERLBREW_VERSION"    = NA,
       "PERL_LOCAL_LIB_ROOT" = NA,
       "PERL_MB_OPT"         = NA,
       "PERL_MM_OPT"         = NA,
       "PERL5LIB"            = NA)
