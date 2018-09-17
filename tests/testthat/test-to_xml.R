context("test-to_xml")

test_that("to_xml works", {
  path <- system.file("extdata", "example1.md", package = "tinkr")
  post_list <- to_xml(path)
  expect_equal(names(post_list)[1], "yaml")
  expect_equal(names(post_list)[2], "body")
  expect_is(post_list[[2]], "xml_document")
})
