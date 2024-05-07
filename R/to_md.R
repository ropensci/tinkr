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

  if (length(yaml) > 0) {
    yaml <- glue::glue_collapse(yaml, sep = "\n")
  }

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

#' @examples
#' path <- system.file("extdata", "example1.md", package = "tinkr")
#' y <- tinkr::yarn$new(path)
#' items <- xml2::xml_find_all(y$body, ".//md:item", tinkr::md_ns())
#' links <- xml2::xml_find_all(y$body, ".//md:link", tinkr::md_ns())
#' md_fragment(items)
#' md_fragment(links)
md_fragment <- function(nodelist) {
  parents <- purrr::map(nodelist, xml2::xml_parent)
  donor <- xml2::read_xml(commonmark::markdown_xml(""))
  gparents <- add_children_to_donor(donor, parents, nodelist)
  add_grandparents(donor, gparents)
  return(copy_xml(donor))
}

copy_and_isolate <- function(nodelist) {

  doc <- copy_xml(xml2::xml_root(nodelist))
  path <- xml2::xml_path(nodelist)
  tim <- as.character(as.integer(Sys.time()))
  purrr::walk(path, label_nodes, doc = doc, label = tim)
  xpath <- paste0(".//node()[@label='",tim,"']")
  labelled <- xml2::xml_find_all(doc, xpath)
  purrr::walk(labelled, isolate_labelled)
  return(doc)
}

label_nodes <- function(xpath, doc, label = "save") {
  xml2::xml_set_attr(
    xml2::xml_find_all(doc, xpath, ns = md_ns()), 
    "label", label)
}
isolate_labelled <- function(node) {
  sibs <- xml2::xml_siblings(node)
  lab <- xml2::xml_attr(node, "label")
  nolab <- xml2::xml_attr(sibs, "label") != lab
  if (any(nolab)) {
    xml2::xml_remove(sibs[nolab])
  }
}


add_children_to_donor <- function(donor, parents, children) {
  old_parent <- NULL
  new_parent <- NULL
  gparents <- list()
  # loop over all the parents
  for (i in seq(parents)) {
    # when we have not encountered the current parent
    if (!identical(old_parent, parents[[i]])) {
      # set it to the old_parent
      old_parent <- parents[[i]]
      # record its grandparent
      grandparent <- xml2::xml_parent(old_parent)
      if (is_root(grandparent)) {
        grandparent <- NULL
      } 
      # add grandparent to the list
      gparents <- c(gparents, list(grandparent))
      # insert the old parent as a child of the donor document,
      # returning the new node
      new_parent <- insert_child(old_parent, donor)
    }
    # if the new_parent contains a parent, then add the child to the parent
    if (!is.null(new_parent)) {
      xml2::xml_add_child(new_parent, children[[i]])
    }
  }
  # return the grandparents for further processing
  names(gparents) <- seq_along(gparents)
  return(gparents)
}

add_grandparents <- function(donor, grandparents) {
  if (all(vapply(grandparents, is.null, logical(1)))) {
    return(donor)
  }
  children <- xml2::xml_children(donor)
  ggparents <- grandparents
  old_grandparent <- NULL
  this_parent <- NULL
  for (i in seq(children)) {
    if (is.null(grandparents[[i]]) || is_root(grandparents[[i]])) {
      next
    }
    # when the grandparents are identical, then we need add the current parent
    if (identical(old_grandparent, grandparents[[i]])) {
      xml2::xml_add_parent(children[[i]], this_parent)
    } else {
      # otherwise, we need to insert a new parent
      insert_parent(grandparents[[i]], children[[i]])
      this_parent <- xml2::xml_parent(children[[i]])
      # because we've recorded a new parent, we need to move up and 
      # capture the 
      old_grandparent <- grandparents[[i]]
      ggp <- xml2::xml_parent(grandparents[[i]])
      if (is_root(ggp)) {
        ggp <- NULL
      }
      ggparents[[i]] <- ggp
    }
  }
  return(add_grandparents(donor, ggparents))
}

insert_child <- function(from, to) {
  insert_node(from, to, type = "child")
}

insert_parent <- function(from, to) {
  insert_node(from, to, type = "parent")
}

insert_node <- function(from, to, type = "child") {
  if (type == "child") {
    this_parent <- xml2::xml_add_child(to, xml2::xml_name(from))
  } else {
    this_parent <- xml2::xml_add_parent(to, xml2::xml_name(from))
  }
  purrr::imap(xml2::xml_attrs(from),
    function(x, i) xml2::xml_set_attr(this_parent, i, x)
  )
  return(this_parent)
}

is_root <- function(node) {
  xml2::xml_name(node) == "document"
}
