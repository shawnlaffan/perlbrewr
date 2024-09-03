#context("regression tests")

test_that("regression - handle NULL from knitr::opts_chunk$get('engine.opts')$perl ", {
  words <- perlbrewr:::shellwords(x = NULL)
  expect_equal(words, character(0))
})
