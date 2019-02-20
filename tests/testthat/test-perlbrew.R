context("perlbrew")

library(withr)

test_that("correctly initialised - sanity check", {
  root <- Sys.getenv("PERLBREW_ROOT")
  expect_match(root, "mock$", label = "init_mock() successful")
  expect_in_environment(vars  = names(test_required_envvars),
                        label = "home, root, version and command, etc...")

  brew_list <- system("perl ${perlbrew_command} list", intern = TRUE)

  expect_equal(brew_list, c("  perl-5.26.0", "  perl-5.26.0@random"),
               label = "perl 5.26.0")
  expect_perl(regexp = test_system_perl, fixed = TRUE, label = "system perl")
})

test_that("brewing", {
  root <- Sys.getenv("PERLBREW_ROOT")
  expect_in_environment(vars = names(test_required_envvars))

  withr::with_envvar(new = test_unset_envvars, code = {
    perlbrewr(root = root, version = "5.26.0")

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

    perlbrewr(root = root, version = "5.26.0", lib = "random")

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
    if (author_dbg) warn_perlbrew_envvars()
  })

})

test_that("drinking", {
  root <- Sys.getenv("PERLBREW_ROOT")
  expect_in_environment(vars = names(test_required_envvars))

  withr::with_envvar(new = test_unset_envvars, code = {
    perlbrewr(root = root, version = "5.26.0", lib = "random")
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

    unperlbrewr(root = root)

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
