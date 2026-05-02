#' The tinkr stylesheet
#'
#' This function returns the path to the tinkr stylesheet
#'
#' @return a single element character vector representing the path to the
#'   stylesheet used by tinkr.
#' @export
#' @examples
#' tinkr::stylesheet()
stylesheet <- function() {
  system.file("stylesheets", "xml2md_gfm.xsl", package = "tinkr")
}

is_stylesheet <- function(stylesheet) {
  inherits(stylesheet, "xml_document") &&
    length(xml2::xml_name(stylesheet)) == 1L &&
    xml2::xml_name(stylesheet) == "stylesheet"
}

read_stylesheet <- function(stylesheet_path) {
  # if the stylesheet already is an XML stylesheet, just return.
  if (is_stylesheet(stylesheet_path)) {
    return(stylesheet_path)
  }

  null_or_na <- is.null(stylesheet_path) ||
    length(stylesheet_path) != 1L ||
    any(is.na(stylesheet_path))

  if (null_or_na) {
    stop("'stylesheet_path' must be a path to an XSL stylesheet", call. = FALSE)
  }
  if (!file.exists(stylesheet_path)) {
    cli::cli_abort(
      "Can't find {.path {stylesheet_path}}.",
      call = NULL
    )
  }
  out <- xml2::read_xml(stylesheet_path)
  if (is_stylesheet(out)) {
    return(out)
  } else {
    cli::cli_abort("{.path {stylesheet_path}} is not a valid stylesheet")
  }
}
