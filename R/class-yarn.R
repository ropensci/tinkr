#' R6 class containing XML representation of Markdown
#'
#' @description
#' Wrapper around an XML representation of a Markdown document. It contains four
#' publicly accessible slots: path, frontmatter, body, and ns.
#' @details
#' This class is a fancy wrapper around the results of [tinkr::to_xml()] and
#' has methods that make it easier to add, analyze, remove, or write elements
#' of your markdown document.
#' @export
yarn <- R6::R6Class(
  "yarn",
  portable = TRUE,
  public = list(
    #' @field path \[`character`\] path to file on disk
    path = NULL,

    #' @field frontmatter \[`character`\] text block at head of file
    frontmatter = NULL,

    #' @field frontmatter_format \[`character`\] 'YAML', 'TOML' or 'JSON'
    frontmatter_format = NULL,

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
    initialize = function(
      path = NULL,
      encoding = "UTF-8",
      sourcepos = FALSE,
      ...
    ) {
      if (is.null(path)) {
        return(self)
      } else {
        xml <- to_xml(path, encoding, sourcepos, ...)
      }
      self$path <- path
      self$frontmatter <- xml$frontmatter
      self$frontmatter_format <- xml$frontmatter_format
      self$body <- xml$body
      self$ns <- tinkr::md_ns()
      private$sourcepos <- sourcepos
      private$encoding <- encoding
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
      x <- to_xml(
        self$path,
        encoding = private$encoding,
        sourcepos = private$sourcepos
      )
      self$body <- x$body
      self$frontmatter <- x$frontmatter
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
    write = function(path = NULL, stylesheet_path = stylesheet()) {
      if (is.null(path)) {
        stop("Please provide a file path", call. = FALSE)
      }
      private$md_lines(path, stylesheet_path)
      invisible(self)
    },

    #' @description show the markdown contents on the screen
    #'
    #' @param lines a subset of elements to show. Defaults to `TRUE`, which
    #'    shows all lines of the output. This can be either logical or numeric.
    #' @param stylesheet_path path to the xsl stylesheet to convert XML to markdown.
    #' @return a character vector with one line for each line in the output
    #' @examples
    #' path <- system.file("extdata", "example2.Rmd", package = "tinkr")
    #' ex2 <- tinkr::yarn$new(path)
    #' ex2$head(5)
    #' ex2$tail(5)
    #' ex2$show()
    show = function(lines = TRUE, stylesheet_path = stylesheet()) {
      if (is.character(lines) && length(lines) == 1 && file.exists(lines)) {
        # when using {tinkr} < 0.3.0
        stylesheet_path <- lines
        lines <- TRUE
        the_call <- match.call()
        the_call$stylesheet_path <- the_call$lines
        the_call$lines <- NULL
        new_call <- capture.output(print(the_call))
        rlang::warn(
          c(
            "!" = "In {tinkr} 0.3.0, the $show() method gains the `lines` argument as the first argument.",
            "i" = "To remove this warning, use the following code:",
            " " = new_call
          ),
          call. = FALSE
        )
      }
      show_user(private$md_lines(stylesheet = stylesheet_path)[lines])
    },

    #' @description show the head of the markdown contents on the screen
    #'
    #' @param n the number of elements to show from the top. Negative numbers
    #' @param stylesheet_path path to the xsl stylesheet to convert XML to markdown.
    #' @return a character vector with `n` elements
    head = function(n = 6L, stylesheet_path = stylesheet()) {
      show_user(head(private$md_lines(stylesheet = stylesheet_path), n))
    },

    #' @description show the tail of the markdown contents on the screen
    #'
    #' @param n the number of elements to show from the bottom. Negative numbers
    #' @param stylesheet_path path to the xsl stylesheet to convert XML to markdown.
    #'
    #' @return a character vector with `n` elements
    tail = function(n = 6L, stylesheet_path = stylesheet()) {
      show_user(tail(private$md_lines(stylesheet = stylesheet_path), n))
    },

    #' @description query and extract markdown elements
    #'
    #' @param xpath a valid XPath expression
    #' @param stylesheet_path path to the xsl stylesheet to convert XML to markdown.
    #'
    #' @return a vector of markdown elements generated from the query
    #' @seealso [to_md_vec()] for a way to generate the same vector from a
    #'   nodelist without a yarn object
    #' @examples
    #' path <- system.file("extdata", "example1.md", package = "tinkr")
    #' ex <- tinkr::yarn$new(path)
    #' # all headings
    #' ex$md_vec(".//md:heading")
    #' # all headings greater than level 3
    #' ex$md_vec(".//md:heading[@level>3]")
    #' # all links
    #' ex$md_vec(".//md:link")
    #' # all links that are part of lists
    #' ex$md_vec(".//md:list//md:link")
    #' # all code
    #' ex$md_vec(".//md:code | .//md:code_block")
    md_vec = function(xpath = NULL, stylesheet_path = stylesheet()) {
      if (is.null(xpath)) {
        return(NULL)
      }
      nodes <- xml2::xml_find_all(self$body, xpath, ns = self$ns)
      return(to_md_vec(nodes, stylesheet_path))
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
    #' @description append abritrary markdown to a node or set of nodes
    #'
    #' @param md a string of markdown formatted text.
    #' @param nodes an XPath expression that evaulates to object of class
    #'   `xml_node` or `xml_nodeset` that are all either inline or block nodes
    #'   (never both). The XPath expression is passed to [xml2::xml_find_all()].
    #'   If you want to append a specific node, you can pass that node to this
    #'   parameter.
    #' @param space if `TRUE`, inline nodes will have a space inserted before
    #'   they are appended.
    #' @details this is similar to the `add_md()` method except that it can do
    #'   the following:
    #'   1. append content after a _specific_ node or set of nodes
    #'   2. append content to multiple places in the document
    #' @examples
    #' path <- system.file("extdata", "example2.Rmd", package = "tinkr")
    #' ex <- tinkr::yarn$new(path)
    #' # append a note after the first heading
    #'
    #' txt <- c("> Hello from *tinkr*!", ">", ">  :heart: R")
    #' ex$append_md(txt, ".//md:heading[1]")$head(20)
    append_md = function(md, nodes = NULL, space = TRUE) {
      self$body <- insert_md(
        self$body,
        md,
        nodes,
        where = "after",
        space = space
      )
      invisible(self)
    },
    #' @description prepend arbitrary markdown to a node or set of nodes
    #'
    #' @param md a string of markdown formatted text.
    #' @param nodes an XPath expression that evaulates to object of class
    #'   `xml_node` or `xml_nodeset` that are all either inline or block nodes
    #'   (never both). The XPath expression is passed to [xml2::xml_find_all()].
    #'   If you want to append a specific node, you can pass that node to this
    #'   parameter.
    #' @param space if `TRUE`, inline nodes will have a space inserted before
    #'   they are prepended.
    #' @details this is similar to the `add_md()` method except that it can do
    #'   the following:
    #'   1. prepend content after a _specific_ node or set of nodes
    #'   2. prepend content to multiple places in the document
    #' @examples
    #' path <- system.file("extdata", "example2.Rmd", package = "tinkr")
    #' ex <- tinkr::yarn$new(path)
    #'
    #' # prepend a table description to the birds table
    #' ex$prepend_md("Table: BIRDS, NERDS", ".//md:table[1]")$tail(20)
    prepend_md = function(md, nodes = NULL, space = TRUE) {
      self$body <- insert_md(
        self$body,
        md,
        nodes,
        where = "before",
        space = space
      )
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
    },
    #' @description Protect curly phrases `{likethat}` from being escaped
    #'
    #' @examples
    #' path <- system.file("extdata", "basic-curly.md", package = "tinkr")
    #' ex <- tinkr::yarn$new(path)
    #' ex$protect_curly()$head()
    protect_curly = function() {
      self$body <- protect_curly(self$body, self$ns)
      invisible(self)
    },
    #' @description Protect fences of Pandoc fenced divs `:::`
    #'
    #' @examples
    #' path <- system.file("extdata", "fenced-divs.md", package = "tinkr")
    #' ex <- tinkr::yarn$new(path)
    #' ex$protect_fences()$head()
    protect_fences = function() {
      self$body <- protect_fences(self$body, self$ns)
      invisible(self)
    },
    #' @description Protect unescaped square braces from being escaped.
    #'
    #' This is applied by default when you use `yarn$new(sourcepos = TRUE)`.
    #'
    #' @note this requires the `sourcepos` attribute to be recorded when the
    #'   object is initialised. See [protect_unescaped()] for details.
    #'
    #' @examples
    #' path <- system.file("extdata", "basic-curly.md", package = "tinkr")
    #' ex <- tinkr::yarn$new(path, sourcepos = TRUE, unescaped = FALSE)
    #' ex$tail()
    #' ex$protect_unescaped()$tail()
    protect_unescaped = function() {
      if (private$sourcepos) {
        txt <- readLines(self$path)[-seq_along(self$frontmatter)]
        self$body <- protect_unescaped(self$body, txt, self$ns)
      } else {
        message(
          "to use the `protect_unescaped()` method, you will need to re-read your document with `yarn$new(sourcepos = TRUE)`"
        )
      }
      invisible(self)
    },
    #' @description Return nodes whose contents are protected from being escaped
    #' @param type a character vector listing the protections to be included.
    #'   Defaults to `NULL`, which includes all protected nodes:
    #'   - math: via the [protect_math()] function
    #'   - curly: via the `protect_curly()` function
    #'   - fence: via the `protect_fences()` function
    #'   - unescaped: via the `protect_unescaped()` function
    #'
    #' @examples
    #' path <- system.file("extdata", "basic-curly.md", package = "tinkr")
    #' ex <- tinkr::yarn$new(path, sourcepos = TRUE)
    #' # protect curly braces
    #' ex$protect_curly()
    #' # add fenced divs and protect then
    #' ex$add_md(c("::: alert\n",
    #'   "blabla",
    #'   ":::")
    #' )
    #' ex$protect_fences()
    #' # add math and protect it
    #' ex$add_md(c("## math\n",
    #'   "$c^2 = a^2 + b^2$\n",
    #'   "$$",
    #'   "\\sum_{i}^k = x_i + 1",
    #'   "$$\n")
    #' )
    #' ex$protect_math()
    #' # get protected now shows all the protected nodes
    #' ex$get_protected()
    #' ex$get_protected(c("math", "curly")) # only show the math and curly
    get_protected = function(type = NULL) {
      get_protected(self$body, type = type, self$ns)
    }
  ),
  active = list(
    #' @field yaml \[`character`\] `r lifecycle::badge("deprecated")` `frontmatter`
    yaml = function(yml) {
      lifecycle::deprecate_soft(
        "0.2.1",
        I("The yaml field of yarn objects"),
        I("frontmatter")
      )
      if (!missing(yml)) self$frontmatter <- yml
      self$frontmatter
    }
  ),
  private = list(
    sourcepos = FALSE,
    encoding = "UTF-8",
    # converts the document to markdown and separates the output into lines
    md_lines = function(path = NULL, stylesheet = NULL) {
      print_lines(self, path = path, stylesheet = stylesheet)
    }
  )
)
