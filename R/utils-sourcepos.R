has_sourcepos <- function(node) {
  xml2::xml_has_attr(node, "sourcepos")
}
# Get the position of an element
get_pos <- function(x, e = 1) {
  as.integer(
    gsub(
      "^(\\d+?):(\\d+?)[-](\\d+?):(\\d+?)$",
      glue::glue("\\{e}"),
      xml2::xml_attr(x, "sourcepos")
    )
  )
}

# helpers for get_pos
get_linestart <- function(x) get_pos(x, e = 1)
get_colstart  <- function(x) get_pos(x, e = 2)
get_lineend   <- function(x) get_pos(x, e = 3)
get_colend    <- function(x) get_pos(x, e = 4)

get_sourcepos <- function(node) {
  list(
    linestart = get_linestart(node),
    colstart = get_colstart(node),
    lineend = get_lineend(node),
    colend = get_colend(node)
  )
}
make_sourcepos <- function(pos) {
  glue::glue("{pos$linestart}:{pos$colstart}-{pos$lineend}:{pos$colend}")
}

split_sourcepos <- function(node) {
  pos <- get_sourcepos(node)
  ranges <- get_full_ranges(node)
  offset <- pos$colstart - 1L
  pos$colstart <- ranges$start + offset
  pos$colend <- ranges$end
  make_sourcepos(pos)
}

join_sourcepos <- function(nodes) {
  pos <- get_sourcepos(nodes)
  pos$linestart <- min(pos$linestart)
  pos$colstart <- min(pos$colstart)
  pos$lineend <- max(pos$lineend)
  pos$colend <- max(pos$colend)
  make_sourcepos(pos)
}
