#' Find between a pattern
#'
#' Helper function to find all nodes between a standard pattern. This is useful
#' if you want to find unnested pandoc tags.
#'
#' @param body and XML document
#' @param ns the namespace of the document
#' @param pattern an XPath expression that defines characteristics of nodes
#'   between which you want to extract everything.
#' @param include if `TRUE`, the tags matching `pattern` will be included in
#'   the output, defaults to `FALSE`, which only gives you the nodes in between
#'   `pattern`.
#' @return a nodeset
#' @export
#' @examples
#' md <- glue::glue("
#'  h1
#'  ====
#'
#'  ::: section
#'
#'  h2
#'  ----
#'
#'  section *text* with [a link](https://ropensci.org/)
#'  
#'  :::
#' ")
#' x <- xml2::read_xml(commonmark::markdown_xml(md))
#' ns <- xml2::xml_ns_rename(xml2::xml_ns(x), d1 = "md")
#' res <- find_between(x, ns)
#' res
#' xml2::xml_text(res)
#' xml2::xml_find_all(res, ".//descendant-or-self::md:*", ns = ns)
find_between <- function(body, ns, pattern = "md:paragraph[md:text[starts-with(text(), ':::')]]", include = FALSE) {
  after  <- "following-sibling::"
  before <- "preceding-sibling::"
  after_first_pattern <- glue::glue("{after}{pattern}")
  before_last_pattern <- glue::glue("{before}md:*[{before}{pattern}]")
  prefix <- if (include) glue::glue(".//{pattern} | .//") else ".//"
  xpath <- glue::glue("{prefix}{after_first_pattern}/{before_last_pattern}")
  xml2::xml_find_all(body, xpath, ns = ns)
}
