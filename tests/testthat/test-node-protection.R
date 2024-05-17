
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




test_that("protection can be added and removed", {
  expected <- c(
    "\\a\\b\\c\\d",
    "\\e\\f\\g\\h",
    ""
  )
  temp_file <- withr::local_tempfile()
  brio::write_lines(expected, temp_file)
  wool <- tinkr::yarn$new(temp_file, unescaped = FALSE)
  nodes <- xml2::xml_find_all(wool$body, ".//md:text", ns = md_ns())

  # NO RANGES -------------------------------------------------------
  # the body is not a text node
  expect_true(not_text_node(wool$body))
  # the text nodes are not a single text node
  expect_true(not_text_node(nodes))
  # individual text nodes are nodes
  expect_true(is_text_node(nodes[[1]]))
  expect_false(not_text_node(nodes[[1]]))
  expect_false(is_protected(nodes[[1]]))
  expect_false(is_protected(nodes[[2]]))

  # no range protection exists
  expect_null(get_protected_ranges(nodes))
  expect_equal(lapply(nodes, get_protected_ranges),
    vector(mode = "list", length = 2) # empty list
  )
  
  # no protection applied, the text is all escaped
  no_protection <- wool$show()
  expect_equal(no_protection, gsub("\\\\", "\\\\\\\\", expected))

  # ADDING PROTECTION -----------------------------------------------
  # protecting second and fourth entities
  expect_false(is_protected(nodes[[1]]))

  add_protected_ranges(nodes[[1]], start = c(3, 7), end = c(4, 8))

  expect_true(is_protected(nodes[[1]]))

  # protecting everything
  expect_false(is_protected(nodes[[2]]))

  add_protected_ranges(nodes[[2]], start = 1, end = 8)

  expect_false(is_protected(nodes[[2]]))
  expect_true(is_asis(nodes[[2]]))

  expect_equal(get_protected_ranges(nodes[[1]]),
    list(start = c(3, 7), end = c(4, 8))
  )
  expect_equal(get_protected_ranges(nodes[[2]]), NULL)

  some_protection <- wool$show()
  # we expect all but the first and third entities to be protected
  some_expected <- gsub("\\\\([ac])", "\\\\\\\\\\1", expected)
  expect_equal(object = some_protection, expected = some_expected)

  # OVERLAPPING PROTECTIONS ----------------------------------------
  # adding identical protections do not duplicate them
  add_protected_ranges(nodes[[1]], start = c(3, 7), end = c(4, 8))
  expect_equal(get_protected_ranges(nodes[[1]]),
    list(start = c(3, 7), end = c(4, 8))
  )
  # adding completely overlapping protections does not cause an error
  add_protected_ranges(nodes[[2]], start = c(3, 7), end = c(4, 8))
  expect_true(is_asis(nodes[[2]]))
  expect_equal(get_protected_ranges(nodes[[2]]), NULL)

  some_protection <- wool$show()
  # we expect all but the first and third entities to be protected
  some_expected <- gsub("\\\\([ac])", "\\\\\\\\\\1", expected)
  expect_equal(object = some_protection, expected = some_expected)

  # NEW PROTECTIONS -----------------------------------------------
  # we can add a new range that does not overlap (but it can abut)
  add_protected_ranges(nodes[[1]], start = 1, end = 2)
  expect_equal(get_protected_ranges(nodes[[1]]),
    list(start = c(1, 3, 7), end = c(2, 4, 8))
  )
  some_protection <- wool$show()
  some_expected <- gsub("\\\\([c])", "\\\\\\\\\\1", expected)
  expect_equal(object = some_protection, expected = some_expected)
  
  # if we add an overlapping range, they are connected
  add_protected_ranges(nodes[[1]], start = 1, end = 4)
  expect_equal(get_protected_ranges(nodes[[1]]),
    list(start = c(1, 7), end = c(4, 8))
  )
  some_protection <- wool$show()
  some_expected <- gsub("\\\\([c])", "\\\\\\\\\\1", expected)
  expect_equal(object = some_protection, expected = some_expected)
  
  # REMOVING PROTECTIONS -----------------------------------------
  expect_true(is_protected(nodes[[1]]))

  remove_protected_ranges(nodes[[1]])

  expect_false(is_protected(nodes[[1]]))

  expect_null(get_protected_ranges(nodes[[1]]))

  # now the top line is unprotected 
  some_protection <- wool$show()
  some_expected <- gsub("\\\\([abcd])", "\\\\\\\\\\1", expected)
  expect_equal(object = some_protection, expected = some_expected)

})

