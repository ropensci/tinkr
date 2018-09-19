library("magrittr")
fs::dir_ls("inst/samples") %>%
  purrr::map(readLines) %>%
  unlist() %>%
  writeLines("inst/extdata/bigsample.md")
