require(pacman)
pacman::p_load(devtools, rvest, httr, XML, dplyr, textreuse, rslp, tm, proxy, factoextra, text2vec, ngram, ggplot2, stringr, stringi, cluster, dendextend, wordcloud, wordcloud2, rmarkdown, knitr, gridExtra, kableExtra, textreuse, syuzhet, RColorBrewer, tidyverse, reshape2, lexiconPT, textdata, tidyr, scales, broom, purrr, widyr,igraph, ggraph, SnowballC, RWekajars, dplyr, tidytext, topicmodels, quanteda, bookdown, DT, magrittr, shiny, shinyjs)



# clean data 
clean_text = function(dados)
{ source("./funcoes.r")
  file <- url("https://jodavid.github.io/Slide-Introdu-o-a-Web-Scrapping-com-rvest/stopwords_pt_BR.txt")
  stopwords_ptBR <- read.table(file)
  stopwords_ptBR <- unlist(stopwords_ptBR, use.names = FALSE)
  stopwords_comentarios <- stopwords("portuguese")
  stopwords_iso<-sort(stopwords::stopwords("pt", source = "stopwords-iso"))
  stopwords<-c(stopwords_comentarios,stopwords_ptBR, stopwords_iso)
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
  dados<- gsub("\\b\\w{1,2}\\b\\s*", "", dados)
  dados<- na.omit(dados)
  dados <- Retira_Plural(dados)
  dados <- Representante(dados)
  return(dados)
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
  tibble(word=names(freq), freq=freq) %>%
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

sent = function(val, x){
  dados <- tibble(val)
  
  dados <- dados %>%
    filter(is.na(val) == FALSE)
  
  ngram<- dados %>%
    unnest_tokens(ngram, val,  token = "ngrams", n = x)%>%
    mutate(polaridade = unlist(get_polaridade_vec(ngram)))
  
  return(ngram)
} 

ap_topics<-function(x, k){
  
  my_table<- x %>%
    mutate(ID = 1:nrow(x))%>%
    select(ID, ngram, n)
  colnames(my_table)<-c("id", "term", "freq")
  
  dtm<-my_table %>%
    cast_dtm(id, term, freq)
  
  ap_lda <- LDA(dtm , k = k, control = list(seed = 123))
  
  ap_topics <- tidy(ap_lda, matrix = "beta")
  
  return(ap_topics)  
}

ap_top_terms <- function(x, n){
  x %>%
    group_by(topic) %>%
    top_n(n, beta) %>%
    ungroup() %>%
    arrange(topic, -beta)
}




# call shiny app
shinyApp(
  ui = fluidPage(
    titlePanel("Mineração de textos"),
    
    
    hr(),
    
    sidebarPanel(
      
      # select a file 
      fileInput("file", label = h4("Source"), multiple = FALSE),
      
      
      # select stopword
      radioButtons("tabela_escolhida", label = "Escolha uma tabela:",
                   choices = c("Stopwords_1", "Stopwords_2", "Stopwords_3", "Stopwords_123"),
                   selected = "Stopwords_1"),
      
      
      # add a reset button 
      actionButton("adicionar", "Adicionar Stopword"),
      
      selectInput("removerlinha", "Remover Stopword", choices = NULL),
      
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
      
      sliderInput("height", "height", min = 100, max = 800 , value = 550),
      sliderInput("width", "width", min = 100, max = 800, value = 650),
      # parameters for each plot
      
      conditionalPanel(condition="input.conditionedPanels == 2",
                       hr(),
                       h4("Escala"),
                       helpText("Tamanho das letras"),
                       sliderInput("size", label = "", min = 8, max =26, 
                                   value = 12, step = 2)),
      
      
      conditionalPanel(condition="input.conditionedPanels==2 || input.conditionedPanels==7",
                       hr(),
                       h4("Número de N-gramas"),
                       sliderInput("n1", label = "", min = 1, max = 100, 
                                   value = 20, step = 1)),
      
      conditionalPanel(condition="input.conditionedPanels==3",
                       hr(),
                       h4("Número de N-gramas"),
                       sliderInput("n2", label = "", min = 1, max = 100, 
                                   value = 80, step = 1)),
      
      
      conditionalPanel(condition="input.conditionedPanels == 3",
                       hr(),
                       h4("Escala"),
                       helpText("Tamanho das letras"),
                       sliderInput("size3", label = "", min = 1, max =10, 
                                   value = 4, step = 1)),
      
      conditionalPanel(condition="input.conditionedPanels == 3",
                       hr(),
                       helpText("Espaço entre palavras"),
                       sliderInput("size2", label = "", min = 0.1, max =2, 
                                   value = 0.2, step = 0.1)),
      
      
      conditionalPanel(condition="input.conditionedPanels == 4 ||
                       input.conditionedPanels == 5||input.conditionedPanels == 6",
                       hr(),
                       h4("Parameters"),
                       helpText("Sparsity"),
                       sliderInput("sparsity", label = "", min = 0, max = 1, 
                                   value = 0.87, step = 0.01)),
      
      conditionalPanel(condition="input.conditionedPanels==4 || input.conditionedPanels==5|| input.conditionedPanels==7",
                       hr(),
                       helpText("Number of clusters"),
                       sliderInput("k", label = "", min = 1, max = 10, 
                                   value = 4, step = 1))     
      
    ),
    
    
    
    mainPanel(
      
      # show plots 
      tabsetPanel(
        tabPanel("Dados importados", value = 1, dataTableOutput("value")),
        navbarMenu("Stopwords",
                   tabPanel("Stopwords_1", dataTableOutput("Stopwords_1")),
                   tabPanel("Stopwords_2", dataTableOutput("Stopwords_2")),
                   tabPanel("Stopwords_3", dataTableOutput("Stopwords_3")),
                   tabPanel("Stopwords_123", dataTableOutput("Stopwords_123")),
                   tabPanel("Stopwords_editável", dataTableOutput("stop"))),
        navbarMenu("Palavras Removidas",
                   tabPanel("words_1", dataTableOutput("words_1")),
                   tabPanel("words_2", dataTableOutput("words_2")),
                   tabPanel("words_3", dataTableOutput("words_3")),
                   tabPanel("words_123", dataTableOutput("words_123"))),
        navbarMenu("Pré-processamento",
                   tabPanel("Pontuação", dataTableOutput("dados_punct")),
                   tabPanel("Caracteres Repetidos", dataTableOutput("dados_rep")),
                   tabPanel("Stopwords", dataTableOutput("dados_stopw")),
                   tabPanel("Três_caracteres", dataTableOutput("dados_min")),
                   tabPanel("Retira Plural", dataTableOutput("dados_retiraPlural")),
                   tabPanel("Representante", dataTableOutput("dados_representante")),
                   tabPanel("Dados processados", dataTableOutput("table"))),
        navbarMenu("Tabelas de Frequencia",
                   tabPanel("Palavras", dataTableOutput("table1")),
                   tabPanel("Bigramas", dataTableOutput("table2")),
                   tabPanel("Trigramas", dataTableOutput("table3")),
                   tabPanel("Tetragramas", dataTableOutput("table4")),
                   tabPanel("Pentagramas", dataTableOutput("table5"))),
        navbarMenu("Graficos de Frequencia", 
                   tabPanel("Palavras", value = 2, plotOutput("plot1"),
                            width = 250, height = 250), 
                   tabPanel("Bigramas", value = 2, plotOutput("plot6"),
                            width = 250, height = 250),  
                   tabPanel("Trigramas", value = 2, plotOutput("plot7"),
                            width = 250, height = 250), 
                   tabPanel("Tetragramas", value = 2, plotOutput("plot8"),
                            width = 250, height = 250), 
                   tabPanel("Pentagramas", value = 2, plotOutput("plot9"),
                            width = 250, height = 250)), 
        navbarMenu("Nuvens de Palavras", 
                   tabPanel("Palavras", value = 3, plotOutput("plot2"),
                            width = 250, height = 250), 
                   tabPanel("Bigramas", value = 3, plotOutput("plot10"),
                            width = 250, height = 250), 
                   tabPanel("Trigramas", value = 3, plotOutput("plot11"),
                            width = 250, height = 250),
                   tabPanel("Tetragramas", value = 3, plotOutput("plot12"),
                            width = 250, height = 250),
                   tabPanel("Pentagramas", value = 3, plotOutput("plot13"),
                            width = 250, height = 250)),
        navbarMenu("Análise de Tópicos", 
                   tabPanel("Palavras", value = 7, plotOutput("plot14"),
                            dataTableOutput("table6")),
                   tabPanel("Bigramas", value = 7, plotOutput("plot15"), 
                            dataTableOutput("table7")),
                   tabPanel("Trigramas", value = 7, plotOutput("plot16"),
                            dataTableOutput("table8")),
                   tabPanel("Tetragramas", value = 7, plotOutput("plot17"),
                            dataTableOutput("table9")),
                   tabPanel("Pentagramas", value = 7, plotOutput("plot18"),
                            dataTableOutput("table10"))),
        tabPanel("Sentimentos", value = 3, plotOutput("plot19"),
                 width = 250, height = 250),
        tabPanel("Clusterizacao", value = 4, plotOutput("plot3"),
                 width = 250, height = 250),
        tabPanel("KMeans", value = 5, plotOutput("plot4"),
                 width = 250, height = 250),
        tabPanel("Redes", value = 6, plotOutput("plot5"),
                 width = 250, height = 250),
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
      data<-tibble(data()) 
    )
    
    ######################################################################
    
    stop1 = reactive({
      file <- url("https://jodavid.github.io/Slide-Introdu-o-a-Web-Scrapping-com-rvest/stopwords_pt_BR.txt")
      stop1<- read.table(file)
      stop1<- tibble(stopword = unlist(stop1, use.names = FALSE))
    })
    
    stop2 = reactive({
      stop2<-sort(stopwords::stopwords("pt", source = "stopwords-iso"))
      stop2 <- tibble(stopword = stop2)
    })
    
    stop3 = reactive({
      stop3 <- stopwords("portuguese")
      stop3 <- tibble(stopword = stop3)
    })
    
    stop4 = reactive({
      stop4 <- unlist(c(stop1(), stop2(), stop3()))
      dups2 <- duplicated(stop4)
      sum(dups2)
      stop4 <- stop4[!dups2]
      stop4 <- tibble(stopword = stop4)
    })
    
    
    output$Stopwords_1 = renderDataTable({
      datatable(stop1())
    })
    
    output$Stopwords_2 = renderDataTable({
      datatable(stop2())
    })
    
    output$Stopwords_3 = renderDataTable({
      datatable(stop3())
    })
    
    output$Stopwords_123 = renderDataTable({
      datatable(stop4())
    })
    ######################################################################
    
  
      
   
      
    
    
    stopw <- reactiveValues(stopw = observeEvent(input$tabela_escolhida, {
      stopw$stopw <-
        switch(input$tabela_escolhida,
               "Stopwords_1" = stop1(),
               "Stopwords_2" = stop2(),
               "Stopwords_3" = stop3(),
               "Stopwords_123" = stop4())
    }))
  
    
    observeEvent(input$adicionar, {
      novaLinha <- tibble(stopword = NA)
      stopw$stopw <- bind_rows(novaLinha, stopw$stopw)
    })
  
    
    observe({
      choices <- c("",  stopw$stopw)
      updateSelectInput(session, "removerlinha", choices = choices)
    })
    
   
    observeEvent(input$removerlinha, {
      stopw$stopw<- stopw$stopw[stopw$stopw != input$removerlinha, ]
    })
    
    
    output$stop = renderDataTable({
      stopw<- datatable(stopw$stopw, editable = TRUE)
    })
    
    observeEvent(input$stop_cell_edit, {
      info <- input$stop_cell_edit
      linha <- info$row
      coluna <- info$col
      valor <- info$value
      
      # Atualizar a tabela com os dados editados
      stopw$stopw[linha, coluna] <- valor
    })
    
  #########################################################################
    
    dados_punct = reactive({
      dados_punct<- tibble(data())
      dados_punct <- gsub("\n"," ", dados_punct)
      dados_punct <- gsub("[[:punct:]]"," ", dados_punct)
    })
    
    dados_rep = reactive({
      dados_rep<- tibble(dados_punct())
      dados_rep <- gsub("([^rs])(?=\\1+)|(rr)(?=r+)|(ss)(?=s+)", "",  dados_rep, perl = TRUE)
      dados_rep <- gsub("[^[:alnum:][:space:]]", "", iconv(dados_rep, to = "UTF-8//TRANSLIT"))
    })

    
    dados_stopw = reactive({
      tabela_editada<-stopw$stopw
      dados_stopw <- tolower(dados_rep())
      dados_stopw<- removeNumbers(dados_stopw)
      dados_stopw <- removeWords(dados_stopw,unlist(tabela_editada))
      dados_stopw<- stripWhitespace(dados_stopw)
      dados_stopw<- gsub("\\b\\w{1,2}\\b\\s*", "", dados_stopw)
    })
    
    dados_min = reactive({
      dados_min<- tibble(dados_stopw())
      dados_min<- gsub("\\b\\w{1,2}\\b\\s*", "", dados_min)
    })
    
    dados_retiraPlural = reactive({
      source("./funcoes.r")
      dados_retiraPlural <- Retira_Plural(dados_min())
    })
    
    dados_representante = reactive({
      source("./funcoes.r")
      dados_representante <- Representante(dados_retiraPlural()) 
    })
    
    dados = reactive({
      dados <- dados_representante() 
      dados <- tibble(dados) 
    })
    
    output$dados_punct = renderDataTable({
      dados_punct<- tibble(dados_punct())
      datatable(dados_punct)
    })
    
    output$dados_rep = renderDataTable({
      dados_rep<- tibble(dados_rep())
      datatable(dados_rep)
    })
    
    output$dados_stopw = renderDataTable({
      dados_stopw<- tibble(dados_stopw())
      datatable(dados_stopw)
    })
    
    output$dados_min = renderDataTable({
      dados_min<- tibble(dados_min())
      datatable(dados_min)
    })
    
    output$dados_retiraPlural = renderDataTable({
      dados_retiraPlural<- tibble(dados_retiraPlural())
      datatable(dados_retiraPlural)
    })
    
    output$dados_representante = renderDataTable({
      dados_representante<- tibble(dados_representante())
      datatable(dados_representante)
    })
    
    output$table = renderDataTable({
      dados<- tibble(dados())
      datatable(dados)
    })
    
    
    ######################################################################
    
    
    df = reactive({
      freq_ngrams(dados(),1)
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
    
    
    output$plot1 = renderPlot(width = function() input$width,
                              height = function() input$height,
                              res = 96,{
                                hist_data = df()[1:input$n1,]
                                hist_data %>%
                                  mutate(ngram = reorder(ngram, n)) %>%
                                  ggplot(aes(ngram, n)) +
                                  geom_bar(stat="identity") +
                                  scale_y_continuous(labels = comma_format()) +
                                  coord_flip() +
                                  theme(axis.text.x = element_text(size = input$size),
                                        axis.text.y = element_text(size = input$size))
                              })
    
    output$plot6 = renderPlot(width = function() input$width,
                              height = function() input$height,
                              res = 96,{
                                hist_data = df2()[1:input$n1,]
                                hist_data %>%
                                  mutate(ngram = reorder(ngram, n)) %>%
                                  ggplot(aes(ngram, n)) +
                                  geom_bar(stat="identity") +
                                  scale_y_continuous(labels = comma_format()) +
                                  coord_flip() +
                                  theme(axis.text.x = element_text(size = input$size),
                                        axis.text.y = element_text(size = input$size))
                              })
    
    output$plot7 = renderPlot(width = function() input$width,
                              height = function() input$height,
                              res = 96,{
                                hist_data = df3()[1:input$n1,]
                                hist_data %>%
                                  mutate(ngram = reorder(ngram, n)) %>%
                                  ggplot(aes(ngram, n)) +
                                  geom_bar(stat="identity") +
                                  scale_y_continuous(labels = comma_format()) +
                                  coord_flip() +
                                  theme(axis.text.x = element_text(size = input$size),
                                        axis.text.y = element_text(size = input$size))
                              })
    
    output$plot8 = renderPlot(width = function() input$width,
                              height = function() input$height,
                              res = 96,{
                                hist_data = df4()[1:input$n1,]
                                hist_data %>%
                                  mutate(ngram = reorder(ngram, n)) %>%
                                  ggplot(aes(ngram, n)) +
                                  geom_bar(stat="identity") +
                                  scale_y_continuous(labels = comma_format()) +
                                  coord_flip() +
                                  theme(axis.text.x = element_text(size = input$size),
                                        axis.text.y = element_text(size = input$size))
                              })
    
    output$plot9 = renderPlot(width = function() input$width,
                              height = function() input$height,
                              res = 96,{
                                hist_data = df5()[1:input$n1,]
                                hist_data %>%
                                  mutate(ngram = reorder(ngram, n)) %>%
                                  ggplot(aes(ngram, n)) +
                                  geom_bar(stat="identity") +
                                  scale_y_continuous(labels = comma_format()) +
                                  coord_flip() +
                                  theme(axis.text.x = element_text(size = input$size),
                                        axis.text.y = element_text(size = input$size))
                              })
    
    ### WORDCLOUDS
    
    
    output$plot2 = renderPlot(width = function() input$width,
                              height = function() input$height,
                              res = 96,{
                                wordcloud(words = df()$ngram,
                                          freq = df()$n,
                                          max.words = input$n2,
                                          scale = c(input$size3,input$size2),
                                          colors = brewer.pal(8, "Dark2"))
                              })
    
    
    output$plot10 = renderPlot(width = function() input$width,
                               height = function() input$height,
                               res = 96,{
                                 wordcloud(words = df2()$ngram, 
                                           freq = df2()$n,
                                           max.words = input$n2, 
                                           scale = c(input$size3,input$size2),
                                           colors = brewer.pal(8, "Dark2"))
                               })
    
    output$plot11 = renderPlot(width = function() input$width,
                               height = function() input$height,
                               res = 96,{
                                 wordcloud(words = df3()$ngram, 
                                           freq = df3()$n,
                                           max.words = input$n2, 
                                           scale = c(input$size3,input$size2),
                                           colors = brewer.pal(8, "Dark2"))
                               })
    
    output$plot12 = renderPlot(width = function() input$width,
                               height = function() input$height,
                               res = 96,{
                                 wordcloud(words = df4()$ngram, 
                                           freq = df4()$n,
                                           max.words = input$n2, 
                                           scale = c(input$size3,input$size2),
                                           colors = brewer.pal(8, "Dark2"))
                               })
    
    output$plot13 = renderPlot(width = function() input$width,
                               height = function() input$height,
                               res = 96,{
                                 wordcloud(words = df5()$ngram, 
                                           freq = df5()$n,
                                           max.words = input$n2, 
                                           scale = c(input$size3,input$size2),
                                           colors = brewer.pal(8, "Dark2"))
                               })
    ####### TÓPICOS
    
    
    ap_topics1 = reactive({
      ap_topics(df(), input$k)       
    })
    
    
    ap_top_terms1 =reactive({
      ap_top_terms(ap_topics1(), input$n1)       
    })
    
    
    output$plot14 = renderPlot({
      ap_top_terms1() %>%
        mutate(term = reorder(term, beta)) %>%
        ggplot(aes(term, beta, fill = factor(topic))) +
        geom_col(show.legend = FALSE) +
        facet_wrap(~ topic, scales = "free") +
        coord_flip()
    })
    
    
    output$table6 = renderDataTable(
      ap_top_terms1()
    )
    
    
    
    ap_topics2 = reactive({
      ap_topics(df2(), input$k)       
    })
    
    
    ap_top_terms2 =reactive({
      ap_top_terms(ap_topics2(), input$n1)       
    })
    
    
    output$plot15 = renderPlot({
      ap_top_terms2() %>%
        mutate(term = reorder(term, beta)) %>%
        ggplot(aes(term, beta, fill = factor(topic))) +
        geom_col(show.legend = FALSE) +
        facet_wrap(~ topic, scales = "free") +
        coord_flip()
    })
    
    output$table7 = renderDataTable(
      ap_top_terms2()
    )
    
    
    ap_topics3 = reactive({
      ap_topics(df3(), input$k)       
    })
    
    
    ap_top_terms3 =reactive({
      ap_top_terms(ap_topics3(), input$n1)       
    })
    
    
    output$plot16 = renderPlot({
      ap_top_terms3() %>%
        mutate(term = reorder(term, beta)) %>%
        ggplot(aes(term, beta, fill = factor(topic))) +
        geom_col(show.legend = FALSE) +
        facet_wrap(~ topic, scales = "free") +
        coord_flip()
    })
    
    output$table8 = renderDataTable(
      ap_top_terms3()
    )
    
    
    ap_topics4 = reactive({
      ap_topics(df4(), input$k)       
    })
    
    
    ap_top_terms4 =reactive({
      ap_top_terms(ap_topics4(), input$n1)       
    })
    
    
    output$plot17 = renderPlot({
      ap_top_terms4() %>%
        mutate(term = reorder(term, beta)) %>%
        ggplot(aes(term, beta, fill = factor(topic))) +
        geom_col(show.legend = FALSE) +
        facet_wrap(~ topic, scales = "free") +
        coord_flip()
    })
    
    output$table9 = renderDataTable(
      ap_top_terms4()
    )
    
    ap_topics5 = reactive({
      ap_topics(df5(), input$k)       
    })
    
    
    ap_top_terms5 =reactive({
      ap_top_terms(ap_topics5(), input$n1)       
    })
    
    
    output$plot18 = renderPlot({
      ap_top_terms5() %>%
        mutate(term = reorder(term, beta)) %>%
        ggplot(aes(term, beta, fill = factor(topic))) +
        geom_col(show.legend = FALSE) +
        facet_wrap(~ topic, scales = "free") +
        coord_flip()
    })
    
    
    output$table10 = renderDataTable(
      ap_top_terms5()
    )
    
    ### SENTIMENTOS
    
    dfsent = reactive({
      sent(dados(),1)
    })
    
    token_sentiments_count <- reactive({
    
      token_sentiments <- dfsent() %>%
        mutate(polaridade = unlist(get_polaridade_vec(ngram))) %>%
        mutate(sentimento = factor(polaridade, levels = c(-1,0,1), labels = c("Negativo", "Neutro", "Positivo")))
      
      token_sentiments_count <- token_sentiments %>% 
        count(ngram, polaridade, sentimento, sort = TRUE)
      
      token_sentiments_count <- token_sentiments_count %>%
        filter(polaridade != 0) %>%
        acast(ngram ~ sentimento, 
              value.var = "n", fill = 0)
    })
    
    
    output$plot19 = renderPlot(width = function() input$width,
                               height = function() input$height,
                               res = 56,{
      token_sentiments_count() %>%
        comparison.cloud(colors = c("red4", "green4"), 
                         max.words = input$n2,
                         scale = c(input$size3,input$size2))
      
    })
    
    
    ###### CLUSTERIZAÇÃO
    
    myDtm = reactive({
      clean_data = clean_text(data())
      dtm(clean_data)
    })
    
    myTdm = reactive({
      clean_data = clean_text(data())
      tdm(clean_data)
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
    
    output$plot3 = renderPlot(width = function() input$width,
                              height = function() input$height,
                              res = 96,{
                                # remove sparse terms
                                plot(fit(), hang=-1, xlab = "", sub ="")
                                rect.hclust(fit(), input$k, border="red") # draw dendogram with red borders around the 5 clusters   
                                groups = cutree(fit(), input$k)   # "k=" defines the number of clusters you are using 
                              })
    
    d_tdm = reactive(dist(t((as.matrix(tdms()))), method="euclidean"))
    output$plot4 = renderPlot(width = function() input$width,
                              height = function() input$height,
                              res = 96,{
                                kfit = kmeans(d_tdm(), input$k)   
                                clusplot(as.matrix(d_tdm()), kfit$cluster, main = "",
                                         color=T, shade=T, labels=2, lines=0)
                              })
    
    output$plot5  = renderPlot(width = function() input$width,
                               height = function() input$height,
                               res = 96,{
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