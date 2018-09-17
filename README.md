# tinkr

[![Project Status: WIP – Initial development is in progress, but there has not yet been a stable, usable release suitable for the public.](https://www.repostatus.org/badges/latest/wip.svg)](https://www.repostatus.org/#wip)

The goal of tinkr is to cast (R)Markdown files to XML and back to allow their editing via XPat. Possible applications are R scripts using this and XPath in `xml2` to:

* change levels of headers, cf [this script](inst/scripts/roweb2_headers.R) and [this pull request to roweb2](https://github.com/ropensci/roweb2/pull/279)

* change chunk labels and options, still [a project](https://github.com/ropenscilabs/tinkr/issues/1)

* etc.

Only the body is cast to XML, using the Commonmark specification via the `commonmark` package. YAML metadata could be edited using the `yaml` package, which is not the goal of this package.

The current workflow I have in mind is

1. use `to_xml`

2. edit the XML using `xml2`

3. use `to_md`

Maybe there could be shortcuts functions for some operations in 2, maybe not.

## Installation

Not recommended at the moment.

``` r
remotes::install_github("maelle/tinkr")
```

## Example

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

## Details/notes

* At the moment the XLST stylesheet used to cast XML back to Markdown doesn't support extensions (striked through text, tables) so when converting the Markdown files to XML the package uses `extensions=FALSE`.


