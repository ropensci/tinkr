f <- system.file("extdata", "link-test.md", package = "tinkr")

test_that("anchored links are processed by default", {
  m <- yarn$new(f, sourcepos = TRUE)
  expect_snapshot(show_user(m$tail(30), force = TRUE))
})

test_that("users can turn off anchor links", {
  m <- yarn$new(f, sourcepos = TRUE, anchor_links = FALSE)
  expect_snapshot(show_user(m$tail(30), force = TRUE))
})

