test_that("an empty yarn object can be created", {
  y1 <- yarn$new()
  expect_s3_class(y1, "yarn")
  expect_null(y1$body)
  expect_null(y1$yaml)
  expect_null(y1$ns)
  expect_null(y1$path)
})


test_that("yarn can be created from markdown", {
  pathmd  <- system.file("extdata", "example1.md", package = "tinkr")
  y1 <- yarn$new(pathmd)
  t1 <- to_xml(pathmd)
  expect_s3_class(y1, "yarn")
  expect_s3_class(y1$body, "xml_document")
  expect_named(y1$ns, "md")
  expect_match(y1$ns, "commonmark")
})

test_that("yarn show, head, and tail methods work", {
  pathrmd <- system.file("extdata", "example2.Rmd", package = "tinkr")
  y1 <- yarn$new(pathrmd)
  expect_snapshot(show_user(res <- y1$show(), TRUE))
  expect_type(res, "character")

  # the head method is identical to subsetting 10 lines
  expect_snapshot(show_user(res_11 <- y1$show(11:20), TRUE))
  expect_length(res_11, 10) %>%
    expect_identical(res[11:20]) %>%
    expect_type("character")

  # a subset from the top has 10 lines
  expect_snapshot(show_user(res_1 <- y1$show(1:10), TRUE))
  expect_length(res_1, 10) %>%
    expect_type("character")

  # the head method is identical to subsetting 10 lines
  expect_snapshot(show_user(res <- y1$head(10), TRUE))
  expect_length(res, 10) %>%
    expect_identical(res_1) %>%
    expect_type("character")

  expect_snapshot(show_user(res <- y1$tail(11), TRUE))
  expect_length(res, 11) %>%
    expect_type("character")

})


test_that("yarn show method will warn if using positional stylesheet", {

  path <- system.file("extdata", "table.md", package = "tinkr")
  y1 <- yarn$new(path)
  expect_no_warning({
    md_show <- y1$show(TRUE)
  })
  expect_no_warning({
    md_show1 <- y1$show(stylesheet_path = stylesheet())
  })
  suppressWarnings({
    expect_warning(md_show2 <- y1$show(stylesheet()))
  })
  expect_identical(md_show, md_show2)

})


test_that("yarn can be created from Rmarkdown", {
  pathrmd <- system.file("extdata", "example2.Rmd", package = "tinkr")
  y1 <- yarn$new(pathrmd)
  t1 <- to_xml(pathrmd)
  expect_s3_class(y1, "yarn")
  expect_s3_class(y1$body, "xml_document")
  expect_named(y1$ns, "md")
  expect_match(y1$ns, "commonmark")
})

test_that("the write method needs a filename", {
  pathmd <- system.file("extdata", "example1.md", package = "tinkr")
  expect_error(yarn$new(pathmd)$write(), "Please provide a file path")
})

test_that("a yarn object can be written back to markdown", {
  tmpdir <- withr::local_tempdir()
  scarf1 <- withr::local_file(file.path(tmpdir, "yarn.md"))
  scarf2 <- withr::local_file(file.path(tmpdir, "yarn.Rmd"))
  pathrmd <- system.file("extdata", "example2.Rmd", package = "tinkr")
  pathmd <- system.file("extdata", "example1.md", package = "tinkr")
  y1 <- yarn$new(pathmd)
  y2 <- yarn$new(pathrmd)
  y1$write(scarf1)
  y2$write(scarf2)
  expect_snapshot_file(scarf1)
  expect_snapshot_file(scarf2)
})


test_that("protect_unescaped() throws a message if sourcepos is not available", {
  path <- system.file("extdata", "basic-curly.md", package = "tinkr")
  y1 <- yarn$new(path, sourcepos = FALSE)
  expect_message(y1$protect_unescaped(), "sourcepos")
})


test_that("protect_unescaped() will work if the user implements it later", {
  path <- system.file("extdata", "basic-curly.md", package = "tinkr")
  y1 <- yarn$new(path, sourcepos = TRUE, unescaped = FALSE)
  old <- y1$tail()
  new <- y1$protect_unescaped()$tail()
  expect_snapshot(writeLines(old))
  expect_snapshot(writeLines(new))
})

test_that("a yarn object can be reset", {
  scarf1 <- withr::local_tempfile(fileext = "md")
  pathmd  <- system.file("extdata", "example1.md", package = "tinkr")
  y1 <- yarn$new(pathmd, sourcepos = TRUE, encoding = "utf-8")

  expect_equal(y1$.__enclos_env__$private$encoding, "utf-8")
  expect_true(y1$.__enclos_env__$private$sourcepos)
  expect_s3_class(y1$body, "xml_document")
  expect_false(is.na(xml2::xml_attr(y1$body, "sourcepos")))

  y1$body <- xml2::xml_missing()
  expect_s3_class(y1$body, "xml_missing")

  y1$reset()
  expect_s3_class(y1$body, "xml_document")
  expect_equal(y1$.__enclos_env__$private$encoding, "utf-8")
  expect_true(y1$.__enclos_env__$private$sourcepos)
  expect_false(is.na(xml2::xml_attr(y1$body, "sourcepos")))

})

test_that("random markdown can be added to the body", {

  tmpdir <- withr::local_tempdir()
  scarf3 <- withr::local_file(file.path(tmpdir, "yarn-kilroy.md"))
  mdtable <- system.file("extdata", "table.md", package = "tinkr")
  t1 <- yarn$new(mdtable)
  expect_equal(xml2::xml_name(xml2::xml_child(t1$body)), "table")
  expect_length(xml2::xml_find_all(t1$body, "link", t1$ns), 0L)

  newmd <- c("# TABLE HERE\n\n",
    "[KILROY](https://en.wikipedia.org/wiki/Kilroy_was_here) WAS **HERE**\n\n",
    "stop copying me!" # THIS WILL BE COPIED TWICE
  )
  t1$add_md(paste(newmd, collapse = ""))
  t1$add_md(toupper(newmd[[3]]), where = 3)
  expect_length(xml2::xml_find_all(t1$body, "md:link", t1$ns), 0L)

  t1$write(scarf3)
  expect_snapshot_file(scarf3)

})


test_that("markdown can be appended to elements", {
  path <- system.file("extdata", "example2.Rmd", package = "tinkr")
  ex <- tinkr::yarn$new(path)
  # append a note after the first heading
  txt <- c("The following message is sponsored by me:\n", "> Hello from *tinkr*!", ">", ">  :heart: R")
  # Via XPath ------------------------------------------------------------------
  ex$append_md(txt, ".//md:heading[1]")
  # the block quote has been added to the first heading 
  expect_length(xml2::xml_find_all(ex$body, ".//md:block_quote", ns = ex$ns), 1)
  # Via node -------------------------------------------------------------------
  heading2 <- xml2::xml_find_first(ex$body, ".//md:heading[2]", ns = ex$ns)
  ex$append_md(txt, heading2)
  expect_length(xml2::xml_find_all(ex$body, ".//md:block_quote", ns = ex$ns), 2)
  # Because the body is a copy, the original nodeset will throw an error
  expect_error(ex$append_md(txt, heading2), class = "insert-md-body")

  # Via nodeset ----------------------------------------------------------------
  ex$append_md(txt, ".//md:heading")
  expect_length(xml2::xml_find_all(ex$body, ".//md:block_quote", ns = ex$ns), 4)
})


test_that("Inline markdown can be appended (to a degree)", {
  path <- system.file("extdata", "example2.Rmd", package = "tinkr")
  ex <- tinkr::yarn$new(path)
  nodes <- xml2::xml_find_all(ex$body, 
    ".//md:code[contains(text(), 'READ THIS')]", ex$ns)
  expect_length(nodes, 0)
  ex <- tinkr::yarn$new(path)
  nodes <- xml2::xml_find_all(ex$body, 
    ".//md:code[contains(text(), ' <-- READ THIS')]", ex$ns)
  expect_length(nodes, 0)
  ex$append_md("`<-- READ THIS`", ".//md:link")
  nodes <- xml2::xml_find_all(ex$body, 
    ".//md:code[contains(text(), ' <-- READ THIS')]", ex$ns)
  expect_length(nodes, 1)
})


test_that("space parameter can be shut off", {
  path <- system.file("extdata", "example2.Rmd", package = "tinkr")
  ex <- tinkr::yarn$new(path)
  chk <- xml2::xml_find_all(ex$body, 
    ".//md:heading/*[contains(text(), '!!!')]", ex$ns)
  space_chk <- xml2::xml_find_all(ex$body, 
    ".//md:heading/*[contains(text(), ' !!!')]", ex$ns)
  expect_length(chk, 0)
  expect_length(space_chk, 0)
  ex <- tinkr::yarn$new(path)
  ex$append_md("!!!", ".//md:heading/*", space = FALSE)
  chk <- xml2::xml_find_all(ex$body, 
    ".//md:heading/*[contains(text(), '!!!')]", ex$ns)
  space_chk <- xml2::xml_find_all(ex$body, 
    ".//md:heading/*[contains(text(), ' !!!')]", ex$ns)
  expect_length(chk, 2)
  expect_length(space_chk, 0)
})



test_that("markdown can be prepended", {
  path <- system.file("extdata", "example2.Rmd", package = "tinkr")
  ex <- tinkr::yarn$new(path)
  nodes <- xml2::xml_find_all(ex$body, 
    ".//node()[contains(text(), 'NERDS')]", ex$ns)
  expect_length(nodes, 0)
  ex$prepend_md("I come before the table.\n\nTable: BIRDS, NERDS", ".//md:table")
  nodes <- xml2::xml_find_all(ex$body, 
    ".//node()[contains(text(), 'NERDS')]", ex$ns)
  expect_length(nodes, 1)
  pretxt <- xml2::xml_find_first(nodes[[1]], ".//parent::*/preceding-sibling::*[1]")
  expect_equal(xml2::xml_text(pretxt), "I come before the table.")
})


test_that("an error happens when you try to append with a number", {
  path <- system.file("extdata", "example2.Rmd", package = "tinkr")
  ex <- tinkr::yarn$new(path)
  expect_error(ex$append_md("WRONG", 42), class = "insert-md-node")
})

test_that("an error happens when you try to append to a non-existant node", {
  path <- system.file("extdata", "example2.Rmd", package = "tinkr")
  ex <- tinkr::yarn$new(path)
  expect_error(ex$append_md("WRONG", ".//md:nope"), 
    "No nodes matched the expression './/md:nope'",
    class = "insert-md-xpath")
})


test_that("an error happens when you try to append markdown to disparate elements", {

  path <- system.file("extdata", "example2.Rmd", package = "tinkr")
  ex <- tinkr::yarn$new(path)
  xpath <- ".//md:text[contains(text(), 'bird')] | .//md:paragraph[md:text[contains(text(), 'Non')]]"

  expect_error(ex$append_md("WRONG", xpath), class = "insert-md-dual-type")
})




test_that("md_vec() will convert a query to a markdown vector", {

  pathmd  <- system.file("extdata", "example1.md", package = "tinkr")
  y1 <- yarn$new(pathmd, sourcepos = TRUE, encoding = "utf-8")

  expect_null(y1$md_vec(NULL))

  headings <- xml2::xml_find_all(y1$body, ".//md:heading", y1$ns)

  expected <- paste(strrep("#", xml2::xml_attr(headings, "level")),
    xml2::xml_text(headings)
  )
  expect_equal(y1$md_vec(".//md:heading[@level=3]"), expected[1:4])
  expect_length(y1$md_vec(".//md:list//md:link"), 5)
  
  skip_on_os("windows")
  expect_equal(y1$md_vec(".//md:heading[@level=4]"), expected[5:7])
  expect_equal(y1$md_vec(".//md:heading"), expected)

})

