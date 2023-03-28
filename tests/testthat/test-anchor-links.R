f <- system.file("extdata", "link-test.md", package = "tinkr")


test_that("anchor links with duplicate id and text are not doubled", {
  # https://github.com/ropensci/tinkr/issues/92
  lines <- c("[thing]", "lala[^1] blabla", "", "[thing]: what", "[^1]: pof")

  temp_file <- withr::local_tempfile()
  writeLines(lines, temp_file)

  res <- tinkr::yarn$new(temp_file)$show()
  expect_equal(res[res != ""], lines[lines != ""])
  #> [thing] lala[^1] blabla
  #> 
  #> [thing]: what
  #> [^1]: pof

})


test_that("anchored links are processed by default", {
  m <- yarn$new(f, sourcepos = TRUE)
  expect_snapshot(show_user(m$show(), force = TRUE))
})

test_that("users can turn off anchor links", {
  m <- yarn$new(f, sourcepos = TRUE, anchor_links = FALSE)
  expect_snapshot(show_user(m$show(), force = TRUE))
})

test_that("links can go round trip", {
  
  m <- yarn$new(f)
  tmp <- withr::local_tempfile()
  m$write(tmp)
  mt <- yarn$new(tmp)
  expect_equal(m$show(), mt$show())

})

test_that("singluar nodes can be added to the body", {
  
  m <- yarn$new(f)
  node1 <- build_anchor_links("[a]: b 'c'")[[1]]
  node2 <- build_anchor_links("[A]: B 'C'")[[1]]

  # add node1 at the top of the body
  add_nodes_to_body(m$body, node1)
  buddy <- copy_xml(m$body)
  buddy_node1 <- xml2::xml_find_first(buddy, ".//md:link", md_ns())
  expect_equal(xml2::xml_text(buddy_node1), "a")
  expect_equal(xml2::xml_attr(buddy_node1, "anchor"), "true")

  # add node2 after node1
  add_node_siblings(buddy_node1, node2, remove = FALSE)
  buddy <- copy_xml(buddy)
  buddy_node2 <- xml2::xml_find_all(buddy, ".//md:link", md_ns())[[2]]
  expect_equal(xml2::xml_text(buddy_node2), "A")
  expect_equal(xml2::xml_attr(buddy_node2, "anchor"), "true")
  
})
