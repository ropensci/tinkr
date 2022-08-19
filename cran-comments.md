## Response to review

There were two comments from the previous submission:

> You have examples for unexported functions. Please either omit these examples or export these functions.

This was raised from `man/find_between.Rd` and is a false alarm (as I indicated in an earlier submission). If you look closely, the code for this example (man/find_between.Rd lines 34-46) [1] is creating an example of a pandoc fenced Div [2], which always starts and ends with at least three colons.

> Please ensure that your functions do not write by default or in your examples/vignettes/tests in the user's home filespace (including the package directory and getwd()). This is not allowed by CRAN policies. Please omit any default path in writing functions. In your examples/vignettes/tests you can write to tempdir().

I can not find the place in the tests or vignettes where I am writing to the user workspace. In all the instances I find code that writes to the workspace, it is writing to a temporary file or a file in a temporary directory that is cleaned up at the end of the example. Moreover, in the code itself, the default argument of `path` for the write functions [3, 4] are all `NULL`, which either return the output to a character vector or error (depending on context). 

All the best,
Zhian

[1]: https://github.com/ropensci/tinkr/blob/9aeeaf9cdd230d2561491d9c8a383113a05313ca/man/find_between.Rd#L34-L46
[2]: https://pandoc.org/MANUAL.html#divs-and-spans
[3]: https://github.com/ropensci/tinkr/blob/5eb23b46864df26d5cf150600f796d3f3609b11c/R/class-yarn.R#L89-L95
[4]: https://github.com/ropensci/tinkr/blob/5eb23b46864df26d5cf150600f796d3f3609b11c/R/to_md.R#L53-L57

## R CMD check results

0 errors | 0 warnings | 1 note

* This is a resubmission of a new release.
