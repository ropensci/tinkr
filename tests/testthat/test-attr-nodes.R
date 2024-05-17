test_that("protect_curly() works", {
  pathcurly <- system.file("extdata", "basic-curly.md", package = "tinkr")
  curly <- yarn$new(pathcurly, sourcepos = TRUE)
  protec <- protect_curly(curly$body)
  expect_snapshot(cat(as.character(protec)))
})


test_that("protect_curly() can be reversed", {
  pathcurly <- system.file("extdata", "basic-curly.md", package = "tinkr")
  tmpfile <- withr::local_tempfile()
  file.copy(pathcurly, tmpfile, overwrite = TRUE)
  cat(c(
    "",
    "![image with long alt text](image.png){#image alt='this is",
    "long alt text that should be all",
    "included in the image'}", 
    "",
    "![image with short alt text](img.png){#img alt='short alt text'}",
    ""
    ),
    sep = "\n",
    file = tmpfile,
    append = TRUE
  )
  curly <- yarn$new(tmpfile, sourcepos = TRUE)
  curly$protect_curly()
  orig <- copy_xml(curly$body)

  expect_length(get_protected_nodes(curly$body), 3)
  expect_length(xml2::xml_find_all(curly$body, ".//node()[@curly]"), 10)

  # when split the protected nodes go away
  splitsville <- split_protected_nodes(curly$body)
  expect_snapshot(cat(as.character(splitsville)))
  expect_length(get_protected_nodes(splitsville), 0)

  joinsville <- join_split_nodes(splitsville)
  expect_identical(joinsville, splitsville)
  # joining restores these nodes
  sprotec <- get_protected_nodes(splitsville)
  expect_length(sprotec, 3)
  expect_equal(
    lapply(sprotec, get_protected_ranges),
    lapply(get_protected_nodes(orig), get_protected_ranges)
  )
  expect_length(xml2::xml_find_all(splitsville, ".//node()[@curly]"), 10)
  expect_snapshot(cat(as.character(joinsville)))
})



test_that("multiline alt text can be processed", {
  pathcurly <- system.file("extdata", "basic-curly.md", package = "tinkr")
  tmpfile <- withr::local_tempfile()
  file.copy(pathcurly, tmpfile, overwrite = TRUE)
  cat(c("![image with long alt text](image.png){#image alt='this is",
    "long alt text that should be all",
    "included in the image'}", 
    "",
    "![image with short alt text](img.png){#img alt='short alt text'}",
    ""
    ),
    sep = "\n",
    file = tmpfile,
    append = TRUE
  )
  curly <- yarn$new(tmpfile, sourcepos = TRUE)
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
