#' Generate an XML representation of a list
#'
#' @param li a list
#' @return an XML representation of the list.
#'
#' @noRd
#' @examples
#' example <- list(
#'   "kittens", 
#'   list(
#'     "are", 
#'     list(
#'       "**super**", 
#'       "*cute*"
#'     ), 
#'     "have", 
#'      list(
#'        "teef", 
#'        "murder mittens"
#'      )
#'   ), 
#'   "brains", 
#'   list(
#'     "are", 
#'     list(
#'       "wrinkly"
#'     )
#'   )
#' )
#' xml_from_list(example)
#' example2 <- list(
#'   kittens = list(
#'     are = list(
#'       "super",
#'       "cute"
#'     ),
#'     have = list(
#'       "teef",
#'       "murder mittens"
#'     )
#'   ),
#'   brains = list(
#'     are = list(
#'       "wrinkly"
#'     )
#'   )
#' )
#' xml_from_list(example2)
xml_from_list <- function(li) {
  xli <- if (is.null(names(li))) format_list(li) else format_named_list(li)
  doc <- xml2::as_xml_document(xli)
  return(xml2::xml_child(doc))
}

xml_from_table <- function(tbl) {
  tbl <- format_table(tbl)
  doc <- xml2::as_xml_document(tbl)
  return(xml2::xml_child(doc))
}


format_named_list <- function(li) {
  res <- list()
  lnames <- names(li)
  has_names <- !is.null(lnames)
  for (i in seq_along(li)) {
    is_named <- has_names && lnames[[i]] != ""
    if (is_named) {
      res[[i]] <- format_item(lnames[[i]])
    } else {
      res[[i]] <- list(item = NULL)
    }
    item <- li[[i]]
    if (is.list(item) || is_named) {
      item <- format_named_list(item)$document
      res[[i]]$item <- c(res[[i]]$item, item)
    } else {
      res[[i]] <- format_item(item)
    }
  }
  attr(res, "type") <- "bullet"
  attr(res, "tight") <- "true"
  return(list(document = list(list = res)))
}

format_list <- function(li) {
  res <- list()
  i <- 1
  for (item in li) {
    # if we run into a list item, we need to recurse
    if (is.list(item)) {
      # if the list item is the first thing we've seen, we need to make sure
      # it has list item ready to insert.
      if (i == 1) {
        res[[i]] <- list(item = NULL)
        i <- i + 1
      }
      # Append the the nested list into the previous item
      idx <- i - 1
      to_append <- format_list(item)
      res[[idx]]$item <- c(res[[idx]]$item, to_append$document)
    } else {
      # if the item is not a list, then we can format it properly
      res[[i]] <- format_item(item)
      i <- i + 1
    }
  }
  attr(res, "type") <- "bullet"
  attr(res, "tight") <- "true"
  return(list(document = list(list = res)))
}

format_text_to_list <- function(txt) {
  xml <- xml2::read_xml(commonmark::markdown_xml(txt, extensions = TRUE))
  return(xml2::as_list(xml))
}

format_item <- function(txt) {
  txt <- format_text_to_list(txt)
  res <- list(item = txt$document)
  return(res)
}

format_table <- function(tbl) {
  tbl <- as.matrix(tbl)
  if (!is.null(rownames(tbl))) {
    tbl <- cbind(rownames(tbl), tbl)
  }
  header <- list(table_header = format_row(colnames(tbl)))
  rows <- apply(tbl, MARGIN = 1, format_row, simplify = FALSE)
  names(rows) <- rep("table_row", length(rows))
  return(list(document = list(table = c(header, rows))))
}

format_row <- function(txt) {
  unname(purrr::map(txt, format_cell))
}

format_cell <- function(txt) {
  txt <- format_text_to_list(txt)
  cell <- txt$document$paragraph
  if (!is.null(cell)) {
    attr(cell$text, "asis") <- "true"
  }
  res <- list(table_cell = cell)
  return(res)
}


insert_table <- function(body, tbl) {
  bdy <- copy_xml(body)
  tbl <- xml_from_table(tbl)
  xml2::xml_add_child(bdy, tbl)
  copy_xml(bdy)
}
