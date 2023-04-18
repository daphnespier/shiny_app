if(!require(pacman)) install.packages("pacman")
pacman::p_load(devtools, rvest, httr, XML, dplyr, textreuse, rslp, tm, proxy, factoextra, text2vec, ngram, ggplot2, stringr, stringi, cluster, dendextend, wordcloud, wordcloud2, rmarkdown, knitr, gridExtra, kableExtra, textreuse, syuzhet, RColorBrewer, tidyverse, reshape2, lexiconPT, textdata, tidyr, scales, broom, purrr, widyr,igraph, ggraph, SnowballC, RWekajars, dplyr, tidytext, sentimentBR, topicmodels, quanteda, quanteda.corpora, quanteda.textstats, bookdown, DT, magrittr, shiny)



# clean data 
clean_text = function(val)
{
  x <- c("muita", "muito","ser", "outro", "outra", "tava", "pra", "vai", "vimo", "havia", "cal", "ter",  "ali", "aqui", "tudo", "todo")
  file_x <- url("https://jodavid.github.io/Slide-Introdu-o-a-Web-Scrapping-com-rvest/stopwords_pt_BR.txt")
  stopwords_ptBR <- read.table(file_x)
  stopwords_ptBR <- unlist(stopwords_ptBR, use.names = FALSE)
  stopwords_comentarios <- stopwords("portuguese")
  stopwords_iso<-sort(stopwords::stopwords("pt", source = "stopwords-iso"))
  stopwords<-c(stopwords_comentarios,stopwords_ptBR, stopwords_iso, x)
  dups2 <- duplicated(stopwords)
  sum(dups2)
  stopwords <- stopwords[!dups2]
  n_stopwords <- c("nao")
  stopwords <-  removeWords(stopwords, n_stopwords)
  val <- tolower(val)
  val <- gsub("[[:punct:]]"," ",val)
  val <- gsub("([^rs])(?=\\1+)|(rr)(?=r+)|(ss)(?=s+)", "",  val, perl = TRUE)
  val <- gsub("[^[:alnum:][:space:]]", "", iconv(val, to = "ASCII//TRANSLIT"))
  val <- gsub("\n"," ",val)
  val<- removeNumbers(val)
  val<- stemDocument(val)
  val <- removeWords(val, stopwords)
  val <- gsub("\n"," ", val)
  val<- gsub("\\b\\w{1,2}\\b\\s*", "", val)
  val<- stripWhitespace(val)
  val<- na.omit(val)
  return(val)
}


# stemming 
dtm = function(val){
  corpus = Corpus(VectorSource(val))
  tm::TermDocumentMatrix(corpus, control = list(minWordLength = 3))
  dtm<- DocumentTermMatrix(corpus, control = list(wordLengths = c(3,Inf)))
}

tdm = function(val){
  corpus = Corpus(VectorSource(val))
  tm::TermDocumentMatrix(corpus, control = list(minWordLength = 3))
}


# compute frequency and output data frame
freq_table = function(val){
  # find frequency:
  freq = colSums(t(as.matrix(val)))
  # order   
  ord = rev(order(freq))
  
  # output df
  data_frame(word=names(freq), freq=freq) %>%
    group_by(word) %>% 
    arrange(desc(freq))
  
}


freq_ngrams = function(val, x){
  dados <- tibble(val)
  
  dados <- dados %>%
    filter(is.na(val) == FALSE)
  
  ngram<- dados %>%
    unnest_tokens(ngram, val,  token = "ngrams", n = x)%>%
    count(ngram, sort = TRUE)
  
  return(ngram)
} 


# call shiny app
shinyApp(
  ui = fluidPage(
    titlePanel("Mineração de textos"),
    
    hr(),
    
    sidebarPanel(
      # select a file 
      fileInput("file", label = h3("Source"), multiple = FALSE),
      
      # add a reset button 
      actionButton("reset", "Reset File"),
      
      # reset fileInput 
      tags$script('
                  Shiny.addCustomMessageHandler("resetFileInputHandler", function(x) {      
                  
                  var id = "#" + x + "_progress";
                  
                  var idBar = id + " .bar";
                  
                  $(id).css("visibility", "hidden");
                  
                  $(idBar).css("width", "0%");
                  
                  });
                  
                  '),
      
      # parameters for each plot
      conditionalPanel(condition="input.conditionedPanels==2",
                       hr(),
                       h3("Parameters"),
                       helpText("Number of Most Frequent Words"),
                       sliderInput("n1", label = "", min = 1, max = 100, 
                                   value = 20, step = 1)),
      
      conditionalPanel(condition="input.conditionedPanels==3",
                       hr(),
                       h3("Parameters"),
                       helpText("Number of Most Frequent Words"),
                       sliderInput("n2", label = "", min = 1, max = 100, 
                                   value = 50, step = 1)),
      
      conditionalPanel(condition="input.conditionedPanels == 4 ||
                       input.conditionedPanels == 5||input.conditionedPanels == 6",
                       hr(),
                       h3("Parameters"),
                       helpText("Sparsity"),
                       sliderInput("sparsity", label = "", min = 0, max = 1, 
                                   value = 0.87, step = 0.01)),
      
      conditionalPanel(condition="input.conditionedPanels==4 || input.conditionedPanels==5",
                       hr(),
                       helpText("Number of clusters"),
                       sliderInput("k", label = "", min = 1, max = 10, 
                                   value = 5, step = 1))     
      
    ),
    
    mainPanel(
      
      # show plots 
      tabsetPanel(
        tabPanel("Dados importados", value = 1, DT::dataTableOutput("value")),
        navbarMenu("Tabelas de Frequencia",
                   tabPanel("Palavras", dataTableOutput("table1")),
                   tabPanel("Bigramas", dataTableOutput("table2")),
                   tabPanel("Trigramas", dataTableOutput("table3")),
                   tabPanel("Tetragramas", dataTableOutput("table4")),
                   tabPanel("Pentagramas", dataTableOutput("table5"))),
        navbarMenu("Graficos de Frequencia", 
                  tabPanel("Palavras", value = 2, plotOutput("plot1")), 
                  tabPanel("Bigramas", value = 2, plotOutput("plot6")), 
                  tabPanel("Trigramas", value = 2, plotOutput("plot7")), 
                  tabPanel("Tetragramas", value = 2, plotOutput("plot8")), 
                  tabPanel("Pentagramas", value = 2, plotOutput("plot9"))), 
        navbarMenu("Nuvens de Palavras", 
                   tabPanel("Palavras", value = 3, plotOutput("plot2")), 
                   tabPanel("Bigramas", value = 3, plotOutput("plot10")), 
                   tabPanel("Trigramas", value = 3, plotOutput("plot11")),
                   tabPanel("Tetragramas", value = 3, plotOutput("plot12")),
                   tabPanel("Pentagramas", value = 3, plotOutput("plot13"))),
        tabPanel("Clusterizacao", value = 4, plotOutput("plot3")),
        tabPanel("KMeans", value = 5, plotOutput("plot4")),
        tabPanel("Redes", value = 6, plotOutput("plot5")),
        id = "conditionedPanels"
      )
    )
  ),
  
  server = function(input, output, session) {
    file = reactive(input$file)
    
    data = reactive({
      if (is.null(file())){
        NULL
      } else {
        readLines(file()$datapath) 
      }
    })
    
    
    
    output$value = renderDataTable(
      tibble(data()) 
    )
    
    
    myDtm = reactive({
      clean_data = clean_text(data())
      dtm(clean_data)
    })
    
    myTdm = reactive({
      clean_data = clean_text(data())
      tdm(clean_data)
    })
    
    dados = reactive({
      dados = clean_text(data())
    })
    
    
    df = reactive({
      freq_table(myTdm())
    })
    
   
    output$table1 = renderDataTable(
      df()
    )
    
    
    df2 = reactive({
      freq_ngrams(dados(),2)
    })
    
    output$table2 = renderDataTable(
      df2()
    )
    
    
    df3 = reactive({
      freq_ngrams(dados(),3)
    })
    
    output$table3 = renderDataTable(
      df3()
    )
    
    
    df4 = reactive({
      freq_ngrams(dados(),4)
    })
    
    output$table4 = renderDataTable(
      df4()
    )
    
    df5 = reactive({
      freq_ngrams(dados(),5)
    })
    
    output$table5 = renderDataTable(
      df5()
    )
    
    
    ###### HISTOGRAMAS
    
    
    output$plot1 = renderPlot({
      hist_data = df()[1:input$n1,]
      ggplot(hist_data, aes(reorder(word, -freq), freq))+
        geom_bar(stat="identity") +
        theme_minimal() +
        theme(axis.text.x=element_text(angle=45, hjust=1)) +
        ylab("Frequency") + xlab("")
    })
    
    output$plot6 = renderPlot({
      hist_data = df2()[1:input$n1,]
      hist_data %>%
        mutate(ngram = reorder(ngram, n)) %>%
        ggplot(aes(ngram, n)) +
        geom_bar(stat="identity") +
        scale_y_continuous(labels = comma_format()) +
        coord_flip() 
    })
    
    output$plot7 = renderPlot({
      hist_data = df3()[1:input$n1,]
      hist_data %>%
        mutate(ngram = reorder(ngram, n)) %>%
        ggplot(aes(ngram, n)) +
        geom_bar(stat="identity") +
        scale_y_continuous(labels = comma_format()) +
        coord_flip() 
    })
    
    output$plot8 = renderPlot({
      hist_data = df4()[1:input$n1,]
      hist_data %>%
        mutate(ngram = reorder(ngram, n)) %>%
        ggplot(aes(ngram, n)) +
        geom_bar(stat="identity") +
        scale_y_continuous(labels = comma_format()) +
        coord_flip() 
    })
    
    output$plot9 = renderPlot({
      hist_data = df5()[1:input$n1,]
      hist_data %>%
        mutate(ngram = reorder(ngram, n)) %>%
        ggplot(aes(ngram, n)) +
        geom_bar(stat="identity") +
        scale_y_continuous(labels = comma_format()) +
        coord_flip() 
    })
    
    ### WORDCLOUDS
    
    output$plot2 = renderPlot({
      wordcloud(df()$word, df()$freq, 
                max.words = input$n2, scale = c(4,0.5),
                colors = brewer.pal(8, "Dark2") )
    })
    
  
    output$plot10 = renderPlot({
      wordcloud(words = df2()$ngram, 
                freq = df2()$n,
                max.words = input$n2, 
                scale = c(3,0.2),
                colors = brewer.pal(8, "Dark2"))
    })
    
    output$plot11 = renderPlot({
      wordcloud(words = df3()$ngram, 
                freq = df3()$n,
                max.words = input$n2, 
                scale = c(2,0.2),
                colors = brewer.pal(8, "Dark2"))
    })
    
    output$plot12 = renderPlot({
      wordcloud(words = df4()$ngram, 
                freq = df4()$n,
                max.words = input$n2, 
                scale = c(1,0.2),
                colors = brewer.pal(8, "Dark2"))
    })
    
    output$plot13 = renderPlot({
      wordcloud(words = df5()$ngram, 
                freq = df5()$n,
                max.words = input$n2, 
                scale = c(1,0.2),
                colors = brewer.pal(8, "Dark2"))
    })
    
    
    
    
    tdms = reactive({
      removeSparseTerms(myTdm(), input$sparsity)       
    })
    
    
    dtms = reactive({
      removeSparseTerms(myDtm(), input$sparsity)       
    })
    
    #tdmss <- reactive(as.matrix(tdms))
    
    d = reactive(dist(t((as.matrix(dtms()))), method="euclidean"))
    
    fit = reactive(hclust(d() , method = "ward.D"))
    
    output$plot3 = renderPlot({
      # remove sparse terms
      plot(fit(), hang=-1, xlab = "", sub ="")
      rect.hclust(fit(), input$k, border="red") # draw dendogram with red borders around the 5 clusters   
      groups = cutree(fit(), input$k)   # "k=" defines the number of clusters you are using 
    })
    
    d_tdm = reactive(dist(t((as.matrix(tdms()))), method="euclidean"))
    output$plot4 = renderPlot({
      kfit = kmeans(d_tdm(), input$k)   
      clusplot(as.matrix(d_tdm()), kfit$cluster, main = "",
               color=T, shade=T, labels=2, lines=0)
    })
    
    output$plot5  = renderPlot({
      termDocMatrix = as.matrix(tdms())
      termDocMatrix[termDocMatrix>=1] = 1
      termMatrix = termDocMatrix %*% t(termDocMatrix)
      g = graph.adjacency(termMatrix, weighted=T, mode = "undirected")
      V(g)$label = V(g)$name
      V(g)$degree = degree(g)
      # remove loops
      g = simplify(g)
      V(g)$label.cex = log(rank(V(g)$degree)) + 1
      V(g)$label.color = rgb(0, 0, .2, .8)
      V(g)$frame.color = NA
      egam = (log(E(g)$weight)+.4) / max(log(E(g)$weight)+.4)
      E(g)$color = rgb(.5, .5, 0, egam)
      E(g)$width = egam*2
      plot(g)
    })
    
    observe({
      input$reset
      session$sendCustomMessage(type = "resetFileInputHandler", "file")   
    })
  }
)

