
author_dbg <- FALSE

init_mock <- function(perlbrew_root = file.path(getwd(), "mock"))
{
  required_envvars <-
    list("PERLBREW_ROOT"    = perlbrew_root,
         "PERLBREW_HOME"    = file.path(perlbrew_root, ".perlbrew"),
         "perlbrew_command" = file.path(perlbrew_root, "bin", "perlbrew"))
  do.call("Sys.setenv", required_envvars)
  # initialise perlbrew from mock directory
  init <- system("perl ${perlbrew_command} init", intern = TRUE,
              ignore.stdout = TRUE, ignore.stderr = !author_dbg,
              timeout = 2)
  status <- attr(init, "status")
  if(!is.null(status) && author_dbg) {
    warning(paste0("perlbrew init failed status=", status))
  }
  # create a directory for a version of perl
  five_two_six <- file.path(perlbrew_root, "perls", "perl-5.26.0")
  if( !dir.exists(five_two_six) ) {
    dir.create(five_two_six, recursive = TRUE)
  }
  # write .version file
  text <- c("5.026000")
  writeLines(text = text, con = file.path(five_two_six, ".version"), sep = "\n")
  # create a bin directory
  five_two_six <- file.path(five_two_six, "bin")
  if( !dir.exists(five_two_six) ) {
    dir.create(five_two_six)
  }
  write_mock_perl(path = file.path(five_two_six, "perl"))
  # create a local lib
  lib_create <- suppressWarnings({
    system("perl ${perlbrew_command} lib create 5.26.0@random", intern = TRUE,
           ignore.stdout = TRUE, ignore.stderr = !author_dbg, timeout = 2)
  })
  status <- attr(lib_create, "status")
  if(!is.null(status) && author_dbg) {
    warning(paste0("perlbrew lib create failed status=", status))
  }
  required_envvars
}

write_mock_perl <- function (path = NULL) {
  text <- c(
    "#!/bin/sh",
    "",
    "cat - <<'EOF'",
    "This is perl 5, version 26, subversion 0 (v5.26.0) built for x86_64-linux",
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
