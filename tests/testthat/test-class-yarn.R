pathmd  <- system.file("extdata", "example1.md", package = "tinkr")
pathrmd <- system.file("extdata", "example2.Rmd", package = "tinkr")
`%<%` <- magrittr::`%>%`

test_that("an empty yarn object can be created", {
  y1 <- yarn$new()
  expect_s3_class(y1, "yarn")
  expect_null(y1$body)
  expect_null(y1$yaml)
  expect_null(y1$ns)
  expect_null(y1$path)
})


test_that("yarn can be created from markdown", {
  y1 <- yarn$new(pathmd)
  t1 <- to_xml(pathmd)
  expect_s3_class(y1, "yarn")
  expect_s3_class(y1$body, "xml_document")
  expect_named(y1$ns, "md")
  expect_match(y1$ns, "commonmark")
})

test_that("yarn show, head, and tail methods work", {

  y1 <- yarn$new(pathrmd)
  expect_snapshot(show_user(res <- y1$show(), TRUE))
  expect_type(res, "character") 

  expect_snapshot(show_user(res <- y1$head(10), TRUE))
  expect_length(res, 10) %>%
    expect_type("character")

  expect_snapshot(show_user(res <- y1$tail(11), TRUE))
  expect_length(res, 11) %>%
    expect_type("character")

})

test_that("yarn can be created from Rmarkdown", {
  y1 <- yarn$new(pathrmd)
  t1 <- to_xml(pathrmd)
  expect_s3_class(y1, "yarn")
  expect_s3_class(y1$body, "xml_document")
  expect_named(y1$ns, "md")
  expect_match(y1$ns, "commonmark")
})

test_that("the write method needs a filename", {
  expect_error(yarn$new(pathmd)$write(), "Please provide a file path")
})

test_that("a yarn object can be written back to markdown", {
  tmpdir <- withr::local_tempdir()
  scarf1 <- withr::local_file(file.path(tmpdir, "yarn.md"))
  scarf2 <- withr::local_file(file.path(tmpdir, "yarn.Rmd"))
  y1 <- yarn$new(pathmd)
  y2 <- yarn$new(pathrmd)
  y1$write(scarf1) 
  y2$write(scarf2) 
  expect_snapshot_file(scarf1)
  expect_snapshot_file(scarf2)
}) 

test_that("a yarn object can be reset", {

  scarf1 <- withr::local_tempfile(fileext = "md")
  y1 <- yarn$new(pathmd, sourcepos = TRUE, encoding = "utf-8")

  expect_equal(y1$.__enclos_env__$private$encoding, "utf-8")
  expect_true(y1$.__enclos_env__$private$sourcepos)
  expect_s3_class(y1$body, "xml_document")
  expect_false(is.na(xml2::xml_attr(y1$body, "sourcepos")))

  y1$body <- xml2::xml_missing()
  expect_s3_class(y1$body, "xml_missing")

  y1$reset()
  expect_s3_class(y1$body, "xml_document")
  expect_equal(y1$.__enclos_env__$private$encoding, "utf-8")
  expect_true(y1$.__enclos_env__$private$sourcepos)
  expect_false(is.na(xml2::xml_attr(y1$body, "sourcepos")))

})

test_that("random markdown can be added", {

  tmpdir <- withr::local_tempdir()
  scarf3 <- withr::local_file(file.path(tmpdir, "yarn-kilroy.md"))
  mdtable <- system.file("extdata", "table.md", package = "tinkr")
  t1 <- yarn$new(mdtable)
  expect_equal(xml2::xml_name(xml2::xml_child(t1$body)), "table")
  expect_length(xml2::xml_find_all(t1$body, "link", t1$ns), 0L)
  
  newmd <- c("# TABLE HERE\n\n", 
    "[KILROY](https://en.wikipedia.org/wiki/Kilroy_was_here) WAS **HERE**\n\n",
    "stop copying me!" # THIS WILL BE COPIED TWICE
  )
  t1$add_md(paste(newmd, collapse = ""))$add_md(toupper(newmd[[3]]), where = 3)
  expect_length(xml2::xml_find_all(t1$body, "md:link", t1$ns), 0L)
  
  t1$write(scarf3)
  expect_snapshot_file(scarf3)

})
