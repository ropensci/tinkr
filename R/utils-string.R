# Replacements for stringr functions
# to preserve the argument order + nice name

str_replace <- function(string, pattern, replacement) {
  sub(pattern, replacement, string)
}

str_replace_all <- function(string, pattern, replacement) {
  gsub(pattern, replacement, string)
}

str_remove <- function(string, pattern) {
  str_replace(string, pattern, "")
}

str_remove_all <- function(string, pattern) {
  str_replace_all(string, pattern, "")
}

str_detect <- function(string, pattern) {
  grepl(pattern, string)
}

str_split <- function(string, pattern) {
  strsplit(string, pattern)[[1]]
}
