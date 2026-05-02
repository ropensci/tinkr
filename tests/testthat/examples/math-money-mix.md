---
title: "Dollar as currency mixed with math"
---


## currency and ambiguous math

I've got $5.45 and $A = `r runif(1)`$

## currency and math on the same line

Math that starts on the dollar: I've got $5.45 and $A = \pi r^2$.

Math that starts at the equation: I've got $5.45 _and_ $A = \pi r^2$.

## broken math trailing currency

The area of a circle is $A =
\pi r^2$.

## Currency preceding inline broken math (due to emph)

It's 5:45 and I've got $5.45.

Below is an example from https://github.com/ropensci/tinkr/issues/38
$\frac{\sum _{i=N-n}^{N}Q_i} {\sum_{j=N-n}^{N}{(\frac{C_j+C_{j-1}}2)}}$

The area of circle is $A _i = \pi r_ i^2$.

$P =
NP$

## Currency with inline broken math (due to emph)


The following line is considered to _all_ be math:
$199 and $\frac{\sum _{i=N-n}^{N}Q_i} {\sum_{j=N-n}^{N}{(\frac{C_j+C_{j-1}}2)}}$.

The following line has math starting at the correct place:
$199 _and_ $\frac{\sum _{i=N-n}^{N}Q_i} {\sum_{j=N-n}^{N}{(\frac{C_j+C_{j-1}}2)}}$.

The following line correctly protects math because of the link
There is a $1 bet on [wikipedia](https://wikipedia.org) that the area of circle is $A _i = \pi r_ i^2$.

$99
$9

$P \ne
NP$

## Trailing currency does not affect the computation.

Dang a whopper and a 40 cost $10 now, but I've only got $5.45.
