test_that("can parse inside chunk options", {
  pathchunk <- system.file("extdata", "chunk-options.Rmd", package = "tinkr")
  inside_stitch <- tinkr::yarn$new(pathchunk)
  code_chunks <-  inside_stitch$body %>%
    xml2::xml_find_all(xpath = './/d1:code_block[@language]',
      xml2::xml_ns(.))
  expect_setequal(
    names(xml2::xml_attrs(code_chunks[[1]])),
    c("space", "language", "name", "message-outchunk", "inchunk_options")
  )
  expect_setequal(
    names(xml2::xml_attrs(code_chunks[[2]])),
    c("space", "language", "name", "inchunk_options")
  )

  directory <- withr::local_tempdir()

  inside_stitch$write(file.path(directory, "chunk-options.Rmd"))
  expect_snapshot_file(file.path(directory, "chunk-options.Rmd"))
})
