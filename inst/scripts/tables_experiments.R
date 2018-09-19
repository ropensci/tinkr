# From Markdown to XML
path <- system.file("extdata", "example2.Rmd", package = "tinkr")
yaml_xml_list <- to_xml(path)

library("magrittr")
body <- yaml_xml_list$body
body %>%
  xml2::xml_find_all(xpath = './/d1:table',
                     xml2::xml_ns(.))
to_md(yaml_xml_list, "test.md")
file.edit("test.md")


