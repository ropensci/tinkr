#' Transform file to XML
#'
#' @param path Path to the file.
#' @param encoding Encoding to be used by readLines.
#'
#' @return A list containing the YAML of the file (yaml)
#' and its body (body) as XML.
#' @export
#'
#' @examples
#' path <- system.file("extdata", "example1.md", package = "tinkr")
#' post_list <- to_xml(path)
#' names(post_list)
to_xml <- function(path, encoding = "UTF-8"){
  content <- readLines(path, encoding = encoding)
  content <- clean_content(content)

  splitted_content <- blogdown:::split_yaml_body(content)

  yaml <- splitted_content$yaml

  splitted_content$body %>%
    commonmark::markdown_xml(extensions = FALSE) %>%
    xml2::read_xml() -> body

  list(yaml = yaml,
       body = body)
}


clean_content <- function(content){
  content %>%
    stringr::str_replace_all("“", '"') %>%
    stringr::str_replace_all("”", '"') %>%
    stringr::str_replace_all("’", "'")
}
