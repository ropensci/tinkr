
test_that("str_replace_all() replaces all", {
  txt <- "I have a tall order and a tall tale"
  expects <- "I have a short order and a short tale"
  expect_equal(str_replace_all(txt, "tall", "short"), expects)
})

test_that("str_remove_all() removes all", {
  txt <- "I have a tall order and a tall tale"
  expects <- "I have a order and a tale"
  expect_equal(str_remove_all(txt, "tall "), expects)
})

