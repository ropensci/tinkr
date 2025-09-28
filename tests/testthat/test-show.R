test_that("show_list() will isolate elements", {
  path <- system.file("extdata", "show-example.md", package = "tinkr")
  y <- tinkr::yarn$new(path, sourcepos = TRUE)
  links <- xml2::xml_find_all(y$body, ".//md:link", tinkr::md_ns())
  headings <- xml2::xml_find_all(y$body, ".//md:heading", tinkr::md_ns())
  code <- xml2::xml_find_all(y$body, ".//md:code", tinkr::md_ns())
  blocks <- xml2::xml_find_all(y$body, ".//md:code_block", tinkr::md_ns())
  # show a list of items
  expect_snapshot(show_user(show_list(links), force = TRUE))
  expect_snapshot(show_user(show_list(code), force = TRUE))
  expect_snapshot(show_user(show_list(blocks), force = TRUE))
})

test_that("show_list() will isolate groups of elements", {
  path <- system.file("extdata", "show-example.md", package = "tinkr")
  y <- tinkr::yarn$new(path, sourcepos = TRUE)
  links <- xml2::xml_find_all(y$body, ".//md:link", tinkr::md_ns())
  headings <- xml2::xml_find_all(y$body, ".//md:heading", tinkr::md_ns())
  # show a list of items
  expect_snapshot(show_user(show_list(list(links, headings)), force = TRUE))
})


test_that("show_censor() will show a censored list of disparate elements", {
  path <- system.file("extdata", "show-example.md", package = "tinkr")
  y <- tinkr::yarn$new(path, sourcepos = TRUE)
  pth <- c("*[6]", "*[9]/*[2]", "*[9]/*[3]")
  nodes <- purrr::map(pth, function(p) {
    xml2::xml_find_all(y$body, p)
  })
  expect_length(nodes, 3)
  # the censor option can be adjusted
  withr::local_options(list(
    tinkr.censor.mark = ".",
    tinkr.censor.regex = "[^[:space:]]"
  ))
  disp <- show_censor(nodes)[1:29]
  expect_snapshot(show_user(disp, force = TRUE))
})


test_that("show_censor() will censor elements", {
  path <- system.file("extdata", "show-example.md", package = "tinkr")
  y <- tinkr::yarn$new(path, sourcepos = TRUE)
  items <- xml2::xml_find_all(y$body, ".//md:item", tinkr::md_ns())
  links <- xml2::xml_find_all(y$body, ".//md:link", tinkr::md_ns())
  code <- xml2::xml_find_all(y$body, ".//md:code", tinkr::md_ns())
  blocks <- xml2::xml_find_all(y$body, ".//md:code_block", tinkr::md_ns())
  # give us the original for comparison
  orig <- y$show()
  n <- length(orig) - length(y$frontmatter) + 1
  # the censor option can be adjusted
  withr::local_options(list(
    tinkr.censor.mark = ".",
    tinkr.censor.regex = "[^[:space:]]"
  ))
  lnks <- show_censor(links)
  cd <- show_censor(code)
  blks <- show_censor(blocks)

  # the length of the documents are identical
  expect_length(lnks, n)
  expect_length(cd, n)
  expect_length(blks, n)

  expect_snapshot(show_user(lnks, force = TRUE))
  expect_snapshot(show_user(cd, force = TRUE))
  expect_snapshot(show_user(blks, force = TRUE))
})

test_that("tinkr.censor.regex can adjust for symbols", {
  path <- system.file("extdata", "show-example.md", package = "tinkr")
  y <- tinkr::yarn$new(path, sourcepos = TRUE)
  items <- xml2::xml_find_all(
    y$body,
    ".//node()[not(self::md:code_block)]",
    tinkr::md_ns()
  )

  # the censor option can be adjusted
  withr::local_options(list(
    tinkr.censor.mark = "A",
    tinkr.censor.regex = "[^[:space:][:punct:]]"
  ))
  itms <- show_censor(items)

  # the length of the documents are identical
  # give us the original for comparison
  orig <- y$show()
  n <- length(orig) - length(y$frontmatter) + 1
  expect_length(itms, n)

  expect_snapshot(show_user(itms, force = TRUE))
})


test_that("show_block() will provide context for the elements", {
  path <- system.file("extdata", "show-example.md", package = "tinkr")
  y <- tinkr::yarn$new(path, sourcepos = TRUE)
  items <- xml2::xml_find_all(y$body, ".//md:item", tinkr::md_ns())
  links <- xml2::xml_find_all(y$body, ".//md:link", tinkr::md_ns())
  code <- xml2::xml_find_all(y$body, ".//md:code", tinkr::md_ns())
  blocks <- xml2::xml_find_all(y$body, ".//md:code_block", tinkr::md_ns())

  # show the items in the structure of the document
  b_items <- show_block(items)
  b_links <- show_block(links)
  expect_snapshot(show_user(b_items, force = TRUE))
  expect_snapshot(show_user(b_links, force = TRUE))
  # show the items with context markers ([...]) in the structure of the document
  bmark_links <- show_block(links, mark = TRUE)
  bmark_code <- show_block(code, mark = TRUE)
  expect_snapshot(show_user(bmark_links, force = TRUE))
  expect_snapshot(show_user(bmark_code, force = TRUE))
})
