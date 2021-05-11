#' Aliased namespace prefix for commonmark
#'
#' The {commonmark} package is used to translate markdown to XML, but it does
#' not assign a namespace prefix, which means that {xml2} will auto-assign a 
#' default prefix of `d1`. 
#'
#' This function renames the default prefix to `md`, so that you can use XPath
#' queries that are slightly more descriptive.
#'
#' @return an `xml_namespace` object (see [xml2::xml_ns()])
#' @export
#' @examples
#'
#' tink <- tinkr::to_xml(system.file("extdata", "example1.md", package = "tinkr"))
#' # with default namespace
#' xml2::xml_find_all(tink$body, 
#'   ".//d1:link[starts-with(@destination, 'https://ropensci')]"
#' )
#' # with tinkr namespace
#' xml2::xml_find_all(tink$body, 
#'   ".//md:link[starts-with(@destination, 'https://ropensci')]",
#'   tinkr::md_ns()
#' )
#'
md_ns <- function() {
  structure(c(md = "http://commonmark.org/xml/1.0"), class = "xml_namespace")
}
