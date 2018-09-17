roblog <- "C:/Users/Maelle/Documents/ropensci/roweb2/content/blog"
all_posts <- fs::dir_ls(roblog, regexp = "*.md")
all_posts <- all_posts[all_posts != "_index.md"]

library("magrittr")



homogeneize <- function(post_xml){
  headers <- post_xml %>%
    xml2::xml_find_all(xpath = './/d1:heading',
                       xml2::xml_ns(.))

  levels <-  xml2::xml_attr(headers, "level") %>%
    as.character() %>%
    as.numeric()

  no_levels <- length(unique(levels))

  if(no_levels == 1){
    xml2::xml_set_attr(headers, "level", "2")
  }

  if(no_levels == 2){
    headers1 <- headers[xml2::xml_attr(headers, "level") == min(levels)]
    xml2::xml_set_attr(headers1, "level", "2")

    headers2 <- headers[xml2::xml_attr(headers, "level") == max(levels)]
    xml2::xml_set_attr(headers2, "level", "3")
  }

  if(no_levels == 3){
    headers1 <- headers[xml2::xml_attr(headers, "level") == min(levels)]
    xml2::xml_set_attr(headers1, "level", "2")

    headers3 <- headers[xml2::xml_attr(headers, "level") == max(levels)]
    xml2::xml_set_attr(headers3, "level", "4")

    headers2 <- headers[xml2::xml_attr(headers, "level") == (min(levels)+1)]
    xml2::xml_set_attr(headers2, "level", "3")
  }

  #missing step converting back to Markdown
  post_xml
}
correct_post <- function(post_path){
  message(post_path)
  yaml_xml_list <- tinkr::to_xml(post_path)
  yaml_xml_list$body <- homogeneize(yaml_xml_list$body)
  tinkr::to_md(yaml_xml_list, path = post_path)
}

correct_post(all_posts[grepl("2013-11-21-rgbif-changes",
                             all_posts)])

purrr::walk(all_posts, correct_post)

