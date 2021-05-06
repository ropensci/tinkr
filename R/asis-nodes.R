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

protect_inline_math <- function(body, ns) {
  math <- find_inline_math(body, ns)
  broke <- find_broken_math(math)

  # protect math that is strictly inline
  bespoke <- !(broke$no_end | broke$no_beginning)
  new_nodes <- lapply(fix_fully_inline(math[bespoke]), xml2::xml_children)

  # since we split up the nodes, we have to do this node by node
  for (i in seq(new_nodes)) {
    add_node_siblings(math[bespoke][[i]], new_nodes[[i]])
  }
  copy_xml(body)
}

fix_fully_inline <- function(math) {
  char <- as.character(math)
  # Find inline math that is complete and wrap it in text with asis
  # <text>this is $\LaTeX$ text</text>
  #   becomes
  # <text>this is</text><text asis='true'> $\LaTeX$ </text><text>text</text>
  char <- gsub(
    inline_dollars_regex("full"),
    "</text><text asis='true'>\\1</text><text>", 
    char
  )
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

find_block_math <- function(body, ns, tag = "md:text[contains(text(), '$$')]", include = FALSE) {
  after  <- "following-sibling::"
  before <- "preceding-sibling::"
  after_first_tag <- glue::glue("{after}{tag}")
  before_last_tag <- glue::glue("{before}md:*[{before}{tag}]")
  prefix <- if (include) glue::glue(".//{tag} | .//") else ".//"
  xpath <- glue::glue("{prefix}{after_first_tag}/{before_last_tag}")
  bm <- xml2::xml_find_all(body, xpath, ns = ns)
  xml2::xml_find_all(bm, ".//descendant-or-self::md:*", ns = ns)
}

protect_block_math <- function(body, ns) {
  bm <- find_block_math(body, ns)
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
