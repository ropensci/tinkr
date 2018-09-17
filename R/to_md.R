#' Write YAML and XML back to disk as (R)Markdown
#'
#' @param yaml_xml_list result from a call to \code{to_xml} and editing.
#' @param path path of the new file
#'
#' @export
#'
#' @examples
#' path <- system.file("extdata", "example1.md", package = "tinkr")
#' yaml_xml_list <- to_xml(path)
#' names(yaml_xml_list)
#' library("magrittr")
#' # transform level 3 headers into level 1 headers
#' body <- yaml_xml_list$body
#' body %>%
#'   xml2::xml_find_all(xpath = './/d1:heading',
#'                      xml2::xml_ns(.)) %>%
#'   .[xml2::xml_attr(., "level") == "3"] -> headers3
#' xml2::xml_set_attr(headers3, "level", 1)
#' yaml_xml_list$body <- body
#' # save back and have a look
#' to_md(yaml_xml_list, "newmd.md")
#' file.edit("newmd.md")
#'
to_md <- function(yaml_xml_list, path){
  system.file("extdata", "xml2md.xsl", package = "tinkr") %>%
    xml2::read_xml() -> stylesheet

yaml_xml_list$body %>%
    xslt::xml_xslt(stylesheet = stylesheet) -> body

yaml_xml_list$yaml %>%
  glue::glue_collapse(sep = "\n") -> yaml

glue::glue("{{{{yaml}}}}\n{{{{body}}}}",
               .open = "{{{{",
               .close = "}}}}") %>%
    writeLines(path, useBytes = TRUE)
}
