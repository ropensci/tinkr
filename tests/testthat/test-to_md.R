tmpdir <- withr::local_file("newdir")
dir.create(tmpdir)

test_that("to_md works", {
  newmd  <- withr::local_file("to_md-newmd.md")
  path <- system.file("extdata", "example1.md", package = "tinkr")

  yaml_xml_list <- to_xml(path)
  library("magrittr")
  # transform level 3 headers into level 1 headers
  body <- yaml_xml_list$body
  body %>%
    xml2::xml_find_all(xpath = './/d1:heading',
                       xml2::xml_ns(.)) %>%
    .[xml2::xml_attr(., "level") == "3"] -> headers3
  xml2::xml_set_attr(headers3, "level", 1)
  yaml_xml_list$body <- body

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
  newmd <- withr::local_file("to_md-newmd.Rmd")
  path <- system.file("extdata", "example2.Rmd", package = "tinkr")

  yaml_xml_list <- to_xml(path, sourcepos = TRUE)
  library("magrittr")
  body <- yaml_xml_list$body
  blocks <- yaml_xml_list$body %>%
    xml2::xml_find_all(xpath = './/d1:code_block',
                       xml2::xml_ns(.))

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
  newtable <- file.path(tmpdir, "table.md")

  yaml_xml_list <- to_xml(path)
  to_md(yaml_xml_list, newtable)
  expect_snapshot_file(newtable)
})

test_that("code chunks can be inserted on round trip", {

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
