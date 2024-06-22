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

append_md <- function(body, md, after = NULL, space = TRUE) {
  new <- md_to_xml(md)
  shove_nodes_in(body, new, nodes = after, where = "after", space = space)
  copy_xml(body)
}

prepend_md <- function(body, md, before = NULL, space = TRUE) {
  new <- md_to_xml(md)
  shove_nodes_in(body, new, nodes = before, where = "before", space = space)
  copy_xml(body)
}

shove_nodes_in <- function(body, new, nodes, where = "after", space = TRUE) {
  if (inherits(nodes, "character")) {
    nodes <- xml2::xml_find_all(body, nodes, ns = md_ns())
  }
  if (!inherits(nodes, c("xml_node", "xml_nodeset"))) {
    rlang::abort("an object of class `xml_node` or `xml_nodeset` was expected",
      class = "insert-md-node"
    )
  }
  root <- xml2::xml_root(nodes)
  if (!identical(root, body)) {
    rlang::abort("nodes must come from the same body as the yarn document",
      class = "insert-md-body"
    )
  }
  return(add_nodes_to_nodes(new, old = nodes, where = where, space = space))
}


node_is_inline <- function(node) {
  blocks <- c("document", "paragraph", "heading", "block_quote", "list",
  "item", "code_block", "html_block", "custom_block", "thematic_break",
  "table")
  !xml2::xml_name(node) %in% blocks
}

add_nodes_to_nodes <- function(nodes, old, where = "after", space = TRUE) {
  inlines <- node_is_inline(old)
  n <- sum(inlines)
  single_node <- inherits(old, "xml_node")
  if (n > 0) {
    if (!single_node && n < length(old)) {
      rlang::abort("Nodes must be either block type or inline, but not both", 
        class = "insert-md-dual-type",
        call. = FALSE
      )
    }
    nodes <- xml2::xml_children(nodes)
    if (space) {
      lead <- if (inherits(nodes, "xml_node")) nodes else nodes[[1]]
      txt <- if (where == "after") " %s" else "%s " 
      xml2::xml_set_text(lead, sprintf(txt, xml2::xml_text(lead)))
    }
  }
  if (single_node) {
    old <- list(old)
  }
  purrr::walk(old, add_node_siblings, nodes, where = where, remove = FALSE)
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
