test_that("protected nodes can be accessed", {
  path <- system.file("extdata", "basic-curly.md", package = "tinkr")
  ex <- tinkr::yarn$new(path, sourcepos = TRUE)
  # we should have two protected elements right off due to the braces
  expect_length(ex$get_protected(), 2)

  # protect curly braces
  ex$protect_curly()
  # we should have six protected curly nodes
  expect_length(ex$get_protected(), 2 + 6)
  # add math and protect it
  ex$add_md(c("## math\n", 
    "$c^2 = a^2 + b^2$\n", 
    "$$",
    "\\sum_{i}^k = x_i + 1",
    "$$\n")
  )
  ex$protect_math()
  # one inline math, two softbreaks, one line of block
  expect_length(ex$get_protected(), 2 + 6 + 4)

  expect_length(ex$get_protected("curly"), 6)
  expect_length(ex$get_protected("math"), 4)
  expect_length(ex$get_protected("unescaped"), 2)

  expect_message(ex$get_protected(c("curly", "shemp", "moe")), 
    "shemp, and moe are not"
  )
})

