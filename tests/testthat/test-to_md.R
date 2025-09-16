test_that("to_md works without a file", {
  path <- system.file("extdata", "table.md", package = "tinkr")
  stys <- system.file("stylesheets", "xml2md_gfm.xsl", package = "tinkr")
  stys <- xml2::read_xml(stys)

  yaml_xml_list <- to_xml(path)
  res <- to_md(yaml_xml_list)
  # an XML stylsheet object can be provided
  expect_equal(res, to_md(yaml_xml_list, stylesheet_path = stys))
  expect_length(res, 2)
  f <- textConnection(res)

  fin <- trimws(readLines(path, 3))
  fout <- trimws(readLines(f, 3))
  expect_equal(fin, fout)
  expect_match(res[[2]], "aaaaaaaaaa")
})

test_that("to_md fails if the stylesheet is not correct", {
  tmp <- withr::local_tempfile(fileext = ".xml")
  path <- system.file("extdata", "table.md", package = "tinkr")
  yaml_xml_list <- to_xml(path)
  xml2::write_xml(yaml_xml_list$body, tmp)
  # NULL for stylesheet
  expect_error(
    to_md(yaml_xml_list, stylesheet_path = NULL),
    "'stylesheet_path' must be a path to an XSL stylesheet"
  )
  # NA for stylesheet
  expect_error(
    to_md(yaml_xml_list, stylesheet_path = NA),
    "'stylesheet_path' must be a path to an XSL stylesheet"
  )
  # multi-element vector
  expect_error(
    to_md(yaml_xml_list, stylesheet_path = letters),
    "'stylesheet_path' must be a path to an XSL stylesheet"
  )
  # zero-element vector
  expect_error(
    to_md(yaml_xml_list, stylesheet_path = character(0)),
    "'stylesheet_path' must be a path to an XSL stylesheet"
  )
  # xml document that is not a stylesheet
  expect_error(
    to_md(yaml_xml_list, stylesheet_path = tmp),
    "'*.xml' is not a valid stylesheet"
  )
  # file that doesn't exist
  expect_error(
    to_md(yaml_xml_list, stylesheet_path = "path/to/stylesheet.xsl"),
    "The file 'path/to/stylesheet.xsl' does not exist."
  )
  # xml object
  expect_error(
    to_md(yaml_xml_list, stylesheet_path = yaml_xml_list$body),
    "'stylesheet_path' must be a path to an XSL stylesheet"
  )
})

test_that("to_md works", {
  tmpdir <- withr::local_tempdir("newdir")
  newmd <- withr::local_file(file.path(tmpdir, "to_md-works.md"))
  path <- system.file("extdata", "example1.md", package = "tinkr")

  yaml_xml_list <- to_xml(path)
  # transform level 3 headers into level 1 headers
  yaml_xml_list$body %>%
    xml2::xml_find_all(xpath = './/d1:heading[@level="3"]', xml2::xml_ns(.)) %>%
    xml2::xml_set_attr("level", 1)

  # save back and have a look
  to_md(yaml_xml_list, newmd)
  expect_snapshot_file(newmd)
  expect_silent(loop <- to_xml(newmd))

  # text is the same
  expect_equal(
    xml2::xml_text(loop$body),
    xml2::xml_text(yaml_xml_list$body)
  )

  # elements are the same
  expect_equal(
    xml2::xml_name(loop$body),
    xml2::xml_name(yaml_xml_list$body)
  )
})


test_that("to_md works for Rmd", {
  tmpdir <- withr::local_tempdir("newdir")
  newmd <- withr::local_file(file.path(tmpdir, "to_md-works-for-Rmd.Rmd"))
  path <- system.file("extdata", "example2.Rmd", package = "tinkr")

  yaml_xml_list <- to_xml(path, sourcepos = TRUE)
  body <- yaml_xml_list$body
  blocks <- yaml_xml_list$body %>%
    xml2::xml_find_all(xpath = './/d1:code_block', xml2::xml_ns(.))

  # Two non-evaluated blocks
  lang_attr <- xml2::xml_attr(blocks, "language")
  expect_equal(sum(is.na(lang_attr)), 2)

  # One block with info
  info_attr <- xml2::xml_attr(blocks, "info")
  expect_equal(sum(!is.na(info_attr)), 1)

  xml2::xml_set_attr(blocks, "language", "julia")

  # save back and have a look
  to_md(yaml_xml_list, newmd)
  expect_snapshot_file(newmd)

  # Still one block with info after writing (the process has not clobbered things)
  info_attr <- xml2::xml_attr(blocks, "info")
  expect_equal(sum(!is.na(info_attr)), 1)

  expect_silent(loop <- to_xml(newmd))
  # text is the same
  expect_equal(
    xml2::xml_text(loop$body),
    xml2::xml_text(yaml_xml_list$body)
  )

  # elements are the same
  expect_equal(
    xml2::xml_name(loop$body),
    xml2::xml_name(yaml_xml_list$body)
  )
})

test_that("to_md does not break tables", {
  path <- system.file("extdata", "table.md", package = "tinkr")
  tmpdir <- withr::local_tempdir("newdir")
  newtable <- withr::local_file(file.path(tmpdir, "table.md"))

  yaml_xml_list <- to_xml(path)
  to_md(yaml_xml_list, newtable)
  expect_snapshot_file(newtable)
})


test_that("code chunks can be inserted on round trip", {
  tmpdir <- withr::local_tempdir("newdir")
  path <- system.file("extdata", "example2.Rmd", package = "tinkr")
  newmd <- file.path(tmpdir, "new-code-chunk.Rmd")

  # read in document
  yaml_xml_list <- to_xml(path)

  # set up new code block
  cc <- "<code_block language='r' name='cody' xmlns='http://commonmark.org/xml/1.0'></code_block>"
  xcc <- xml2::read_xml(cc)

  # NOTE: code elements MUST have a newline character at the end to be
  # processed by the stylesheet and I'm not sure why.
  txt <- "# assign a sequence of 10 to 'a'\na <- 1:10\n"
  xml2::xml_set_text(xcc, txt)

  # add code block after setup chunk
  cody_block <- ".//d1:code_block[@name='cody']"
  xml2::xml_add_child(yaml_xml_list$body, xcc, .where = 1L)

  # Check that our code block exists and that it contains the same code
  our_block <- xml2::xml_find_all(yaml_xml_list$body, cody_block)
  expect_length(our_block, 1L)
  expect_named(xml2::xml_attrs(our_block)[[1]], c("language", "name", "xmlns"))
  expect_equal(xml2::xml_text(our_block)[1], txt)

  # Convert to markdown and re-test
  to_md(yaml_xml_list, newmd)
  expect_snapshot_file(newmd)
})

test_that("links that start lines are not escaped", {
  expected <- "## Dataset\n\nThe data used:\n[data](https://example.com)\n"
  math <- commonmark::markdown_xml(expected)
  txt <- xml2::read_xml(math)
  protxt <- protect_inline_math(txt, md_ns())
  actual <- to_md(list(yaml = NULL, body = protxt))
  expect_equal(actual, expected)
})

test_that("to_md_vec() returns a vector of the same length as the nodelist", {
  path <- system.file("extdata", "example1.md", package = "tinkr")
  y <- tinkr::yarn$new(path, sourcepos = TRUE)
  items <- xml2::xml_find_all(y$body, ".//md:item", tinkr::md_ns())
  links <- xml2::xml_find_all(y$body, ".//md:link", tinkr::md_ns())
  code <- xml2::xml_find_all(y$body, ".//md:code", tinkr::md_ns())
  blocks <- xml2::xml_find_all(y$body, ".//md:code_block", tinkr::md_ns())
  # no tables
  tables <- xml2::xml_find_all(y$body, ".//md:table", tinkr::md_ns())

  # each item is a character vector of equal length to the nodelist
  expect_length(to_md_vec(items), length(items)) %>%
    expect_type("character")
  expect_length(to_md_vec(links), length(links)) %>%
    expect_type("character")
  expect_length(to_md_vec(code), length(code)) %>%
    expect_type("character")
  expect_length(to_md_vec(blocks), length(blocks)) %>%
    expect_type("character")
  expect_length(to_md_vec(tables), 0) %>%
    expect_type("character")

  # single elements work as well
  expect_length(to_md_vec(blocks[[1]]), 1) %>%
    expect_type("character")

  # the output is as expected
  expect_snapshot(show_user(to_md_vec(blocks[5:6]), force = TRUE))
})

test_that("(#59) Bare links are not transformed to markdown links", {
  input <- c(
    "<https://example.com/one> and",
    "[https://example.com/two](https://example.com/two \"with a title\") and",
    "https://example.com/three",
    ""
  )
  tmp <- withr::local_tempfile()
  writeLines(input, tmp)
  expected <- input
  expected[3] <- paste0("<", input[3], ">")
  expected <- paste(expected, collapse = "\n")
  xml <- to_xml(tmp)
  md <- to_md(xml)
  expect_identical(expected, md)
})

test_that("list subitems keep their 3 spaces (ordered)", {
  input <- c(
    "1. My list item",
    "   - First sub-item",
    "   - Second sub-item",
    ""
  )
  tmp <- withr::local_tempfile()
  writeLines(input, tmp)
  xml <- to_xml(tmp)
  md <- to_md(xml)
  md <- strsplit(md, split = "\n")
  expect_snapshot(md)
})

test_that("list subitems keep their 2 spaces (unordered)", {
  input <- c(
    "- My list item",
    "   - First sub-item",
    "   - Second sub-item",
    ""
  )
  tmp <- withr::local_tempfile()
  writeLines(input, tmp)
  xml <- to_xml(tmp)
  md <- to_md(xml)
  md <- strsplit(md, split = "\n")
  expect_snapshot(md)
})


test_that("list subitems keep empty line", {
  input <- c(
    "- My list item",
    "",
    "   - First sub-item",
    "   - Second sub-item",
    ""
  )
  tmp <- withr::local_tempfile()
  writeLines(input, tmp)
  xml <- to_xml(tmp)
  md <- to_md(xml)
  md <- strsplit(md, split = "\n")
  expect_snapshot(md)
})
