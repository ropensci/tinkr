table_path <- system.file("extdata", "xml_table.xml",
                          package = "tinkr")

library("magrittr")
body <- xml2::read_xml(table_path)

xml2::read_xml("inst/extdata/xml2md.xsl") -> stylesheet

temp <- fs::file_temp(ext = ".xml")
on.exit(file.remove(temp))
body  %>%
  xml2::write_xml(file = temp)


(xml2::read_xml(temp) %>%
  xslt::xml_xslt(stylesheet = stylesheet))

