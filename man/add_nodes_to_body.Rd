% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/add_md.R
\name{add_nodes_to_body}
\alias{add_nodes_to_body}
\title{Add children to a specific location in the full document.}
\usage{
add_nodes_to_body(body, nodes, where = 0L)
}
\arguments{
\item{body}{an XML object generated via tinkr}

\item{nodes}{an object of \code{xml_node} or list of nodes}

\item{where}{the position in the markdown document to insert the new markdown}
}
\value{
a copy of the XML object with nodes inserted
}
\description{
Add children to a specific location in the full document.
}
\keyword{internal}
