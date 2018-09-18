# from blogdown
# https://github.com/rstudio/blogdown/blob/9c7f7db5f11a481e1606031e88142b4a96139cce/R/utils.R#L391
split_yaml_body = function(x) {
  i = grep('^---\\s*$', x)
  n = length(x)
  res = if (n < 2 || length(i) < 2 || (i[1] > 1 && !knitr:::is_blank(x[seq(i[1] - 1)]))) {
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
transform_params <- function(params){
  params_string <- try(eval(parse(text = paste('alist(', quote_label(params), ')'))),
                       silent = TRUE)

  if(inherits(params_string, "try-error")){
    params <- stringr::str_replace(params, " ", ", ")
    params_string <- eval(parse(text = paste('alist(', quote_label(params), ')')))
  }

  label <- parse_label(params_string[[1]])

  result <- unlist(c(label, params_string[-1]))
  result[purrr::map_lgl(result, is.character)&
           !names(result) %in% c("language", "name")] <- glue::glue('"{result[purrr::map_lgl(result, is.character)&
           !names(result) %in% c("language", "name")]}"')

   result
}


parse_label <- function(label){
  label %>%
    stringr::str_replace(" ", "\\/") %>%
    stringr::str_split("\\/",
                       simplify = TRUE) -> language_name

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
