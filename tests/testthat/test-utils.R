test_that("transform_params() works", {
  expect_equal(
    transform_params("r name, a=1, b=2"),
    c(language = "r", name = "name", a = "1", b = "2")
  )

  expect_equal(
    transform_params("r, name, a=1, b=2"),
    c(language = "r", name = "name", a = "1", b = "2")
  )

  expect_equal(
    transform_params("r, a=1, b=2"),
    c(language = "r", name = "", a = "1", b = "2")
  )
})

test_that("transform params can parse params with a missing leading comma", {
  params <- "r a=1, b=2"
  expect_equal(
    transform_params(params),
    c(language = "r", name = "", a = "1", b = "2")
  )
})


test_that("is_blank works", {
  expect_true(is_blank(""))
  expect_true(is_blank(NULL))
  expect_true(is_blank("\n\t\r   \n\t  \t  \t \t\t    "))
  expect_false(is_blank("\n\t\r hello  \n\t  \t  \t \t\t    "))
})
