## Response to review

> Please do not start the description with "This package", package name, title or similar.
This was a false positive. My package did not have this in the description. 

> "Using foo:::f instead of foo::f allows access to unexported objects. This is generally not recommended, as the semantics of unexported objects may be changed by the package author in routine maintenance." Please omit one colon.

Fixed. This was present in the documentation for unexported functions. These functions are internal and not displayed on the default help, but I wanted to document them for posterity so I have removed the triple colons from the examples and have added a catch to make sure these functions are only run in a development environment.

Additionally, I have examples that use pandoc's fenced-div syntax, which would give a false-positive result if the check for unexported functions is a search for ':::'. These examples are valid. 

> You have examples for unexported functions. -> man/yarn.Rd Please either omit these examples or export these functions.

Correct issue, wrong file. I have addresed the issue above.

> Please choose a more meaningful vignette title and not "Untitled".

This was a false positive. My vignette is not "untitled"

> Please ensure that your functions do not write by default or in your examples/vignettes/tests in the user's home filespace (including the package directory and getwd()). This is not allowed by CRAN policies. Please omit any default path in writing functions. In your examples/vignettes/tests you can write to tempdir().

Fixed. 


## R CMD check results

0 errors | 0 warnings | 1 note

* This is a resubmission of a new release.
