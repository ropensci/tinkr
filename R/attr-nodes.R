# CURLY ------------------
find_curly <- function(body, ns) {
  i <- ".//md:text[not(@asis) and contains(text(), '{')]"
  curlies <- xml2::xml_find_all(body, i, ns = ns)
  # https://github.com/carpentries/pegboard/blob/a8db02ab037f2ffeab6e13cc3b662ea8c42822ad/R/get_images.R#L84
  attr_texts <- xml2::xml_text(curlies)
  no_closing <- !grepl("[}]", attr_texts)
  if (any(no_closing)) {
    close_xpath <- "self::*/following-sibling::md:text[contains(text(), '}')]"
    for (not_closed in curlies[no_closing]) {
      closing <- xml2::xml_find_all(
        not_closed,
        glue::glue("./{close_xpath}"),
        ns
      )
      xml2::xml_text(not_closed) <- paste(
        xml2::xml_text(not_closed),
        xml2::xml_text(closing),
        sep = "\n"
      )
      xml2::xml_remove(closing)
    }
  }
  curlies
}

digest_curly <- function(curly, ns) {
  label_curly_nodes(curly)
  char <- xml2::xml_text(curly)
  alt_fragment <- regmatches(char, gregexpr("alt=['\"].*?['\"]", char))[[1]]
  if (length(alt_fragment) > 0) {
    alt_text <- sub("^alt=", "", alt_fragment)
    xml2::xml_set_attr(curly, "alt", alt_text)
  }
}

label_curly_nodes <- function(node) {
  char <- xml2::xml_text(node)
  # Find the locations of inline chars that is complete
  locations <- gregexpr(
    pattern = "\\{.*?\\}",
    char,
    perl = TRUE
  )
  start <- locations[[1]]
  end   <- start + attr(locations[[1]], "match.len")
  return(add_protected_ranges(node, start, end))

}

#' Protect curly elements for further processing
#'
#' @inheritParams protect_math
#' @return a copy of the modified XML object
#' @details Commonmark will render text such as `{.unnumbered}`
#' (Pandoc/Quarto option) or
#' `{#hello .greeting .message style="color: red;"}`
#' (Markdown custom block)
#' as normal text which might be problematic if trying to extract
#' real text from the XML.
#'
#' If sending the XML to, say, a translation API that allows some tags
#' to be ignored, you could first transform the text tags with the
#' attribute `curly` to `curly` tags, and then transform them back
#' to text tags before using `to_md()`.
#'
#' @note this function is also a method in the [tinkr::yarn] object.
#'
#' @export
#' @examples
#' m <- tinkr::to_xml(system.file("extdata", "basic-curly.md", package = "tinkr"))
#' xml2::xml_child(m$body)
#' m$body <- protect_curly(m$body)
#' xml2::xml_child(m$body)
protect_curly <- function(body, ns = md_ns()) {
  curly <- find_curly(body, ns)
  purrr::walk(curly, digest_curly, ns = ns)
  return(body)
}
