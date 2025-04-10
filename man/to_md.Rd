% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/to_md.R
\name{to_md}
\alias{to_md}
\alias{to_md_vec}
\title{Write front-matter (YAML, TOML or JSON) and XML back to disk as (R)Markdown}
\usage{
to_md(
  frontmatter_xml_list,
  path = NULL,
  stylesheet_path = stylesheet(),
  yaml_xml_list = deprecated()
)

to_md_vec(nodelist, stylesheet_path = stylesheet())
}
\arguments{
\item{frontmatter_xml_list}{result from a call to \code{\link[=to_xml]{to_xml()}} and editing.}

\item{path}{path of the new file. Defaults to \code{NULL}, which will not write
any file, but will still produce the conversion and pass the output as
a character vector.}

\item{stylesheet_path}{path to the XSL stylesheet}

\item{yaml_xml_list}{\ifelse{html}{\href{https://lifecycle.r-lib.org/articles/stages.html#deprecated}{\figure{lifecycle-deprecated.svg}{options: alt='[Deprecated]'}}}{\strong{[Deprecated]}} Use \code{frontmatter_xml_list()}.}

\item{nodelist}{an object of \code{xml_nodelist} or \code{xml_node}}
}
\value{
\itemize{
\item \code{to_md()}: \verb{\[character\]} the converted document, invisibly as a character vector containing two elements: the frontmatter list and the markdown body.
\item \code{to_md_vec()}: \verb{\[character\]} the markdown representation of each node.
}
}
\description{
Write front-matter (YAML, TOML or JSON) and XML back to disk as (R)Markdown
}
\details{
The stylesheet you use will decide whether lists
are built using "*" or "-" for instance. If you're keen to
keep your own Markdown style when using \code{\link[=to_md]{to_md()}} after
\code{\link[=to_xml]{to_xml()}}, you can tweak the XSL stylesheet a bit and provide
the path to your XSL stylesheet as argument.
}
\examples{
path <- system.file("extdata", "example1.md", package = "tinkr")
frontmatter_xml_list <- to_xml(path)
names(frontmatter_xml_list)
# extract the level 3 headers from the body
headers3 <- xml2::xml_find_all(
  frontmatter_xml_list$body,
  xpath = './/md:heading[@level="3"]',
  ns = md_ns()
)
# show the headers
print(h3 <- to_md_vec(headers3))
# transform level 3 headers into level 1 headers
# NOTE: these nodes are still associated with the document and this is done
# in place.
xml2::xml_set_attr(headers3, "level", 1)
# preview the new headers
print(h1 <- to_md_vec(headers3))
# save back and have a look
newmd <- tempfile("newmd", fileext = ".md")
res <- to_md(frontmatter_xml_list, newmd)
# show that it works
regmatches(res[[2]], gregexpr(h1[1], res[[2]], fixed = TRUE))
# file.edit("newmd.md")
file.remove(newmd)

}
