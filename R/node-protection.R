label_fully_inline <- function(math) {
  char <- xml2::xml_text(math)
  locations <- gregexpr(pattern = inline_dollars_regex("full"), 
    char, 
    perl = TRUE
  )
  add_protection(math, locations)
}

add_protection <- function(node, locations) {
  start <- locations[[1]]
  end <- start + attr(locations[[1]], "match.len")
  if (xml2::xml_has_attr(node, "protect.pos")) {
    # extract the ranges from the attributes
    ostart <- strsplit(xml2::xml_attr(node, "protect.pos"), " ")[[1]]
    oend <- strsplit(xml2::xml_attr(node, "protect.end"), " ")[[1]]
    # update the ranges and the variables
    new_ranges <- update_ranges(
      start = c(as.integer(ostart), start),
      end = c(as.integer(oend), end),
    )
    start <- new_ranges$start
    end <- new_ranges$end
  }
  xml2::xml_set_attr(node, "protect.pos", paste(start, collapse = " "))
  xml2::xml_set_attr(node, "protect.end", paste(end, collapse = " "))
}

inrange <- function(s1, e1, s2, e2) {
  s1 <= s2 & e1 >= e2
}

overlap <- function(s1, e1, s2, e2) {
  s1 <= e2 & s2 <= e1
}


# https://www.geeksforgeeks.org/merging-intervals/
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
