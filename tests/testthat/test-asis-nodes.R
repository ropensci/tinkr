pathmath <- system.file("extdata", "math-example.md", package = "tinkr")

test_that("block math can be protected", {
  m <- yarn$new(pathmath)
  expect_snapshot(m$protect_math()$tail(48))
})
