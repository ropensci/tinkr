Submitting Author: Maëlle Salmon (@maelle)  
Other Package Authors: Zhian N. Kamvar (@zkamvar)
Repository:  <!--repourl-->https://github.com/ropensci/tinkr/<!--end-repourl-->
Submission type: <!--submission-type-->Pre-submission<!--end-submission-type-->

---

-   Paste the full DESCRIPTION file inside a code block below:

```
Package: tinkr
Title: Casts (R)Markdown Files to XML and Back Again
Version: 0.0.0.9000
Authors@R: 
    c(person(given = "Maëlle",
             family = "Salmon",
             role = c("aut", "cre"),
             email = "msmaellesalmon@gmail.com",
             comment = c(ORCID = "0000-0002-2815-0399")),
      person(given = "Zhian N.",
             family = "Kamvar",
             role = "aut",
             email = "zkamvar@gmail.com",
             comment = c(ORCID = "0000-0003-1458-7108")),
      person(given = "Jeroen",
             family = "Ooms",
             role = "aut"),
      person(given = "Nick",
             family = "Wellnhofer",
             role = "cph",
             comment = "Nick Wellnhofer wrote the XSLT stylesheet."),
      person(given = "rOpenSci",
             role = "fnd",
             comment = "https://ropensci.org/"),
      person(given = "Peter",
             family = "Daengeli",
             role = "ctb"))
Description: Casts (R)Markdown files to XML and back to allow their
    editing via XPath.
License: GPL-3
URL: https://docs.ropensci.org/tinkr/, https://github.com/ropensci/tinkr
BugReports: https://github.com/ropensci/tinkr/issues
Imports: 
    commonmark (>= 1.6),
    fs,
    glue,
    knitr,
    magrittr,
    purrr,
    R6,
    stringr,
    xml2,
    xslt,
    yaml
Suggests: 
    covr,
    testthat (>= 3.0.0),
    withr
Config/testthat/edition: 3
Encoding: UTF-8
LazyData: true
Roxygen: list(markdown = TRUE)
RoxygenNote: 7.1.1.9001
```


## Scope 

- Please indicate which category or categories from our [package fit policies](https://ropensci.github.io/dev_guide/policies.html#package-categories) this package falls under: (Please check an appropriate box below.:

	- [ ] data retrieval
	- [ ] data extraction
	- [ ] database access
	- [x] data munging
	- [ ] data deposition
	- [ ] workflow automation
	- [ ] version control
	- [ ] citation management and bibliometrics
	- [ ] scientific software wrappers
	- [ ] database software bindings
	- [ ] geospatial data
	- [ ] text analysis
	

- Explain how and why the package falls under these categories (briefly, 1-2 sentences).  Please note any areas you are unsure of:

With tinkr one can extract structured data out of R Markdown or Markdown files with XPath, instead of regular expressions.
A further application, that is however not in scope as it might be viewed as "general tools for literate programming", is _modifying_ such files, e.g. adding a code chunk to a bunch of R Markdown files at once.

-   Who is the target audience and what are scientific applications of this package?  

The target audience would be any scientist using R Markdown or Markdown files as data source. Salient examples of applications are extracting/modifying links from markdown documents (e.g. for CRAN checks), analyzing patterns of markdown features in documents across repositories (e.g. https://carpentries.github.io/pegboard/articles/swc-survey.html#summary-of-solutions-1), and transformation of markdown documents in a systematic way (e.g. https://carpentries.github.io/pegboard/#manipulation).

-   Are there other R packages that accomplish the same thing? If so, how does yours differ or meet [our criteria for best-in-category](https://ropensci.github.io/dev_guide/policies.html#overlap)?

The [parsermd](https://rundel.github.io/parsermd/articles/parsermd.html) package by Colin Rundel aims at "extracting the content of an R Markdown file to allow for programmatic interactions with the document’s contents (i.e. code chunks and markdown text)".
However, parsermd is focused on R Markdown documents, and as written in its docs "The goal is to capture the fundamental structure of the document and as such we do not attempt to parse every detail of the Rmd" whereas tinkr parses everything into XML according to the commonmark style.

-   (If applicable) Does your package comply with our [guidance around _Ethics, Data Privacy and Human Subjects Research_](https://devguide.ropensci.org/policies.html#ethics-data-privacy-and-human-subjects-research)?

Not applicable.

-  Any other questions or issues we should be aware of?:

No.
