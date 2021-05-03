find_inline_math <- function(body, ns) {
   i <- ".//md:text[contains(text(), '$') and not(contains(text(), '$$'))]"
   xml2::xml_find_all(body, i, ns = ns)
}

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

set_asis <- function(nodes) {
  xml2::xml_set_attr(nodes[xml2::xml_name(nodes) != "softbreak"], "asis", "true")
}

tick_check <- function(body, ns) {
  predicate <- "starts-with(text(), '[ ]') or starts-with(text(), '[x]')"
  cascade <- glue::glue(".//md:item/md:paragraph/md:text[{predicate}]")
  xml2::xml_find_all(body, cascade, ns = ns)
}

fix_tickboxes <- function(body, ns) {
  ticks <- tick_check(body, ns)
}
