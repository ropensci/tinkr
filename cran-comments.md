## Response to review

> > Please do not start the description with "This package", package name, title or similar.
> 
> Your description starts with: "Casts '(R)Markdown' files to 'XML' and back to..." Which is essentially your title.

Fixed.

> > Please choose a more meaningful vignette title and not "Untitled".
> 
> While you don't have an untitled vignette, there are a lot of .Rmd files in your /inst and /test directories which seem to be unnecessary. Please check if you really need them all or if some of them can be omitted.

I have removed the unneeded Rmd files in the `inst/` directories. The Rmd files that do exist are there for demonstrative purposes. I have additionally moved the XML stylesheets to a new semantic path called `stylesheets/` 

The Rmd files in the test directories are necessary as they are used to test the functionality of the package.

## R CMD check results

0 errors | 0 warnings | 1 note

* This is a resubmission of a new release.
