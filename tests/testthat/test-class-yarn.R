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
