#' Display a node or nodelist as markdown
#'
#' When inspecting the results of an XPath query, displaying the text often
#' @param nodelist an object of class `xml_nodeset` OR `xml_node` OR a list of
#'   either.
#' @inheritParams to_md
#' @return a character vector, invisibly. The result of these functions are
#'   displayed to the screen
#' @examples
#' path <- system.file("extdata", "show-example.md", package = "tinkr")
#' y <- tinkr::yarn$new(path, sourcepos = TRUE)
#' y$protect_math()$protect_curly()
#' items <- xml2::xml_find_all(y$body, ".//md:item", tinkr::md_ns())
#' imgs <- xml2::xml_find_all(y$body, ".//md:image | .//node()[@curly]",
#'   tinkr::md_ns())
#' links <- xml2::xml_find_all(y$body, ".//md:link", tinkr::md_ns())
#' code <- xml2::xml_find_all(y$body, ".//md:code", tinkr::md_ns())
#' blocks <- xml2::xml_find_all(y$body, ".//md:code_block", tinkr::md_ns())
#'
#' # show a list of items
#' show_list(links)
#' show_list(code)
#' show_list(blocks)
#'
#' # show the items in their local structure
#' show_block(items)
#' show_block(links, mark = TRUE)
#'
#' # show the items in the full document censored (everything but whitespace):
#' show_censor(imgs)
#'
#' # You can also adjust the censorship parameters. There are two paramters
#' # available: the mark, which chooses what character you want to use to
#' # replace characters (default: `\u2587`); and the regex which specifies
#' # characters to replace (default: `[^[:space:]]`, which replaces all
#' # non-whitespace characters.
#' #
#' # The following will replace everything that is not a whitespace
#' # or punctuation character with "o" for a very ghostly document
#' op <- options()
#' options(tinkr.censor.regex = "[^[:space:][:punct:]]")
#' options(tinkr.censor.mark = "o")
#' show_censor(links)
#' options(tinkr.censor.regex = NULL)
#' options(tinkr.censor.mark = NULL)
#' @seealso [to_md_vec()] to get a vector of these elements in isolation.
#' @rdname show
#' @export
show_list <- function(nodelist, stylesheet_path = stylesheet()) {
  res <- isolate_nodes(nodelist, type = "list")
  return(show_user(print_lines(res$doc)))
}

#' @rdname show
#' @param mark \[bool\] When `TRUE` markers (`[...]`) are added to replace
#'   nodes that come before or after the islated nodes. Defaults to `FALSE`,
#'   which only shows the isolated nodes in their respective blocks. Note that
#'   the default state may cause nodes within the same block to appear adjacent
#'   to each other.
#' @export
show_block <- function(nodelist, mark = FALSE, stylesheet_path = stylesheet()) {
  res <- isolate_nodes(nodelist, type = "context")
  if (mark) {
    res <- add_isolation_context(nodelist, res)
  }
  return(show_user(print_lines(res$doc)))
}

#' @rdname show
#' @export
show_censor <- function(nodelist, stylesheet_path = stylesheet()) {
  res <- isolate_nodes(nodelist, type = "censor")
  return(show_user(print_lines(res$doc)))
}

#' Isolate nodes in a document
#'
#' @inheritParams show_list
#' @param type a string of either "context" (default), "censor", or "list"
#'
#' @return a list of two elements:
#'  - doc: a copy of the document with the nodes isolated depending on the
#'         context
#'  - key: a string used to tag nodes that are isolated via the `tnk-key`
#'         attribute
#'
#' @details
#' `isolate_nodes()`is the workhorse for the `show` family of functions. These
#' functions will create a copy of the document with the nodes present in
#' `nodelist` isolated. It has the following switches for "type":
#' - "context" include the nodes within the block context of the document.
#'   For example, if the nodelist contains links in headings, paragraphs, and
#'   lists, those links will appear within these blocks. When `mark = TRUE`,
#'   ellipses `[...]` will be added to indicate hidden content.
#' - "censor" by default will replace all non-whitespace characters with a
#'   censor character. This is controlled by `tinkr.censor.regex` and
#'   `tinkr.censor.mark`
#' - "list" creates a new document and copies over the nodes so they appear
#'   as a list of paragraphs.
#' @keywords internal
#' @family nodeset isolation functions
#' @examplesIf isTRUE(as.logical(Sys.getenv("NOT_CRAN", "false")))
#' path <- system.file("extdata", "show-example.md", package = "tinkr")
#' y <- tinkr::yarn$new(path, sourcepos = TRUE)
#' y$protect_math()$protect_curly()
#' items <- xml2::xml_find_all(y$body, ".//md:item", tinkr::md_ns())
#' tnk <- asNamespace("tinkr")
#' tnk$isolate_nodes(items, type = "context")
#' tnk$isolate_nodes(items, type = "censor")
#' tnk$isolate_nodes(items, type = "list")
isolate_nodes <- function(nodelist, type = "context") {
  switch(
    type,
    "context" = isolate_nodes_block(nodelist),
    "censor" = isolate_nodes_censor(nodelist),
    "list" = isolate_nodes_list(nodelist),
  )
}

#' Create a document and list of nodes to isolate
#'
#' This uses [xml2::xml_root()] and [xml2::xml_path()] to make a copy of the
#' root document and then tag the corresponding nodes in the nodelist so that
#' we can filter on nodes that are not connected to those present in the
#' nodelist. This function is required for [isolate_nodes()] to work.
#'
#'
#' @inheritParams isolate_nodes
#'
#' @return a list of three elements:
#'  - doc: a copy of the document with the nodes isolated depending on the
#'         context
#'  - key: a string used to tag nodes that are isolated via the `tnk-key`
#'         attribute.
#'  - unrelated: an `xml_nodeset` containing nodes that have no ancestor,
#'         descendant, or self relationship to the nodes in `nodelist`.
#' @keywords internal
#' @family nodeset isolation functions
#' @examplesIf isTRUE(as.logical(Sys.getenv("NOT_CRAN", "false")))
#' path <- system.file("extdata", "show-example.md", package = "tinkr")
#' y <- tinkr::yarn$new(path, sourcepos = TRUE)
#' y$protect_math()$protect_curly()
#' items <- xml2::xml_find_all(y$body, ".//md:item", tinkr::md_ns())
#' tnk <- asNamespace("tinkr")
#' tnk$provision_isolation(items)
provision_isolation <- function(nodelist) {
  # create a copy of our document
  doc <- if (inherits(nodelist, "xml_node")) nodelist else nodelist[[1]]
  doc <- copy_xml(xml2::xml_root(doc))
  # get the path to the currently labelled nodes so we can
  # isolate them in the copy.
  # This will return one path statement per node
  if (inherits(nodelist, c("xml_nodeset", "xml_node"))) {
    path <- xml2::xml_path(nodelist)
  } else {
    path <- purrr::flatten_chr(purrr::map(nodelist, xml2::xml_path))
  }
  # label new nodes with unique timestamp
  key <- as.character(as.integer(Sys.time()))
  purrr::walk(path, label_nodes, doc = doc, label = key)

  # find the unrelated nodes for deletion/censoring
  #  - not labelled
  #  - not a descendant of a labelled node
  #  - not an _ancestor_ of a labelled node
  predicate <- sprintf("@tnk-key=%s", key)
  ancestor <- sprintf("ancestor::*[%s]", predicate)
  descendant <- sprintf("descendant::*[%s]", predicate)
  xpth <- sprintf(
    "not(%s) and not(%s) and not(%s)",
    ancestor,
    descendant,
    predicate
  )
  unrelated <- xml2::xml_find_all(doc, sprintf("//node()[%s]", xpth))
  return(list(doc = doc, key = key, unrelated = unrelated))
}


isolate_nodes_list <- function(nodelist) {
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
      purrr::walk(node, function(n) {
        xml2::xml_add_child(parent, n)
        xml2::xml_add_child(parent, "softbreak")
      })
    }
  }
  return(list(doc = doc, key = NULL))
}


isolate_nodes_block <- function(nodelist) {
  res <- provision_isolation(nodelist)
  xml2::xml_remove(res$unrelated)
  return(list(doc = res$doc, key = res$key))
}

isolate_nodes_censor <- function(nodelist) {
  res <- provision_isolation(nodelist)
  censor_attr(res$unrelated, "destination")
  censor_attr(res$unrelated, "title")
  censor_attr(res$unrelated, "rel")
  txt <- xml2::xml_find_all(res$unrelated, ".//text()")
  xml2::xml_set_text(txt, censor(xml2::xml_text(txt)))
  return(list(doc = res$doc, key = res$key))
}

add_isolation_context <- function(nodelist, isolated) {
  sib <- sprintf("sibling::*[1][not(@tnk-key=%s)]", isolated$key)
  pretext <- xml2::xml_find_lgl(
    nodelist,
    sprintf("boolean(count(preceding-%s)!=0)", sib)
  )
  postext <- xml2::xml_find_lgl(
    nodelist,
    sprintf("boolean(count(following-%s)!=0)", sib)
  )
  xpath <- sprintf(".//node()[@tnk-key=%s]", isolated$key)
  labelled <- xml2::xml_find_all(isolated$doc, xpath)
  purrr::walk(labelled[pretext], function(node) {
    xml2::xml_add_sibling(
      node,
      .where = "before",
      "text",
      "[...] ",
      asis = "true"
    )
  })
  purrr::walk(labelled[postext], function(node) {
    xml2::xml_add_sibling(
      node,
      .where = "after",
      "text",
      " [...]",
      asis = "true"
    )
  })
  return(isolated)
}


censor_attr <- function(nodes, attr) {
  attrs <- xml2::xml_attr(nodes, attr)
  nomiss <- !is.na(attrs)
  xml2::xml_set_attr(nodes[nomiss], attr, censor(attrs[nomiss]))
}

censor <- function(x) {
  regex <- getOption("tinkr.censor.regex", default = "[^[:space:]]")
  mark <- getOption("tinkr.censor.mark", default = "\u2587")
  gsub(regex, mark, x, perl = TRUE)
}

print_lines <- function(xml, path = NULL, stylesheet = NULL) {
  if (inherits(xml, "xml_document")) {
    xml <- list(frontmatter = "", body = xml)
  }
  if (is.null(stylesheet)) {
    md <- to_md(xml, path)
  } else {
    md <- to_md(xml, path, stylesheet)
  }
  if (!is.null(path) && !is.null(stylesheet)) {
    return(md)
  }
  # Make sure that the frontmatter is not sitting on top of the first markdown line
  if (length(md) == 2) {
    md[1] <- paste0(md[1], "\n")
  }
  f <- textConnection(md)
  on.exit(close(f))
  readLines(f)
}

label_nodes <- function(xpath, doc, label = "save") {
  xml2::xml_set_attr(
    xml2::xml_find_all(doc, xpath, ns = md_ns()),
    "tnk-key",
    label
  )
}
