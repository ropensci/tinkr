#' @exportS3Method roxygen2::roxy_tag_parse
roxy_tag_parse.roxy_tag_yarn <- function(x) {
  roxygen2::tag_words(x)
}

#' @exportS3Method roxygen2::roxy_tag_rd
roxy_tag_rd.roxy_tag_yarn <- function(x, base_path, env) {
  roxygen2::rd_section("yarn", x$val)
}

#' @export
format.rd_section_yarn <- function(x, ...) {
  "\\section{Note: yarn method}{
  This function is also a method in the \\link{yarn} object.
    }\n"
}
