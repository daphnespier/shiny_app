
getwd()
source("./00_Scripts/funcoes.r")
data<- read.csv2("./01_Dados/00_Comentariosjalapao.csv", encoding = 'UTF-8')

data<-data[,2]

#packrat::install_local("Rsteam")

if(!require(pacman)) install.packages("pacman")
pacman::p_load(devtools, rvest, httr, XML, dplyr, textreuse, rslp, tm, proxy, factoextra, text2vec, ngram, ggplot2, stringr, stringi, cluster, dendextend, wordcloud, wordcloud2, rmarkdown, knitr, gridExtra, kableExtra, textreuse, syuzhet, RColorBrewer, tidyverse, reshape2, lexiconPT, textdata, tidyr, scales, broom, purrr, widyr,igraph, ggraph, SnowballC, RWekajars, dplyr, tidytext, sentimentBR, topicmodels, quanteda, quanteda.corpora, quanteda.textstats, bookdown, DT, magrittr, shiny)



# clean data 
clean_text = function(dados)
{
  x <- c("muita", "muito","ser", "outro", "outra", "tava", "pra", "vai", "vimo", "havia", "cal", "ter",  "ali", "aqui", "tudo", "todo")
  #  file <- url("https://jodavid.github.io/Slide-Introdu-o-a-Web-Scrapping-com-rvest/stopwords_pt_BR.txt")
  stopwords_ptBR <- read.table("./01_Dados/file.txt")
  stopwords_ptBR <- unlist(stopwords_ptBR, use.names = FALSE)
  stopwords_comentarios <- stopwords("portuguese")
  stopwords_iso<-sort(stopwords::stopwords("pt", source = "stopwords-iso"))
  stopwords<-c(stopwords_comentarios,stopwords_ptBR, stopwords_iso, x)
  dups2 <- duplicated(stopwords)
  sum(dups2)
  stopwords <- stopwords[!dups2]
  n_stopwords <- c("não", "nao")
  stopwords <-  removeWords(stopwords, n_stopwords)
  dados <- gsub("\n"," ", dados)
  dados<- gsub("\\b\\w{1,2}\\b\\s*", "", dados)
  dados <- gsub("[[:punct:]]"," ",dados)
  dados <- gsub("([^rs])(?=\\1+)|(rr)(?=r+)|(ss)(?=s+)", "",  dados, perl = TRUE)
  dados <- gsub("[^[:alnum:][:space:]]", "", iconv(dados, to = "UTF-8//TRANSLIT"))
  #dados<- stemDocument(dados)
  dados <- tolower(dados)
  dados<- removeNumbers(dados)
  dados <- removeWords(dados, stopwords)
  dados<- stripWhitespace(dados)
  dados<- na.omit(dados)
  return(dados)
}


# stemming 
dtm = function(dados){
  corpus = Corpus(VectorSource(dados))
  tdm<-TermDocumentMatrix(corpus, control = list(minWordLength = 3))
  dtm<- DocumentTermMatrix(corpus, control = list(wordLengths = c(3,Inf)))
  return(dtm)
}

tdm = function(dados){
  corpus = Corpus(VectorSource(dados))
  tm::TermDocumentMatrix(corpus, control = list(minWordLength = 3))
}


freq_ngrams <- function(dados, n){
  dados <- tibble(dados)
  dados <- dados %>%
    filter(is.na(dados) == FALSE)
  ngrams <- dados %>%
    unnest_tokens(ngram, dados, token = "ngrams", n = n)%>%
    filter(!is.na(ngram)) %>%
    count(ngram, sort = TRUE)
  return(ngrams)
}

plot_freq <- function(ngrams){
  ngrams %>%
    head(40) %>%
    mutate(ngram = reorder(ngram, n)) %>%
    ggplot(aes(ngram, n)) +
    geom_col(fill = "lightblue") +
    scale_y_continuous(labels = comma_format()) +
    coord_flip()
}

clean<-clean_text(data)
myDtm = dtm(clean)

dtms = removeSparseTerms(myDtm, 0.88)       

dtmss = as.matrix(dtms)

t_dtmss = t(dtmss)

d =  dist(t_dtmss, method="euclidean")

fit =  hclust(d , method = "ward.D")

plot(fit, hang=-1, xlab = "", sub ="")
rect.hclust(fit, 8, border="red") # draw dendogram with red borders around the 5 clusters   
groups = cutree(fit, 8)  
















dtms <- removeSparseTerms(myDtm, 0.88)
dtms_matrix <- as.matrix(dtms)
dist <- dist(t(dtms_matrix), method="euclidean")
fit_comentarios <- hclust(d=dist, method="complete")
dend_comentarios <- color_branches(fit_comentarios, k = 8)
par( mar = c(4,4,4,2)+2.5)
plot(dend_comentarios, yaxt='n')

        