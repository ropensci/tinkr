#' Protect math elements from commonmark's character escape
#'
#' @param body an XML object
#' @param ns an XML namespace object (defaults: [md_ns()]).
#' @return a copy of the modified XML object
#' @details Commonmark does not know what LaTeX is and will LaTeX equations as
#' normal text. This means that content surrounded by underscores are 
#' interpreted as `<emph>` elements and all backslashes are escaped by default.
#' This function protects inline and block math elements that use `$` and `$$`
#' for delimiters, respectively. 
#' 
#' @note this function is also a method in the [tinkr::yarn] object.
#' 
#' @export
#' @examples
#' m <- tinkr::to_xml(system.file("extdata", "math-example.md", package = "tinkr"))
#' txt <- textConnection(tinkr::to_md(m))
#' cat(tail(readLines(txt)), sep = "\n") # broken math
#' close(txt)
#' m$body <- protect_math(m$body)
#' txt <- textConnection(tinkr::to_md(m))
#' cat(tail(readLines(txt)), sep = "\n") # fixed math
#' close(txt)
protect_math <- function(body, ns = md_ns()) {
  # block math adds attributes, done in memory
  protect_block_math(body, ns)
  # inline math adds _nodes_, which means a new document
  protect_inline_math(body, ns)
}

set_asis <- function(nodes) {
  xml2::xml_set_attr(nodes[xml2::xml_name(nodes) != "softbreak"], "asis", "true")
}

# INLINE MATH ------------------------------------------------------------------

# finding inline math consists of searching for $ and excluding $$
find_inline_math <- function(body, ns) {
   i <- ".//md:text[not(@asis) and contains(text(), '$') and not(contains(text(), '$$'))]"
   xml2::xml_find_all(body, i, ns = ns)
}

# Helper function to return the proper regex for inline math.
# Having the start and stop type individually allows me to invert the
# union between them to find the incomplete cases.
inline_dollars_regex <- function(type = c("start", "stop", "full")) {
  # any space
  ace   <- "[:space:]"
  punks <- glue::glue("[{ace}[:punct:]]")
  # Note about this regex: the first part is a lookahead (?=...) that searches 
  # for the line start, space, or punctuation. Importantly about lookaheads,
  # they do not consume the string 
  # (https://junli.netlify.app/en/overlapping-regular-expression-in-python/)
  # 
  # The rest of the regex looks for a dollar sign that does not butt up against
  # a space or another dollar. 
  start <- glue::glue("(?=^|{punks})[$]?[$][^{ace}$]")
  stop  <- glue::glue("[^{ace}$][$][$]?(?={punks}|$)")
  switch(type,
    start = start,
    stop = stop,
    full = glue::glue('({start}.+?{stop})')
  )
}

# Find incomplete cases for inline math
find_broken_math <- function(math) {
  txt <- xml2::xml_text(math)
  start <- grepl(inline_dollars_regex("start"), txt, perl = TRUE)
  stop  <- grepl(inline_dollars_regex("stop"), txt, perl = TRUE)
  incomplete <- !(start & stop)
  list(
    no_end = start & incomplete, 
    no_beginning = stop & incomplete
  )
}

#' Find and protect all inline math elements
#' 
#' @param body an XML document
#' @param ns an XML namespace
#' @return a modified _copy_ of the original XML document
#' @keywords internal
#' @examples
#' txt <- commonmark::markdown_xml(
#'   r"{This sentence contains $I_A$ $\frac{\pi}{2}$ inline $\LaTeX$ math.}"
#' )
#' txt <- xml2::read_xml(txt)
#' cat(to_md(list(body = txt, yaml = "")), sep = "\n")
#' ns  <- tinkr::md_ns()
#' protxt <- tinkr:::protect_inline_math(txt, ns)
#' cat(to_md(list(body = protxt, yaml = "")), sep = "\n")
protect_inline_math <- function(body, ns) {
  body  <- copy_xml(body)
  math  <- find_inline_math(body, ns)
  if (length(math) == 0) {
    return(body)
  }
  broke <- find_broken_math(math)

  bespoke  <- !(broke$no_end | broke$no_beginning)
  endless  <- broke$no_end[!bespoke]
  headless <- broke$no_beginning[!bespoke]

  imath   <- math[bespoke]
  bmath   <- math[!bespoke]

  # protect math that is strictly inline
  if (length(imath)) {
    new_nodes <- lapply(imath, fix_fully_inline)
    # since we split up the nodes, we have to do this node by node
    for (i in seq(new_nodes)) {
      add_node_siblings(imath[[i]], new_nodes[[i]], remove = TRUE)
    }
  }

  # protect math that is broken across lines or markdown elements
  if (length(bmath)) {
    # If the lengths of the beginning and ending tags don't match, we throw
    # an error.
    if ((le <- length(bmath[endless])) != (lh <- length(bmath[headless]))) {
      unbalanced_math_error(bmath, endless, headless, le, lh) 
    }
    # assign sequential tags to the pairs of inline math elements
    tags <- seq(length(bmath[endless]))  
    xml2::xml_set_attr(bmath[endless], "latex-pair", tags)
    xml2::xml_set_attr(bmath[headless], "latex-pair", tags)
    for (i in tags) {
      fix_partial_inline(i, body, ns)
    }
  }
  copy_xml(body)
}

# Partial inline math are math elements that are not entirely embedded in a 
# single `<text>` element. There are two reasons for this: 
#
# 1. Math is split across separate lines in the markdown document
# 2. There are elements like `_` that are interpreted as markdown elements.
#
# To use this function, an inline pair needs to be first tagged with a 
# `latex-pair` attribute that uniquely identifies that pair of tags. It assumes
# that all of the content between that pair of tags belongs to the math element.
fix_partial_inline <- function(tag, body, ns) {
  # find everything between the tagged pair
  math_lines <- find_between_inlines(body, ns, tag)
  # make sure everything between the tagged pair is labeled as 'asis'
  filling <- math_lines[is.na(xml2::xml_attr(math_lines, "latex-pair"))]
  set_asis(filling)
  filling <- xml2::xml_find_all(filling, ".//node()")
  set_asis(filling)
  # paste the lines together and create new nodes
  n <- length(math_lines)
  char <- as.character(math_lines)
  char[[1]] <- sub("[$]", "$</text><text asis='true'>", char[[1]])
  char[[n]] <- sub("[<]text ", "<text asis='true' ", char[[n]])
  nodes <- paste(char, collapse = "")
  nodes <- make_text_nodes(nodes)
  # add the new nodes to the bottom of the existing math lines 
  last_line <- math_lines[n]
  to_remove <- math_lines[-n]
  add_node_siblings(last_line, nodes, remove = TRUE)
  # remove the duplicate lines
  xml2::xml_remove(to_remove)
}

fix_fully_inline <- function(math) {
  char <- as.character(math)
  # Find inline math that is complete and wrap it in text with asis
  # <text>this is $\LaTeX$ text</text>
  #   becomes
  # <text>this is </text><text asis='true'>$\LaTeX$</text><text> text</text>
  char <- gsub(
    pattern = inline_dollars_regex("full"),
    replacement = "</text><text asis='true'>\\1</text><text>", 
    x = char,
    perl = TRUE
  )
  make_text_nodes(char)
}

#' Transform a character vector of XML into text nodes
#'
#' This is useful in the case where we want to modify some text content to
#' split it and label a portion of it 'asis' to protect it from commonmark's
#' escape processing.
#' 
#' For example, `fix_fully_inline()` uses this to modify a single text node
#' into several text nodes: 
#'
#' ```html
#'    <text>this is $\LaTeX$ text</text>
#'      becomes
#'    <text>this is </text><text asis='true'>$\LaTeX$</text><text> text</text>
#' ```
#'
#' The `make_text_nodes()` function takes the above text string and converts it
#' into nodes so that the original text node can be replaced.
#' @param a character vector of modified text nodes 
#' @return a nodeset with no associated namespace
#' @noRd
make_text_nodes <- function(txt) {
  doc <- glue::glue(commonmark::markdown_xml("{paste(txt, collapse = '')}")) 
  nodes <- xml2::xml_ns_strip(xml2::read_xml(doc))
  xml2::xml_find_all(nodes, ".//paragraph/text/*")
}


# BLOCK MATH ------------------------------------------------------------------

find_block_math <- function(body, ns) {
  find_between(body, ns, pattern = "md:text[contains(text(), '$$')]", include = FALSE)
}

find_between_inlines <- function(body, ns, tag) {
  to_find <- "md:text[@latex-pair='{tag}']"
  find_between(body, ns, pattern = glue::glue(to_find), include = TRUE)
}

protect_block_math <- function(body, ns) {
  bm <- find_block_math(body, ns)
  # get all of the internal nodes
  bm <- xml2::xml_find_all(bm, ".//descendant-or-self::md:*", ns = ns)
  set_asis(bm) 
}

# TICK BOXES -------------------------------------------------------------------

tick_check <- function(body, ns) {
  predicate <- "starts-with(text(), '[ ]') or starts-with(text(), '[x]')"
  cascade <- glue::glue(".//md:item/md:paragraph/md:text[{predicate}]")
  xml2::xml_find_all(body, cascade, ns = ns)
}

protect_tickbox <- function(body, ns) {
  body <- copy_xml(body)
  ticks <- tick_check(body, ns)
  if (length(ticks) == 0) {
    return(body)
  }
  # set the tickbox asis
  set_asis(ticks)
  char <- as.character(ticks)
  char <- sub("(\\[.\\])", "\\1</text><text>", char, perl = TRUE)
  new_nodes <- lapply(char, make_text_nodes)
  # since we split up the nodes, we have to do this node by node
  for (i in seq(new_nodes)) {
    add_node_siblings(ticks[[i]], new_nodes[[i]], remove = TRUE)
  }
  copy_xml(body)
}
