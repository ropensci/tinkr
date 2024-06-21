---
title: 'Example of the show methods'
---

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
sourcepos <- c("2:1-2:33", "4:1-7:7")
pattern <- "([[:digit:]]+):([[:digit:]]+)-([[:digit:]]+):([[:digit:]]+)"
proto <- data.frame(
  linestart = integer(), colstart = integer(),
  lineend = integer(), colend = integer()
)
utils::strcapture(pattern, sourcepos, proto)
```

## Math

Inline math can be written as $y = mx + b$ while block math should be:

$$
y = mx + b
$$

[anchor links]: https://example.com/anchor
