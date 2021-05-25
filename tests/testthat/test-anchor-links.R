f <- system.file("extdata", "link-test.md", package = "tinkr")

test_that("anchored links are processed by default", {
  m <- yarn$new(f, sourcepos = TRUE)
  expect_snapshot(show_user(m$tail(30), force = TRUE))
})

test_that("users can turn off anchor links", {
  m <- yarn$new(f, sourcepos = TRUE, anchor_links = FALSE)
  expect_snapshot(show_user(m$tail(30), force = TRUE))
})

test_that("links can go round trip", {
  
  m <- yarn$new(f)
  withr::local_file(tmp <- tempfile())
  m$write(tmp)
  mt <- yarn$new(tmp)
  expect_equal(m$tail(30), mt$tail(30))

})
