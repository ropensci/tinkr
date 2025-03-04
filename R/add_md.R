#' Add markdown content to an XML object
#'
#' @param body an XML object generated via {tinkr}
#' @param md a string of new markdown to insert
#' @param where the position in the markdown document to insert the new markdown
#' @keywords internal
#'
#' @return a copy of the XML object with the markdown inserted.
#' @dev
add_md <- function(body, md, where = 0L) {
  new <- md_to_xml(md)
  add_nodes_to_body(body, new, where)
  copy_xml(body)
}

#' Add children to a specific location in the full document.
#'
#' @inheritParams add_md
#' @param nodes an object of `xml_node` or list of nodes
#' @return a copy of the XML object with nodes inserted
#' @dev
add_nodes_to_body <- function(body, nodes, where = 0L) {
  if (inherits(nodes, "xml_node")) {
    xml2::xml_add_child(body, nodes, .where = where)
  } else {
    purrr::walk(rev(nodes), ~xml2::xml_add_child(body, .x, .where = where))
  }
}


#' Insert markdown before or after a set of nodes
#'
#' @inheritParams add_md
#' @param md markdown text to insert
#' @param nodes a character vector of an XPath expression OR an `xml_node` or
#'   `xml_nodeset` object. 
#' @param space when `TRUE` (default) inline nodes have a single space appended
#'   or prepended to avoid the added markdown abutting text.
#' @return a copy of the XML object with the translated markdown inserted
#'
#' @note The markdown content must be of the same type as the XML nodes, either
#'   inline or block content.
#' @dev
insert_md <- function(body, md, nodes, where = "after", space = TRUE) {
  new <- md_to_xml(md)
  shove_nodes_in(body, new, nodes = nodes, where = where, space = space)
  copy_xml(body)
}

shove_nodes_in <- function(body, new, nodes, where = "after", space = TRUE) {
  if (inherits(nodes, "character")) {
    xpath <- nodes
    nodes <- xml2::xml_find_all(body, nodes, ns = md_ns())
  } else {
    xpath <- NULL
  }
  if (length(nodes) == 0) {
    msg <- glue::glue("No nodes matched the expression {sQuote(xpath)}")
    rlang::abort(msg, class = "insert-md-xpath")
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

# add a new set of nodes before or after an exsiting set of nodes.
add_nodes_to_nodes <- function(new, old, where = "after", space = TRUE) {
  single_node <- inherits(old, "xml_node")
  # count the number of inline elements
  inlines <- node_is_inline(old)
  n <- sum(inlines)
  # when there are any inline nodes, we need to adjust the new node so that
  # we extract child-level elements. Note that we assume that the user will
  # be supplying strictly inline markdown, but it may not be so neat. 
  if (n > 0) {
    if (!single_node && n < length(old)) {
      rlang::abort("Nodes must be either block type or inline, but not both", 
        class = "insert-md-dual-type",
        call. = FALSE
      )
    }
    # make sure the new nodes are inline by extracting the children. 
    parents <- new
    new <- xml2::xml_children(new)
    if (space) {
      # For inline nodes, we want to make sure they are separated from existing
      # node by a space. The lead node is the adjoining child of the new nodes.
      lead <- if (inherits(new, "xml_node")) {
        new
      } else if (where == "after") {
        new[[1]]
      } else {
        new[[length(new)]]
      }
      # If the lead node is a text node, we can add a space using regular text
      # parsing. This is desirable to retain as much structure as possible.
      # Otherwise, a new node is appended. 
      if (xml2::xml_name(lead) == "text") {
        txt <- if (where == "after") " %s" else "%s "
        xml2::xml_set_text(lead, sprintf(txt, xml2::xml_text(lead)))
      } else {
        space_pos <- if (where == "after") "before" else "after"
        sib <- xml2::xml_add_sibling(lead, "text", .where = space_pos)
        xml2::xml_set_text(sib, " ")
        # replace the child nodes
        new <- xml2::xml_children(parents)
      }
    }
  }
  if (single_node) {
    # allow purrr::walk() to work on a single node
    old <- list(old)
  }
  purrr::walk(.x = old, .f = add_node_siblings,
    new = new, where = where, remove = FALSE
  )
}

# Add siblings to a node
add_node_siblings <- function(node, new, where = "after", remove = TRUE) {
  # if there is a single node, then we need only add it
  if (inherits(new, "xml_node")) {
    xml2::xml_add_sibling(node, new, .where = where)
  } else {
    if (where == "after") {
      # Appending new nodes requires us to insert them from the bottom to
      # the top. The reason for this is because we are always using the existing
      # node as a reference.
      new <- rev(new)
    }
    purrr::walk(new, ~xml2::xml_add_sibling(node, .x, .where = where))
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
