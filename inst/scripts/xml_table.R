input <- c(
  "| a  | b  |  c  |  d |",
  "| :- | -- | :-: | -: |",
  "| l  | n  |  c  |  r |"
)
library("magrittr")
commonmark::markdown_xml(input, extensions = TRUE) %>%
  xml2::read_xml() -> XML


system.file("stylesheets", "xml2md.xsl", package = "tinkr") %>%
  xml2::read_xml() -> stylesheet

xslt::xml_xslt(XML, stylesheet = stylesheet)
