#' Get protected nodes
#'
#' @param body an `xml_document` object
#' @param type a character vector listing the protections to be included.
#'   Defaults to `NULL`, which includes all protected nodes:
#'   - math: via the `protect_math()` function
#'   - curly: via the `protect_curly()` function
#'   - unescaped: via the `protect_unescaped()` function
#' @param ns the namespace of the document (defaults to [md_ns()])
#' @return an `xml_nodelist` object.
#' @export
#' @examples
#' path <- system.file("extdata", "basic-curly.md", package = "tinkr")
#' ex <- tinkr::yarn$new(path, sourcepos = TRUE)
#' # protect curly braces
#' ex$protect_curly()
#' # add math and protect it
#' ex$add_md(c("## math\n", 
#'   "$c^2 = a^2 + b^2$\n", 
#'   "$$",
#'   "\\sum_{i}^k = x_i + 1",
#'   "$$\n")
#' )
#' ex$protect_math()
#' # get protected now shows all the protected nodes
#' get_protected(ex$body)
#' get_protected(ex$body, c("math", "curly")) # only show the math and curly
get_protected <- function(body, type = NULL, ns = md_ns()) {
  protections <- c(
    math = "@math",
    curly = "@curly",
    unescaped = "(@asis and text()='[' or text()=']')"
  )
  if (!is.null(type)) {
    keep <- match.arg(type, names(protections), several.ok = TRUE)
    missing <- setdiff(type, keep)
    if (length(missing) > 0) {
      be <- if (length(missing) > 1) "are" else "is"
      missing <- glue::glue_collapse(missing, sep = ", ", last = ", and ")
      message(glue::glue("the type options {missing} {be} not one of math, curly, or unescaped"))
    }
  } else {
    keep <- TRUE
  }
  xpath <- sprintf(".//node()[%s]", paste(protections[keep], collapse = " or "))
  xml2::xml_find_all(body, xpath, ns = ns)
}
