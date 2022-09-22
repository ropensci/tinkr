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
  # This looks for a potetial minus sign followed by maybe a space to allow for
  # $\beta, $$\beta, $-\beta, $- \beta
  minus_maybe <- glue::glue("(?=([-][{ace}]?)?")
  # punctuation marks that should _not_ occur after the dollar sign. I'm listing
  # them here because \ and - and opening symbols are valid afaict.
  post_punks <- "]})>[:space:],;.?$-"
  no_punks <- glue::glue("{minus_maybe}[^{post_punks}])")
  start <- glue::glue("(?=^|{punks})[$]?[$]{no_punks}")
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
  stop <- grepl(inline_dollars_regex("stop"), txt, perl = TRUE)
  full <- grepl(inline_dollars_regex("full"), txt, perl = TRUE)

  incomplete <- !(start & stop)
  no_end <- start & incomplete
  no_beginning <- stop & incomplete

  list(
    no_end = no_end,
    no_beginning = no_beginning,
    ambiguous = !full & !(no_end | no_beginning)
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
#'   "This sentence contains $I_A$ $\\frac{\\pi}{2}$ inline $\\LaTeX$ math."
#' )
#' txt <- xml2::read_xml(txt)
#' cat(tinkr::to_md(list(body = txt, yaml = "")), sep = "\n")
#' ns  <- tinkr::md_ns()
#' if (requireNamespace("withr")) {
#' protxt <- withr::with_namespace("tinkr", protect_inline_math(txt, ns))
#' cat(tinkr::to_md(list(body = protxt, yaml = "")), sep = "\n")
#' }
protect_inline_math <- function(body, ns) {
  body  <- copy_xml(body)
  math  <- find_inline_math(body, ns)
  if (length(math) == 0) {
    return(body)
  }
  broke <- find_broken_math(math)

  bespoke  <- !(broke$no_end | broke$no_beginning | broke$ambiguous)
  endless  <- broke$no_end[!bespoke]
  headless <- broke$no_beginning[!bespoke]

  imath   <- math[bespoke]
  bmath   <- math[!bespoke]

  # protect math that is strictly inline
  if (length(imath)) {
    new_nodes <- purrr::map(imath, fix_fully_inline)
    # since we split up the nodes, we have to do this node by node
    for (i in seq(new_nodes)) {
      add_node_siblings(imath[[i]], new_nodes[[i]], remove = TRUE)
    }
  }

  # protect math that is broken across lines or markdown elements
  if (length(bmath)) {
    if (any(broke$ambiguous)) {
      # ambiguous math may be due to inline r code that produces an answer:
      # $R^2 = `r runif(1)`$
      # In this case, we can detect it and properly address it as a headless
      # part.
      has_inline_code <- xml2::xml_find_lgl(bmath,
        "boolean(.//preceding-sibling::md:code)", ns
      )
      headless <- headless | has_inline_code
    }
    # If the lengths of the beginning and ending tags don't match, we throw
    # an error.
    le <- length(bmath[endless])
    lh <- length(bmath[headless])
    if (le != lh) {
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
  new_nodes <- purrr::map(char, make_text_nodes)
  # since we split up the nodes, we have to do this node by node
  for (i in seq(new_nodes)) {
    add_node_siblings(ticks[[i]], new_nodes[[i]], remove = TRUE)
  }
  copy_xml(body)
}

# FOOTNOTES --------------------------------------------------------------------

#' Protect unescaped square brackets from being escaped
#'
#' Commonmark allows both `[unescaped]` and `\[escaped\]` square brackets, but
#' in the XML representation, it makes no note of which square brackets were 
#' originally escaped and thus will escape both in the output.
#'
#' To fix this, we dive back into the source document and find the brackets that
#' were originally escaped and wrap those characters in protective tags so that
#' they do not become escaped when the XML is written. This has the benefit of 
#' protecting footnotes and [reference style links](https://spec.commonmark.org/0.30/#reference-link) 
#' that refer to link definitions in [child documents](https://bookdown.org/yihui/rmarkdown-cookbook/child-document.html)
#' which are not included in the AST, and not recognised as links
#' by default.
#'
#' @inheritParams resolve_anchor_links
#' @param offset the offset in lines of the yaml header defaults to 0,
#' indicating that the text has the yaml header stripped off. 
#' @keywords internal
#' @note This requires documents to be read in with `sourcepos = TRUE`
#'
#' @examples
#' f <- system.file("extdata", "link-test.md", package = "tinkr")
#' md <- yarn$new(f, sourcepos = TRUE, unescaped = FALSE)
#' md$show()
#' if (requireNamespace("withr")) {
#' lnks <- withr::with_namespace("tinkr", 
#'   protect_unescaped(md$body, readLines(md$path), offset = length(md$yaml)))
#' md$body <- lnks
#' md$show()
#' }
protect_unescaped <- function(body, txt, offset = 0L, ns = md_ns()) {
  has_sourcepos <- xml2::xml_find_lgl(body, "boolean(.//@sourcepos)")
  if (!has_sourcepos) {
    warning("`protect_unescaped()` needs to know the source position. No modification taking place.")
    return(body)
  }
  body <- copy_xml(body)
  squares <- find_escaped_squares(txt)
  escapes <- which(vapply(squares, sum, integer(1)) > 0L)
  XPATH <- ".//md:text[not(@asis)][contains(text(), '[') or contains(text(), ']')]"
  snodes <- xml2::xml_find_all(body, XPATH, ns = ns)
  fix_unescaped_squares(snodes, txt, squares, escapes, offset)
  copy_xml(body)
}


find_escaped_squares <- function(txt) {
  gregexpr("(\\\\\\])|(\\\\\\[)", txt)
}

fix_unescaped_squares <- function(nodes, txt, squares, escapes, offset) {
  lines  <- get_linestart(nodes) + offset
  for (i in seq_along(lines)) {
    this_line <- lines[[i]]
    this_node <- nodes[[i]]
    if (!this_line %in% escapes) {
      # if there are no existing escaped braces here, we need to protect them
      fix_unescaped(this_node)
    } else {
      # if there are escaped braces, there may be situations where we have
      # escaped and unescaped braces on the same line (for example a link and
      # an example of a link). This will tell us if the node we are handling
      # contain the characters we need to escape (markup splits the nodes).
      start <- get_colstart(this_node)
      end   <- get_colend(this_node)
      escape_sequence <- squares[[this_line]]
      overlaps <- start <= max(escape_sequence) & end >= min(escape_sequence)
      if (overlaps) {
        fix_unescaped(this_node, escape_sequence, offset = start)
      }
    }
  }
}

fix_unescaped <- function(node, escaped = NULL, offset = 1L) {
  
  txt <- as.character(node)
  # Converted to text, the node becomes <text ...>Actual text</text>
  # Because the position is based on the actual text, we need to find the start
  # of the actual text in the node text
  text_start <- gregexpr("[>]", txt)[[1]][[1]] + 1L
  if (is.null(escaped)) {
    unescaped <- TRUE
  } else {
    # Because the escaped characters were stripped off, we have to account for 
    # a rolling count of the number of escapes
    missing_chars <- seq_along(escaped) - 1L
    # If the source starts with markup, we have to take into account the offset
    # position. This will set the escaped to start at the end of the XML markup
    unescaped <- -(escaped + text_start - offset - missing_chars)
  }
  # Here we split the character and exclude the escaped braces, protecting
  # the unescaped braces.
  chars <- strsplit(txt, "")[[1]]
  chars[unescaped] <- sub(
    pattern = "(\\[|\\])", 
    replacement = "</text><text asis='true'>\\1</text><text>", 
    x = chars[unescaped]
  )
  new_nodes <- make_text_nodes(paste(chars, collapse = ""))
  add_node_siblings(node, new_nodes, remove = TRUE)
}

