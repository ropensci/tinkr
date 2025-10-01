rmarkdown::render("inst/scripts/rmd_doc.Rmd")
doc <- docxtractr::read_docx("inst/scripts/rmd_doc.docx")
class(doc)
rmarkdown::pandoc_convert(
  input = file.path(getwd(), "inst/scripts/rmd_doc.docx"),
  to = "gfm",
  output = "rmd_doc_pandoc.Rmd"
)

library("magrittr")
tinkr::to_xml("inst/scripts/rmd_doc_pandoc.Rmd") %>%
  tinkr::to_md("inst/scripts/rmd_doc_loop.Rmd")
