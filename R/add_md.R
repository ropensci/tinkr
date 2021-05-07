#' Add markdown content to an XML object
#'
#' @param body an XML object generated via {tinkr}
#' @param md a string of new markdown to insert
#' @param where the position in the markdown document to insert the new markdown
#'
#' @return a copy of the XML object with the markdown inserted.
add_md <- function(body, md, where = 0L) {
  new <- md_to_xml(md)
  add_node_children(body, new, where)
}

# Add children to a specific location and then copies the xml of the full
# document. 
add_node_children <- function(body, nodes, where = 0L) {
  for (child in rev(nodes)) {
    xml2::xml_add_child(body, child, .where = where)
  }
  copy_xml(body)
}

add_node_siblings <- function(node, nodes, where = "after", remove = TRUE) {
  for (sib in rev(nodes)) {
    xml2::xml_add_sibling(node, sib, .where = where)
  }
  if (remove) xml2::xml_remove(node)
}

#' Convert markdown to XML
#'
#' @param md a character vector of markdown text
#' @return an XML nodeset of the markdown text
#' @keywords internal
#' @examples
#' tinkr:::md_to_xml(c(
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
md_to_xml <- function(md) {
  new <- clean_content(paste(md, collapse = "\n"))
  new <- commonmark::markdown_xml(new, extensions = TRUE)
  parse_rmd(new <- xml2::read_xml(new))
  new <- xml2::xml_ns_strip(new)
  xml2::xml_children(new)
}
