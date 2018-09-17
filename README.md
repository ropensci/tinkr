# tinkr

The goal of tinkr is to cast (R)Markdown files to XML and back to allow their editing via XPat. Possible applications are R scripts using this and XPath in `xml2` to:

* change levels of headers

* change chunk labels and options

* etc.

Only the body is cast to XML, using the Commonmark specification via the `commonmark` package. YAML headers could be edited using the `yaml` package, which is not the goal of this package.

## Installation

Not recommended at the moment.

``` r
remotes::install_github("maelle/tinkr")
```

## Example

This is a basic example. We read "example1.md", change all headers 3 to headers 1, and save it back to md.

``` r
path <- system.file("extdata", "example1.md", package = "tinkr")
yaml_xml_list <- to_xml(path)
names(yaml_xml_list)
library("magrittr")
# transform level 3 headers into level 1 headers
body <- yaml_xml_list$body
body %>%
  xml2::xml_find_all(xpath = './/d1:heading',
                     xml2::xml_ns(.)) %>%
  .[xml2::xml_attr(., "level") == "3"] -> headers3

xml2::xml_set_attr(headers3, "level", 1)

yaml_xml_list$body <- body

to_md(yaml_xml_list, "newmd.md")
file.edit("newmd.md")
```

## Details/notes

* At the moment the XLST stylesheet used to cast XML back to Markdown doesn't support extensions (striked through text, tables) so when converting the Markdown files to XML the package uses `extensions=FALSE`.


