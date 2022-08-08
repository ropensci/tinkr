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

    #' @field ns \[`xml_document`\] an xml namespace object defining "md" to
    #'   commonmark.
    ns = NULL,
    #' @description Create a new yarn document 
    #' 
    #' @param path \[`character`\] path to a markdown episode file on disk
    #' @param encoding \[`character`\] encoding passed to [readLines()]
    #' @param sourcepos passed to [commonmark::markdown_xml()]. If `TRUE`, the
    #'   source position of the file will be included as a "sourcepos" attribute.
    #'   Defaults to `FALSE`.
    #' @param ... arguments passed on to [to_xml()].
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
    initialize = function(path = NULL, encoding = "UTF-8", sourcepos = FALSE, ...) {
      if (is.null(path)) {
        return(self)
      } else {
        xml <- to_xml(path, encoding, sourcepos, ...)
      }
      self$path <- path
      self$yaml <- xml$yaml
      self$body <- xml$body
      self$ns   <- tinkr::md_ns()
      private$sourcepos <- sourcepos
      private$encoding  <- encoding
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
      x <- to_xml(self$path, encoding = private$encoding, sourcepos = private$sourcepos)
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
    write = function(path = NULL, stylesheet_path = stylesheet()){
      if (is.null(path)) {
        stop("Please provide a file path", call. = FALSE)
      }
      private$md_lines(path, stylesheet_path)
      invisible(self)
    },

    #' @description show the markdown contents on the screen
    #'
    #' @param stylesheet_path path to the xsl stylesheet to convert XML to markdown.
    #' @return a character vector with one line for each line in the output
    #' @examples
    #' path <- system.file("extdata", "example2.Rmd", package = "tinkr")
    #' ex2 <- tinkr::yarn$new(path)
    #' ex2$head(5)
    #' ex2$tail(5)
    #' ex2$show()
    show = function(stylesheet_path = stylesheet() ) {
      show_user(private$md_lines(stylesheet = stylesheet_path))
    },

    #' @description show the head of the markdown contents on the screen
    #'
    #' @param n the number of elements to show from the top. Negative numbers
    #' @param stylesheet_path path to the xsl stylesheet to convert XML to markdown.
    #' exclude lines from the bottom
    #' @return a character vector with `n` elements
    head = function(n = 6L, stylesheet_path = stylesheet()) {
      show_user(head(private$md_lines(stylesheet = stylesheet_path), n))
    },

    #' @description show the tail of the markdown contents on the screen
    #'
    #' @param n the number of elements to show from the bottom. Negative numbers
    #' @param stylesheet_path path to the xsl stylesheet to convert XML to markdown.
    #' exclude lines from the top
    #' 
    #' @return a character vector with `n` elements
    tail = function(n = 6L, stylesheet_path = stylesheet()) {
      show_user(tail(private$md_lines(stylesheet = stylesheet_path), n))
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
      self$body <- add_md(self$body, md, where)
      invisible(self)
    },
    #' @description Protect math blocks from being escaped
    #' 
    #' @examples
    #' path <- system.file("extdata", "math-example.md", package = "tinkr")
    #' ex <- tinkr::yarn$new(path)
    #' ex$tail() # math blocks are escaped :(
    #' ex$protect_math()$tail() # math blocks are no longer escaped :)
    protect_math = function() {
      self$body <- protect_math(self$body, self$ns)
      invisible(self)
    }
  ),
  private = list(
    sourcepos = FALSE,
    encoding  = "UTF-8",
    # converts the document to markdown and separates the output into lines
    md_lines = function(path = NULL, stylesheet = NULL) {
      if (is.null(stylesheet)) {
        md <- to_md(self, path)
      } else {
        md <- to_md(self, path, stylesheet)
      }
      if (!is.null(path) && !is.null(stylesheet)) {
        return(md)
      }
      # Make sure that the yaml is not sitting on top of the first markdown line
      if (length(md) == 2) {
        md[1] <- paste0(md[1], "\n")
      }
      f  <- textConnection(md)
      on.exit(close(f))
      readLines(f)
    }
  )
)
