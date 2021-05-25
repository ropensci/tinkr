#' Resolve Reference-Style Links
#'
#' @description
#'
#' [Reference style 
#' links](https://www.markdownguide.org/basic-syntax/#reference-style-links) are
#' a form of markdown syntax that reduces dupcliation and makes markdown more
#' readable. They come in two parts:
#'
#' 1. The inline part that uses two pairs of square brackets where the second
#'    pair of square brackets contains the reference for the anchor part of the
#'    link. Example:
#'    ```
#'    [inline text describing link][link-reference]
#'    ```
#' 2. The anchor part, which can be anywhere in the document, contains a pair
#'    of square brackets followed by a colon and space with the link and 
#'    optionally the link title. Example: 
#'    ```
#'    [link-reference]: https://docs.ropensci.org/tinkr/ 'documentation for tinkr'
#'    ```
#'
#' Commonmark treats reference-style links as regular links, which can be a
#' pain when converting large documents. This function resolves these
#' links by reading in the source document, finding the reference-style links,
#' and adding them back at the end of the document with the 'anchor' attribute.
#'
#' @param body an XML body
#' @param path path to the source file
#' @param ns an the namespace that resolves the Markdown namespace
#' @param encoding the encoding of the file. Defaults to UTF-8
#' @keywords internal
#' @examples
#' f <- system.file("extdata", "link-test.md", package = "tinkr")
#' md <- yarn$new(f, sourcepos = TRUE, anchor_links = FALSE)
#' md$show()
#' lnks <- tinkr:::resolve_anchor_links(md$body, readLines(md$path))
#' md$body <- lnks
#' md$show()
resolve_anchor_links <- function(body, txt, ns = md_ns()) {
  # copy the body so that we can recover from errors
  body <- copy_xml(body)
  # find all links and images (since either one could have an anchor link)
  links <- xml2::xml_find_all(body, ".//md:link | .//md:image", ns)
  if (length(links) == 0) {
    return(invisible(body))
  }
  # Search for the pattern that resolves to `]: <LINK>` and return the 
  # line number the link was found on 
  targets <- xml2::xml_attr(links, "destination")
  targets <- gsub("([.|()\\^{}+$*?]|\\[|\\])", "\\\\\\1", targets)
  rel <- paste0("\\]:\\s+?", targets)
  pos <- purrr::map_int(rel, find_anchor_link, txt)
  if (sum(pos) == 0) {
    return(invisible(body))  
  }
  # extract all of matches from the document
  anchors <- txt[pos]
  # set the attributes of the links that have anchors
  xml2::xml_set_attr(links[pos != 0], "rel", rl_name(anchors))
  # add the anchors at the end of the document
  add_anchor_links(body, unique(anchors))
}

find_anchor_link <- function(target, txt) {
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
# build_anchor_links("[CAT!]: https://placekitten.com/200/200 'cute kitty'")
build_anchor_links <- function(link) {
  txt <- glue::glue("<text>{rl_name(link)}</text>")
  attrs <- glue::glue(
    "destination='{rl_dest(link)}' title='{rl_title(link)}' anchor='true'"
  ) 
  # wrap the nodes in a paragraph to make sure they don't get screwed up by
  # any footer text
  make_text_nodes(c(
    "<paragraph>",
      glue::glue("<link {attrs}>{txt}</link>"),
    "</paragraph>"
  ))
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
  # try to find titles, but if they don't exist, they will match exactly with
  # the original string, so we need to censor them.
  titles <- sub("^[\\[].+?[\\]]:\\s[^\\s]+?(\\s['\"](.*?)['\"])$", "\\2", 
    link, perl = TRUE)
  titles[titles == link] <- ""
  titles
}

#nocov start
# Get the position of an element
get_pos <- function(x, e = 1) {
  as.integer(
    gsub(
      "^(\\d+?):(\\d+?)[-](\\d+?):(\\d)+?$",
      glue::glue("\\{e}"),
      xml2::xml_attr(x, "sourcepos")
    )
  )
}

# helpers for get_pos
get_linestart <- function(x) get_pos(x, e = 1)
get_colstart  <- function(x) get_pos(x, e = 2)
get_lineend   <- function(x) get_pos(x, e = 3)
get_colend    <- function(x) get_pos(x, e = 4)
#nocov end
