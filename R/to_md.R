#' Write YAML and XML back to disk as (R)Markdown
#'
#' @param yaml_xml_list result from a call to \code{to_xml} and editing.
#' @param path path of the new file
#' @param stylesheet_path path to the XSL stylesheet
#'
#' @details The stylesheet you use will decide whether lists
#' are built using "*" or "-" for instance. If you're keen to
#'  keep your own Markdown style when using \code{to_md} after
#'  \code{to_xml}, you can tweak the XSL stylesheet a bit and provide
#'  the path to your XSL stylesheet as argument.
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
#' # file.edit("newmd.md")
#'
to_md <- function(yaml_xml_list, path,
                  stylesheet_path = system.file("extdata", "xml2md_gfm.xsl", package = "tinkr")){

   stylesheet_path %>%
    xml2::read_xml() -> stylesheet

  temp <- fs::file_temp(ext = ".xml")
  on.exit(file.remove(temp))

  body <- yaml_xml_list$body

  transform_code_blocks(body)

body  %>%
  xml2::write_xml(file = temp)

xml2::read_xml(temp) %>%
    xslt::xml_xslt(stylesheet = stylesheet) -> body

yaml_xml_list$yaml %>%
  glue::glue_collapse(sep = "\n") -> yaml

writeLines(c(yaml, body), con = path,
           useBytes = TRUE,
           sep =  "\n\n")
}

transform_code_blocks <- function(xml){
  code_blocks <- xml %>%
    xml2::xml_find_all(xpath = './/d1:code_block',
                       xml2::xml_ns(.))


  if(length(code_blocks) == 0){
    return(TRUE)
  }
  # transform to info string
  # if it had been parsed
  if(xml2::xml_has_attr(code_blocks[[1]], "language")){
    purrr::walk(code_blocks, to_info)
  }
}

to_info <- function(code_block){
 attrs <- xml2::xml_attrs(code_block)
 options <- attrs[!names(attrs) %in%
                    c("language", "name")]

 if(length(options) > 0){
   options <- glue::glue("{names(options)}={options}") %>%
     glue::glue_collapse(sep = ", ")
   options <- paste(",", options)
 }else{
   options <- ""
 }


 if(attrs["name"] != ""){
   attrs["name"] <- paste0(" ", attrs["name"])
 }

 info <- glue::glue('{attrs["language"]}{attrs["name"]}{options}')
 info <- paste0("{", info)
 info <- paste0(info, "}")
 names(info) <- "info"

 xml2::xml_set_attrs(code_block, info)
}
