test_that("protect_curly() works", {
  pathcurly <- system.file("extdata", "basic-curly.md", package = "tinkr")
  curly <- yarn$new(pathcurly, sourcepos = TRUE)
  expect_snapshot(cat(as.character(protect_curly(curly$body))))
})

test_that("a curly-protected yarn object can be written back to markdown", {
  md_pathcurly <- system.file("extdata", "basic-curly.md", package = "tinkr")
  rmd_pathcurly <- system.file("extdata", "basic-curly2.Rmd", package = "tinkr")
  tmpdir <- withr::local_tempdir()
  scarf1 <- withr::local_file(file.path(tmpdir, "yarn.md"))
  scarf2 <- withr::local_file(file.path(tmpdir, "yarn.Rmd"))
  y1 <- yarn$new(md_pathcurly, sourcepos = TRUE)
  y2 <- yarn$new(rmd_pathcurly, sourcepos = TRUE)
  y1$protect_curly()$write(scarf1)
  y2$protect_curly()$write(scarf2)
  expect_snapshot_file(scarf1)
  expect_snapshot_file(scarf2)
})
