# yarn show, head, and tail methods work

    Code
      show_user(res <- y1$show(), TRUE)
    Output
      ---
      title: "Untitled"
      author: "M. Salmon"
      date: "September 6, 2018"
      output: html_document
      ---
      
      ```{r setup, include=FALSE, eval=TRUE}
      knitr::opts_chunk$set(echo = TRUE)
      ```
      
      ## R Markdown
      
      This is an ~~R Markdown document~~. Markdown is a simple formatting syntax for authoring HTML, PDF, and MS Word documents. For more details on using R Markdown see [http://rmarkdown.rstudio.com](http://rmarkdown.rstudio.com).
      
      When you click the **Knit** button a document will be generated that includes both content as well as the output of any embedded R code chunks within the document. You can embed an R code chunk like this:
      
      ```{r, eval=TRUE, echo=TRUE}
      summary(cars)
      ```
      
      ## Including Plots
      
      You can also embed plots, for example:
      
      ```{python, fig.cap="pretty plot", echo=-c(1, 2), eval=TRUE}
      plot(pressure)
      ```
      
      ```{python}
      plot(pressure)
      ```
      
      Non-RMarkdown blocks are also considered
      
      ```bash
      echo "this is an unevaluted bash block"
      ```
      
      ```
      This is an ambiguous code block
      ```
      
      Note that the `echo = FALSE` parameter was added to the code chunk to prevent printing of the R code that generated the plot.
      
      | scientific\_name            | common\_name         | n   | 
      | :------------------------- | :------------------ | --: |
      | Corvus corone              | Carrion Crow        | 288 | 
      | Turdus merula              | Eurasian Blackbird  | 285 | 
      | Anas platyrhynchos         | Mallard             | 273 | 
      | Fulica atra                | Eurasian Coot       | 268 | 
      | Parus major                | Great Tit           | 266 | 
      | Podiceps cristatus         | Great Crested Grebe | 254 | 
      | Ardea cinerea              | Gray Heron          | 236 | 
      | Cygnus olor                | Mute Swan           | 234 | 
      | Cyanistes caeruleus        | Eurasian Blue Tit   | 233 | 
      | Chroicocephalus ridibundus | Black-headed Gull   | 223 | 
      
      blabla
      

---

    Code
      show_user(res <- y1$head(10), TRUE)
    Output
      ---
      title: "Untitled"
      author: "M. Salmon"
      date: "September 6, 2018"
      output: html_document
      ---
      
      ```{r setup, include=FALSE, eval=TRUE}
      knitr::opts_chunk$set(echo = TRUE)
      ```

---

    Code
      show_user(res <- y1$tail(11), TRUE)
    Output
      | Anas platyrhynchos         | Mallard             | 273 | 
      | Fulica atra                | Eurasian Coot       | 268 | 
      | Parus major                | Great Tit           | 266 | 
      | Podiceps cristatus         | Great Crested Grebe | 254 | 
      | Ardea cinerea              | Gray Heron          | 236 | 
      | Cygnus olor                | Mute Swan           | 234 | 
      | Cyanistes caeruleus        | Eurasian Blue Tit   | 233 | 
      | Chroicocephalus ridibundus | Black-headed Gull   | 223 | 
      
      blabla
      

