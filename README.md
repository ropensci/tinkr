# tinkr

<!-- badges: start -->
[![Project Status: WIP – Initial development is in progress, but there has not yet been a stable, usable release suitable for the public.](https://www.repostatus.org/badges/latest/wip.svg)](https://www.repostatus.org/#wip) 
  [![R build status](https://github.com/ropenscilabs/tinkr/workflows/R-CMD-check/badge.svg)](https://github.com/ropenscilabs/tinkr/actions)
 [![Coverage status](https://codecov.io/gh/ropenscilabs/tinkr/branch/master/graph/badge.svg)](https://codecov.io/github/ropenscilabs/tinkr?branch=master)
  <!-- badges: end -->



The goal of tinkr is to convert (R)Markdown files to XML and back to allow their editing with `xml2` (XPath!) instead of numerous complicated regular expressions. [If new to XPath refer to this great intro](https://www.w3schools.com/xml/xpath_intro.asp). Possible applications are R scripts using this and XPath in `xml2` to:

* change levels of headers, cf [this script](inst/scripts/roweb2_headers.R) and [this pull request to roweb2](https://github.com/ropensci/roweb2/pull/279)

* change chunk labels and options

* your idea, feel free to suggest use cases!

Only the body of the (R) Markdown file is cast to XML, using the Commonmark specification via the [`commonmark` package](https://github.com/jeroen/commonmark). YAML metadata could be edited using the [`yaml` package](https://github.com/viking/r-yaml), which is not the goal of this package.

The current workflow I have in mind is

1. use `to_xml` to obtain XML from (R) Markdown (_based on `commonmark::markdown_xml` and `blogdown:::split_yaml_body`_).

2. edit the XML using `xml2`.

3. use `to_md` to save back the resulting (R) Markdown (_this uses a XSLT stylesheet, and [the `xslt` package](https://github.com/ropensci/xslt)_).

Maybe there could be shortcuts functions for some operations in 2, maybe not.

## Installation

Wanna try the package and tell me what doesn't work? 

``` r
remotes::install_github("ropenscilabs/tinkr")
```

## Examples

### Markdown

This is a basic example. We read "example1.md", change all headers 3 to headers 1, and save it back to md.

``` r
# From Markdown to XML
path <- system.file("extdata", "example1.md", package = "tinkr")
yaml_xml_list <- to_xml(path)

library("magrittr")
# transform level 3 headers into level 1 headers
body <- yaml_xml_list$body
body %>%
  xml2::xml_find_all(xpath = './/d1:heading',
                     xml2::xml_ns(.)) %>%
  .[xml2::xml_attr(., "level") == "3"] -> headers3

xml2::xml_set_attr(headers3, "level", 1)

yaml_xml_list$body <- body

# Back to Markdown
to_md(yaml_xml_list, "newmd.md")
file.edit("newmd.md")
```

### R Markdown

For R Markdown files, to ease editing of chunk label and options, `to_xml` munges the chunk info into different attributes. E.g. below you see that `code_blocks` can have a `language`, `name`, `echo` attributes.

``` r
path <- system.file("extdata", "example2.Rmd", package = "tinkr")
yaml_xml_list <- tinkr::to_xml(path)
yaml_xml_list$body
#> {xml_document}
#> <document xmlns="http://commonmark.org/xml/1.0">
#>  [1] <code_block language="r" name="setup" include="FALSE" eval="TRUE">k ...
#>  [2] <heading level="2">\n  <text>R Markdown</text>\n</heading>
#>  [3] <paragraph>\n  <text>This is an R Markdown document. Markdown is a  ...
#>  [4] <paragraph>\n  <text>When you click the </text>\n  <strong>\n    <t ...
#>  [5] <code_block language="r" name="" eval="TRUE" echo="TRUE">summary(ca ...
#>  [6] <heading level="2">\n  <text>Including Plots</text>\n</heading>
#>  [7] <paragraph>\n  <text>You can also embed plots, for example:</text>\ ...
#>  [8] <code_block language="python" name="" echo="FALSE" eval="TRUE">plot ...
#>  [9] <code_block language="python" name="">plot(pressure)\n</code_block>
#> [10] <paragraph>\n  <text>Note that the </text>\n  <code>echo = FALSE</c ...
```

### Inserting new elements

You can insert new elements into the document via {xml2}, but you should make
sure that the namespace matches that of your xml document. For example, let's
say we wanted to add a new R code chunk after the setup chunk:

> NOTE: Inserting new code MUST have a newline character at the end of the
> chunk or else the last line will be lost.

``` r
path <- system.file("extdata", "example2.Rmd", package = "tinkr")
yaml_xml_list <- tinkr::to_xml(path)
# Add chunk into document
xml2::xml_add_child(yaml_xml_list$body, 
                    "code_block",
                    "message(\"this is a new chunk from {tinkr}\")\n",
                    language='r', 
                    name='xml-block', 
                    xmlns=xml2::xml_ns(yaml_xml_list$body)[[1]],
                    .where = 1L)
out <- tempfile(fileext = ".Rmd")
tinkr::to_md(yaml_xml_list, out)
file.edit(out)
```

````markdown
---
title: "Untitled"
author: "M. Salmon"
date: "September 6, 2018"
output: html_document
---

```{r setup, include=FALSE, eval=TRUE}
knitr::opts_chunk$set(echo = TRUE)
```

```{r xml-block}
message("this is a new chunk from {tinkr}")
```

## R Markdown
````

## Loss of Markdown style

### General principles and solution

The (R)md to XML to (R)md loop on which `tinkr` is based is slightly lossy because of Markdown syntax redundancy, so the loop from (R)md to R(md) via `to_xml` and `to_md` will be a bit lossy. For instance 

 * lists can be created with either "+", "-" or "*". When using `tinkr`, the (R)md after editing will only use "-" for lists. 
 
 * Links built like `[word][smallref]` and bottom `[smallref]: URL` become `[word](URL)`.
 
 * Characters are escaped (e.g. "[" when not for a link).
 
 * Block quotes lines all get ">" whereas in the input only the first could have a ">" at the beginning of the first line.
 
 * For tables see the next subsection.
    
  Such losses make your (R)md different, and the git diff a bit harder to parse, but should _not_ change the documents your (R)md is rendered to. If it does, report a bug in the issue tracker!
  
  A solution to not loose your Markdown style, e.g. your preferring "*" over "-" for lists is to tweak [our XSL stylesheet](inst/extdata/xml2md_gfm.xsl) and provide its filepath as `stylesheet_path` argument to `to_md`.
  
### The special case of tables
  
* Tables are supposed to remain/become pretty after a full loop `to_xml` + `to_md`. If you notice something amiss, e.g. too much space compared to what you were expecting, please open an issue.

## Meta

Please note that the 'tinkr' project is released with a [Contributor Code of Conduct](CODE_OF_CONDUCT.md). By contributing to this project, you agree to abide by its terms.
