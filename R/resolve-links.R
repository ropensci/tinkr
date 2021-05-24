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
#' @keywords internal
#' @examples
#' f <- system.file("extdata", "link-test.md", package = "tinkr")
#' md <- yarn$new(f, sourcepos = TRUE)
#' md$show()
#' lnks <- tinkr:::resolve_links(md$body, md$path)
#' md$body <- lnks
#' md$show()
resolve_links <- function(body, path, ns = md_ns(), encoding = "UTF-8") {
  # if (is.na(xml2::xml_attr(body, "sourcepos"))) {
  #   warning("no sourcepos attribute")
  #   return(invisible(body))
  # }
  body <- copy_xml(body)
  links <- xml2::xml_find_all(body, ".//md:link | .//md:image", ns)
  if (length(links) == 0) {
    return(invisible(body))
  }
  targets <- xml2::xml_attr(links, "destination")
  txt <- readLines(path, encoding = encoding)
  targets <- gsub("([.|()\\^{}+$*?]|\\[|\\])", "\\\\\\1", targets)
  rel <- paste0(":\\s+?", targets)
  pos <- purrr::map_int(rel, find_rel_link, txt)
  anchors <- txt[pos]
  xml2::xml_set_attr(links[pos != 0], "rel", rl_name(anchors))
  add_anchor_links(body, unique(anchors))
}

find_rel_link <- function(target, txt) {
  position <- grep(target, txt)
  if (length(position) == 0) {
    return(0L)
  }
  position
}

add_anchor_links <- function(body, links) {
  new <- build_anchor_links(links)
  add_nodes_to_body(body, new, where = length(xml2::xml_children(body)))
  copy_xml(body)
}

# Make an anchor link node from a text string
# build_anchor_links("![CAT!]: https://placekitten.com/200/200 'cute kitty'")
build_anchor_links <- function(link) {
  txt <- glue::glue("<text>{rl_name(link)}</text>")
  attrs <- glue::glue(
    "destination='{rl_dest(link)}' title='{rl_title(link)}' anchor='true'"
  ) 
  make_text_nodes(glue::glue("<link {attrs}>{txt}</link>"))
}

# Helpers for parsing anchor links:
#
#   [name]: dest 'title'
rl_name <- function(link) {
  sub("^[[\\[](.+?)[\\]]:\\s.+?$", "\\1", link, perl = TRUE)
}

rl_dest <- function(link) {
  sub("^[\\[].+?[\\]]:\\s([^\\s]+?)(\\s['\"]?.*?)?$", "\\1", link, perl = TRUE)
}

rl_title <- function(link) {
  titles <- sub("^[\\[].+?[\\]]:\\s[^\\s]+?(\\s['\"](.*?)['\"])$", "\\2", link, perl = TRUE)
  titles[titles == link] <- ""
  titles
}

