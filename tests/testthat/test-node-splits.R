
test_that("splitting and joining protected nodes will work round trip", {

  ex <- system.file("extdata", "math-example.md", package = "tinkr")
  m <- tinkr::yarn$new(ex)
  m$protect_math()
  # protection gives us protected nodes
  protected <- length(get_protected_nodes(m$body))
  expect_gt(protected, 0)
  # ---- splitting --------------------------------------------
  # splitting transforms those nodes into split text nodes
  split_body <- split_protected_nodes(m$body)
  # no protected nodes exist
  expect_false(identical(split_body, m$body))
  expect_length(get_protected_nodes(split_body), 0)

  # there should be the same number of unique ids as the protected
  splits <- xml2::xml_find_all(split_body, ".//node()[@split-id]")
  expect_gt(length(splits), 0)
  ids <- unique(xml2::xml_attr(splits, "split-id"))
  expect_equal(length(ids), protected)

  # The effect is the same
  h1 <- m$head(10)
  m$body <- split_body
  h2 <- m$head(10)
  expect_equal(h1, h2)
  # ---- joining ----------------------------------------------
  # joining is done in place
  join_split_nodes(m$body)
  expect_identical(m$body, split_body)
  h3 <- m$head(10)
  expect_equal(h1, h3)
  expect_equal(length(get_protected_nodes(m$body)), protected)

})


test_that("splitting and joining protected nodes will work round trip with sourcepos", {

  ex <- system.file("extdata", "math-example.md", package = "tinkr")
  m <- tinkr::yarn$new(ex, sourcepos = TRUE)
  m$protect_math()
  # the source positions exist
  expect_true(has_sourcepos(m$body))
  # protection gives us protected nodes
  protected <- length(get_protected_nodes(m$body))
  expect_gt(protected, 0)
  # ---- splitting --------------------------------------------
  # splitting transforms those nodes into split text nodes
  split_body <- split_protected_nodes(m$body)
  # no protected nodes exist
  expect_false(identical(split_body, m$body))
  expect_length(get_protected_nodes(split_body), 0)

  # there should be the same number of unique ids as the protected
  splits <- xml2::xml_find_all(split_body, ".//node()[@split-id]")
  expect_gt(length(splits), 0)
  ids <- unique(xml2::xml_attr(splits, "split-id"))
  expect_equal(length(ids), protected)

  # The effect is the same
  h1 <- m$head(10)
  m$body <- split_body
  h2 <- m$head(10)
  expect_equal(h1, h2)
  # ---- joining ----------------------------------------------
  # joining is done in place
  join_split_nodes(m$body)
  expect_identical(m$body, split_body)
  h3 <- m$head(10)
  expect_equal(h1, h3)
  expect_equal(length(get_protected_nodes(m$body)), protected)

})
