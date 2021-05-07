---
title: An example with math elements
---

This is cheap, it only costs 10$!

This example has $\LaTeX$ elements embedded in the
text. It is intended to demonstrate that m $\alpha_\tau$ h
mode can work with tinkr. $y = 
mx + b$

 - [ ] This is an empty checkbox
 - [x] This is a checked checkbox
 - [This is a link](https://ropensci.org)
 - \[this is an example\]

Here is an example from the mathjax website:

When $a \ne 0$, there are two solutions to \(ax^2 + bx + c = 0\) and they are
\[x = {-b \pm \sqrt{b^2-4ac} \over 2a}.\]

```latex
$$
\begin{align} % This mode aligns the equations to the '&=' signs
\begin{split} % This mode groups the equations into one.
\bar{r}_d &= \frac{\sum\sum{cov_{j,k}}}{
                   \sum\sum{\sqrt{var_{j} \cdot var_{k}}}} \\
          &= \frac{V_O - V_E}{2\sum\sum{\sqrt{var_{j} \cdot var_{k}}}}
\end{split}
\end{align}
$$
```

$$
\begin{align} % This mode aligns the equations to the '&=' signs
\begin{split} % This mode groups the equations into one.
\bar{r}_d &= \frac{\sum\sum{cov_{j,k}}}{
                   \sum\sum{\sqrt{var_{j} \cdot var_{k}}}} \\
          &= \frac{V_O - V_E}{2\sum\sum{\sqrt{var_{j} \cdot var_{k}}}}
\end{split}
\end{align}
$$

When $a \ne 0$, there are two solutions to $ax^2 + bx + c = 0$ and they are

```latex
$$
x = {-b \pm \sqrt{b^2-4ac} \over 2a}
$$
```


$$
x = {-b \pm \sqrt{b^2-4ac} \over 2a}
$$

Below is an example from https://github.com/ropensci/tinkr/issues/38
$\frac{\sum _{i=N-n}^{N}Q_i} {\sum_{j=N-n}^{N}{(\frac{C_j+C_{j-1}}2)}}$

```latex
$$
Q_{N(norm)}=\frac{C_N +C_{N-1}}2\times 
\frac{\sum _{i=N-n}^{N}Q_i} {\sum_{j=N-n}^{N}{(\frac{C_j+C_{j-1}}2)}}
$$
```

$$
Q_{N(norm)}=\frac{C_N +C_{N-1}}2\times 
\frac{\sum _{i=N-n}^{N}Q_i} {\sum_{j=N-n}^{N}{(\frac{C_j+C_{j-1}}2)}}
$$
