context("perlbrew knitr")

test_that("unit tests augument knitr::opts_chunk - engine.opts", {
  opt <- "engine.opts"
  #
  # ADD
  #
  perlbrewr:::augment_knitr_opts_chunk(opt = opt,
                                       value = "-I/tmp",
                                       action = "add")
  expect_equal(knitr::opts_chunk$get(opt)$perl, "-I/tmp")

  perlbrewr:::augment_knitr_opts_chunk(opt = opt,
                                       value = "-I/tmp",
                                       action = "add")
  expect_equal(knitr::opts_chunk$get(opt)$perl, "-I/tmp")

  perlbrewr:::augment_knitr_opts_chunk(opt = opt,
                                       value = "-I/opt/perl5",
                                       action = "add")
  expect_equal(knitr::opts_chunk$get(opt)$perl, "-I/tmp -I/opt/perl5")

  perlbrewr:::augment_knitr_opts_chunk(opt = opt,
                                       value = "-I/opt/perl5 -CS",
                                       action = "add")
  expect_equal(knitr::opts_chunk$get(opt)$perl, "-I/tmp -I/opt/perl5 -CS")

  #
  # REMOVE
  #
  perlbrewr:::augment_knitr_opts_chunk(opt = opt,
                                       value = "-I/opt/perl5",
                                       action = "remove")
  expect_equal(knitr::opts_chunk$get(opt)$perl, "-I/tmp -CS")

  perlbrewr:::augment_knitr_opts_chunk(opt = opt,
                                       value = "-I/opt/perl5 -I/tmp -CS",
                                       action = "remove")
  expect_equal(knitr::opts_chunk$get(opt)$perl, "")

  perlbrewr:::augment_knitr_opts_chunk(opt = opt,
                                       value = "-I/opt/perl5 -I/tmp -CS",
                                       action = "remove")
  expect_equal(knitr::opts_chunk$get(opt)$perl, "")

  #
  # correct set diff
  #
  perlbrewr:::augment_knitr_opts_chunk(opt = opt,
                                       value = "-I/opt/perl5 -CS",
                                       action = "add")
  expect_equal(knitr::opts_chunk$get(opt)$perl, "-I/opt/perl5 -CS")
  perlbrewr:::augment_knitr_opts_chunk(opt = opt,
                                       value = "-I/opt/perl5 -CS -a",
                                       action = "remove")
  expect_equal(knitr::opts_chunk$get(opt)$perl, "")

  #
  # check set diff again
  #
  perlbrewr:::augment_knitr_opts_chunk(opt = opt,
                                       value = "-I/opt/perl5 -CS",
                                       action = "add")
  expect_equal(knitr::opts_chunk$get(opt)$perl, "-I/opt/perl5 -CS")
  # removing an empty string does not change value
  perlbrewr:::augment_knitr_opts_chunk(opt = opt,
                                       value = "",
                                       action = "remove")
  expect_equal(knitr::opts_chunk$get(opt)$perl, "-I/opt/perl5 -CS")
})

test_that("unit tests augument knitr::opts_chunk - engine.path", {
  opt <- "engine.path"
  # add
  perlbrewr:::augment_knitr_opts_chunk(opt = opt,
                                       value = "/usr/local/perlbrew/bin/perl",
                                       action = "add")
  expect_equal(knitr::opts_chunk$get(opt)$perl, "/usr/local/perlbrew/bin/perl")
  # check add replaces
  perlbrewr:::augment_knitr_opts_chunk(opt = opt,
                                       value = "/usr/local/perlbrew-0.76/bin/perl",
                                       action = "add")
  expect_equal(knitr::opts_chunk$get(opt)$perl, "/usr/local/perlbrew-0.76/bin/perl")
  # remove unsets completely - NULL
  perlbrewr:::augment_knitr_opts_chunk(opt = opt,
                                       value = "/usr/local/perlbrew/bin/perl",
                                       action = "remove")
  expect_equal(knitr::opts_chunk$get(opt)$perl, NULL)
})

test_that("unit tests augument knitr::opts_chunk - engine.path non list", {
  opt <- "engine.path"
  knitr::opts_chunk$set(engine.path = "/usr/bin/python")
  # add
  expect_error(
    perlbrewr:::augment_knitr_opts_chunk(opt = opt,
                                         value = "/usr/local/perlbrew/bin/perl",
                                         action = "add"),
    "do not know how to do this"
  )
  # leave it as something we can manage
  knitr::opts_chunk$set(engine.path = list())
})


