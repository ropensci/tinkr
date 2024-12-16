show_user <- function(out, force = FALSE) {
  if (force || !identical(Sys.getenv("TESTTHAT"), "true")) cat(out, sep = "\n")
  invisible(out)
}

unbalanced_math_error <- function(bmath, endless, headless, le, lh) {
  no_end <- xml2::xml_text(bmath[endless])
  no_beginning <- xml2::xml_text(bmath[headless])
  msg <- glue::glue("
    Inline math delimiters are not balanced.

    HINT: If you are writing BASIC code, make sure you wrap variable
          names and code in backtics like so: `INKEY$`.

    Below are the pairs that were found:"
  )
  l <- seq(max(le, lh))
  no_end <- ifelse(is.na(no_end[l]), "", no_end[l])
  no_beginning <- ifelse(is.na(no_beginning[l]), "", no_beginning[l])
  no_end <- format(c("start", "-----", no_end), justify = "right")
  pairs <- glue::glue("{no_end}...{c('end', '---', no_beginning)}")
  msg <- glue::glue_collapse(c(msg, pairs), sep = "\n")
  stop(msg, call. = FALSE)
}
# from blogdown
# https://github.com/rstudio/blogdown/blob/9c7f7db5f11a481e1606031e88142b4a96139cce/R/utils.R#L391
split_thing_body = function(x, regex, regex2 = regex) {
  i = c(grep(regex, x), grep(regex2, x))
  n = length(x)
  res = if (n < 2 || length(i) < 2 || (i[1] > 1 && !is_blank(x[seq(i[1] - 1)]))) {
    list(frontmatter = character(), body = x)
  } else list(
    frontmatter = x[i[1]:i[2]], frontmatter_range = i[1:2],
    body = if (i[2] == n) character() else x[(i[2] + 1):n]
  )

  res
}

split_frontmatter_body <- function(x) {
  yamlish <- split_thing_body(x, '^---\\s*$')
  if (length(yamlish[["frontmatter"]]) > 0) {
    yamlish$frontmatter_format <- "YAML"
    return(yamlish)
  }

  tomlish <- split_thing_body(x, '^\\+\\+\\+\\s*$')
  if (length(tomlish[["frontmatter"]]) > 0) {
    tomlish$frontmatter_format <- "TOML"
    return(tomlish)
  }

  jsonish <- split_thing_body(x, '^\\{\\s*$', '\\}$')
  if (length(jsonish[["frontmatter"]]) > 0) {
    jsonish$frontmatter_format <- "JSON"
    return(jsonish)
  }

  list(
    frontmatter = character(0),
    body = x,
    frontmatter_format = NA
  )
}


# from knitr via namer
# https://github.com/lockedata/namer/blob/2d88c5cb200724f775631946fc8e08903ff110de/R/utils.R#L3
transform_params <- function(params) {

  # Step 1: parse the parameters and their labels into a list
  params_list <- try(parse_params(params), silent = TRUE)

  if (inherits(params_list, "try-error")) {
    params <- str_replace(params, " ", ", ")
    params_list <- parse_params(params)
  }

  label <- parse_label(params_list[[1]])
  result <- c(label, params_list[-1])

  # Step 2: find the parameters that are characters because we need to add
  # quotes around them (as all parameters are coerced as characters)
  are_characters <- purrr::map_lgl(result, is.character)

  # Step 3: flatten all params into a character vector
  result <- unlist(result)

  # Step 4: add quotes around the params that are characters
  not_forbidden <- !names(result) %in% c("language", "name")
  needs_quoting <- are_characters & not_forbidden
  result[needs_quoting] <- shQuote(result[needs_quoting], type = "cmd")

  result

}

parse_params <- function(params) {
  eval(parse(text = paste('alist(', quote_label(params), ')')))
}

parse_label <- function(label) {

  language_name <- str_replace(label, " ", "\\/")
  language_name <- str_split(language_name, "\\/")

  if (length(language_name) == 1) {
    list(
      language = trimws(language_name[1]),
      name = ""
    )
  } else {
    list(
      language = trimws(language_name[1]),
      name = trimws(language_name[2])
    )
  }
}

# from knitr
# https://github.com/yihui/knitr/blob/2b3e617a700f6d236e22873cfff6cbc3568df568/R/parser.R#L148
# quote the chunk label if necessary
quote_label = function(x) {
  x = gsub('^\\s*,?', '', x)
  if (grepl('^\\s*[^\'"](,|\\s*$)', x)) {
    # <<a,b=1>>= ---> <<'a',b=1>>=
    x = gsub('^\\s*([^\'"])(,|\\s*$)', "'\\1'\\2", x)
  } else if (grepl('^\\s*[^\'"](,|[^=]*(,|\\s*$))', x)) {
    # <<abc,b=1>>= ---> <<'abc',b=1>>=
    x = gsub('^\\s*([^\'"][^=]*)(,|\\s*$)', "'\\1'\\2", x)
  }
  x
}

# from knitr
# https://github.com/yihui/knitr/blob/5cb166d8ba82c3334927c69f82ddfefc929a8dd4/R/utils.R#L47
is_blank = function(x) {
  if (length(x)) all(grepl('^\\s*$', x)) else TRUE
}

# note
globalVariables(".")
