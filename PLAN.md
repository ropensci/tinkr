# Plan: protect_emojis()

## Context

The tinkr package has a family of `protect_*()` functions that mark special text
patterns in CommonMark XML with custom attributes so they survive round-trips
through external APIs (e.g. translation services) without being mangled.

Goal: add `protect_emojis()` to mark emoji shortcodes like `:wave:` or
`:snake_case:` with an `emoji='true'` attribute.

Emojis appear **inline** inside text nodes (e.g. `"I am :sparkles: a human
:tada:"`), so the implementation must **split** text nodes like `protect_curly()`
does, producing:

```xml
<text>I am </text>
<text emoji="true">:sparkles:</text>
<text> a human </text>
<text emoji="true">:tada:</text>
```

### Regex

The user-specified pattern `[:]([_-0-9A-z])*[:]` is not valid R regex because
`[_-0]` is an invalid ASCII range. The R-compatible equivalent with a negative
lookbehind to eliminate time-like false positives is:

```
(?<![0-9A-Za-z]):[_0-9A-Za-z-]+:
```

Used with `perl = TRUE`. The lookbehind asserts that the opening `:` is **not**
immediately preceded by a letter or digit, so `1:30:` (time) won't match while
` :wave:` and `:snake:` will.

### False positives

The `not(@asis)` XPath filter already excludes code spans and code blocks.
With the lookbehind, remaining risks are minimal:

| Pattern | Example | Verdict |
|---------|---------|---------|
| Time with seconds | `1:30:00` → `:30:` preceded by `1` | **Excluded** by lookbehind |
| `foo:bar:` | letter before `:` | **Excluded** by lookbehind |
| ` :wave: ` | space before `:` | Matched correctly |
| `:snake:` | start of string | Matched correctly |
| URL path colons | `http://` | Not matched (no closing `:word:` structure) |

---

## Files to change

| File | Action |
|------|--------|
| `R/attr-nodes.R` | Add `find_emojis`, `digest_emoji`, `protect_emojis` |
| `R/get_protected.R` | Add `emoji = "@emoji"` to protections vector + update docs |
| `R/class-yarn.R` | Add `$protect_emojis()` method, update `get_protected` bullet list |
| `tests/testthat/test-attr-nodes.R` | Add snapshot test |
| `inst/extdata/emoji.md` | New example data file |
| `NAMESPACE` | Auto-generated via `devtools::document()` |

---

## 1. `inst/extdata/emoji.md` (new)

```markdown
# Emoji test

Hello :wave: world.

:snake: is the Python emoji.

Multiple emojis: :smile: and :tada:.

The meeting is at 1:30:00.

This is foo:bar: notation.
```

---

## 2. `R/attr-nodes.R` — append at bottom

Structure mirrors `protect_curly()`. `make_text_nodes()` and
`add_node_siblings()` are already available (defined in `R/asis-nodes.R`,
already used by `protect_curly()` in this same file).

```r
# EMOJIS ------------------

find_emojis <- function(body, ns) {
  i <- ".//md:text[not(@asis) and contains(text(), ':')]"
  candidates <- xml2::xml_find_all(body, i, ns = ns)
  texts <- xml2::xml_text(candidates)
  candidates[grepl("(?<![0-9A-Za-z]):[_0-9A-Za-z-]+:", texts, perl = TRUE)]
}

digest_emoji <- function(emoji_node, ns) {
  char <- as.character(emoji_node)
  emojis <- regmatches(char, gregexpr("(?<![0-9A-Za-z]):[_0-9A-Za-z-]+:", char, perl = TRUE))[[1]]
  for (em in emojis) {
    char <- sub(
      em,
      sprintf("</text><text emoji='true'>%s</text><text>", em),
      char,
      fixed = TRUE
    )
  }
  make_text_nodes(char)
}

#' Protect emoji shortcodes for further processing
#'
#' @inheritParams protect_math
#' @return a copy of the modified XML object
#' @details Commonmark will render emoji shortcodes such as `:wave:`
#' as normal text which might be problematic if trying to extract
#' real text from the XML.
#'
#' If sending the XML to, say, a translation API that allows some tags
#' to be ignored, you could first transform the text tags with the
#' attribute `emoji` to `emoji` tags, and then transform them back
#' to text tags before using `to_md()`.
#'
#' @note this function is also a method in the [tinkr::yarn] object.
#'
#' @export
#' @examples
#' m <- tinkr::to_xml(system.file("extdata", "emoji.md", package = "tinkr"))
#' xml2::xml_child(m$body)
#' m$body <- protect_emojis(m$body)
#' xml2::xml_child(m$body)
protect_emojis <- function(body, ns = md_ns()) {
  body <- copy_xml(body)
  emojis <- find_emojis(body, ns)
  new_nodes <- purrr::map(emojis, digest_emoji, ns = ns)
  for (i in seq(new_nodes)) {
    add_node_siblings(emojis[[i]], new_nodes[[i]], remove = TRUE)
  }
  copy_xml(body)
}
```

---

## 3. `R/get_protected.R`

Add `emoji = "@emoji"` to the `protections` vector and add a bullet to `@param type`:

```r
protections <- c(
  math = "@math",
  curly = "@curly",
  fence = "@fence",
  emoji = "@emoji",           # add this line
  unescaped = "(@asis and text()='[' or text()=']')"
)
```

`@param type` bullet to add:
```
#'   - emoji: via the \`protect_emojis()\` function
```

---

## 4. `R/class-yarn.R`

Insert after the `protect_fences` method (around line 312):

```r
    #' @description Protect emoji shortcodes `:like_this:` from being escaped
    #'
    #' @examples
    #' path <- system.file("extdata", "emoji.md", package = "tinkr")
    #' ex <- tinkr::yarn$new(path)
    #' ex$protect_emojis()$head()
    protect_emojis = function() {
      self$body <- protect_emojis(self$body, self$ns)
      invisible(self)
    },
```

Also add `- emoji: via the \`protect_emojis()\` function` to the `get_protected`
method's `@description` bullet list.

---

## 5. `tests/testthat/test-attr-nodes.R`

Append:

```r
test_that("protect_emojis() works", {
  path <- system.file("extdata", "emoji.md", package = "tinkr")
  ex <- yarn$new(path, sourcepos = TRUE)
  expect_snapshot(cat(as.character(protect_emojis(ex$body))))
})
```

---

## Verification

1. `devtools::document()` — `protect_emojis` appears in NAMESPACE.
2. `devtools::test(filter = "attr-nodes")` — snapshot generated; verify text nodes
   are split correctly with `emoji='true'` on the right nodes.
3. `devtools::check()` — no R CMD check errors.
