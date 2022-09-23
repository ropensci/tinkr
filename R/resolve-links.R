#' Resolve Reference-Style Links
#'
#' @description
#'
#' [Reference style links and
#' images](https://www.markdownguide.org/basic-syntax/#reference-style-links)
#' are a form of markdown syntax that reduces duplication and makes markdown
#' more readable. They come in two parts:
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
#' and adding them back at the end of the document with the 'anchor' attribute
#' and appending the reference to the link with the 'ref' attribute. 
#'
#' @details
#' 
#' ## Nomenclature
#'
#' The reference-style link contains two parts, but they don't have common names
#' (the [markdown guide](https://www.markdownguide.org/basic-syntax/) calls 
#' these "first part and second part"), so in this documentation, we call the
#' link pattern of `[link text][link-ref]` as the "inline reference-style link"
#' and the pattern of `[link-ref]: <URL>` as the "anchor references-style link".
#'
#' ## Reference-style links in commonmark's XML representation
#'
#' A link or image in XML is represented by a node with the following attributes
#'  
#'  - destination: the URL for the link
#'  - title: an optional title for the link
#'
#' For example, this markdown link `[link text](https://example.com "example 
#' link")` is represented in XML as text inside of a link node:
#'
#' ```{r}
#' lnk <- "[link text](https://example.com 'example link')"
#' xml <- xml2::read_xml(commonmark::markdown_xml(lnk))
#' cat(as.character(xml2::xml_find_first(xml, ".//d1:link")))
#' ```
#' 
#' However, reference-style links are rendered equivalently: 
#' 
#' ```{r}
#' lnk <- "
#' [link text][link-ref]
#'
#' [link-ref]: https://example.com 'example link'
#' "
#' xml <- xml2::read_xml(commonmark::markdown_xml(lnk))
#' cat(as.character(xml2::xml_find_first(xml, ".//d1:link")))
#' ```
#'
#' ## XML attributes of reference-style links
#'
#' To preserve the anchor reference-style links, we search the source document
#' for the destination attribute proceded by `]: `, transform that information
#' into a new link node with the `anchor` attribute, and add it to the end of
#' the document. That node looks like this:
#'
#' ```{r, echo = FALSE, comment = NA}
#' lnk <- "[link-ref]: https://example.com 'example link'"
#' al <- withr::with_namespace("tinkr", build_anchor_links(lnk))
#' cat(as.character(xml2::xml_find_first(al, ".//link")))
#' ```
#' 
#' From there, we add the anchor text to the node that is present in our 
#' document as the `ref` attribute:
#'
#' ```{r, echo = FALSE, comment = NA}
#' lnk <- "
#' [link text][link-ref]
#'
#' [link-ref]: https://example.com 'example link'
#' "
#' xml <- xml2::read_xml(commonmark::markdown_xml(lnk))
#' lnk <- xml2::xml_find_first(xml, ".//d1:link")
#' xml2::xml_set_attr(lnk, "rel", "link-ref")
#' cat(as.character(lnk))
#' ```
#'
#' @note this function is internally used in the function [to_xml()].
#' @param body an XML body
#' @param txt the text of a source file
#' @param ns an the namespace that resolves the Markdown namespace (defaults to
#'   [md_ns()])
#' @keywords internal
#' @examples
#' f <- system.file("extdata", "link-test.md", package = "tinkr")
#' md <- yarn$new(f, sourcepos = TRUE, anchor_links = FALSE)
#' md$show()
#' if (requireNamespace("withr")) {
#' lnks <- withr::with_namespace("tinkr", 
#'   resolve_anchor_links(md$body, readLines(md$path)))
#' md$body <- lnks
#' md$show()
#' }
resolve_anchor_links <- function(body, txt, ns = md_ns()) {
  # copy the body so that we can recover from errors
  body <- copy_xml(body)
  # find all links and images (since either one could have an anchor link)
  links <- xml2::xml_find_all(body, ".//md:link | .//md:image", ns)
  if (length(links) == 0) {
    return(invisible(body))
  }
  # Search for the pattern that resolves to `]: <LINK>( <TITLE>)` and return the 
  # line number the link was found on 
  dests  <- xml2::xml_attr(links, "destination")
  titles <- xml2::xml_attr(links, "title")
  targets <- paste0(clean_targets(dests), "\\s?['\"]?", clean_targets(titles))
  rel <- paste0("\\]:\\s+?", targets, "['\"]?\\s*$")
  pos <- purrr::map_int(rel, find_anchor_link, txt)
  if (sum(pos) == 0) {
    return(invisible(body))  
  }
  # extract all of matches from the document
  anchors <- txt[pos]
  # set the attributes of the links that have anchors
  xml2::xml_set_attr(links[pos != 0], "rel", al_name(anchors))
  # add the anchors at the end of the document
  add_anchor_links(body, unique(anchors))
}

# Lifted from Hmisc::escapeRegex in Hmisc 4.5.0
clean_targets <- function(targets) {
  gsub("([.|()\\^{}+$*?]|\\[|\\])", "\\\\\\1", targets)
}

find_anchor_link <- function(target, txt) {
  position <- grep(target, txt)
  if (length(position) == 0) {
    return(0L)
  }
  max(position) # examples in markdown will create duplicates
}

add_anchor_links <- function(body, links) {
  new <- build_anchor_links(links)
  add_nodes_to_body(body, new, where = length(xml2::xml_children(body)))
  copy_xml(body)
}

# Make an anchor link node from a text string
# build_anchor_links("[CAT!]: https://placekitten.com/200/200 'cute kitty'")
build_anchor_links <- function(link) {
  txt <- glue::glue("<text>{al_name(link)}</text>")
  attrs <- glue::glue(
    "destination='{al_dest(link)}' title='{al_title(link)}' anchor='true'"
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

escape_ampersand <- function(amp) {
  # escape ampersands that are not valid code points, though this will still
  # allow invalid code points, but it's better than nothing
  gsub("[&](?![#]?[A-Za-z0-9]+?[;])", "&amp;", amp, perl = TRUE)
}

al_name <- function(link) {
  res <- sub("^[[\\[](.+?)[\\]]:\\s.+?$", "\\1", link, perl = TRUE)
  escape_ampersand(res)
}

al_dest <- function(link) {
  res <- sub("^[\\[].+?[\\]]:\\s([^\\s]+?)(\\s['\"]?.*?)?$", "\\1", link, perl = TRUE)
  escape_ampersand(res)
}

al_title <- function(link) {
  # try to find titles, but if they don't exist, they will match exactly with
  # the original string, so we need to censor them.
  titles <- sub("^[\\[].+?[\\]]:\\s[^\\s]+?(\\s['\"](.*?)['\"])$", "\\2", 
    link, perl = TRUE)
  titles[titles == link] <- ""
  escape_ampersand(titles)
}

#nocov start
# Get the position of an element
get_pos <- function(x, e = 1) {
  as.integer(
    gsub(
      "^(\\d+?):(\\d+?)[-](\\d+?):(\\d+?)$",
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
