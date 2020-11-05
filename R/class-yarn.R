#' R6 class containing XML representation of Markdown
#'
#' @description
#' Wrapper around an XML representation of a Markdown document. It contains four
#' publicly accessible slots: path, yaml, body, and ns.
#' @details
#' This class is a fancy wrapper around the results of [tinkr::to_xml()] and
#' has methods that make it easier to add, analyze, remove, or write elements
#' of your markdown document.
#' @export
yarn <- R6::R6Class("yarn",
  portable = TRUE,
  public = list(
    #' @field path \[`character`\] path to file on disk
    path = NULL,

    #' @field yaml \[`character`\] text block at head of file
    yaml = NULL,

    #' @field body \[`xml_document`\] an xml document of the (R)Markdown file.
    body = NULL,

    #' @field ns \[`xml_document`\] an xml namespace object definining "md" to
    #'   commonmark.
    ns = NULL,
    #' @description Create a new yarn document
    #'
    #' @param path \[`character`\] path to a markdown episode file on disk
    #' @param encoding \[`character`\] encoding passed to [readLines()]
    #' @param sourcepos passed to [commonmark::markdown_xml()]. If `TRUE`, the
    #'   source position of the file will be included as a "sourcepos" attribute.
    #'   Defaults to `FALSE`.
    #' @return A new yarn object containing an XML representation of a
    #' (R)Markdown file.
    #'
    #' @examples
    #' path <- system.file("extdata", "example1.md", package = "tinkr")
    #' ex1 <- tinkr::yarn$new(path)
    #' ex1
    #' path2 <- system.file("extdata", "example2.Rmd", package = "tinkr")
    #' ex2 <- tinkr::yarn$new(path2)
    #' ex2
    initialize = function(path = NULL, encoding = "UTF-8", sourcepos = FALSE) {
      if (is.null(path)) {
        xml <- list(yaml = NULL, body = NULL)
      } else {
        xml <- to_xml(path, encoding, sourcepos)
      }

      self$path <- path
      self$yaml <- xml$yaml
      self$body <- xml$body
      self$ns   <- xml2::xml_ns_rename(xml2::xml_ns(xml$body), d1 = "md")
      invisible(self)
    },

    #' @description reset a yarn document from the original file
    #' @examples
    #'
    #' path <- system.file("extdata", "example1.md", package = "tinkr")
    #' ex1 <- tinkr::yarn$new(path)
    #' # OH NO
    #' ex1$body
    #' ex1$body <- xml2::xml_missing()
    #' ex1$reset()
    #' ex1$body
    reset = function() {
      x <- to_xml(self$path)
      self$body <- x$body
      self$yaml <- x$yaml
      invisible(self)
    },

    #' @description Write a yarn document to Markdown/R Markdown
    #'
    #' @param path path to the file you want to write
    #' @param stylesheet_path path to the xsl stylesheet to convert XML to markdown.
    #' @examples
    #' path <- system.file("extdata", "example1.md", package = "tinkr")
    #' ex1 <- tinkr::yarn$new(path)
    #' ex1
    #' tmp <- tempfile()
    #' try(readLines(tmp)) # nothing in the file
    #' ex1$write(tmp)
    #' head(readLines(tmp)) # now a markdown file
    #' unlink(tmp)
    write = function(path = NULL,
      stylesheet_path = system.file("extdata", "xml2md_gfm.xsl", package = "tinkr")){

      output <- to_md(self, path, stylesheet_path)

      if (is.null(path)) {
        cat(output)
      }

      invisible(output)
    },

    #' @description add an arbitrary Markdown element to the document
    #'
    #' @param md a string of markdown formatted text.
    #' @param where the location in the document to add your markdown text.
    #'   This is passed on to [xml2::xml_add_child()]. Defaults to 0, which
    #'   indicates the very top of the document.
    #' @examples
    #' path <- system.file("extdata", "example2.Rmd", package = "tinkr")
    #' ex <- tinkr::yarn$new(path)
    #' # two headings, no lists
    #' xml2::xml_find_all(ex$body, "md:heading", ex$ns)
    #' xml2::xml_find_all(ex$body, "md:list", ex$ns)
    #' ex$add_md(
    #'   "# Hello\n\nThis is *new* formatted text from `{tinkr}`!",
    #'   where = 1L
    #' )$add_md(
    #'   " - This\n - is\n - a new list",
    #'   where = 2L
    #' )
    #' # three headings
    #' xml2::xml_find_all(ex$body, "md:heading", ex$ns)
    #' xml2::xml_find_all(ex$body, "md:list", ex$ns)
    #' tmp <- tempfile()
    #' ex$write(tmp)
    #' readLines(tmp, n = 20)
    add_md = function(md, where = 0L) {
      b <- self$body
      new <- clean_content(md)
      new <- commonmark::markdown_xml(new, extensions = TRUE)
      new <- xml2::xml_ns_strip(xml2::read_xml(new))
      new <- xml2::xml_children(new)
      for (child in rev(new)) {
        xml2::xml_add_child(b, child, .where = where)
      }
      self$body <- copy_xml(b)
      invisible(self)
    }
  ),
)
