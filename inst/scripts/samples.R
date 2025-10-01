library("magrittr")
tinkr::to_xml("inst/extdata/bigsample.md") %>%
  tinkr::to_md("inst/extdata/bigsample_after_loop.md")

diffr::diffr(
  file1 = "inst/extdata/bigsample.md",
  file2 = "inst/extdata/bigsample_after_loop.md"
)
