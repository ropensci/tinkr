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
      

