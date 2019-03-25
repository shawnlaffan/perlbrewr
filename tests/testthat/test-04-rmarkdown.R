context("rmarkdown templates")

test_that("knit doc", {
  # check there is still a template under inst
  template <- "perlbrewr"
  package <- "perlbrewr"
  template_path = system.file("rmarkdown", "templates", template,
                              package = package)
  expect_true(nzchar(template_path))
  # create a draft
  # Have to supply full template path. For some reason system.file() call in
  # rmarkdown::draft() cannot find package, although the above does.
  # Passing package = NULL, ensures template is used verbatim.
  draft <- rmarkdown::draft(file       = file.path(tempdir(), "perlbrewr.Rmd"),
                            template   = template_path,
                            package    = NULL,
                            create_dir = FALSE,
                            edit       = FALSE)
  # knit using rmarkdown rendering
  output <-
    rmarkdown::render(input = draft,
                      output_file = file.path(tempdir(), "perlbrewr.md"),
                      output_format = "github_document",
                      quiet = TRUE)
  # test output
  content <- readLines(output)
  lib_lines <- content[grepl(pattern = "perl-5\\.26\\.0@template", content)]
  expect_equal(length(lib_lines), 3)

  # warning(paste0(content, collapse = "\n"))

})
