test_that("to_md works", {
  path <- system.file("extdata", "example1.md", package = "tinkr")
  newmd <- tempfile(pattern = "newmd", fileext = ".Rmd")
  on.exit(file.remove(newmd))

  yaml_xml_list <- to_xml(path)
  library("magrittr")
  # transform level 3 headers into level 1 headers
  body <- yaml_xml_list$body
  body %>%
    xml2::xml_find_all(xpath = './/d1:heading',
                       xml2::xml_ns(.)) %>%
    .[xml2::xml_attr(., "level") == "3"] -> headers3
  xml2::xml_set_attr(headers3, "level", 1)
  yaml_xml_list$body <- body
  # save back and have a look
  to_md(yaml_xml_list, newmd)
  expect_true(file.exists(newmd))
  expect_silent(to_xml(newmd))
})


test_that("to_md works for Rmd", {
  path <- system.file("extdata", "example2.Rmd", package = "tinkr")
  newmd <- tempfile(pattern = "newmd", fileext = ".Rmd")
  on.exit(file.remove(newmd))

  yaml_xml_list <- to_xml(path, sourcepos = TRUE)
  library("magrittr")
  body <- yaml_xml_list$body
  blocks <- yaml_xml_list$body %>%
    xml2::xml_find_all(xpath = './/d1:code_block',
                       xml2::xml_ns(.))

  # Two non-evaluated blocks
  lang_attr <- xml2::xml_attr(blocks, "language")
  expect_equal(sum(is.na(lang_attr)), 2)

  # One block with info
  info_attr <- xml2::xml_attr(blocks, "info")
  expect_equal(sum(!is.na(info_attr)), 1)

  xml2::xml_set_attr(blocks, "language", "julia")

  # save back and have a look
  to_md(yaml_xml_list, newmd)
  expect_true(file.exists(newmd))

  # Still one block with info after writing (the process has not clobbered things)
  info_attr <- xml2::xml_attr(blocks, "info")
  expect_equal(sum(!is.na(info_attr)), 1)

  expect_silent(to_xml(newmd))
  expect_true(stringr::str_detect(toString(readLines(newmd)),
                                  "julia"))
  expect_false(stringr::str_detect(toString(readLines(newmd)),
                                   "sourcepos"))
})

test_that("to_md does not break tables", {
  path <- system.file("extdata", "table.md", package = "tinkr")
  tmpdir <- tempdir()
  dir.create(tmpdir)
  newmd <- file.path(tmpdir, "table.md")
  on.exit(file.remove(newmd))

  yaml_xml_list <- to_xml(path)
  to_md(yaml_xml_list, newmd)
  testthat::expect_snapshot_file(newmd)
})

test_that("to_md does not break checkboxes", {
  path <- system.file("extdata", "checkboxes.md", package = "tinkr")
  tmpdir <- tempdir()
  dir.create(tmpdir)
  newmd <- file.path(tmpdir, "checkboxes.md")
  on.exit(file.remove(newmd))

  yaml_xml_list <- to_xml(path)
  to_md(yaml_xml_list, newmd)
  testthat::expect_snapshot_file(newmd)
})
