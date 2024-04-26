
test_that("overlap returns false for separate overlaps", {
  expect_false(overlap(1, 3, 5, 8))
  expect_false(overlap(5, 8, 1, 3))
  expect_false(overlap(1, 1, 5, 5))
})
test_that("overlap returns true for separate overlaps", {
  expect_true(overlap(1, 8, 5, 13))
  expect_true(overlap(5, 13, 1, 8))
  expect_true(overlap(5, 9, 1, 10))
  expect_true(overlap(1, 10, 5, 9))
})


test_that("update_ranges will add non-overlapping ranges", {
  a = list(
    start = c(1, 5, 10),
    end = c(3, 8, 50)
  )
  b = list(
    start = c(100, 500, 1000),
    end = c(300, 800, 5000)
  )
  expect_equal(update_ranges(c(b$start, a$start), c(b$end, a$end)),
    list(start = c(a$start, b$start), end = c(a$end, b$end))
  )
})

test_that("update_ranges will merge overlapping ranges", {
  # in this scenario, we get the ranges from (a) [5, 8], [10, 50], 
  # joined by the first range from (b) [5, 35] 
  # which ends up as [5, 50]
  a = list(
    start = c(1, 5, 10),
    end   = c(3, 8, 50)
  )
  b = list(
    start = c(5, 100, 500, 1000),
    end   = c(35, 300, 800, 5000)
  )
  expect_equal(update_ranges(c(b$start, a$start), c(b$end, a$end)),
    list(start = c(a$start[-3],  b$start[-1]), end = c(a$end[-2], b$end[-1]))
  )
})


test_that("update_ranges will merge all overlapping ranges", {
  a = list(
    start = c(1, 5, 10),
    end = c(3, 8, 50)
  )
  b = list(
    start = c(100, 500, 1000),
    end = c(300, 800, 5000)
  )
  c = list(
    start = 1,
    end = 2500
  )
  expect_equal(
    update_ranges(
      c(b$start, a$start, c$start), 
      c(b$end, a$end, c$end)
    ),
    list(start = 1, end = 5000)
  )

})

