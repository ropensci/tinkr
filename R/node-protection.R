#' Handle protected ranges for a node
#'
#' @param node an XML `<text>` node.
#' @param start `\[integer\]` a vector of starting indices of a set of ranges
#' @param end `\[integer\]` a vector of ending indices that are paired with
#'   `start`
#' @return 
#'   - `add_protected_ranges()`: the modified node
#'   - `remove_protected_ranges()`: the modified node
#'   - `is_protected()`: `TRUE` if the node has protection attributes
#'   - `get_protected_ranges()` a list containing integer vectors `start` and
#'     `end` if the node is protected, otherwise, it returns NULL
#' @rdname protected_ranges
add_protected_ranges <- function(node, start, end) {
  if (any(start < 1)) {
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
  xml2::xml_set_attr(node, "protect.pos", paste(start, collapse = " "))
  xml2::xml_set_attr(node, "protect.end", paste(end, collapse = " "))
  return(node)
}

#' @rdname protected_ranges
is_protected <- function(node) {
  xml2::xml_has_attr(node, "protect.pos") && 
    xml2::xml_has_attr(node, "protect.end")
}

#' @rdname protected_ranges
get_protected_ranges <- function(node) {
  if (is_protected(node)) {
    start <- strsplit(xml2::xml_attr(node, "protect.pos"), " ")[[1]]
    end <- strsplit(xml2::xml_attr(node, "protect.end"), " ")[[1]]
  } else {
    return(NULL)
  }
  return(list(start = start, end = end))
}

#' @rdname protected_ranges
remove_protected_ranges <- function(node) {
  xml2::xml_set_attr(node, "protect.pos", NULL)
  xml2::xml_set_attr(node, "protect.end", NULL)
  return(node)
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
