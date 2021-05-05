set_asis <- function(nodes) {
  xml2::xml_set_attr(nodes[xml2::xml_name(nodes) != "softbreak"], "asis", "true")
}

# INLINE MATH ------------------------------------------------------------------

find_inline_math <- function(body, ns) {
   i <- ".//md:*[contains(text(), '$') and not(contains(text(), '$$'))]"
   xml2::xml_find_all(body, i, ns = ns)
}

inline_dollars_regex <- function(type = c("start", "stop", "full")) {
  start <- "(^|[[:space:][:punct:]])[$]?[$][^ $]"
  stop  <- "[^ $][$][$]?([[:space:][:punct:]]|$)"
  switch(type,
    start = start,
    stop = stop,
    full = glue::glue('{start}.+?{stop}')
  )
}

find_broken_math <- function(math) {
  txt <- xml2::xml_text(math)
  start <- grepl(inline_dollars_regex("start"), txt)
  stop  <- grepl(inline_dollars_regex("stop"), txt)
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

find_block_math <- function(body, ns, tag = "md:text[contains(text(), '$$')]") {
  after  <- "following-sibling::"
  before <- "preceding-sibling::"
  after_first_tag <- glue::glue("{after}{tag}")
  before_last_tag <- glue::glue("{before}md:*[{before}{tag}]")
  xpath <- glue::glue(".//{after_first_tag}/{before_last_tag}")
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
