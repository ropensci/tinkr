test_that("protect_curly() works", {
  pathcurly <- system.file("extdata", "basic-curly.md", package = "tinkr")
  curly <- yarn$new(pathcurly)
  expect_snapshot(cat(as.character(protect_curly(curly$body))))
})
