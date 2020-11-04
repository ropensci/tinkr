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

    #' @description Write a yarn document to markdown/Rmarkdown
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
      if (is.null(path)) {
        stop("Please provide a file path", call. = FALSE)
      }
      to_md(self, path, stylesheet_path)
      invisible(self)
    }
  )
)
