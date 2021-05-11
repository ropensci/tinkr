# mal-formed inline math throws an informative error

    Inline math delimiters are not balanced.
    
    HINT: If you are writing BASIC code, make sure you wrap variable
          names and code in backtics like so: `INKEY$`. 
    
    Below are the pairs that were found:
               start...end
               -----...---
     Give you $2 to ... me what INKEY$ means.
     Give you $2 to ... 2$ verbally.
    We write $2 but ...

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
      
      Below is an example from [https://github.com/ropensci/tinkr/issues/38](https://github.com/ropensci/tinkr/issues/38)
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

