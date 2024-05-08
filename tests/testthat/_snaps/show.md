# show_list() will isolate elements

    Code
      show_user(show_list(links), force = TRUE)
    Output
      
      
      [second post of the series where we obtained data from
      eBird](https://ropensci.org/blog/2018/08/21/birds-radolfzell/)
      
      [the fourth post of the
      series](https://ropensci.org/blog/2018/09/04/birds-taxo-traits/)
      
      [previous post
      of the series](https://ropensci.org/blog/2018/08/21/birds-radolfzell/)
      
      [(`glue::glue_collapse(species, sep = ", ", last = " and ")`)](https://twitter.com/LucyStats/status/1031938964796657665?s=19)
      
      [`taxize`](https://github.com/ropensci/taxize)
      
      [`spocc`](https://github.com/ropensci/spocc)
      
      [`fulltext`](https://github.com/ropensci/fulltext)
      
      ["Investigating the impact of media on demand for wildlife: A case
      study of Harry Potter and the UK trade in
      owls"](http://journals.plos.org/plosone/article?id=10.1371/journal.pone.0182368)
      
      [`cites`](https://github.com/ecohealthalliance/cites/)
      
      [`rcites`](https://ibartomeus.github.io/rcites/)
      
      [`wordcloud`
      package](https://cran.r-project.org/web/packages/wordcloud/index.html)
      
      [`wordcloud2`
      package](https://github.com/Lchiffon/wordcloud2)
      
      [from
      Phylopic](http://phylopic.org/image/6209c9be-060e-4d7f-bc74-a75f3ccf4629/)
      
      [DataONE](https://www.dataone.org/)
      
      [searching
      DataONE
      vignette](https://github.com/DataONEorg/rdataone/blob/master/vignettes/searching-dataone.Rmd)
      
      [download data
      vignette](https://github.com/DataONEorg/rdataone/blob/master/vignettes/download-data.Rmd)
      
      [`europepmc`](https://github.com/ropensci/europepmc)
      
      [`jstor`](https://github.com/ropensci/jstor)
      
      [`suppdata`](https://github.com/ropensci/suppdata)
      
      [much
      more](https://ropensci.org/packages/)
      
      [`dataone`
      package](https://github.com/DataONEorg/rdataone)
      
      [`rfigshare`](https://github.com/ropensci/rfigshare)
      
      [Figshare](https://figshare.com/)
      
      [`EML` package](https://github.com/ropensci/EML)
      
      [unconf
      `dataspice` project](https://github.com/ropenscilabs/dataspice)
      
      [here](https://ropensci.org/packages/)
      
      [How to identify spots for birding using open geographical
      data](https://ropensci.org/blog/2018/08/14/where-to-bird/)
      
      [How to obtain bird occurrence data in
      R](https://ropensci.org/blog/2018/08/21/birds-radolfzell/)
      
      [How to extract text from old natural history
      drawings](https://ropensci.org/blog/2018/08/28/birds-ocr/)
      
      [How to complement an occurrence dataset with taxonomy and trait
      information](https://ropensci.org/blog/2018/09/04/birds-taxo-traits/)
      
      [our friendly discussion
      forum](https://discuss.ropensci.org/c/usecases)
      

---

    Code
      show_user(show_list(code[1:10]), force = TRUE)
    Output
      
      
      `glue::glue_collapse(species, sep = ", ", last = " and ")`
      
      `taxize`
      
      `spocc`
      
      `fulltext`
      
      `fulltext`
      
      `tidytext`
      
      `dplyr::bind_rows`
      
      `fulltext`
      
      `cites`
      
      `rcites`
      

---

    Code
      show_user(show_list(blocks[1:2]), force = TRUE)
    Output
      
      
      ```r
      # polygon for filtering
      landkreis_konstanz <- osmdata::getbb("Landkreis Konstanz",
                                   format_out = "sf_polygon")
      crs <- sf::st_crs(landkreis_konstanz)
      
      # get and filter data
      f_out_ebd <- "ebird/ebd_lk_konstanz.txt"
      
      library("magrittr")
      
      ebd <- auk::read_ebd(f_out_ebd) %>%
        sf::st_as_sf(coords = c("longitude", "latitude"),
                      crs = crs)
      
      in_indices <- sf::st_within(ebd, landkreis_konstanz)
      
      ebd <- dplyr::filter(ebd, lengths(in_indices) > 0)
      
      ebd <- as.data.frame(ebd)
      
      ebd <- dplyr::filter(ebd, approved, lubridate::year(observation_date) > 2010)
      ```
      
      
      ```r
      species <- ebd %>%
        dplyr::count(common_name, sort = TRUE) %>%
        head(n = 50) %>%
        dplyr::pull(common_name)
      ```
      
      

# show context will provide context for the elements

    Code
      show_user(show_bare(items), force = TRUE)
    Output
      
      
      - study the results of such queries (e.g. meta studies of number of,
        say, versions by datasets)
      
      - or find data to integrate to a new study. If you want to *download*
        data from DataONE, refer to the [download data
        vignette](https://github.com/DataONEorg/rdataone/blob/master/vignettes/download-data.Rmd).
      
      - [How to identify spots for birding using open geographical
        data](https://ropensci.org/blog/2018/08/14/where-to-bird/).
        Featuring `opencage` for geocoding, `bbox` for bounding box
        creation, `osmdata` for OpenStreetMap's Overpass API querying,
        `osmplotr` for map drawing using OpenStreetMap's data.
      
      - [How to obtain bird occurrence data in
        R](https://ropensci.org/blog/2018/08/21/birds-radolfzell/).
        Featuring `rebird` for interaction with the eBird's API, and `auk`
        for munging of the whole eBird dataset.
      
      - [How to extract text from old natural history
        drawings](https://ropensci.org/blog/2018/08/28/birds-ocr/).
        Featuring `magick` for image manipulation, `tesseract` for Optical
        Character Recognition, `cld2` and `cld3` for language detection, and
        `taxize::gnr_resolve` for taxonomic name resolution.
      
      - [How to complement an occurrence dataset with taxonomy and trait
        information](https://ropensci.org/blog/2018/09/04/birds-taxo-traits/).
        Featuring `taxize`, taxonomic toolbelt for R, and `traits`,
        providing access to species traits data.
      
      - How to query the scientific literature and scientific open data
        repositories. This is the post you've just read!
      

---

    Code
      show_user(show_bare(links), force = TRUE)
    Output
      
      
      [second post of the series where we obtained data from
      eBird](https://ropensci.org/blog/2018/08/21/birds-radolfzell/)[the fourth post of the
      series](https://ropensci.org/blog/2018/09/04/birds-taxo-traits/)
      
      [previous post
      of the series](https://ropensci.org/blog/2018/08/21/birds-radolfzell/)
      
      [(`glue::glue_collapse(species, sep = ", ", last = " and ")`)](https://twitter.com/LucyStats/status/1031938964796657665?s=19)
      
      [`taxize`](https://github.com/ropensci/taxize)[`spocc`](https://github.com/ropensci/spocc)[`fulltext`](https://github.com/ropensci/fulltext)
      
      ["Investigating the impact of media on demand for wildlife: A case
      study of Harry Potter and the UK trade in
      owls"](http://journals.plos.org/plosone/article?id=10.1371/journal.pone.0182368)[`cites`](https://github.com/ecohealthalliance/cites/)[`rcites`](https://ibartomeus.github.io/rcites/)
      
      [`wordcloud`
      package](https://cran.r-project.org/web/packages/wordcloud/index.html)
      
      [`wordcloud2`
      package](https://github.com/Lchiffon/wordcloud2)[from
      Phylopic](http://phylopic.org/image/6209c9be-060e-4d7f-bc74-a75f3ccf4629/)
      
      [DataONE](https://www.dataone.org/)
      
      [searching
      DataONE
      vignette](https://github.com/DataONEorg/rdataone/blob/master/vignettes/searching-dataone.Rmd)
      
      - [download data
        vignette](https://github.com/DataONEorg/rdataone/blob/master/vignettes/download-data.Rmd)
      
      [`europepmc`](https://github.com/ropensci/europepmc)[`jstor`](https://github.com/ropensci/jstor)[`suppdata`](https://github.com/ropensci/suppdata)[much
      more](https://ropensci.org/packages/)
      
      [`dataone`
      package](https://github.com/DataONEorg/rdataone)[`rfigshare`](https://github.com/ropensci/rfigshare)[Figshare](https://figshare.com/)[`EML` package](https://github.com/ropensci/EML)[unconf
      `dataspice` project](https://github.com/ropenscilabs/dataspice)
      
      [here](https://ropensci.org/packages/)
      
      - [How to identify spots for birding using open geographical
        data](https://ropensci.org/blog/2018/08/14/where-to-bird/)
      
      - [How to obtain bird occurrence data in
        R](https://ropensci.org/blog/2018/08/21/birds-radolfzell/)
      
      - [How to extract text from old natural history
        drawings](https://ropensci.org/blog/2018/08/28/birds-ocr/)
      
      - [How to complement an occurrence dataset with taxonomy and trait
        information](https://ropensci.org/blog/2018/09/04/birds-taxo-traits/)
      
      [our friendly discussion
      forum](https://discuss.ropensci.org/c/usecases)
      

---

    Code
      show_user(show_context(links[20:31]), force = TRUE)
    Output
      
      
      [...] [much
      more](https://ropensci.org/packages/) [...]
      
      [...] [`dataone`
      package](https://github.com/DataONEorg/rdataone) [...][...] [`rfigshare`](https://github.com/ropensci/rfigshare) [...][...] [Figshare](https://figshare.com/) [...][...] [`EML` package](https://github.com/ropensci/EML) [...][...] [unconf
      `dataspice` project](https://github.com/ropenscilabs/dataspice) [...]
      
      [...] [here](https://ropensci.org/packages/) [...]
      
      - [How to identify spots for birding using open geographical
        data](https://ropensci.org/blog/2018/08/14/where-to-bird/) [...]
      
      - [How to obtain bird occurrence data in
        R](https://ropensci.org/blog/2018/08/21/birds-radolfzell/) [...]
      
      - [How to extract text from old natural history
        drawings](https://ropensci.org/blog/2018/08/28/birds-ocr/) [...]
      
      - [How to complement an occurrence dataset with taxonomy and trait
        information](https://ropensci.org/blog/2018/09/04/birds-taxo-traits/) [...]
      
      [...] [our friendly discussion
      forum](https://discuss.ropensci.org/c/usecases) [...]
      

---

    Code
      show_user(show_context(code[1:10]), force = TRUE)
    Output
      
      
      [[...] `glue::glue_collapse(species, sep = ", ", last = " and ")` [...]](https://twitter.com/LucyStats/status/1031938964796657665?s=19)
      
      [`taxize`](https://github.com/ropensci/taxize)[`spocc`](https://github.com/ropensci/spocc)[`fulltext`](https://github.com/ropensci/fulltext)
      
      [...] `fulltext` [...][...] `tidytext` [...]
      
      [...] `dplyr::bind_rows` [...][...] `fulltext` [...]
      
      [`cites`](https://github.com/ecohealthalliance/cites/)[`rcites`](https://ibartomeus.github.io/rcites/)
      

