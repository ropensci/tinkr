context("test-to_xml")

test_that("to_xml works", {
  path <- system.file("extdata", "example1.md", package = "tinkr")
  post_list <- to_xml(path)
  expect_equal(names(post_list)[1], "yaml")
  expect_equal(names(post_list)[2], "body")
  expect_is(post_list[[2]], "xml_document")
})

test_that("to_xml works for Rmd", {
  path <- system.file("extdata", "example2.Rmd", package = "tinkr")
  post_list <- to_xml(path)
  expect_equal(names(post_list)[1], "yaml")
  expect_equal(names(post_list)[2], "body")
  expect_is(post_list[[2]], "xml_document")

  blocks <- post_list[[2]] %>%
    xml2::xml_find_all(xpath = './/d1:code_block',
                       xml2::xml_ns(.)) %>%
    .[xml2::xml_has_attr(., "language")]

  expect_equal(length(blocks), 3)

})
