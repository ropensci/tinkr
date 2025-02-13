# (#121) money dollars mixed with broken math don't break

    Code
      show_user(dollar_math$show(), force = TRUE)
    Output
      ---
      title: "Dollar as currency mixed with math"
      ---
      
      ## currency and ambiguous math
      
      I've got $5.45 and $A = `r runif(1)`$
      
      ## currency and math on the same line
      
      Math that starts on the dollar: I've got $5.45 and $A = \pi r^2$.
      
      Math that starts at the equation: I've got $5.45 *and* $A = \pi r^2$.
      
      ## broken math trailing currency
      
      The area of a circle is $A =
      \pi r^2$.
      
      ## Currency preceding inline broken math (due to emph)
      
      It's 5:45 and I've got $5.45.
      
      Below is an example from <https://github.com/ropensci/tinkr/issues/38>
      $\frac{\sum _{i=N-n}^{N}Q_i} {\sum_{j=N-n}^{N}{(\frac{C_j+C_{j-1}}2)}}$
      
      The area of circle is $A _i = \pi r_ i^2$.
      
      $P =
      NP$
      
      ## Currency with inline broken math (due to emph)
      
      The following line is considered to *all* be math:
      $199 and $\frac{\sum _{i=N-n}^{N}Q_i} {\sum_{j=N-n}^{N}{(\frac{C_j+C_{j-1}}2)}}$.
      
      The following line has math starting at the correct place:
      $199 *and* $\frac{\sum _{i=N-n}^{N}Q_i} {\sum_{j=N-n}^{N}{(\frac{C_j+C_{j-1}}2)}}$.
      
      The following line correctly protects math because of the link
      There is a $1 bet on [wikipedia](https://wikipedia.org) that the area of circle is $A _i = \pi r_ i^2$.
      
      $99
      $9
      
      $P \ne
      NP$
      
      ## Trailing currency does not affect the computation.
      
      Dang a whopper and a 40 cost $10 now, but I've only got $5.45.
      

# postfix dollars throws an informative error

    Inline math delimiters are not balanced.
    
    HINT: If you are writing BASIC code, make sure you wrap variable
          names and code in backtics like so: `INKEY$`.
    
    Below are the pairs that were found:
    start...end
    -----...---
         ...INKEY$

# block math can be protected

    Code
      show_user(m$protect_math()$tail(48), force = TRUE)
    Output
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
      \sum\sum{\sqrt{var_{j} \cdot var_{k}}}} \
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
      
      Below is an example from <https://github.com/ropensci/tinkr/issues/38>
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
      

# tick boxes are protected by default

    Code
      show_user(m$head(15), force = TRUE)
    Output
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

