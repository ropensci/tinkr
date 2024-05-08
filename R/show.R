#' Display a node or nodelist as markdown
#'
#' When inspecting the results of an XPath query, displaying the text often 
#' @param nodelist an object of class `xml_nodelist` OR `xml_node` OR a list of
#'   either.
#' @return a character vector, displayed to the screen.
#' @examples
#' path <- system.file("extdata", "example1.md", package = "tinkr")
#' y <- tinkr::yarn$new(path, sourcepos = TRUE)
#' items <- xml2::xml_find_all(y$body, ".//md:item", tinkr::md_ns())
#' links <- xml2::xml_find_all(y$body, ".//md:link", tinkr::md_ns())
#' code <- xml2::xml_find_all(y$body, ".//md:code", tinkr::md_ns())
#' blocks <- xml2::xml_find_all(y$body, ".//md:code_block", tinkr::md_ns())
#'
#' # show a list of items 
#' show_list(links[1:10])
#' show_list(code[1:10])
#' show_list(blocks[1:2])
#' 
#' # show the items in the structure of the document
#' show_bare(items)
#' show_bare(links)
#'
#' # show the items with context markers ([...]) in the structure of the document
#' show_context(links[20:31])
#' show_context(code[1:10])
#' @rdname show
#' @export
show_list <- function(nodelist) {
  res <- isolate_nodes(nodelist, type = "list")
  return(show_user(print_lines(res$doc)))
}

#' @rdname show
#' @export
show_bare <- function(nodelist) {
  res <- isolate_nodes(nodelist)
  return(show_user(print_lines(res$doc)))
}

#' @rdname show
#' @export
show_context <- function(nodelist) {
  res <- isolate_nodes(nodelist)
  res <- add_isolation_context(nodelist, res)
  return(show_user(print_lines(res$doc)))
}

isolate_nodes <- function(nodelist, type = "context") {
  switch(type,
    "context" = isolate_nodes_in_context(nodelist),
    "list" = isolate_nodes_a_la_carte(nodelist),
  )
}

isolate_nodes_a_la_carte <- function(nodelist) {
  doc <- xml2::read_xml(commonmark::markdown_xml(""))
  # if we get a single node, make sure it's in a list
  if (inherits(nodelist, "xml_node")) {
    nodelist <- list(nodelist)
  }
  for (node in nodelist) {
    parent <- xml2::xml_add_child(doc, "paragraph")
    if (inherits(node, "xml_node")) {
      xml2::xml_add_child(parent, node)
    } else {
      purrr::walk(node, function(n) xml2::xml_add_child(parent, n))
    }
  }
  return(list(doc = doc, key = NULL))
}

provision_isolation <- function(nodelist) {
  # create a copy of our document
  doc <- copy_xml(xml2::xml_root(nodelist))
  # get the path to the currently labelled nodes so we can isolate them
  # in the copy
  # This will return one path statement per node
  path <- xml2::xml_path(nodelist)
  # label new nodes with unique timestamp
  tim <- as.character(as.integer(Sys.time()))
  purrr::walk(path, label_nodes, doc = doc, label = tim)

  # find the unlabelled nodes
  predicate <- sprintf("@label=%s", tim)
  xpth <- sprintf("not(descendant::*[%s]) and not(ancestor::*[%s]) and not(%s)",
    predicate, predicate, predicate
  )
  rents <- xml2::xml_find_all(doc, sprintf("//node()[%s]", xpth))
  return(list(doc = doc, key = tim, parents = rents))

}

isolate_nodes_in_context <- function(nodelist) {
  res <- provision_isolation(nodelist)
  xml2::xml_remove(res$parents)
  return(list(doc = res$doc, key = res$key))
}

add_isolation_context <- function(nodelist, isolated) {
  pretext <- xml2::xml_find_lgl(nodelist, 
    "boolean(count(preceding-sibling::*)!=0)"
  )
  postext <- xml2::xml_find_lgl(nodelist, 
    "boolean(count(following-sibling::*)!=0)"
  )
  xpath <- sprintf(".//node()[@label=%s]", isolated$key)
  labelled <- xml2::xml_find_all(isolated$doc, xpath)
  purrr::walk(labelled[pretext], function(node) {
    xml2::xml_add_sibling(node, .where = "before",
      "text", "[...] ", asis = "true"
    )
  })
  purrr::walk(labelled[postext], function(node) {
    xml2::xml_add_sibling(node, .where = "after",
      "text", " [...]", asis = "true"
    )
  })
  return(isolated)
} 

print_lines <- function(xml, path = NULL, stylesheet = NULL) {
  if (inherits(xml, "xml_document")) {
    xml <- list(yaml = "", body = xml)
  }
  if (is.null(stylesheet)) {
    md <- to_md(xml, path)
  } else {
    md <- to_md(xml, path, stylesheet)
  }
  if (!is.null(path) && !is.null(stylesheet)) {
    return(md)
  }
  # Make sure that the yaml is not sitting on top of the first markdown line
  if (length(md) == 2) {
    md[1] <- paste0(md[1], "\n")
  }
  f  <- textConnection(md)
  on.exit(close(f))
  readLines(f)
}

label_nodes <- function(xpath, doc, label = "save") {
  xml2::xml_set_attr(
    xml2::xml_find_all(doc, xpath, ns = md_ns()), 
    "label", label)
}

add_context_siblings <- function(node, where = "after") {
  xml2::xml_add_sibling(node, .where = "after",
    "text", " [...] ", asis = "true"
  )
  xml2::xml_add_sibling(node, .where = "before",
    "text", "[...] ", asis = "true"
  )
}


