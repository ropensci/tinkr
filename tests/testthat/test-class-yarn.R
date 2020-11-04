pathmd  <- system.file("extdata", "example1.md", package = "tinkr")
pathrmd <- system.file("extdata", "example2.Rmd", package = "tinkr")

test_that("yarn can be created from markdown", {
  y1 <- yarn$new(pathmd)
  t1 <- to_xml(pathmd)
  expect_s3_class(y1, "yarn")
  expect_s3_class(y1$body, "xml_document")
  expect_named(y1$ns, "md")
  expect_match(y1$ns, "commonmark")
})

test_that("yarn can be created from Rmarkdown", {
  y1 <- yarn$new(pathrmd)
  t1 <- to_xml(pathrmd)
  expect_s3_class(y1, "yarn")
  expect_s3_class(y1$body, "xml_document")
  expect_named(y1$ns, "md")
  expect_match(y1$ns, "commonmark")
})

test_that("a yarn object can be written back to markdown", {
  scarf1 <- withr::local_file("yarn-write.md")
  scarf2 <- withr::local_file("yarn-write.Rmd")
  y1 <- yarn$new(pathmd)
  y2 <- yarn$new(pathrmd)
  y1$write(scarf1) 
  y2$write(scarf2) 
  expect_snapshot_file(scarf1)
  expect_snapshot_file(scarf2)
}) 

test_that("a yarn object can be reset", {

  scarf1 <- withr::local_file("yarn-write.md")
  y1 <- yarn$new(pathmd)
  expect_s3_class(y1$body, "xml_document")
  y1$body <- xml2::xml_missing()
  expect_s3_class(y1$body, "xml_missing")
  y1$reset()
  expect_s3_class(y1$body, "xml_document")

})

test_that("random markdown can be added", {

  scarf3 <- withr::local_file("yarn-write-table.md")
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
