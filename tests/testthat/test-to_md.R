context("test-to_md")

test_that("to_md works", {
  path <- system.file("extdata", "example1.md", package = "tinkr")
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
  to_md(yaml_xml_list, "newmd.md")
  expect_true(file.exists("newmd.md"))
  expect_silent(to_xml("newmd.md"))
  file.remove("newmd.md")
})


test_that("to_md works for Rmd", {
  path <- system.file("extdata", "example2.Rmd", package = "tinkr")
  yaml_xml_list <- to_xml(path)
  library("magrittr")
  body <- yaml_xml_list$body
  blocks <- body %>%
    xml2::xml_find_all(xpath = './/d1:code_block',
                       xml2::xml_ns(.))
  xml2::xml_set_attr(blocks, "language", "julia")
  yaml_xml_list$body <- body
  # save back and have a look
  to_md(yaml_xml_list, "newmd.Rmd")
  expect_true(file.exists("newmd.Rmd"))
  expect_silent(to_xml("newmd.Rmd"))
  expect_true(stringr::str_detect(toString(readLines("newmd.Rmd")),
                                  "julia"))
  file.remove("newmd.Rmd")
})

