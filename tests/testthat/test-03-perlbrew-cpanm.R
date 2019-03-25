context("perlbrew cpanm")

unlink_cpanm <- function() {
  root <- file.path(project_srcdir(), "tests", "testthat", "mock")
  cpanm_binary <- file.path(root, "bin", "cpanm")
  ## tidy up if required.
  if (file.exists(cpanm_binary)) {
    unlink(cpanm_binary)
  }
}

filter_path <- function(sys_path) {
  ## subvert mock bin perl, which is only a script
  sys_path <- unlist(strsplit(sys_path, split = ":"))
  sys_path <- sys_path[!grepl(sys_path, pattern = "/perl\\-5\\.[^/]*/bin")]
  sys_path <- paste0(sys_path, collapse = ":")
  sys_path
}

test_that("without install", {
  withr::with_envvar(new = list(PATH="/bin"), code = {
    expect_warning(cpanm(), "cpanm command not available")
  })
})

test_that("install cpanm - mock does not have it", {
  skip_if_offline()
  unlink_cpanm()
  installed <- perlbrew_install_cpanm()
  expect_true(installed, label = "install without force")
})

test_that("install cpanm - mock does not have it", {
  skip_if_offline()
  skip_if_covr() # unsure the cause of this failure under covr
  unlink_cpanm()
  installed <- perlbrew_install_cpanm(force = TRUE)
  expect_true(installed, label = "install with force")
})

test_that("no cpanfile", {
  expect_warning(cpanm(), ". does not appear to be a distribution")
})

test_that("install dependencies", {
  skip_if_offline()
  skip_if_not_installed("here")

  lib <- paste0(sample(letters, 8), collapse = "")
  perls <- perlbrew_list()
  perl  <- perls[!grepl(perls, pattern = "@")][1]
  tmp_home <- file.path(tempdir(), paste0(sample(letters, 8), collapse = ""))

  expect_true(dir.create(tmp_home, recursive = TRUE), label = "create directory")

  sys_path <- Sys.getenv("PATH")
  withr::with_envvar(
    new = list(PERLBREW_HOME = tmp_home,
               PERLBREW_LIB = NA,
               PATH = sys_path),
    code = {
      expect_true(perlbrew_lib_create(version = perl, lib = lib, perlbrew.use = TRUE),
                  label = "create a temporary library")
      ## filter path to get real perl binary
      ## only install pure perl and expect to run!
      Sys.setenv("PATH"=filter_path(sys_path))

      cpanfile <- system.file("cpanfile", package = "perlbrewr")
      installed <- cpanm_installdeps(cpanfile = cpanfile)
      expect_true(installed, label = "cpanm_installdeps ok")
      lib_files <-
        list.files(file.path(tmp_home, "libs", perlbrew_id(perl, lib)),
                   recursive = TRUE, full.names = TRUE,
                   pattern = "\\.pm$")
      expect_true(any(grepl(lib_files, pattern = "/Mojo/Base\\.pm$")),
                  label = "Mojo::Base.pm installed")

      lines <- system("perl -MMojo::Base=-strict -lE 'say 1'", intern = TRUE)
      expect_equal(lines, "1")
    })
})

test_that("distribution testing", {
  wd <- getwd()
  ## directories
  expect_true(is.perl_dist(file.path(wd, "dists", "test001")))
  expect_true(is.perl_dist(file.path(wd, "dists", "test002")))
  expect_true(is.perl_dist(file.path(wd, "dists", "test003")))
  expect_false(is.perl_dist(file.path(wd, "dists", "test004")))
  ## files
  expect_true(is.perl_dist(file.path(wd, "dists", "test005.tar.gz")))
  expect_false(is.perl_dist(file.path(wd, "dists", "test005.tar.bz2")))
  expect_false(is.perl_dist(file.path(wd, "dists", "test100.tar.gz")))
})

test_that("github install", {
  skip_if_offline()

  tmp <- file.path(tempdir(), ".perlbrew")
  if(!dir.exists(tmp)) {
    dir.create(tmp)
  }
  expect_true(dir.exists(tmp))
  expect_warning(cpanm_install_github("miyagawa"),
                 "Invalid git repo specification: 'miyagawa'")

  sys_path <- Sys.getenv("PATH")
  withr::with_envvar(
    new = list(PERLBREW_HOME = tmp,
               PERLBREW_LIB = NA,
               PATH = sys_path),
    code = {
      perl <- "perl-5.26.0"
      lib <- "example"
      expect_true(perlbrew_lib_create(version = perl, lib = lib,
                                      perlbrew.use = TRUE))
      ## filter path to get real perl binary
      ## only install pure perl and expect to run!
      Sys.setenv("PATH"=filter_path(sys_path))

      expect_true(cpanm_install_github("miyagawa/cpanfile@master"))
      lib_files <-
        list.files(file.path(tmp, "libs", perlbrew_id(perl, lib)),
                   recursive = TRUE,
                   full.names = TRUE,
                   pattern = "\\.pm$")
      expect_true(any(grepl(lib_files, pattern = "/Module/CPANfile\\.pm$")),
                  label = "Module::CPANfile.pm installed")
      lines <- system("perl -MModule::CPANfile -lE 'say 1'", intern = TRUE)
      expect_equal(lines, "1")
    })
})
