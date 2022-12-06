
<!-- README.md is generated from README.Rmd. Please edit that file -->

# tinkr

<!-- badges: start -->

[![Project Status: Active – The project has reached a stable, usable
state and is being actively
developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
[![R build
status](https://github.com/ropensci/tinkr/workflows/R-CMD-check/badge.svg)](https://github.com/ropensci/tinkr/actions)
[![Coverage
status](https://codecov.io/gh/ropensci/tinkr/branch/master/graph/badge.svg)](https://codecov.io/github/ropensci/tinkr?branch=master)
<!-- badges: end -->

The goal of tinkr is to convert (R)Markdown files to XML and back to
allow their editing with xml2 (XPath!) instead of numerous complicated
regular expressions. If these words mean nothing to you, see our list of
[resources to get started](#background--pre-requisites).

## Use Cases

Possible applications are R scripts using tinkr, and XPath via xml2 to:

-   change levels of headers, cf [our `roweb2_headers.R`
    script](https://github.com/ropensci/tinkr/blob/main/inst/scripts/roweb2_headers.R)
    and [pull request \#279 to
    roweb2](https://github.com/ropensci-archive/roweb2/pull/279);
-   change chunk labels and options;
-   extract all runnable code (including inline code);
-   insert arbitrary Markdown elements;
-   modify link URLs;
-   your idea, please [report use
    cases](https://discuss.ropensci.org/c/usecases/10)!

## Workflow

Only the body of the (R) Markdown file is cast to XML, using the
Commonmark specification via the [`commonmark`
package](https://github.com/r-lib/commonmark). YAML metadata could be
edited using the [`yaml`
package](https://cran.r-project.org/package=yaml), which is not the goal
of this package.

We have created an [R6 class](https://r6.r-lib.org/) object called
**yarn** to store the representation of both the YAML and the XML data,
both of which are accessible through the `$body` and `$yaml` elements.
In addition, the namespace prefix is set to “md” in the `$ns` element.

You can perform XPath queries using the `$body` and `$ns` elements:

``` r
library("tinkr")
library("xml2")
path <- system.file("extdata", "example1.md", package = "tinkr")
head(readLines(path))
#| [1] "---"                                                                               
#| [2] "title: \"What have these birds been studied for? Querying science outputs with R\""
#| [3] "slug: birds-science"                                                               
#| [4] "authors:"                                                                          
#| [5] "  - name: Maëlle Salmon"                                                           
#| [6] "    url: https://masalmon.eu/"
ex1 <- tinkr::yarn$new(path)
# find all ropensci.org blog links
xml_find_all(
  x = ex1$body, 
  xpath = ".//md:link[contains(@destination,'ropensci.org/blog')]", 
  ns = ex1$ns
)
#| {xml_nodeset (7)}
#| [1] <link destination="https://ropensci.org/blog/2018/08/21/birds-radolfzell/ ...
#| [2] <link destination="https://ropensci.org/blog/2018/09/04/birds-taxo-traits ...
#| [3] <link destination="https://ropensci.org/blog/2018/08/21/birds-radolfzell/ ...
#| [4] <link destination="https://ropensci.org/blog/2018/08/14/where-to-bird/" t ...
#| [5] <link destination="https://ropensci.org/blog/2018/08/21/birds-radolfzell/ ...
#| [6] <link destination="https://ropensci.org/blog/2018/08/28/birds-ocr/" title ...
#| [7] <link destination="https://ropensci.org/blog/2018/09/04/birds-taxo-traits ...
```

## Installation

Wanna try the package and tell us what doesn’t work yet?

``` r
install.packages("tinkr", repos = "https://ropensci.r-universe.dev")
```

## Examples

### Markdown

This is a basic example. We read “example1.md”, change all headers 3 to
headers 1, and save it back to md. Because the xml2 objects are [passed
by
reference](https://blog.penjee.com/wp-content/uploads/2015/02/pass-by-reference-vs-pass-by-value-animation.gif),
manipulating them does not require reassignment.

``` r
library("magrittr")
library("tinkr")
# From Markdown to XML
path <- system.file("extdata", "example1.md", package = "tinkr")
# Level 3 header example:
cat(tail(readLines(path, 40)), sep = "\n")
#| ### Getting a list of 50 species from occurrence data
#| 
#| For more details about the following code, refer to the [previous post
#| of the series](https://ropensci.org/blog/2018/08/21/birds-radolfzell/).
#| The single difference is our adding a step to keep only data for the
#| most recent years.
ex1  <- tinkr::yarn$new(path)
# transform level 3 headers into level 1 headers
ex1$body %>%
  xml2::xml_find_all(xpath = ".//md:heading[@level='3']", ex1$ns) %>% 
  xml2::xml_set_attr("level", 1)

# Back to Markdown
tmp <- tempfile(fileext = "md")
ex1$write(tmp)
# Level three headers are now Level one:
cat(tail(readLines(tmp, 40)), sep = "\n")
#| # Getting a list of 50 species from occurrence data
#| 
#| For more details about the following code, refer to the [previous post
#| of the series](https://ropensci.org/blog/2018/08/21/birds-radolfzell/).
#| The single difference is our adding a step to keep only data for the
#| most recent years.
unlink(tmp)
```

### R Markdown

For R Markdown files, to ease editing of chunk label and options,
`to_xml` munges the chunk info into different attributes. E.g. below you
see that `code_blocks` can have a `language`, `name`, `echo` attributes.

``` r
path <- system.file("extdata", "example2.Rmd", package = "tinkr")
rmd <- tinkr::yarn$new(path)
rmd$body
#| {xml_document}
#| <document xmlns="http://commonmark.org/xml/1.0">
#|  [1] <code_block xml:space="preserve" language="r" name="setup" include="FALS ...
#|  [2] <heading level="2">\n  <text xml:space="preserve">R Markdown</text>\n</h ...
#|  [3] <paragraph>\n  <text xml:space="preserve">This is an </text>\n  <striket ...
#|  [4] <paragraph>\n  <text xml:space="preserve">When you click the </text>\n   ...
#|  [5] <code_block xml:space="preserve" language="r" name="" eval="TRUE" echo=" ...
#|  [6] <heading level="2">\n  <text xml:space="preserve">Including Plots</text> ...
#|  [7] <paragraph>\n  <text xml:space="preserve">You can also embed plots, for  ...
#|  [8] <code_block xml:space="preserve" language="python" name="" fig.cap="&quo ...
#|  [9] <code_block xml:space="preserve" language="python" name="">plot(pressure ...
#| [10] <paragraph>\n  <text xml:space="preserve">Non-RMarkdown blocks are also  ...
#| [11] <code_block info="bash" xml:space="preserve" name="">echo "this is an un ...
#| [12] <code_block xml:space="preserve" name="">This is an ambiguous code block ...
#| [13] <paragraph>\n  <text xml:space="preserve">Note that the </text>\n  <code ...
#| [14] <table>\n  <table_header>\n    <table_cell align="left">\n      <text xm ...
#| [15] <paragraph>\n  <text xml:space="preserve">blabla</text>\n</paragraph>
```

Note that all of the features in tinkr work for both Markdown and R
Markdown.

### Inserting new Markdown elements

Inserting new nodes into the AST is surprisingly difficult if there is a
default namespace, so we have provided a method in the **yarn** object
that will take plain Markdown and translate it to XML nodes and insert
them into the document for you. For example, you can add a new code
block:

``` r
path <- system.file("extdata", "example2.Rmd", package = "tinkr")
rmd <- tinkr::yarn$new(path)
xml2::xml_find_first(rmd$body, ".//md:code_block", rmd$ns)
#| {xml_node}
#| <code_block space="preserve" language="r" name="setup" include="FALSE" eval="TRUE">
new_code <- c(
  "```{r xml-block, message = TRUE}",
  "message(\"this is a new chunk from {tinkr}\")",
  "```")
new_table <- data.frame(
  package = c("xml2", "xslt", "commonmark", "tinkr"),
  cool = TRUE
)
# Add chunk into document after the first chunk
rmd$add_md(new_code, where = 1L)
# Add a table after the second chunk:
rmd$add_md(knitr::kable(new_table), where = 2L)
# show the first 21 lines of modified document
rmd$head(21)
#| ---
#| title: "Untitled"
#| author: "M. Salmon"
#| date: "September 6, 2018"
#| output: html_document
#| ---
#| 
#| ```{r setup, include=FALSE, eval=TRUE}
#| knitr::opts_chunk$set(echo = TRUE)
#| ```
#| 
#| ```{r xml-block, message=TRUE}
#| message("this is a new chunk from {tinkr}")
#| ```
#| 
#| | package                    | cool                | 
#| | :------------------------- | :------------------ |
#| | xml2                       | TRUE                | 
#| | xslt                       | TRUE                | 
#| | commonmark                 | TRUE                | 
#| | tinkr                      | TRUE                |
```

## Background / pre-requisites

If you are not closely following one of the examples provided, what
background knowledge do you need before using tinkr?

-   That XPath, a language for querying XML & HTML, exists, and [some
    basics](https://www.w3schools.com/xml/xpath_intro.asp).
-   Basics of how [xml2
    works](https://blog.r-hub.io/2020/01/22/mutable-api/#exposing-the-c-api-in-xml2):
    how to find, replace, remove nodes etc.
-   How to use R6 classes… although reading the examples should help you
    get the gist.
-   If you are not happy with [our default
    stylesheet](#general-principles-and-solution), then understanding
    [XSLT](https://ropensci.org/blog/2017/01/10/xslt-release/) will help
    you create your own. Refer to this good resource on [XSLT for XML
    transformations](https://www.w3schools.com/xml/xsl_intro.asp).

## Loss of Markdown style

### General principles and solution

The (R)md to XML to (R)md loop on which `tinkr` is based is slightly
lossy because of Markdown syntax redundancy, so the loop from (R)md to
R(md) via `to_xml` and `to_md` will be a bit lossy. For instance

-   lists can be created with either “+”, “-” or “\*“. When using
    `tinkr`, the (R)md after editing will only use”-” for lists.

-   Links built like `[word][smallref]` with a bottom anchor
    `[smallref]: URL` will have the anchor moved to the bottom of the
    document.

-   Characters are escaped (e.g. “\[” when not for a link).

-   [x] GitHub tickboxes are preserved (only for `yarn` objects)

-   Block quotes lines all get “\>” whereas in the input only the first
    could have a “\>” at the beginning of the first line.

-   For tables see the next subsection.

Such losses make your (R)md different, and the git diff a bit harder to
parse, but should *not* change the documents your (R)md is rendered to.
If it does, report a bug in the issue tracker!

A solution to not loose your Markdown style, e.g. your preferring “\*”
over “-” for lists is to tweak [our XSL
stylesheet](https://github.com/ropensci/tinkr/blob/main/inst/stylesheets/xml2md_gfm.xsl)
and provide its filepath as `stylesheet_path` argument to `to_md`.

### The special case of tables

-   Tables are supposed to remain/become pretty after a full loop
    `to_xml` + `to_md`. If you notice something amiss, e.g. too much
    space compared to what you were expecting, please open an issue.

### LaTeX equations

While Markdown parsers like pandoc know what LaTeX is, commonmark does
not, and that means LaTeX equations will end up with extra markup due to
commonmark’s desire to escape characters.

However, if you have LaTeX equations that use either `$` or `$$` to
delimit them, you can protect them from formatting changes with the
`$protect_math()` method (for users of the `yarn` object) or the
`protect_math()` function (for those using the output of `to_xml()`).
Below is a demonstration using the `yarn` object:

``` r
path <- system.file("extdata", "math-example.md", package = "tinkr")
math <- tinkr::yarn$new(path)
math$tail() # malformed
#| 
#| $$
#| Q\_{N(norm)}=\\frac{C\_N +C\_{N-1}}2\\times
#| \\frac{\\sum *{i=N-n}^{N}Q\_i} {\\sum*{j=N-n}^{N}{(\\frac{C\_j+C\_{j-1}}2)}}
#| $$
math$protect_math()$tail() # success!
#| 
#| $$
#| Q_{N(norm)}=\frac{C_N +C_{N-1}}2\times
#| \frac{\sum _{i=N-n}^{N}Q_i} {\sum_{j=N-n}^{N}{(\frac{C_j+C_{j-1}}2)}}
#| $$
```

Note, however, that there are a few caveats for this:

1.  The dollar notation for inline math must be adjacent to the text.
    E.G. `$\alpha$` is valid, but `$ \alpha$` and `$\alpha $` are not
    valid.

2.  We do not currently have support for bracket notation

3.  If you use a postfix dollar sign in your prose (e.g. BASIC commands
    or a Burroughs-Wheeler Transformation demonstration), you must be
    sure to either use punctuation after the trailing dollar sign OR
    format the text as code. (i.e. `` `INKEY$` `` is good, but `INKEY$`
    by itself is not good and will be interpreted as LaTeX code,
    throwing an error: ::: {.cell}

    ``` r
    path <- system.file("extdata", "basic-math.md", package = "tinkr")
    math <- tinkr::yarn$new(path)
    math$head(15) # malformed
    #| ---
    #| title: basic math
    #| ---
    #| 
    #| BASIC programming can make things weird:
    #| 
    #| - Give you $2 to tell me what INKEY$ means.
    #| - Give you $2 to *show* me what INKEY$ means.
    #| - Give you $2 to *show* me what `INKEY$` means.
    #| 
    #| Postfix dollars mixed with prefixed dollars can make things weird:
    #| 
    #| - We write $2 but say 2$ verbally.
    #| - We write $2 but *say* 2$ verbally.
    math$protect_math() #error
    #| Error: Inline math delimiters are not balanced.
    #| 
    #| HINT: If you are writing BASIC code, make sure you wrap variable
    #|       names and code in backtics like so: `INKEY$`. 
    #| 
    #| Below are the pairs that were found:
    #|            start...end
    #|            -----...---
    #|  Give you $2 to ... me what INKEY$ means.
    #|  Give you $2 to ... 2$ verbally.
    #| We write $2 but ...
    ```

    :::

## Meta

Please note that the ‘tinkr’ project is released with a [Contributor
Code of Conduct](https://ropensci.org/code-of-conduct). By contributing
to this project, you agree to abide by its terms.
