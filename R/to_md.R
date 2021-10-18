#' Write YAML and XML back to disk as (R)Markdown
#'
#' @param yaml_xml_list result from a call to [to_xml()] and editing.
#' @param path path of the new file. Defaults to `NULL`, which will not write
#'   any file, but will still produce the conversion and pass the output as
#'   a character vector.
#' @param stylesheet_path path to the XSL stylesheet
#'
#' @details The stylesheet you use will decide whether lists
#' are built using "*" or "-" for instance. If you're keen to
#' keep your own Markdown style when using [to_md()] after
#' [to_xml()], you can tweak the XSL stylesheet a bit and provide
#' the path to your XSL stylesheet as argument.
#'
#'
#' @return the converted document, invisibly. 
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
#' newmd <- tempfile("newmd", fileext = ".md")
#' to_md(yaml_xml_list, newmd)
#' # file.edit("newmd.md")
#' file.remove(newmd)
#'
to_md <- function(yaml_xml_list, path = NULL, stylesheet_path = stylesheet()){

  # duplicate document to avoid overwriting
  body <- copy_xml(yaml_xml_list$body)
  yaml <- yaml_xml_list$yaml

  # read stylesheet and fail early if it doesn't exist
  stylesheet <- read_stylesheet(stylesheet_path)

  transform_code_blocks(body)
  remove_phantom_text(body)

  md_out <- transform_to_md(body, yaml, stylesheet)

  if (!is.null(path)) {
    writeLines(md_out, con = path, useBytes = TRUE, sep =  "\n\n")
  }

  invisible(md_out)
}

# convert body and yaml to markdown text given a stylesheet
transform_to_md <- function(body, yaml, stylesheet) {
  body <- xslt::xml_xslt(body, stylesheet = stylesheet)

  yaml <- glue::glue_collapse(yaml, sep = "\n")

  c(yaml, body)
}

# remove phantom text nodes that occur before links, images, and asis nodes that
# would cause perfectly valid markdown to be escaped.
remove_phantom_text <- function(body) {
  # find the nodes we wish to protect. Append this list if there are any other
  # surprises
  # to_protect <- xml2::xml_find_all(body,
  #   ".//md:link | .//md:image | .//md:text[@asis]", ns = md_ns())
  # # find the nodes that precede these nodes with zero length text
  to_sever <- xml2::xml_find_all(body,
    ".//md:text[string-length(text())=0]", ns = md_ns())
  if (length(to_sever)) {
    xml2::xml_remove(to_sever)
  }
  invisible(body)
}

copy_xml <- function(xml) {
  xml2::read_xml(as.character(xml))
}

transform_code_blocks <- function(xml){
  # Find all code blocks with a language attribute (those without it are not processed)
  code_blocks <- xml %>%
    xml2::xml_find_all(xpath = './/d1:code_block[@language]',
                       xml2::xml_ns(.))

  if(length(code_blocks) == 0){
    return(TRUE)
  }

  # transform to info string
  # if it had been parsed
  purrr::walk(code_blocks, to_info)
}

to_info <- function(code_block){
 attrs <- xml2::xml_attrs(code_block)
 options <- attrs[!names(attrs) %in%
                  c("language", "name", "space", "sourcepos", "xmlns", "xmlns:xml")]

 if(length(options) > 0){
   options <- glue::glue("{names(options)}={options}") %>%
     glue::glue_collapse(sep = ", ")
   options <- paste(",", options)
 }else{
   options <- ""
 }

 if (attrs["name"] != ""){
   attrs["name"] <- paste0(" ", attrs["name"])
 }

 info <- glue::glue('{attrs["language"]}{attrs["name"]}{options}')
 info <- paste0("{", info)
 info <- paste0(info, "}")
 names(info) <- "info"

 xml2::xml_set_attr(code_block, "info", info)
}
