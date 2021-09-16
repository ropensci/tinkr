test_that("to_xml works", {
  path <- system.file("extdata", "example1.md", package = "tinkr")
  post_list <- to_xml(path)
  expect_equal(names(post_list)[1], "yaml")
  expect_equal(names(post_list)[2], "body")
  expect_s3_class(post_list[[2]], "xml_document")
})

test_that("to_xml works for Rmd", {
  path <- system.file("extdata", "example2.Rmd", package = "tinkr")
  post_list <- to_xml(path)
  expect_equal(names(post_list)[1], "yaml")
  expect_equal(names(post_list)[2], "body")
  expect_s3_class(post_list[[2]], "xml_document")

  blocks <- post_list[[2]] %>%
    xml2::xml_find_all(xpath = './/d1:code_block',
                       xml2::xml_ns(.)) %>%
    .[xml2::xml_has_attr(., "language")]

  expect_equal(length(blocks), 4)

})


test_that("to_xml will not convert numeric options to character", {
  txt <- "```{r txt, fig.width=4.2, fig.height=4.2, out.width='100%', purl = TRUE}\n#code\n```"
  con <- textConnection(txt)
  code <- xml2::xml_find_first(to_xml(con)$body, "d1:code_block")
  attrs <- xml2::xml_attrs(code)
  expect_equal(attrs[["fig.width"]], "4.2") 
  expect_equal(attrs[["fig.height"]], "4.2") 
  # out.width is the only one that's quoted
  expect_equal(attrs[["out.width"]], shQuote("100%", type = "cmd"))
  expect_equal(attrs[["purl"]], "TRUE")
  expect_equal(attrs[["name"]], "txt")
})


test_that("to_xml will not convert chunk options as r objects to character", {

  txt <- "```{r txt, R.options = list(width = 100), eval = eval_param}\n#code\n```"
  con <- textConnection(txt)
  code <- xml2::xml_find_first(to_xml(con)$body, "d1:code_block")
  attrs <- xml2::xml_attrs(code)
  expect_equal(attrs[["name"]], "txt")
  expect_equal(attrs[["R.options"]], "list(width = 100)")
  expect_equal(attrs[["eval"]], "eval_param")

})

test_that("to_xml will respect logicals for custom chunk options", {

  txt <- "```{r txt, coffee = TRUE, tea = FALSE, fun = 'pizza+icecream'}\n#code\n```"
  con <- textConnection(txt)
  code <- xml2::xml_find_first(to_xml(con)$body, "d1:code_block")
  attrs <- xml2::xml_attrs(code)
  expect_equal(attrs[["name"]], "txt")
  expect_equal(attrs[["coffee"]], "TRUE")
  expect_equal(attrs[["tea"]], "FALSE")
  expect_equal(attrs[["fun"]], shQuote("pizza+icecream", type = "cmd"))

})

test_that("to_xml works with text connection", {

  path <- system.file("extdata", "example2.Rmd", package = "tinkr")
  txt  <- readLines(path)
  con  <- textConnection(txt)
  expect_equal(to_xml(path)$yaml, to_xml(con)$yaml)

})

test_that("to_xml works with sourcepos", {
  path <- system.file("extdata", "example1.md", package = "tinkr")
  post_list <- to_xml(path, sourcepos = TRUE)
  expect_equal(names(post_list)[1], "yaml")
  expect_equal(names(post_list)[2], "body")
  expect_s3_class(post_list[[2]], "xml_document")
  expect_true(xml2::xml_has_attr(post_list[[2]], "sourcepos"))
  expect_match(xml2::xml_attr(post_list[[2]], "sourcepos"), "^1:1-\\d+?:\\d+$")
})

test_that("to_xml works with sourcepos for Rmd", {
  path <- system.file("extdata", "example2.Rmd", package = "tinkr")
  post_list <- to_xml(path, sourcepos = TRUE)
  expect_equal(names(post_list)[1], "yaml")
  expect_equal(names(post_list)[2], "body")
  expect_s3_class(post_list[[2]], "xml_document")
  expect_true(xml2::xml_has_attr(post_list[[2]], "sourcepos"))
  expect_match(xml2::xml_attr(post_list[[2]], "sourcepos"), "^1:1-\\d+?:\\d+$")
  # code blocks retain their attributes
  first_block <- xml2::xml_find_first(post_list[[2]], ".//d1:code_block")

  expect_match(xml2::xml_attr(first_block, "space"), "preserve")
  expect_match(xml2::xml_attr(first_block, "sourcepos"), "^\\d+?:\\d+?-\\d+?:\\d+$")
  expect_match(xml2::xml_attr(first_block, "language"), "r")
  expect_match(xml2::xml_attr(first_block, "name"), "setup")
  expect_match(xml2::xml_attr(first_block, "include"), "FALSE")
  expect_match(xml2::xml_attr(first_block, "eval"), "TRUE")
})
