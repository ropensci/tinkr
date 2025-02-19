#' @title Transform file to XML
#'
#' @param path Path to the file.
#' @param encoding Encoding to be used by readLines.
#' @param sourcepos passed to [commonmark::markdown_xml()]. If `TRUE`, the
#'   source position of the file will be included as a "sourcepos" attribute.
#'   Defaults to `FALSE`.
#' @param anchor_links if `TRUE` (default), reference-style links with anchors
#'   (in the style of `[key]: https://example.com/link "title"`) will be
#'   preserved as best as possible. If this is `FALSE`, the anchors disappear
#'   and the links will appear as normal links. See [resolve_anchor_links()] for
#'   details.
#' @param unescaped if `TRUE` (default) AND `sourcepos = TRUE`, square braces
#'   that were unescaped in the original document will be preserved as best as
#'   possible. If this is `FALSE`, these braces will be escaped in the output
#'   document. See [protect_unescaped()] for details.
#'
#' @return A list containing the front-matter (YAML, TOML or JSON)
#'   of the file (frontmatter)
#'   and its body (body) as XML.
#'
#' @details This function will take a (R)markdown file, split the frontmatter
#'   from the body, and read in the body through [commonmark::markdown_xml()].
#'   Any RMarkdown code fences will be parsed to expose the chunk options in
#'   XML and tickboxes (aka checkboxes) in GitHub-flavored markdown will be
#'   preserved (both modifications from the commonmark standard).
#'
#' @note
#'   Math elements are not protected by default. You can use [protect_math()] to
#'   address this if needed.
#'
#' @export
#'
#' @examples
#' path <- system.file("extdata", "example1.md", package = "tinkr")
#' post_list <- to_xml(path)
#' names(post_list)
#' path2 <- system.file("extdata", "example2.Rmd", package = "tinkr")
#' post_list2 <- to_xml(path2)
#' post_list2
to_xml <- function(path, encoding = "UTF-8", sourcepos = FALSE, anchor_links = TRUE, unescaped = TRUE){
  content <- readLines(path, encoding = encoding, warn = FALSE)

  splitted_content <- split_frontmatter_body(content)

  frontmatter <- splitted_content$frontmatter

  splitted_content$body %>%
    clean_content() %>%
    commonmark::markdown_xml(extensions = TRUE, sourcepos = sourcepos) %>%
    xml2::read_xml(encoding = encoding) -> body

  parse_rmd(body)
  if (utils::packageVersion("commonmark") < "1.8.0") {
    body <- protect_tickbox(body, md_ns()) # nocov
  }
  if (unescaped && sourcepos) {
    body <- protect_unescaped(body, splitted_content$body)
  }
  if (anchor_links) {
    body <- resolve_anchor_links(body, splitted_content$body)
  }

  list(
    frontmatter = frontmatter,
    body = body,
    frontmatter_format = splitted_content$frontmatter_format
  )
}


clean_content <- function(content){
  illegal_control_chars <- "[^\u0009\u000a\u000d\u0020-\uD7FF\uE000-\uFFFD]"
  smart_double_quotes <- "[\u201C\u201D]"
  smart_single_quotes <- "[\u2018\u2019]"
  content %>%
    str_replace_all(smart_double_quotes, '"') %>%
    str_replace_all(smart_single_quotes, "'") %>%
    str_replace_all(illegal_control_chars, "")
}


transform_block <- function(code_block){
  info <- xml2::xml_attr(code_block, "info")

  if (is.na(info) || !str_detect(info, "^\\{.+?\\}$")) {
    # no transformation needed for non-evaluated blocks
    xml2::xml_set_attr(code_block, "name", "")
    return(code_block)
  }
  info <- str_remove(info, "\\{")
  info <- str_remove(info, "\\}")
  info <- transform_params(info)
  # This prevents partial code blocks that are still apparently valid: ```{r, }
  info <- info[names(info) != ""]

  xml2::xml_set_attr(code_block, "info", NULL)
  # preserve the original non-info attributes (e.g. sourcepos)
  attrs <- xml2::xml_attrs(code_block)
  # the space parameter seems to be persistant, so it's not needed
  attrs <- attrs[names(attrs) != "space"]
  # set the attributes for both info and attrs
  xml2::xml_set_attrs(code_block, c(info, attrs))
  code_block
}

parse_rmd <- function(body){
  code_blocks <- body %>%
    xml2::xml_find_all(xpath = './/d1:code_block',
                       xml2::xml_ns(.))

  purrr::walk(code_blocks, transform_block)
}
