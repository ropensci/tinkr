test_that("protected nodes can be accessed", {
  path <- withr::local_tempfile()
  # five protected curly elements
  curlies <- c("## curlies",
    "\nThis line has {xml2} one and {tinkr} two curlies!",
    "\n![a pretty kitten](https://placekitten.com/200/300){#kitteh alt='a picture of a kitten'}",
    "\n![a pretty puppy](https://placedog.net/200/300){#dog alt=\"a picture", 
    "of a dog\"}",
    # two protected unescaped elements
    "\n[span with attributes]{.span-with-attributes ",
    "style='color: red'}",
    ""
  )
  # six protected math elements
  math <- c("## math", 
    "\n$c^2 = a^2 + b^2$", # 1
    "\n$$", # 2
    # 3 <softbreak>
    "\\sum_{i}^k = x_i + 1", # 4
    # 5 <softbreak>
    "$$", # 6
    ""
  )
  writeLines(c(curlies, "\n", math), path)
  ex <- tinkr::yarn$new(path, sourcepos = TRUE)
  # we should have two protected elements right off due to the braces
  expect_length(ex$get_protected(), 2)

  # one inline math, two softbreaks, one line of block
  ex$protect_math()
  expect_length(ex$get_protected(), 2 + 6)

  # we should have six protected curly nodes
  ex$protect_curly()
  expect_length(ex$get_protected(), 2 + 6 + 5)

  expect_length(ex$get_protected("curly"), 5)
  expect_length(ex$get_protected("math"), 6)
  expect_length(ex$get_protected("unescaped"), 2)

  expect_error(ex$get_protected(c("curly", "shemp")), 
    "not \"shemp\""
  )
})

