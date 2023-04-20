if(!require(pacman)) install.packages("pacman")
pacman::p_load(devtools, rvest, httr, XML, dplyr, textreuse, rslp, tm, proxy, factoextra, text2vec, ngram, ggplot2, stringr, stringi, cluster, dendextend, wordcloud, wordcloud2, rmarkdown, knitr, gridExtra, kableExtra, textreuse, syuzhet, RColorBrewer, tidyverse, reshape2, lexiconPT, textdata, tidyr, scales, broom, purrr, widyr,igraph, ggraph, SnowballC, RWekajars, dplyr, tidytext,  topicmodels, quanteda, bookdown, DT, sentimentBR)

library(rsconnect)
install.packages("renv")
renv::init()
renv::status()


renv::dependencies()



rsconnect::deployApp(appName = "shiny_text_analysis", appDir = "/Users/daphne/IC/Shiny/shiny_text")
