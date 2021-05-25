---
title: this tests links
---


## These are some links that are valid in basic markdown

This is some text [that contains links][this fun link1] which 
[can be `inline`](https://example.com/2) or [can be spread across multiple lines
because the link text is JUST TOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO
LONG, y'all](https://example.com/3).

Mainly, we want to see if [link text
by reference][link4] and if links [can be referenced multiple times][this fun link1]

This should also [include non-reference links](https://example.com/5)

If you write \[some link text\]\[link2\], that will appear as [some link text][link2]

[this fun link1]: https://example.com/1
[link2]: https://example.com/2 "link with title!"
[link3]: https://example.com/3
[link4]: https://example.com/4

## This is some extended markdown content {#extended .callout}

This should also include references that use [standalone] links and 
footnotes should not be properly parsed and will be considered 'asis' nodes,
at least that's what I *believe*[^footy]. Maybe this might not pan out [^but who
knows? footnotes are **WEIRD**, man].

<!-- links go here! -->

[standalone]: https://example.com/standalone
[^footy]: this is a footnote that
  should be preserved