test_that("can parse inside chunk options", {
  pathchunk <- system.file("extdata", "chunk-options.Rmd", package = "tinkr")
  inside_stitch <- tinkr::yarn$new(pathchunk)
  code_chunk <-  inside_stitch$body %>%
    xml2::xml_find_first(xpath = './/d1:code_block[@language]',
      xml2::xml_ns(.))
  expect_mapequal(
    xml2::xml_attrs(code_chunk),
    c(space = "preserve", language = "r", name = "", `message-outchunk` = "FALSE",
      `echo-inchunk` = "FALSE", `fig.width-inchunk` = "10", `fig.cap-inchunk` = "This is a long caption."
    )
  )

  directory <- withr::local_tempdir()

  inside_stitch$write(file.path(directory, "chunk-options.Rmd"))
  expect_snapshot_file(file.path(directory, "chunk-options.Rmd"))
})
