test_that("mal-formed inline math throws an informative error", {
  patherr  <- system.file("extdata", "basic-math.md", package = "tinkr")
  me <- yarn$new(patherr, sourcepos = TRUE)
  expect_snapshot_error(me$protect_math())
})

test_that("multi-line inline math can have punctutation after", {
  template <- "C) $E(\\text{Weight}) = 81.37 + 1.26 \\times x_1 +\n2.65 \\times x_2$punk\n"
  for (punk in c('--', '---', ',', ';', '.', '?', ')', ']', '}', '>')) {
    expected <- sub("punk", punk, template)
    math <- commonmark::markdown_xml(expected)
    txt <- xml2::read_xml(math)
    protxt <- protect_inline_math(txt, md_ns())
    actual <- to_md(list(yaml = NULL, body = protxt))
    expect_equal(actual, expected)
  }
})

test_that("math with inline code still works", {

  expected <- "some inline math, for example $R^2 = `r runif(1)`$, is failing with code\n"
  math <- commonmark::markdown_xml(expected)
  txt <- xml2::read_xml(math)
  protxt <- protect_inline_math(txt, md_ns())
  actual <- to_md(list(yaml = NULL, body = protxt))
  expect_equal(actual, expected)

})

test_that("math with inline code still works", {

  expected <- "example\n\n- 42 $\\alpha$,\n- $R^2 = `r runif(1)`$,\n- is working with $\\beta$ code\n"
  math <- commonmark::markdown_xml(expected)
  txt <- xml2::read_xml(math)
  protxt <- protect_inline_math(txt, md_ns())
  actual <- to_md(list(yaml = NULL, body = protxt))
  expect_equal(actual, expected)

})

test_that("math with inline code works -- one character", {

  expected <- "example\n\n- 42 $R$ note\n"
  math <- commonmark::markdown_xml(expected)
  txt <- xml2::read_xml(math)
  protxt <- protect_inline_math(txt, md_ns())
  actual <- to_md(list(yaml = NULL, body = protxt))
  expect_equal(actual, expected)

})


test_that("math that starts a line will be protected", {
  expected <-  "- so $\\beta^2 = `r runif(1)`$ works and\n- $\\beta$ does too\n"
  math <- commonmark::markdown_xml(expected)
  txt <- xml2::read_xml(math)
  protxt <- protect_inline_math(txt, md_ns())
  actual <- to_md(list(yaml = NULL, body = protxt))
  expect_equal(actual, expected)
})


test_that("block math can be protected", {
  pathmath <- system.file("extdata", "math-example.md", package = "tinkr")
  m <- yarn$new(pathmath, sourcepos = TRUE)
  expect_length(xml2::xml_ns(m$body), 1L)
  expect_equal(md_ns()[[1]], xml2::xml_ns(m$body)[[1]])
  expect_snapshot(show_user(m$protect_math()$tail(48), force = TRUE))
  expect_length(xml2::xml_ns(m$body), 1L)
  expect_equal(md_ns()[[1]], xml2::xml_ns(m$body)[[1]])
})

test_that("tick boxes are protected by default", {
  pathmath <- system.file("extdata", "math-example.md", package = "tinkr")
  m <- yarn$new(pathmath, sourcepos = TRUE)
  m$protect_math()
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

test_that("protect_unescaped() will throw a warning if no sourcpos is available", {
  pathmath <- system.file("extdata", "math-example.md", package = "tinkr")
  m <- yarn$new(pathmath, sourcepos = TRUE)
  x <- to_xml(m$path)
  expect_warning({
    protect_unescaped(x$body, txt = readLines(m$path)[-seq_along(m$yaml)], "sourcepos")
  })
})

