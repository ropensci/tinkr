pathmath <- system.file("extdata", "math-example.md", package = "tinkr")
patherr  <- system.file("extdata", "basic-math.md", package = "tinkr")
m <- yarn$new(pathmath)
me <- yarn$new(patherr)

test_that("mal-formed inline math throws an informative error", {
  expect_snapshot_error(me$protect_math())
})

test_that("multi-line inline math can have punctutation after", {
  template <- "C) $E(\\text{Weight}) = 81.37 + 1.26 \\times x_1 +\n2.65 \\times x_2$punk\n"
  for (punk in c('--', '---', ',', ';', '.', '?', ')', ']', '}', '>')) {
    expected <- sub("punk", punk, template)
    math <- commonmark::markdown_xml(expected)
    txt <- xml2::read_xml(math)
    xml2::xml_ns_strip(txt)
    protxt <- protect_inline_math(txt, md_ns())
    actual <- to_md(list(yaml = NULL, body = protxt))
    expect_equal(actual, expected)
  }
})

test_that("math with inline code still works", {

  expected <- "some inline math, for example $R^2 = `r runif(1)`$, is failing with code\n"
  math <- commonmark::markdown_xml(expected)
  txt <- xml2::read_xml(math)
  xml2::xml_ns_strip(txt)
  protxt <- protect_inline_math(txt, md_ns())
  actual <- to_md(list(yaml = NULL, body = protxt))
  expect_equal(actual, expected)

})

test_that("math with inline code still works", {

  expected <- "example\n\n- 42 $\\alpha$,\n- $R^2 = `r runif(1)`$,\n- is working with $\\beta$ code\n"
  math <- commonmark::markdown_xml(expected)
  txt <- xml2::read_xml(math)
  xml2::xml_ns_strip(txt)
  protxt <- protect_inline_math(txt, md_ns())
  actual <- to_md(list(yaml = NULL, body = protxt))
  expect_equal(actual, expected)

})


test_that("math that starts a line will be protected", {
  expected <-  "- so $\\beta^2 = `r runif(1)`$ works and\n- $\\beta$ does too\n"
  math <- commonmark::markdown_xml(expected)
  txt <- xml2::read_xml(math)
  xml2::xml_ns_strip(txt)
  protxt <- protect_inline_math(txt, md_ns())
  actual <- to_md(list(yaml = NULL, body = protxt))
  expect_equal(actual, expected)
})


test_that("block math can be protected", {
  expect_snapshot(show_user(m$protect_math()$tail(48), force = TRUE))
})

test_that("tick boxes are protected by default", {
  expect_snapshot(show_user(m$head(15), force = TRUE))
})

test_that("documents with no math do no harm", {
  x <- xml2::read_xml(commonmark::markdown_xml("no math here"))
  xml2::xml_ns_strip(x)
  x1 <- as.character(x)
  x <- protect_math(x, md_ns())
  # block math does nothing
  expect_equal(as.character(x), x1)
})

