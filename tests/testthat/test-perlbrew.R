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
  })
})

test_that("edge cases", {
  withr::with_envvar(new = list(PERLBREW_ROOT=NA), code = {
    expect_error(perlbrew(), regexp = "root argument is not valid")
    expect_error(perlbrew(root = "/unknown/directory/path"),
                 regexp = "root argument is not valid")
    expect_error(perlbrew_list(), regexp = "root argument is not valid")
    expect_error(perlbrew_list(root = "/unknown/directory/path"),
                 regexp = "root argument is not valid")
  })
  withr::with_envvar(new = list(), code = {
    expect_error(perlbrew(),
                 regexp = "version argument is not valid")
  })
  withr::with_envvar(new = list(), code = {
    ## TODO: improve interface here.
    expect_warning({ result <- perlbrew(version = "4.10.0") },
                   regexp = "ERROR: The installation \"4.10.0\" is unknown",
                   label = "bad version number")
    expect_false(result, label = "returned false")
  })

})
