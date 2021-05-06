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
#' ns  <- xml2::xml_ns_rename(xml2::xml_ns(txt), d1 = "md")
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
    new_nodes <- lapply(fix_fully_inline(imath), xml2::xml_children)

    # since we split up the nodes, we have to do this node by node
    for (i in seq(new_nodes)) {
      add_node_siblings(math[bespoke][[i]], new_nodes[[i]], remove = TRUE)
    }
  }

  # protect math that is broken across lines
  if (length(bmath)) {
    if (length(bmath[endless]) != length(bmath[headless])) {
      stop("Uneven math elements")
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
  nodes <- xml2::xml_children(set_default_space(nodes))
  # nodes <- xml2::xml_children(fix_fully_inline(one_line))
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
  set_default_space(char)
}

set_default_space <- function(char) {
  new_nodes <- char_to_nodelist(char)
  n <- xml2::xml_find_all(new_nodes, ".//node()")
  # set space to default to avoid weird formatting (this may change)
  xml2::xml_set_attr(n, "xml:space", "default")
  new_nodes
}

char_to_nodelist <- function(txt) {
  doc <- glue::glue(commonmark::markdown_xml("{paste(txt, collapse = '\n')}")) 
  doc <- xml2::read_xml(doc)
  nodes <- xml2::xml_children(xml2::xml_children(doc))
  nodes[xml2::xml_name(nodes) != "softbreak"]
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

fix_tickboxes <- function(body, ns) {
  ticks <- tick_check(body, ns)
}
