# show_list() will isolate elements

    Code
      show_user(show_list(links), force = TRUE)
    Output
      
      
      [relative links](#links)
      
      [anchor links]
      
      [anchor links]: https://example.com/anchor
      
      

---

    Code
      show_user(show_list(code), force = TRUE)
    Output
      
      
      `utils::strcapture()`
      

---

    Code
      show_user(show_list(blocks), force = TRUE)
    Output
      
      
      ```r
      sourcepos <- c("2:1-2:33", "4:1-7:7")
      pattern <- "([[:digit:]]+):([[:digit:]]+)-([[:digit:]]+):([[:digit:]]+)"
      proto <- data.frame(
        linestart = integer(), colstart = integer(),
        lineend = integer(), colend = integer()
      )
      utils::strcapture(pattern, sourcepos, proto)
      ```
      
      

# show_list() will isolate groups of elements

    Code
      show_user(show_list(list(links, headings)), force = TRUE)
    Output
      
      
      [relative links](#links)
      [anchor links]
      [anchor links]: https://example.com/anchor
      
      
      
      ## Links
      
      
      ### Relative
      
      
      ### Images
      
      
      ## Lists
      
      
      ## Code
      
      
      ## Math
      
      
      

# show_censor() will show a censored list of disparate elements

    Code
      show_user(disp, force = TRUE)
    Output
      
      
      ## .....
      
      ### ........
      
      .... ... .... [........ .....](......) ... [...... .....].
      
      ### ......
      
      ![....... ... ....](...............................)....... ...... ....... .. . ........
      
      ## Lists
      
      - .......
        - ...
          - .....
          - ....
        - ....
          - ....
          - ...... .......
      - ......
        - ...
          - .......
      
      ## ....
      
      .... .. .. ....... .. ... `utils::strcapture()` function
      

# show_censor() will censor elements

    Code
      show_user(lnks, force = TRUE)
    Output
      
      
      ## .....
      
      ### ........
      
      .... ... .... [relative links](#links) ... [anchor links].
      
      ### ......
      
      ![....... ... ....](...............................)....... ...... ....... .. . ........
      
      ## .....
      
      - .......
        - ...
          - .....
          - ....
        - ....
          - ....
          - ...... .......
      - ......
        - ...
          - .......
      
      ## ....
      
      .... .. .. ....... .. ... `...................` ........
      
      ```r
      ......... .. ............. ..........
      ....... .. .............................................................
      ..... .. ...........
        ......... . .......... ........ . ..........
        ....... . .......... ...... . .........
      .
      .......................... .......... ......
      ```
      
      ## ....
      
      ...... .... ... .. ....... .. .. . .. . .. ..... ..... .... ...... ...
      
      ..
      . . .. . .
      ..
      
      [anchor links]: https://example.com/anchor
      
      

---

    Code
      show_user(cd, force = TRUE)
    Output
      
      
      ## .....
      
      ### ........
      
      .... ... .... [........ .....](......) ... [...... .....].
      
      ### ......
      
      ![....... ... ....](...............................)....... ...... ....... .. . ........
      
      ## .....
      
      - .......
        - ...
          - .....
          - ....
        - ....
          - ....
          - ...... .......
      - ......
        - ...
          - .......
      
      ## ....
      
      .... .. .. ....... .. ... `utils::strcapture()` ........
      
      ```r
      ......... .. ............. ..........
      ....... .. .............................................................
      ..... .. ...........
        ......... . .......... ........ . ..........
        ....... . .......... ...... . .........
      .
      .......................... .......... ......
      ```
      
      ## ....
      
      ...... .... ... .. ....... .. .. . .. . .. ..... ..... .... ...... ...
      
      ..
      . . .. . .
      ..
      
      [...... .....]: ..........................
      
      

---

    Code
      show_user(blks, force = TRUE)
    Output
      
      
      ## .....
      
      ### ........
      
      .... ... .... [........ .....](......) ... [...... .....].
      
      ### ......
      
      ![....... ... ....](...............................)....... ...... ....... .. . ........
      
      ## .....
      
      - .......
        - ...
          - .....
          - ....
        - ....
          - ....
          - ...... .......
      - ......
        - ...
          - .......
      
      ## ....
      
      .... .. .. ....... .. ... `...................` ........
      
      ```r
      sourcepos <- c("2:1-2:33", "4:1-7:7")
      pattern <- "([[:digit:]]+):([[:digit:]]+)-([[:digit:]]+):([[:digit:]]+)"
      proto <- data.frame(
        linestart = integer(), colstart = integer(),
        lineend = integer(), colend = integer()
      )
      utils::strcapture(pattern, sourcepos, proto)
      ```
      
      ## ....
      
      ...... .... ... .. ....... .. .. . .. . .. ..... ..... .... ...... ...
      
      ..
      . . .. . .
      ..
      
      [...... .....]: ..........................
      
      

# tinkr.censor.regex can adjust for symbols

    Code
      show_user(itms, force = TRUE)
    Output
      
      
      ## Links
      
      ### Relative
      
      Here are some [relative links](#links) and [anchor links].
      
      ### Images
      
      ![kittens are cute](https://loremflickr.com/320/240){alt='a random picture of a kitten'}
      
      ## Lists
      
      - kittens
        - are
          - super
          - cute
        - have
          - teef
          - murder mittens
      - brains
        - are
          - wrinkly
      
      ## Code
      
      Here is an example of the `utils::strcapture()` function
      
      ```r
      AAAAAAAAA <- A("A:A-A:AA", "A:A-A:A")
      AAAAAAA <- "([[:AAAAA:]]+):([[:AAAAA:]]+)-([[:AAAAA:]]+):([[:AAAAA:]]+)"
      AAAAA <- AAAA.AAAAA(
        AAAAAAAAA = AAAAAAA(), AAAAAAAA = AAAAAAA(),
        AAAAAAA = AAAAAAA(), AAAAAA = AAAAAAA()
      )
      AAAAA::AAAAAAAAAA(AAAAAAA, AAAAAAAAA, AAAAA)
      ```
      
      ## Math
      
      Inline math can be written as $y = mx + b$ while block math should be:
      
      $$
      y = mx + b
      $$
      
      [anchor links]: https://example.com/anchor
      
      

# show_block() will provide context for the elements

    Code
      show_user(b_items, force = TRUE)
    Output
      
      
      - kittens
        - are
          - super
          - cute
        - have
          - teef
          - murder mittens
      - brains
        - are
          - wrinkly
      

---

    Code
      show_user(b_links, force = TRUE)
    Output
      
      
      [relative links](#links)[anchor links]
      
      [anchor links]: https://example.com/anchor
      
      

---

    Code
      show_user(bmark_links, force = TRUE)
    Output
      
      
      [...] [relative links](#links) [...][...] [anchor links] [...]
      
      [anchor links]: https://example.com/anchor
      
      

---

    Code
      show_user(bmark_code, force = TRUE)
    Output
      
      
      [...] `utils::strcapture()` [...]
      

