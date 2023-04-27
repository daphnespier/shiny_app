---
title: Short Paper
author:
  - name: Alice Anonymous
    email: alice@example.com
    affiliation: Some Institute of Technology
    correspondingauthor: true
    footnote: 1
  - name: Bob Security
    email: bob@example.com
    affiliation: Another University
  - name: Cat Memes
    email: cat@example.com
    affiliation: Another University
    footnote: 2
  - name: Derek Zoolander
    email: derek@example.com
    affiliation: Some Institute of Technology
    footnote: 2
address:
  - code: Some Institute of Technology
    organization: Big Wig University
    addressline: 1 main street
    city: Gotham
    state: State
    postcode: 123456
    country: United States
  - code: Another University
    organization: Department
    addressline: A street 29
    postcode: 2054 NX
    city: Manchester,
    country: The Netherlands
footnote:
  - code: 1
    text: "This is the first author footnote."
  - code: 2
    text: "Another author footnote."
abstract: |
  This is the abstract.

  It consists of two paragraphs.
keywords: 
  - keyword1
  - keyword2
journal: "An awesome journal"
date: "2023-04-27"
classoption: preprint, 3p, authoryear
bibliography: mybibfile.bib
linenumbers: false
numbersections: true
# Use a CSL with `citation_package = "default"`
# csl: https://www.zotero.org/styles/elsevier-harvard
output: 
  rticles::elsevier_article:
    keep_tex: true
    citation_package: natbib
---

Please make sure that your manuscript follows the guidelines in the 
Guide for Authors of the relevant journal. It is not necessary to 
typeset your manuscript in exactly the same way as an article, 
unless you are submitting to a camera-ready copy (CRC) journal.

For detailed instructions regarding the elsevier article class, see   <https://www.elsevier.com/authors/policies-and-guidelines/latex-instructions>

# Bibliography styles

Here are two sample references: @Feynman1963118 [@Dirac1953888].

By default, natbib will be used with the `authoryear` style, set in `classoption` variable in YAML. 
You can sets extra options with `natbiboptions` variable in YAML header. Example 
```yaml
natbiboptions: longnamesfirst,angle,semicolon
```

There are various more specific bibliography styles available at
<https://support.stmdocs.in/wiki/index.php?title=Model-wise_bibliographic_style_files>. 
To use one of these, add it in the header using, for example, `biblio-style: model1-num-names`.

## Using CSL 

If `citation_package` is set to `default` in `elsevier_article()`, then pandoc is used for citations instead of `natbib`. In this case, the `csl` option is used to format the references. Alternative `csl` files are available from <https://www.zotero.org/styles?q=elsevier>. These can be downloaded
and stored locally, or the url can be used as in the example header.

# Equations

Here is an equation:
$$ 
  f_{X}(x) = \left(\frac{\alpha}{\beta}\right)
  \left(\frac{x}{\beta}\right)^{\alpha-1}
  e^{-\left(\frac{x}{\beta}\right)^{\alpha}}; 
  \alpha,\beta,x > 0 .
$$

Here is another:
\begin{align}
  a^2+b^2=c^2.
\end{align}

Inline equations: $\sum_{i = 2}^\infty\{\alpha_i^\beta\}$

# Figures and tables

Figure \ref{fig2} is generated using an R chunk.

\begin{figure}

{\centering \includegraphics[width=0.5\linewidth]{Untitled_files/figure-latex/fig2-1} 

}

\caption{\label{fig2}A meaningless scatterplot.}\label{fig:fig2}
\end{figure}

# Tables coming from R

Tables can also be generated using R chunks, as shown in Table \ref{tab1} for example.


```r
knitr::kable(head(mtcars)[,1:4], 
    caption = "\\label{tab1}Caption centered above table"
)
```



Table: \label{tab1}Caption centered above table

|                  |  mpg| cyl| disp|  hp|
|:-----------------|----:|---:|----:|---:|
|Mazda RX4         | 21.0|   6|  160| 110|
|Mazda RX4 Wag     | 21.0|   6|  160| 110|
|Datsun 710        | 22.8|   4|  108|  93|
|Hornet 4 Drive    | 21.4|   6|  258| 110|
|Hornet Sportabout | 18.7|   8|  360| 175|
|Valiant           | 18.1|   6|  225| 105|

# References {-}

