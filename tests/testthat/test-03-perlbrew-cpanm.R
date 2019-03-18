context("perlbrew-cpanm")

unlink_cpanm <- function() {
  root <- file.path(project_srcdir(), "tests", "testthat", "mock")
  cpanm_binary <- file.path(root, "bin", "cpanm")
  ## tidy up if required.
  if (file.exists(cpanm_binary)) {
    unlink(cpanm_binary)
  }
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
  expect_warning(cpanm(), "A cpanfile does not exist at .")
})

test_that("install dependencies", {
  skip_if_offline()
  skip_if_not_installed("here")

  lib <- paste0(sample(letters, 8), collapse = "")
  perls <- perlbrew_list()
  perl  <- perls[!grepl(perls, pattern = "@")][1]
  tmp_home <- file.path(tempdir(), paste0(sample(letters, 8), collapse = ""))
  expect_true(dir.create(tmp_home, recursive = TRUE), label = "create directory")

  withr::with_envvar(new = list(PERLBREW_HOME=tmp_home), code = {

    expect_true(perlbrew_lib_create(version = perl, lib = lib, perlbrew.use = TRUE),
                label = "create a temporary library")
    ## subvert mock bin perl, which is only a script
    sys_path <- unlist(strsplit(Sys.getenv("PATH"), split = ":"))
    sys_path <- sys_path[!grepl(sys_path, pattern = "/perl\\-5\\.[^/]*/bin")]
    sys_path <- paste0(sys_path, collapse = ":")
    Sys.setenv("PATH"=sys_path)

    proj_root <- project_srcdir()
    installed <- cpanm_installdeps(cpanfile = file.path(proj_root, "cpanfile"))
    expect_true(installed, label = "cpanm_installdeps ok")
    lib_files <- dir(file.path(tmp_home, "libs", perlbrew_id(perl, lib)),
                     recursive = TRUE, full.names = TRUE)
    expect_true(any(grepl(lib_files, pattern = "/Mojo/Base\\.pm$")),
                label = "Mojo::Base.pm installed")

    # build path like libs/perl-5.24.0@fhcwyaqp/lib/perl5/Mojo/Base.pm
    #base_path <- file.path(tmp_home, "libs", perlbrew_id(perl, lib),
    #                       "lib", "perl5", "Mojo", "Base.pm")
    #expect_true(file.exists(base_path))
    lines <- system("perl -MMojo::Base=-strict -lE 'say 1'", intern = TRUE)
    expect_equal(lines, "1")
  })
})
