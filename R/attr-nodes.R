# CURLY ------------------
find_curly <- function(body, ns) {
  i <- ".//md:text[not(@asis) and contains(text(), '{')]"
  curlies <- xml2::xml_find_all(body, i, ns = ns)
  # https://github.com/carpentries/pegboard/blob/a8db02ab037f2ffeab6e13cc3b662ea8c42822ad/R/get_images.R#L84
  attr_texts <- xml2::xml_text(curlies)
  no_closing <- !grepl("[}]", attr_texts)
  if (any(no_closing)) {
    curlies <- lapply(curlies, function(i) i)
    close_xpath <- "self::*/following-sibling::md:text[contains(text(), '}')]"
    for (i in which(no_closing)) {
      not_closed <- curlies[[i]]
      closing <- xml2::xml_find_first(
        not_closed,
        glue::glue("./{close_xpath}"),
        ns
      )
      all_nodes <- find_between_nodes(not_closed, closing, include = TRUE)
      curlies[[i]] <- all_nodes
      # xml2::xml_text(not_closed) <- paste(
      #   xml2::xml_text(all_nodes),
      #   collapse = "\n"
      # )
      # xml2::xml_remove(all_nodes[-1])
    }
  }
  curlies
}

digest_curly <- function(curly, id, ns) {
  xml2::xml_set_attr(curly, "curly-id", id)
  if (inherits(curly, "xml_node")) {
    label_curly_node(curly)
  } else {
    n <- length(curly)
    label_curly_node(curly[[1]], type = "start")
    label_curly_node(curly[[n]], type = "stop")
    if (n > 2) {
      set_asis(curly[-c(1, n)])
    }
  }
  label_alt(curly)
  return(curly)
}

label_alt <- function(curly) {
  char <- trimws(xml2::xml_text(curly))
  char <- paste(char[char != ""], collapse = " ")
  res <- if (inherits(curly, "xml_node")) curly else curly[[1]]
  alt_fragment <- regmatches(char, gregexpr("alt=['\"].*?['\"]", char))[[1]]
  if (length(alt_fragment) > 0) {
    alt_text <- sub("^alt=", "", alt_fragment)
    xml2::xml_set_attr(res, "alt", alt_text)
  }
}

label_curly_node <- function(node, type = c("full", "start", "stop")) {
  char <- xml2::xml_text(node)
  # Find the locations of inline chars that is complete
  pattern <- switch(match.arg(type),
    full = "\\{.*?\\}",
    start = "\\{[^}]*?",
    stop = "[^{]*?\\}",
  )
  locations <- gregexpr(
    pattern = pattern,
    char,
    perl = TRUE
  )
  start <- locations[[1]]
  end   <- if (match.arg(type) == "start") {
    nchar(char)
  } else {
    start + attr(locations[[1]], "match.len") - 1L
  }
  add_protected_ranges(node, start, end)
  if (is_asis(node)) {
    xml2::xml_set_attr(node, "curly", "true")
  } else {
    xml2::xml_set_attr(node, "curly",
      paste(
        paste(start, collapse = " "),
        paste(end, collapse = " "),
        sep = ":"
      )
    )
  }
  return(node)
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
  purrr::iwalk(curly, digest_curly, ns = ns)
  return(body)
}
