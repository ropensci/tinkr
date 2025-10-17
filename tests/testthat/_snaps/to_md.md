# to_md fails if the stylesheet is not correct

    Code
      to_md(yaml_xml_list, stylesheet_path = NULL)
    Condition
      Error:
      ! 'stylesheet_path' must be a path to an XSL stylesheet

---

    Code
      to_md(yaml_xml_list, stylesheet_path = NA)
    Condition
      Error:
      ! 'stylesheet_path' must be a path to an XSL stylesheet

---

    Code
      to_md(yaml_xml_list, stylesheet_path = letters)
    Condition
      Error:
      ! 'stylesheet_path' must be a path to an XSL stylesheet

---

    Code
      to_md(yaml_xml_list, stylesheet_path = character(0))
    Condition
      Error:
      ! 'stylesheet_path' must be a path to an XSL stylesheet

---

    Code
      to_md(yaml_xml_list, stylesheet_path = tmp, transform = function(x) {
        sub(".* is not a valid stylesheet", "<path> is not a valid stylesheet", x)
      })
    Condition
      Error in `to_md()`:
      ! unused argument (transform = function(x) {
          sub(".* is not a valid stylesheet", "<path> is not a valid stylesheet", x)
      })

---

    Code
      to_md(yaml_xml_list, stylesheet_path = "path/to/stylesheet.xsl")
    Condition
      Error:
      ! Can't find 'path/to/stylesheet.xsl'.

---

    Code
      to_md(yaml_xml_list, stylesheet_path = yaml_xml_list$body)
    Condition
      Error:
      ! 'stylesheet_path' must be a path to an XSL stylesheet

# to_md_vec() returns a vector of the same length as the nodelist

    Code
      show_user(to_md_vec(blocks[5:6]), force = TRUE)
    Output
      ```r
      get_papers <- ratelimitr::limit_rate(.get_papers,
                                           rate = ratelimitr::rate(1, 2))
      
      all_papers <- purrr::map_df(species, get_papers)
      
      nrow(all_papers)
      ```
      ```
      ## [1] 522
      ```

# list subitems keep their 3 spaces (ordered)

    Code
      md
    Output
      [[1]]
      [1] "1. My list item"      "   - First sub-item"  "   - Second sub-item"
      

# list subitems keep their 2 spaces (unordered)

    Code
      md
    Output
      [[1]]
      [1] "- My list item"      "  - First sub-item"  "  - Second sub-item"
      

# list subitems keep empty line

    Code
      md
    Output
      [[1]]
      [1] "- My list item"      "  "                  "  - First sub-item" 
      [4] "  - Second sub-item"
      

---

    Code
      md
    Output
      [[1]]
      [1] "1. My list item"      "   "                  "   - First sub-item" 
      [4] "   - Second sub-item"
      

