context("perlbrew")

library(withr)

test_that("correctly initialised - sanity check", {
  root <- Sys.getenv("PERLBREW_ROOT")
  expect_match(root, "mock$", label = "init_mock() successful")
  expect_in_environment(vars  = names(test_required_envvars),
                        label = "home, root, version and command, etc...")
  expect_perl(regexp = test_system_perl, fixed = TRUE, label = "system perl")
})

test_that("list", {
  brew_list <- perlbrew_list()
  expect_equivalent(brew_list, c("perl-5.24.0", "perl-5.26.0", "perl-5.26.0@random"))
})

test_that("brewing", {
  root <- Sys.getenv("PERLBREW_ROOT")
  expect_in_environment(vars = names(test_required_envvars))

  withr::with_envvar(new = test_unset_envvars, code = {
    perlbrew(root = root, version = "5.26.0")

    expect_in_environment(vars = names(test_required_envvars))
    expect_in_environment(vars = c("PERLBREW_MANPATH",
                                   "PERLBREW_PATH",
                                   "PERLBREW_PERL",
                                   "PERLBREW_VERSION"))
    expect_equal(Sys.getenv("PERLBREW_PERL"), "perl-5.26.0",
                 label = "perl version var set")
    expect_not_in_environment(vars = c("PERLBREW_LIB", "PERL5LIB"))
    expect_perl(regexp = "mock/perls/perl-5.26.0/bin/perl$")

    expect_knitr_path_set(which_perl())
    if (author_dbg) warn_perlbrew_envvars()
  })

  withr::with_envvar(new = test_unset_envvars, code = {
    if (author_dbg) warn_perlbrew_envvars()

    perlbrew(root = root, version = "5.26.0", lib = "random")

    expect_in_environment(vars = names(test_required_envvars))
    expect_in_environment(vars = c("PERLBREW_MANPATH",
                                   "PERLBREW_PATH",
                                   "PERLBREW_PERL",
                                   "PERLBREW_LIB",
                                   "PERLBREW_VERSION",
                                   "PERL_LOCAL_LIB_ROOT",
                                   "PERL_MB_OPT",
                                   "PERL_MM_OPT",
                                   "PERL5LIB"))
    expect_equal(Sys.getenv("PERLBREW_PERL"), "perl-5.26.0",
                 label = "perl version var set")
    expect_equal(Sys.getenv("PERLBREW_LIB"), "random",
                 label = "library var set")
    expect_perl(regexp = "mock/perls/perl-5.26.0/bin/perl$")

    brew_list <- perlbrew_list()
    expect_equivalent(brew_list, c("perl-5.24.0", "perl-5.26.0", "perl-5.26.0@random"))
    expect_equal(attr(brew_list, "active"), c("perl-5.26.0@random"))
    expect_knitr_path_set(which_perl())
    expect_knitr_opts_match(Sys.getenv("PERL5LIB"))

    if (author_dbg) warn_perlbrew_envvars()
  })

})

test_that("drinking", {
  root <- Sys.getenv("PERLBREW_ROOT")
  expect_in_environment(vars = names(test_required_envvars))

  withr::with_envvar(new = test_unset_envvars, code = {
    perlbrew(root = root, version = "5.26.0", lib = "random")
    expect_perl(regexp = "mock/perls/perl-5.26.0/bin/perl$")

    expect_in_environment(vars = names(test_required_envvars))
    expect_in_environment(vars = c("PERLBREW_MANPATH",
                                   "PERLBREW_PATH",
                                   "PERLBREW_PERL",
                                   "PERLBREW_LIB",
                                   "PERLBREW_VERSION",
                                   "PERL_LOCAL_LIB_ROOT",
                                   "PERL_MB_OPT",
                                   "PERL_MM_OPT",
                                   "PERL5LIB"))
    expect_equal(Sys.getenv("PERLBREW_PERL"), "perl-5.26.0",
                 label = "perl version var set")
    expect_equal(Sys.getenv("PERLBREW_LIB"), "random",
                 label = "library var set")
    if (author_dbg) warn_perlbrew_envvars()

    perlbrew_off(root = root)

    expect_not_in_environment(vars = c("PERLBREW_MANPATH",
                                       "PERLBREW_PERL",
                                       "PERLBREW_LIB",
                                       "PERL_LOCAL_LIB_ROOT",
                                       "PERL_MB_OPT",
                                       "PERL_MM_OPT",
                                       "PERL5LIB"))
    expect_perl(regexp = test_system_perl)
    expect_knitr_path_set(test_system_perl)
  })
})

test_that("creating libraries", {
  tmp <- file.path(tempdir(), ".perlbrew")
  if(!dir.exists(tmp)) {
    dir.create(tmp)
  }
  withr::with_envvar(new = c("PERLBREW_HOME" = tmp), code = {
    expect_true(perlbrew_lib_create(version = "5.26.0", lib = "example"))
    brew_list <- perlbrew_list()
    expect_equivalent(brew_list, c("perl-5.24.0", "perl-5.26.0", "perl-5.26.0@example"))
    brew_list <- perlbrew_list(include.libs = FALSE)
    expect_equivalent(brew_list, c("perl-5.24.0", "perl-5.26.0"))
  })
})

test_that("error conditions", {

  expect_error(perlbrew(),
               regexp = "version argument is not valid")
  ## TODO: improve interface here.
  expect_warning({ result <- perlbrew(version = "4.10.0") },
                 regexp = "ERROR: The installation \"4.10.0\" is unknown",
                 label = "bad version number")
  expect_false(result, label = "returned false")
})

test_that("edge cases", {
  mock_root <- Sys.getenv("PERLBREW_ROOT", unset = "/fail/")
  sys_path <- unlist(strsplit(Sys.getenv("PATH"), split = ":"))
  sys_path <- sys_path[!grepl(sys_path, pattern = mock_root)]
  sys_path <- sys_path[!grepl(sys_path, pattern = "/perlbrew[^/]*/bin")]
  sys_path <- paste0(sys_path, collapse = ":")

  no_perlbrew <- list(
    PERLBREW_ROOT=NA,
    PERLBREW_HOME=NA,
    perlbrew_command=NA,
    PATH=sys_path)

  withr::with_envvar(new = no_perlbrew, code = {
    expect_error(perlbrew(), regexp = "root argument is not valid")
    expect_error(perlbrew(root = "/unknown/directory/path"),
                 regexp = "root argument is not valid")
    expect_error(perlbrew_list(), regexp = "root argument is not valid")
    expect_error(perlbrew_list(root = "/unknown/directory/path"),
                 regexp = "root argument is not valid")

    withr::with_options(new = list("perlbrewr.use_bundled"=TRUE), code = {
      expect_warning(expect_error(perlbrew(), regexp = "version argument is not valid"),
                     "Using bundled perlbrew root from perlbrewr package.")
    })
  })

  withr::with_envvar(new = no_perlbrew, code = {
    tmp_root <- file.path(tempdir(), "perlbrew")
    dir.create(file.path(tmp_root, "bin"), recursive = TRUE)
    file.copy(file.path(mock_root, "bin", "perlbrew"),
              file.path(tmp_root, "bin", "perlbrew"),
              copy.mode = TRUE)
    tmp_vars <- init_mock(tmp_root)
    withr::with_envvar(
      new = list(PERLBREW_ROOT=NA, PERLBREW_HOME=NA, perlbrew_command=NA),
      code = {
        expect_error(perlbrew_list(tmp_vars$PERLBREW_ROOT),
                     "error in running command")
      })
  })

})
