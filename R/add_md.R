#' Add markdown content to an XML object
#'
#' @param body an XML object generated via {tinkr}
#' @param md a string of new markdown to insert
#' @param where the position in the markdown document to insert the new markdown
#' @keywords internal
#'
#' @return a copy of the XML object with the markdown inserted.
add_md <- function(body, md, where = 0L) {
  new <- md_to_xml(md)
  add_nodes_to_body(body, new, where)
  copy_xml(body)
}

# Add children to a specific location in the full document.
add_nodes_to_body <- function(body, nodes, where = 0L) {
  if (inherits(nodes, "xml_node")) {
    xml2::xml_add_child(body, nodes, .where = where)
  } else {
    purrr::walk(rev(nodes), ~xml2::xml_add_child(body, .x, .where = where))
  }
}

# Add siblings to a node
add_node_siblings <- function(node, nodes, where = "after", remove = TRUE) {
  # if there is a single node, then we need only add it
  if (inherits(nodes, "xml_node")) {
    xml2::xml_add_sibling(node, nodes, .where = where)
  } else {
    purrr::walk(rev(nodes), ~xml2::xml_add_sibling(node, .x, .where = where))
  }
  if (remove) xml2::xml_remove(node)
}

#' Convert markdown to XML
#'
#' @param md a character vector of markdown text
#' @return an XML nodeset of the markdown text
#' @keywords internal
#' @examples
#' if (requireNamespace("withr")) {
#'
#' withr::with_namespace("tinkr", {
#' md_to_xml(c(
#'   "## This is a new section of markdown",
#'   "",
#'   "Each new element",
#'   "Is converted to a new line of markdown text",
#'   "",
#'   "```{r code-example, echo = FALSE}",
#'   "cat('code blocks work well here, too')",
#'   "```",
#'   "",
#'   "Neat, right?"
#' ))
#' })
#'
#' }
md_to_xml <- function(md) {
  new <- clean_content(paste(md, collapse = "\n"))
  new <- commonmark::markdown_xml(new, extensions = TRUE)
  parse_rmd(new <- xml2::read_xml(new))
  new <- xml2::xml_ns_strip(new)
  xml2::xml_children(new)
}
