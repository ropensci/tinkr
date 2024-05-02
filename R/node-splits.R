#' Transform a character vector of XML into text nodes
#'
#' This is useful in the case where we want to modify some text content to
#' split it and label a portion of it 'asis' to protect it from commonmark's
#' escape processing.
#'
#' `fix_fully_inline()` uses `make_text_nodes()` to modify a single text node
#' into several text nodes. It first takes a string of a single text node like
#' below...
#'
#' ```html
#' <text>this is $\LaTeX$ text</text>
#' ```
#'
#' ...and splits it into three text nodes, surrounding the LaTeX math with text
#' tags that have the 'asis' attribute.
#'
#' ```html
#' <text>this is </text><text asis='true'>$\LaTeX$</text><text> text</text>
#' ```
#'
#' The `make_text_nodes()` function takes the above text string and converts it
#' into nodes so that the original text node can be replaced.
#'
#' @param a character vector of modified text nodes
#' @return a nodeset with no associated namespace
#' @noRd
make_text_nodes <- function(txt) {
  # We are hijacking commonmark here to produce an XML markdown document with
  # a single element: {paste(txt, collapse = ''). This gets passed to glue where
  # it is expanded into nodes that we can read in via {xml2}, strip the
  # namespace, and extract all nodes below
  doc <- glue::glue(commonmark::markdown_xml("{paste(txt, collapse = '')}"))
  nodes <- xml2::xml_ns_strip(xml2::read_xml(doc))
  xml2::xml_find_all(nodes, ".//paragraph/text/*")
}

#' Split and Join nodes that have been protected
#'
#' @param body an `xml_document` class object
#' @return 
#'  - `split_protected_nodes()` - a copy of `body` where text nodes with 
#'    protection are split into 'asis' and regular nodes.
#'  - `join_split_nodes()` - the `body` object where text nodes that have been
#'    split (those with the `@split-id` attribute) are joined into a single text
#'    node.
#' @rdname split_protected_nodes
#' @export
#' @examples
#' ex <- system.file("extdata", "math-example.md", package = "tinkr")
#' m <- tinkr::yarn$new(ex)
#' m$protect_math()
#' # protection gives us protected nodes
#' get_protected_nodes(m$body)
#' original_body <- m$body
#' # ---- splitting --------------------------------------------
#' # splitting transforms those nodes into split text nodes
#' split_body <- split_protected_nodes(m$body)
#' get_protected_nodes(split_body)
#' xml2::xml_find_all(split_body, ".//node()[@split-id]")
#' # The effect is the same
#' m$head(10)
#' m$body <- split_body
#' m$head(10)
#' # ---- joining ----------------------------------------------
#' # joining is done in place
#' join_split_nodes(m$body)
#' m$head(10)
#' get_protected_nodes(m$body)
#' get_protected_nodes(original_body)
#' 
#' # the context is identical even after transformation
#' identical(as.character(m$body), as.character(original_body))
split_protected_nodes <- function(body) {
  body <- copy_xml(body)
  protected <- get_protected_nodes(body)
  if (length(protected) == 0) {
    return(body)
  }
  purrr::iwalk(protected, split_node)
  copy_xml(body)
}

# split a node into adjacent text nodes
split_node <- function(node, id) {
  if (!is_protected(node)) {
    return(node)
  }
  frag <- split_node_text(node)
  if (length(frag$string) == 1) {
    # If we have a single fragment, we can label it "asis" and be on our way
    # This is likely the situation where a math equation contains 
    # two underscores, which the interpreter reads as <emph> nodes.
    set_asis(node)
    remove_protected_ranges(node)
    return(node)
  }
  new_nodes <- glue::glue("<text>{frag$string}</text>")
  new_nodes <- make_text_nodes(new_nodes)
  attrs <- xml2::xml_attrs(node)
  attrs <- attrs[!startsWith(names(attrs), "protect")]
  for (attr in names(attrs)) {
    val <- attrs[[attr]]
    if (attr == "space") {
      attr <- "xml:space"
    }
    xml2::xml_set_attr(new_nodes, attr, val)
  }
  if (has_sourcepos(node)) {
    xml2::xml_set_attr(new_nodes, "sourcepos", split_sourcepos(node))
  }
  remove_protected_ranges(node)
  xml2::xml_set_attr(new_nodes, "split-id", id)
  xml2::xml_set_attr(new_nodes[frag$protected], "asis", "true")
  add_node_siblings(node, new_nodes, remove = TRUE)
}

# splits node text based on protected ranges
split_node_text <- function(node) {
  if (!is_protected(node)) {
    return(node)
  }
  full <- get_full_ranges(node)
  txt <- xml2::xml_text(node)
  parts <- list(
    string = substring(txt, full$start, full$end),
    protected = full$protected
  )
  return(parts)
}

#' @rdname split_protected_nodes
#' @export
join_split_nodes <- function(body) {
  nodes <- xml2::xml_find_all(body, ".//md:text[@split-id]", ns = md_ns())
  if (length(nodes) == 0) {
    return(body)
  }
  ids <- xml2::xml_attr(nodes, "split-id")
  purrr::walk(unique(ids), function(i) join_text_nodes(nodes[ids == i]))
  return(body)
}

join_text_nodes <- function(nodes) {
  nodetxt <- xml2::xml_text(nodes)
  asis_nodes <- is_asis(nodes)
  # In this nodeset, we need to make sure to relabel the asis nodes 
  txt <- paste(nodetxt, collapse = "")
  # our new node is the donor for all other nodes
  new_node <- nodes[[1]]
  xml2::xml_set_text(new_node, txt)
  if (has_sourcepos(new_node)) {
    # restore the sourcepos of the original nodes
    pos <- join_sourcepos(nodes)
    xml2::xml_set_attr(new_node, "sourcepos", pos)
  }
  # compute the protection from the string lengths
  n <- cumsum(nchar(nodetxt))
  start <- n[!asis_nodes] + 1
  end <- n[asis_nodes]
  # if the first node is an asis node, th
  if (isTRUE(asis_nodes[1])) {
    start <- c(1, n[!asis_nodes] + 1)
  }
  start <- start[seq_along(end)]
  add_protected_ranges(new_node, start, end)
  xml2::xml_set_attr(new_node, "split-id", NULL)
  xml2::xml_set_attr(new_node, "asis", NULL)
  xml2::xml_remove(nodes[-1])
}

