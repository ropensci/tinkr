pathmath <- system.file("extdata", "math-example.md", package = "tinkr")
patherr  <- system.file("extdata", "basic-math.md", package = "tinkr")
m <- yarn$new(pathmath)
me <- yarn$new(patherr)

test_that("mal-formed inline math throws an informative error", {
  expect_snapshot_error(me$protect_math())  
})

test_that("block math can be protected", {
  expect_snapshot(show_user(m$protect_math()$tail(48), force = TRUE))
})

test_that("tick boxes are protected by default", {
  expect_snapshot(show_user(m$head(15), force = TRUE))
})

test_that("documents with no math do no harm", {
  x <- xml2::read_xml(commonmark::markdown_xml("no math here"))
  ns <- xml2::xml_ns_rename(xml2::xml_ns(x), "d1" = "md")
  x1 <- as.character(x)
  # block math does nothing
  protect_block_math(x, ns)
  expect_equal(as.character(x), x1)
  # inline math does nothing
  expect_equal(as.character(protect_inline_math(x, ns)), x1)
})

