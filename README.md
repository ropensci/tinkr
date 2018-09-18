# tinkr

[![Project Status: WIP – Initial development is in progress, but there has not yet been a stable, usable release suitable for the public.](https://www.repostatus.org/badges/latest/wip.svg)](https://www.repostatus.org/#wip) [![Travis build status](https://travis-ci.org/ropenscilabs/tinkr.svg?branch=master)](https://travis-ci.org/ropenscilabs/tinkr) [![AppVeyor build status](https://ci.appveyor.com/api/projects/status/github/maelle/tinkr?branch=master&svg=true)](https://ci.appveyor.com/project/maelle/tinkr) [![Coverage status](https://codecov.io/gh/ropenscilabs/tinkr/branch/master/graph/badge.svg)](https://codecov.io/github/ropenscilabs/tinkr?branch=master)



The goal of tinkr is to convert (R)Markdown files to XML and back to allow their editing with `xml2` (XPath!) instead of numerous complicated regular expressions. [If new to XPath refer to this great intro](https://www.w3schools.com/xml/xpath_intro.asp). Possible applications are R scripts using this and XPath in `xml2` to:

* change levels of headers, cf [this script](inst/scripts/roweb2_headers.R) and [this pull request to roweb2](https://github.com/ropensci/roweb2/pull/279)

* change chunk labels and options

* your idea, feel free to suggest use cases!

Only the body of the (R) Markdown file is cast to XML, using the Commonmark specification via the `commonmark` package. YAML metadata could be edited using the `yaml` package, which is not the goal of this package.

The current workflow I have in mind is

1. use `to_xml` to obtain XML from (R) Markdown (_based on `commonmark::markdown_xml` and `blogdown:::split_yaml_body`_).

2. edit the XML using `xml2`.

3. use `to_md` to save back the resulting (R) Markdown (_this uses a XSLT stylesheet, and the `xslt` package_).

Maybe there could be shortcuts functions for some operations in 2, maybe not.

## Installation

Wanna try the package and tell me what doesn't work? 

``` r
remotes::install_github("ropenscilabs/tinkr")
```

## Examples

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


## Details/notes

* The (R)md to XML to (R)md loop on which `tinkr` is based is slightly lossy because of Markdown syntax redundancy. For instance lists can be created with either "+", "-" or "*". When using `tinkr`, the (R)md after editing will only use "-" for lists. Such losses make your (R)md different, and the git diff a bit harder to parse, but should _not_ change the documents your (R)md is rendered to. If it does, report a bug in the issue tracker!

* At the moment the XLST stylesheet used to cast XML back to Markdown doesn't support extensions (striked through text, tables) so when converting the Markdown files to XML the package uses `extensions=FALSE`. This means tables in the XML are text, not easy to edit.


