#' Handle protected ranges for a node
#'
#' @param node an XML `<text>` node.
#' @param start `\[integer\]` a vector of starting indices of a set of ranges
#' @param end `\[integer\]` a vector of ending indices that are paired with
#'   `start`
#' @param body an XML document
#' @return 
#'   - `add_protected_ranges()`: the modified node
#'   - `remove_protected_ranges()`: the modified node
#'   - `is_protected()`: `TRUE` if the node has protection attributes
#'   - `get_protected_ranges()` a list containing integer vectors `start` and
#'     `end` if the node is protected, otherwise, it returns NULL
#'   - `get_protected_nodes()` a nodelist
#' @rdname protected_ranges
#' @export
#' @examples
#' # example of text to protect
#' # SETUP ---------------------
#' expected <- c(
#'   "\\a\\b\\c\\d",
#'   "\\e\\f\\g\\h",
#'   ""
#' )
#' temp_file <- tempfile()
#' writeLines(expected, temp_file)
#' wool <- tinkr::yarn$new(temp_file)
#' nodes <- xml2::xml_find_all(wool$body, ".//md:text", ns = md_ns())
#' writeLines(expected) # this is how it should appear
#' wool$show() # nothing is protected, so the '\' are escaped
#' # ADDING PROTECTION ----------
#' # protections are added _per node_
#' add_protected_ranges(nodes[[1]], start = 1, end = 8) # protect whole range
#' add_protected_ranges(nodes[[2]], start = c(1, 7), end = c(2, 8)) # partial
#' wool$show() # the first row and "\e" and "\h" are protected
#' 
#' # extract the ranges
#' is_protected(nodes[[1]])
#' is_protected(nodes[[2]])
#' get_protected_ranges(nodes[[1]])
#' get_protected_ranges(nodes[[2]])
#' 
#' # Add additional protection that overlaps.
#' # The current range is [1, 2] and [7, 8]. If we add [5, 8], the range
#' # will be updated
#' add_protected_ranges(nodes[[2]], start = 5, end = 8) 
#' get_protected_ranges(nodes[[2]])
#' 
#' # overlapping protection is not duplicated
#' add_protected_ranges(nodes[[1]], start = 1, end = 4) 
#' get_protected_ranges(nodes[[1]])
#'
#' wool$show() # the first row and "\e", "\g", and "\h" are protected
#' get_protected_nodes(wool$body) # showing the nodes that are protected
#' 
#' # REMOVING PROTECTION --------
#' remove_protected_ranges(nodes[[2]])
#' is_protected(nodes[[2]])
#' get_protected_ranges(nodes[[2]])
#' wool$show()
#' 
#' # CLEAN UP -------------------
#' if (file.exists(temp_file)) unlink(temp_file)
add_protected_ranges <- function(node, start, end) {
  no_beginning <- length(start) == 0 || any(start < 1)
  if (no_beginning || not_text_node(node)) {
    # return early if there are no ranges to protect
    return(node)
  }
  if (is_protected(node)) {
    # extract the ranges from the attributes
    orig <- get_protected_ranges(node)
    # update the ranges and the variables
    new <- update_ranges(start = c(start, orig$start), end = c(end, orig$end))
    start <- new$start
    end <- new$end
  }
  xml2::xml_set_attr(node, "protect.start", paste(start, collapse = " "))
  xml2::xml_set_attr(node, "protect.end", paste(end, collapse = " "))
  return(node)
}

is_text_node <- function(node) {
  inherits(node, "xml_node") && xml2::xml_name(node) == "text"
}

not_text_node <- Negate(is_text_node)

#' @rdname protected_ranges
#' @export
is_protected <- function(node) {
  xml2::xml_has_attr(node, "protect.start") && 
    xml2::xml_has_attr(node, "protect.end")
}

#' @rdname protected_ranges
#' @export
xpath_protected <- ".//node()[@protect.start and @protect.end]"

#' @rdname protected_ranges
#' @export
get_protected_ranges <- function(node) {
  if (is_text_node(node) && is_protected(node)) {
    start <- strsplit(xml2::xml_attr(node, "protect.start"), " ")[[1]]
    end <- strsplit(xml2::xml_attr(node, "protect.end"), " ")[[1]]
  } else {
    return(NULL)
  }
  return(list(start = as.integer(start), end = as.integer(end)))
}

#' @rdname protected_ranges
#' @export
remove_protected_ranges <- function(node) {
  xml2::xml_set_attr(node, "protect.start", NULL)
  xml2::xml_set_attr(node, "protect.end", NULL)
  return(node)
}

#' @rdname protected_ranges
#' @export
get_protected_nodes <- function(body) {
  xml2::xml_find_all(body, xpath_protected)
}

get_full_ranges <- function(node) {
  if (!is_protected(node)) {
    return(node)
  }
  ranges <- get_protected_ranges(node)
  txt <- xml2::xml_text(node)
  inv <- inverse_ranges(nchar(txt), ranges$start, ranges$end)
  full <- update_ranges(c(inv$start, ranges$start), c(inv$end, ranges$end))
  full$protected <- full$start %in% ranges$start
  return(full)
}


#' Detect if two ranges are overlapping
#' 
#' @param s1 \[integer\] starting index of first range
#' @param e1 \[integer\] ending index of first range
#' @param s2 \[integer\] starting index of second range
#' @param e2 \[integer\] ending index of second range
#' @return `TRUE` if the ranges overlap and `FALSE` if they do not
#'
#' @noRd
#' @examples
#' overlap(1, 10, 5, 15) # TRUE
#' overlap(1, 4, 5, 15) # FALSE
overlap <- function(s1, e1, s2, e2) {
  s1 <= e2 & s2 <= e1
}

#' Update a set of ranges
#' 
#' @param start `\[integer\]` a vector of starting indices of a set of ranges
#' @param end `\[integer\]` a vector of ending indices that are paired with
#'   `start`
#' @return a list of two integer vectors each with a length of at least one and
#'   at most the same length as the input. 
#'   - `start`
#'   - `end`
#'
#' @details
#' This function merges a set of ranges based on the algorithm presented in
#' <https://www.geeksforgeeks.org/merging-intervals/>. If none of the intervals
#' overlap, then the original `start` and `end` variables are returned sorted by
#' the starting order.
#'
#' If there are overlaps, they will be condensed, removing up to n - 1 intervals
#'
#' @noRd
#' @examples
#' # in this example, the ranges of [10, 20] overlaps with [5, 15]
#' ranges <- data.frame(start = c(1, 10, 100), end = c(2, 20, 200))
#' new <- data.frame(start = c(5, 50, 500), end = c(15, 150, 1500))
#' # thus they become [5, 20]
#' update_ranges(c(ranges$start, new$start), c(ranges$end, new$end))
update_ranges <- function(start, end) {
  # Sort the intervals based on the increasing order of starting time.
  ord <- order(start)
  start <- start[ord]
  end <- end[ord]
  n <- length(start)
  nstart <- integer(n)
  nend <- integer(n)
  # Push the first interval into a stack.
  nstart[1] <- start[1]
  nend[1] <- end[1]
  i <- 2
  j <- 1
  while (i <= n) {
    # For each interval do the following:
    if (overlap(nstart[j], nend[j], start[i], end[i])) {
      # If the current interval overlap with the top of the stack then,
      # update the stack top with the ending time of the current interval.
      nend[j] <- max(nend[j], end[i])
    } else {
      # If the current interval does not overlap with the top of the stack
      # then, push the current interval into the stack.
      j <- j + 1
      nstart[j] <- start[i]
      nend[j] <- end[i]
    }
      i <- i + 1
    # The end stack contains the merged intervals. 
  }
  keep <- seq(j)
  return(list(start = nstart[keep], end = nend[keep]))

}

inverse_ranges <- function(upper, start, end) {
  original <- seq.int(upper)
  n <- length(start) + 1
  res <- list(start = integer(n), end = integer(n))
  i <- 1
  j <- 1
  # create a mask to kee track of where we have been
  mask <- original > 0
  while (i < n) {
    mask <- mask & (original > end[i] | original < start[i])
    keep <- mask & original < end[i]
    if (!any(keep)) {
      i <- i + 1
      next
    }
    rng <- range(original[keep])
    res$start[j] <- rng[1]
    res$end[j] <- rng[2]
    # update the mask to make sure we do not add this again
    mask[rng[1]:rng[2]] <- FALSE
    j <- j + 1
    i <- i + 1
  }
  if (end[n - 1] < upper) {
    res$start[j] <- end[n - 1] + 1
    res$end[j] <- upper
  }
  # remove any empty cells
  res$start <- res$start[res$start != 0]
  res$end <- res$end[res$end != 0]
  return(res)
}
