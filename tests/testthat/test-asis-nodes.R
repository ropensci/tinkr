pathmath <- system.file("extdata", "math-example.md", package = "tinkr")
patherr  <- system.file("extdata", "basic-math.md", package = "tinkr")
m <- yarn$new(pathmath)
me <- yarn$new(patherr)

test_that("mal-formed inline math throws an informative error", {
  expect_snapshot_error(me$protect_math())  
})

test_that("block math can be protected", {
  expect_length(xml2::xml_ns(m$body), 1L)
  expect_equal(md_ns()[[1]], xml2::xml_ns(m$body)[[1]])
  expect_snapshot(show_user(m$protect_math()$tail(48), force = TRUE))
  expect_length(xml2::xml_ns(m$body), 1L)
  expect_equal(md_ns()[[1]], xml2::xml_ns(m$body)[[1]])
})

test_that("tick boxes are protected by default", {
  expect_length(xml2::xml_ns(m$body), 1L)
  expect_equal(md_ns()[[1]], xml2::xml_ns(m$body)[[1]])
  expect_snapshot(show_user(m$head(15), force = TRUE))
})

test_that("documents with no math do no harm", {
  x <- xml2::read_xml(commonmark::markdown_xml("no math here"))
  expect_length(xml2::xml_ns(x), 1L)
  expect_equal(md_ns()[[1]], xml2::xml_ns(x)[[1]])
  x1 <- as.character(x)
  x <- protect_math(x, md_ns())
  expect_length(xml2::xml_ns(x), 1L)
  expect_equal(md_ns()[[1]], xml2::xml_ns(x)[[1]])
  # block math does nothing
  expect_equal(as.character(x), x1)
})

