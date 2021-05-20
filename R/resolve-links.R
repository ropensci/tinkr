#' Resolve Reference-Style Links
#'
#' Commonmark treats reference-style links as regular links, which can be a
#' pain when converting large documents. This is an attempt at resolving these
#' links by reading in the source document, finding the relative links, and 
#' adding them back with the 'asis' attribute.
#'
#' @param body an XML body
#' @param path path to the source file
#' @param ns an the NS that resolves the md ns
#' @param encoding the encoding of the file. Defaults to UTF-8
resolve_links <- function(body, path, ns = md_ns(), encoding = "UTF-8") {
  # if (is.na(xml2::xml_attr(body, "sourcepos"))) {
  #   warning("no sourcepos attribute")
  #   return(invisible(body))
  # }
  links <- xml2::xml_find_all(body, ".//md:link", ns)
  if (length(links) == 0) {
    return(invisible(body))
  }
  targets <- xml2::xml_attr(links, "destination")
  txt <- readLines(path, encoding = encoding)
  targets <- gsub("([.|()\\^{}+$*?]|\\[|\\])", "\\\\\\1", targets)
  rel <- paste0(":\\s+?", targets)
  positions <- lapply(rel, find_rel_link, txt)
  
  # IDEA:
  # 1. collect links and their positions
  # 2. extract link labels
  # 3. transform the links into 'asis' link nodes
  # 4. add unique list of links and labels to the bottom of the document
  # 5. add link[@asis] rule in xslt. 
  list(
    links = links,
    pos = positions
  )

}

find_rel_link <- function(target, txt) {
  position <- grep(target, txt)
  if (length(position) == 0) {
    return(0)
  }

  names(position) <- txt[position]
  position
}

get_rel_link_name <- function(link) {
  sub("^[\\[](.+?)[\\]]:\\s.+?$", "\\1", link, perl = TRUE)
}
