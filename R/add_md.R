#' Add markdown content to an XML object
#'
#' @param body an XML object generated via {tinkr}
#' @param md a string of new markdown to insert
#' @param where the location in the markdown document to insert the new markdown
#'
#' @return a copy of the XML object with the markdown inserted.
add_md <- function(body, md, where = 0L) {
  new <- md_to_xml(md)
  for (child in rev(new)) {
    xml2::xml_add_child(body, child, .where = where)
  }
  copy_xml(body)
}

#' Convert markdown to XML
#'
#' @param md a character vector of markdown text
#' @return an XML nodeset of the markdown text
#' @examples
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
md_to_xml <- function(md) {
  new <- clean_content(paste(md, collapse = "\n"))
  new <- commonmark::markdown_xml(new, extensions = TRUE)
  parse_rmd(new <- xml2::read_xml(new))
  new <- xml2::xml_ns_strip(new)
  xml2::xml_children(new)
}
