test_that("show_list() will isolate elements", {
  
  path <- system.file("extdata", "example1.md", package = "tinkr")
  y <- tinkr::yarn$new(path, sourcepos = TRUE)
  items <- xml2::xml_find_all(y$body, ".//md:item", tinkr::md_ns())
  links <- xml2::xml_find_all(y$body, ".//md:link", tinkr::md_ns())
  code <- xml2::xml_find_all(y$body, ".//md:code", tinkr::md_ns())
  blocks <- xml2::xml_find_all(y$body, ".//md:code_block", tinkr::md_ns())
  # show a list of items 
  expect_snapshot(show_user(show_list(links), force = TRUE))
  expect_snapshot(show_user(show_list(code[1:10]), force = TRUE))
  expect_snapshot(show_user(show_list(blocks[1:2]), force = TRUE))
  
})

test_that("show_list() will isolate groups of elements", {
  
  path <- system.file("extdata", "example1.md", package = "tinkr")
  y <- tinkr::yarn$new(path, sourcepos = TRUE)
  items <- xml2::xml_find_all(y$body, ".//md:item", tinkr::md_ns())
  links <- xml2::xml_find_all(y$body, ".//md:link", tinkr::md_ns())
  code <- xml2::xml_find_all(y$body, ".//md:code", tinkr::md_ns())
  blocks <- xml2::xml_find_all(y$body, ".//md:code_block", tinkr::md_ns())
  # show a list of items 
  expect_snapshot(show_user(show_list(list(links[1:3], links[4:5])), force = TRUE))
  
})


test_that("show_censor() will censor elements", {
  path <- system.file("extdata", "example1.md", package = "tinkr")
  y <- tinkr::yarn$new(path, sourcepos = TRUE)
  items <- xml2::xml_find_all(y$body, ".//md:item", tinkr::md_ns())
  links <- xml2::xml_find_all(y$body, ".//md:link", tinkr::md_ns())
  code <- xml2::xml_find_all(y$body, ".//md:code", tinkr::md_ns())
  blocks <- xml2::xml_find_all(y$body, ".//md:code_block", tinkr::md_ns())
  # give us the original for comparison
  orig <- y$show()
  n <- length(orig) - length(y$yaml) + 1
  # the censor option can be adjusted
  withr::local_options(list(
      tinkr.censor.mark = ".",
      tinkr.censor.regex = "[^[:space:]]"
    )
  )
  lnks <- show_censor(links)
  cd <- show_censor(code)
  blks <- show_censor(blocks)

  # the length of the documents are identical
  expect_length(lnks, n)
  expect_length(cd, n)
  expect_length(blks, n)

  expect_snapshot(show_user(lnks[1:10], force = TRUE))
  expect_snapshot(show_user(tail(cd, 20), force = TRUE))
  expect_snapshot(show_user(blks[19:48], force = TRUE))
})



test_that("show_block() will provide context for the elements", {
  path <- system.file("extdata", "example1.md", package = "tinkr")
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
  b_links <- show_block(links[20:31], mark = TRUE)
  b_code <- show_block(code[1:10], mark = TRUE)
  expect_snapshot(show_user(b_links, force = TRUE))
  expect_snapshot(show_user(b_code, force = TRUE))

})

