test_that("can parse inside chunk options", {
  pathchunk <- system.file("extdata", "chunk-options.Rmd", package = "tinkr")
  tinkr::yarn$new(pathchunk)
})
