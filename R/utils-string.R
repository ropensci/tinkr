# Replacements for stringr functions
# to preserve the argument order + nice name

str_remove_all <- function(string, pattern) {
  gsub(pattern, "", string)
}

str_remove <- function(string, pattern) {
  sub(pattern, "", string)
}

str_replace <- function(string, pattern, replacement) {
  sub(pattern, string, replacement)
}

str_replace_all <- function(string, pattern, replacement) {
  gsub(pattern, string, replacement)
}

str_detect <- function(string, pattern) {
  grepl(pattern, string)
}

str_split <- function(string, pattern) {
  strsplit(string, pattern)[[1]]
}
