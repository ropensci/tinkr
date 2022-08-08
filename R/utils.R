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
split_yaml_body = function(x) {
  i = grep('^---\\s*$', x)
  n = length(x)
  res = if (n < 2 || length(i) < 2 || (i[1] > 1 && !is_blank(x[seq(i[1] - 1)]))) {
    list(yaml = character(), body = x)
  } else list(
    yaml = x[i[1]:i[2]], yaml_range = i[1:2],
    body = if (i[2] == n) character() else x[(i[2] + 1):n]
  )
  res$yaml_list = if ((n <- length(res$yaml)) >= 3) {
    yaml_load(res$yaml[-c(1, n)])
  }
  res
}

# https://github.com/rstudio/blogdown/blob/9c7f7db5f11a481e1606031e88142b4a96139cce/R/utils.R#L407
# anotate seq type values because both single value and list values are
# converted to vector by default
yaml_load = function(x) yaml::yaml.load(
  x, handlers = list(
    seq = function(x) {
      # continue coerce into vector because many places of code already assume this
      if (length(x) > 0) {
        x = unlist(x, recursive = FALSE)
        attr(x, 'yml_type') = 'seq'
      }
      x
    }
  )
)

# from knitr via namer
# https://github.com/lockedata/namer/blob/2d88c5cb200724f775631946fc8e08903ff110de/R/utils.R#L3
transform_params <- function(params) {

  # Step 1: parse the parameters and their labels into a list
  params_list <- try(parse_params(params), silent = TRUE)

  if (inherits(params_list, "try-error")) {
    params <- stringr::str_replace(params, " ", ", ")
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

  language_name <- stringr::str_replace(label, " ", "\\/")
  language_name <- stringr::str_split(language_name, "\\/", simplify = TRUE)

  if(ncol(language_name) == 1){
    list(language = trimws(language_name[1, 1]),
         name = "")
  }else{
    list(language = trimws(language_name[1, 1]),
         name = trimws(language_name[1, 2]))
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
