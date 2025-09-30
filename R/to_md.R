#' Write front-matter (YAML, TOML or JSON) and XML back to disk as (R)Markdown
#'
#' @param frontmatter_xml_list result from a call to [to_xml()] and editing.
#' @param yaml_xml_list `r lifecycle::badge('deprecated')` Use `frontmatter_xml_list()`.
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
#' @return
#'  - `to_md()`: `\[character\]` the converted document, invisibly as a character vector containing two elements: the frontmatter list and the markdown body.
#'  - `to_md_vec()`: `\[character\]` the markdown representation of each node.
#'
#' @export
#'
#' @examples
#' path <- system.file("extdata", "example1.md", package = "tinkr")
#' frontmatter_xml_list <- to_xml(path)
#' names(frontmatter_xml_list)
#' # extract the level 3 headers from the body
#' headers3 <- xml2::xml_find_all(
#'   frontmatter_xml_list$body,
#'   xpath = './/md:heading[@level="3"]',
#'   ns = md_ns()
#' )
#' # show the headers
#' print(h3 <- to_md_vec(headers3))
#' # transform level 3 headers into level 1 headers
#' # NOTE: these nodes are still associated with the document and this is done
#' # in place.
#' xml2::xml_set_attr(headers3, "level", 1)
#' # preview the new headers
#' print(h1 <- to_md_vec(headers3))
#' # save back and have a look
#' newmd <- tempfile("newmd", fileext = ".md")
#' res <- to_md(frontmatter_xml_list, newmd)
#' # show that it works
#' regmatches(res[[2]], gregexpr(h1[1], res[[2]], fixed = TRUE))
#' # file.edit("newmd.md")
#' file.remove(newmd)
#'
to_md <- function(
  frontmatter_xml_list,
  path = NULL,
  stylesheet_path = stylesheet(),
  yaml_xml_list = deprecated()
) {
  # duplicate document to avoid overwriting
  body <- copy_xml(frontmatter_xml_list$body)
  frontmatter <- frontmatter_xml_list$frontmatter

  # read stylesheet and fail early if it doesn't exist
  stylesheet <- read_stylesheet(stylesheet_path)

  transform_code_blocks(body)
  remove_phantom_text(body)

  md_out <- transform_to_md(body, frontmatter, stylesheet)

  if (!is.null(path)) {
    writeLines(md_out, con = path, useBytes = TRUE, sep = "\n\n")
  }

  invisible(md_out)
}

#' @rdname to_md
#' @export
#' @param nodelist an object of `xml_nodelist` or `xml_node`
to_md_vec <- function(nodelist, stylesheet_path = stylesheet()) {
  if (inherits(nodelist, "xml_node")) {
    nodelist <- list(nodelist)
  }
  nodes <- lapply(nodelist, function(i) {
    print_lines(isolate_nodes(i, "list")$doc, stylesheet = stylesheet_path)
  })
  trimws(vapply(nodes, paste, character(1), collapse = "\n"))
}


# convert body and frontmatter to markdown text given a stylesheet
transform_to_md <- function(body, frontmatter, stylesheet) {
  body <- xslt::xml_xslt(body, stylesheet = stylesheet)

  if (length(frontmatter) > 0) {
    frontmatter <- glue::glue_collapse(frontmatter, sep = "\n")
  }

  c(frontmatter, body)
}

# remove phantom text nodes that occur before links, images, and asis nodes that
# would cause perfectly valid markdown to be escaped.
remove_phantom_text <- function(body) {
  # find the nodes we wish to protect. Append this list if there are any other
  # surprises
  # to_protect <- xml2::xml_find_all(body,
  #   ".//md:link | .//md:image | .//md:text[@asis]", ns = md_ns())
  # # find the nodes that precede these nodes with zero length text
  to_sever <- xml2::xml_find_all(
    body,
    ".//md:text[string-length(text())=0]",
    ns = md_ns()
  )
  if (length(to_sever)) {
    xml2::xml_remove(to_sever)
  }
  invisible(body)
}

copy_xml <- function(xml) {
  xml2::read_xml(as.character(xml))
}

transform_code_blocks <- function(xml) {
  # Find all code blocks with a language attribute (those without it are not processed)
  code_blocks <- xml %>%
    xml2::xml_find_all(xpath = './/d1:code_block[@language]', xml2::xml_ns(.))

  if (length(code_blocks) == 0) {
    return(TRUE)
  }

  # transform to info string
  # if it had been parsed
  purrr::walk(code_blocks, to_info)
}

to_info <- function(code_block) {
  attrs <- xml2::xml_attrs(code_block)
  options <- attrs[
    !names(attrs) %in%
      c("language", "name", "space", "sourcepos", "xmlns", "xmlns:xml")
  ]

  if (length(options) > 0) {
    options <- glue::glue("{names(options)}={options}") %>%
      glue::glue_collapse(sep = ", ")
    options <- paste(",", options)
  } else {
    options <- ""
  }

  if (attrs["name"] != "") {
    attrs["name"] <- paste0(" ", attrs["name"])
  }

  info <- glue::glue('{attrs["language"]}{attrs["name"]}{options}')
  info <- paste0("{", info)
  info <- paste0(info, "}")
  names(info) <- "info"

  xml2::xml_set_attr(code_block, "info", info)
}
