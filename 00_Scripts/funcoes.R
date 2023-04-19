searchword2 <- function(palavra,vetorcharacter){

  a=1
  if(class(vetorcharacter)=="character"){
    while(a <= length(vetorcharacter)){
      if(palavra==vetorcharacter[a]){
        return(a)
      }
      a=a+1
    }
  }
  return(0)
}
retirar_plural <- function(palavra,lista){

  i=1

  lista_excecao <- as.data.frame(matrix(c("variáveis","variável","tangíveis","tangível","saudáveis","suadável","intangíveis","intangível"),ncol = 2, byrow = TRUE))

  colnames(lista_excecao) <- c("Plural","Singular")

  lista_excecao$Plural <- as.character(lista_excecao$Plural)

  lista_excecao$Singular <- as.character(lista_excecao$Singular)

  # Variável que vai receber a palavra plural
  word_plural <- vector()

  # variável que vai receber a palavra que não está mais na forma plural
  n_plural <- vector()

  #loop para o número de palavras
  while(i <= length(palavra)){

    p <- searchword2(palavra[i],lista_excecao[,1])

    # verifica se a palavra pertence a uma lista especial de plurais
    if(p > 0){
      palavra[i] <- lista_excecao[p,2]
    }

    # Verifica se a palavra termina com s
    if(str_sub(palavra[i],nchar(palavra[i])) == "s"){

      word_plural[length(word_plural)+1] <- palavra[i]

      # verifica se a palavra termina com "ões","ãos" e "ães" se sim substituir por
      # ão ex: operações
      if(str_sub(palavra[i],nchar(palavra[i])-2) == "ões"
         || str_sub(palavra[i],nchar(palavra[i])-2) == "ãos"
         || str_sub(palavra[i],nchar(palavra[i])-2) == "ães"){

        palavra[i] <- paste(str_sub(palavra[i],1,nchar(palavra[i])-3),"ão",sep = "")

        # Palavras terminada com "zes" ex: rapazes
      }else if(str_sub(palavra[i],nchar(palavra[i])-2) == "zes"){

        palavra[i] <- str_sub(palavra[i],1,nchar(palavra[i])-2)

        # Palavras que terminam com "res" ex: vendedores
      }else if(str_sub(palavra[i],nchar(palavra[i])-2) == "res"){

        palavra[i] <- str_sub(palavra[i],1,nchar(palavra[i])-2)

        # Palavras que terminam com "ais" ex: varais
      }else if(str_sub(palavra[i],nchar(palavra[i])-2) == "ais"){

        palavra[i] <- paste(str_sub(palavra[i],1,nchar(palavra[i])-2),"l", sep = "")

        # Palavras que terminam com "éis" ex: aluguéis
      }else if(str_sub(palavra[i],nchar(palavra[i])-2) == "éis"){

        palavra[i] <- paste(str_sub(palavra[i],1,nchar(palavra[i])-3),"el", sep = "")

        # Palavras que terminam com "eis" ex: contábeis
      }else if(str_sub(palavra[i],nchar(palavra[i])-2) == "eis"){

        palavra[i] <- paste(str_sub(palavra[i],1,nchar(palavra[i])-3),"il", sep = "")

        # Palavras que terminam com "óis" ex: lençóis
      }else if(str_sub(palavra[i],nchar(palavra[i])-2) == "óis"){

        palavra[i] <- paste(str_sub(palavra[i],1,nchar(palavra[i])-3),"ol", sep = "")

        # Palavras que terminam com "uis" ex : pauis
      }else if(str_sub(palavra[i],nchar(palavra[i])-2) == "uis"){

        palavra[i] <- paste(str_sub(palavra[i],1,nchar(palavra[i])-2),"l", sep = "")

        # Palavras que terminam com "ns" ex: origens
      }else if(str_sub(palavra[i],nchar(palavra[i])-1) == "ns"){

        palavra[i] <- paste(str_sub(palavra[i],1,nchar(palavra[i])-2),"m", sep = "")

        # Palavras que terminal com "os" ex: atributos
      }else if(str_sub(palavra[i],nchar(palavra[i])-1) == "os"){

        palavra[i] <- str_sub(palavra[i],1,nchar(palavra[i])-1)

        # Palavras que terminal com "as" ex: falhas
      }else if(str_sub(palavra[i],nchar(palavra[i])-1) == "as"){

        palavra[i] <- str_sub(palavra[i],1,nchar(palavra[i])-1)

        # Palavras que terminal com "es" ex: emergentes
      }else if(str_sub(palavra[i],nchar(palavra[i])-1) == "es"){

        palavra[i] <- str_sub(palavra[i],1,nchar(palavra[i])-1)

      }
      n_plural[length(n_plural)+1] <- palavra[i]
    }
    i=i+1
  }
  if(lista == 0){
    # retornar
    ps <- cbind(word_plural,n_plural)
    colnames(ps) <- c("Plural","Singular")
    return(ps)

  }else if(lista == 1 ){
    # Retorna todas as palavras passadas
    return(palavra)

  }else if( lista == 2){

    # Retorna as palavras que estão na lista de exceção
    return(lista_excecao)
  }

}
Retira_Plural <- function(texto_char){

  i=1

  while(i <= length(texto_char)){

    # divide o documento em um vetor de character
    group_word <- words(texto_char[i])

    # retira o plural das palavras
    group_word <- retirar_plural(group_word, lista = 1)

    # monta o documento novamente
    texto_char[i] <- paste(group_word,collapse=" ")

    i=i+1
  }
  return(texto_char)
}
Corpus_To_Char <- function(var_corpus){

  var_char <- var_corpus[[1]]$content

  if(length(var_corpus)>1){

    for ( i in 2:length( var_corpus)){

      text <- var_corpus[[i]]$content

      var_char <- c( var_char, text)
    }
  }

  return(var_char)
}
Frequencia_Absoluta <- function(texto_char){

  Palavra <- strsplit(texto_char, "\\W+")

  Palavra <- unlist(Palavra)

  Palavra <- table(Palavra)

  Palavra <- sort(Palavra, decreasing=TRUE)

  Palavra <- data.frame(Palavra)

  Palavra[,1] <- as.character(Palavra[,1])

  return(Palavra)
}
Representante <- function(texto){

  # calcula as palavras com maiores frequencias absolutas
  freq_abs <- Frequencia_Absoluta(texto)

  # adciona nomes das palavras a names1
  names1 <- freq_abs[,1]

  # faz uma copia dos nomes
  names2 <- freq_abs[,1]

  # faz o steam dos coment?rios
  names2 <- stemDocument(names2,language = "portuguese")

  # adciona a primeira palavra
  vet_normal <- names1[1]

  # adciona a primeira palavra do steam
  vet_steam <- names2[1]

  i=1
  # loop monta uma lista com a palavras normais e palavras com steam para ser usada na
  # substitui??o no texto
  while( i <= length(names2)){

    if(length(intersect(vet_steam,names2[i]))==0){

      vet_normal <- append(vet_normal,names1[i])

      vet_steam <- append(vet_steam,names2[i])
    }

    i=i+1
  }

  # faz o steam dos documentos
  steam_texto <- stemDocument(texto,language = "portuguese")

  # seleciona documentos com nchar maior que 2
  steam_texto <- subset(steam_texto,nchar(steam_texto)>2)

  # adiciona o documento o primeiro documento a num_word
  num_word <- words(steam_texto[1])

  # copia o num_word para normall_comentario
  normal_comentario <- num_word

  i=1

  #loop para substituir o primeiro documento steam para palavras mais representativa
  while(i <= length(num_word)){

    pos <- searchword2(num_word[i],vet_steam)

    if(pos>0){

      normal_comentario[i] <- vet_normal[pos]
    }


    i=i+1
  }

  # contem o primeiro documento com as palavras mais representativa
  vet_comentario <- paste(normal_comentario,collapse=" ")


  j=2
  # loop para o numero de documento
  while(j <= length(steam_texto)){

    num_word <- words(steam_texto[j])

    normal_comentario <- num_word

    i=1
    # loop para o n?mero de palavras presente no documento
    while(i <= length(num_word)){

      pos <- searchword2(num_word[i],vet_steam)

      if(pos > 0){

        normal_comentario[i] <- vet_normal[pos]
      }

      i=i+1
    }
    # cont?m o coment?rio do documento
    normal_comentario <- paste(normal_comentario,collapse=" ")

    # cont?m os coment?rios dos documentos
    vet_comentario <- append(vet_comentario,normal_comentario)

    j=j+1
  }
  # retorna uma vari?vel com os documentos substituido pela palavra mais representativa
  return(vet_comentario)

}
Dupla_Frequencia <- function(freq1,freq2){

  fa <- c()

  for(k in 1:length(freq1[,1])){

    pp <- searchword2(freq1[k,1],freq2[,1])

    if(pp==0){

      fa <- append(fa,0)

    }else if(pp!=0){

      fa <- append(fa,freq2[pp,2])
    }
  }

  mat <- cbind(freq1,fa)

  colnames(mat) <- c("Palavra", "freq_anuncios","freq_ementas")

  return(mat)
}
Frequencia_Relativa <- function(matrix){

  nomematrix <- rownames(matrix)

  rownames(matrix) <- c()

  relativo <- apply(matrix,1,function(c)sum(c!=0))

  relativo <- ((relativo)/dim(matrix)[2])*100

  resultado <- data.frame("Palavra"=nomematrix, "FreqR"= relativo)

  vetnum <- head(order(resultado[,2],decreasing = TRUE),length(resultado[,1]))

  resultado <- resultado[vetnum,]

  rownames(resultado) <- c(1:dim(resultado)[1])

  return(resultado)

}
Diferenca_Relativa <- function(mat_1,mat_2){

  i=1
  # variavel para receber o valor da mat_2
  vet <- c()

  while(i <= dim(mat_1)[1]){

    # realiza uma pesquisa nas palavras da mat_2
    pos <- searchword2(mat_1[i,1],mat_2[,1])

    # se a pos diferente de zero significa que a palavra tambem existe em
    # mat_2
    if(pos!=0){
      vet <- append(vet,mat_2[pos,2])
    }else{
      vet <- append(vet,0)
    }
    i=i+1
  }

  # calcula a diferenca
  dif <- mat_1[,2] - vet

  # cria uma matriz
  mat_new <- data.frame("Palavra"=mat_1[,1],"Freq_1"=mat_1[,2],
                        "Freq_2"= vet,"Diferenca"= dif)


  return(mat_new)
}
FreqR_Frase <- function(frases,texto_char){

  FR_Frase <- function(frase, texto){

    cont = 0

    # transforma o texto em um vetor de palavras
    word_texto <- words(texto)

    # transforma a frase em um vetor de palavras
    word_frase <- words(frase)

    vetfr = 0

    i=1

    for(i in 1:length(word_texto)){

      k=1

      if(word_frase[k]==word_texto[i]){

        cont=1
        if(length(word_frase)>=2){
          for(k in 2:length(word_frase)){

            if(i+length(word_frase)-1 <= length(word_texto)){

              if(word_frase[k]==word_texto[i+k-1]){

                cont=cont+1

              }
            }
          }
        }


      }
      if(cont==length(word_frase)){

        vetfr <- 1

      }

      cont=0
    }


    return(vetfr)

  }

  FreqR <- c()

  for(j in 1:length(frases)){

    vet <- c()

    for(p in 1:length(texto_char)){

      vet<- append(vet,FR_Frase(frases[j],texto_char[p]))

    }

    FreqR <- append(FreqR,(sum(vet)/length(vet))*100)

  }

  r_ngram <- data.frame("frases"=frases,"FreqR"=as.numeric(FreqR))

  return(r_ngram)

}
Distribuicao_palavra <- function(bigram){

  i=1
  # dupla_word cont?m as duas palavras do bigrama
  dupla_word <- words(bigram[i,1])

  # criando uma vari?vel do tipo lista para adicionar os dataframe
  lista <- list()

  # a primeira coluna do data frame ser? colocado a segunda palavra do bigrama
  # bigram[i,2] est? a frequ?ncia do bigrama stringsAsFactor igual a falso para que
  # as vari?veis do data frame n?o sejam da classe factor
  lista[[i]] <- data.frame(matrix(c(dupla_word[2],bigram[i,2]),ncol = 2),stringsAsFactors=FALSE)

  # Adicionando o nome da lista 1
  names(lista)[[i]] <- dupla_word[1]

  i=2

  while(i <= length(bigram[,1])){

    dupla_word <- words(bigram[i,1])

    # procura se a palavra 1 da dupla_word j? est? na lista de nomes, se sim vai
    # retornar a posi??o, caso contr?rio vai retornar zero
    pos <- searchword2(dupla_word[1],names(lista))

    if(pos == 0){
      lista[[length(lista)+1]] <- data.frame(matrix(c(dupla_word[2],bigram[i,2]),ncol = 2),stringsAsFactors=FALSE)
      names(lista)[[length(lista)]] <- dupla_word[1]
    }else{
      # adiciona a palavra e sua frequ?ncia ao data frame j? existente
      lista[[pos]] <- rbind(lista[[pos]],data.frame(matrix(c(dupla_word[2],bigram[i,2]),ncol = 2)),stringsAsFactors=FALSE)
    }
    i=i+1

  }
  # Loop para modificar a lista
  for(a in 1:length(lista)){

    # transforma a segunda coluna do dataframe em num?rico
    lista[[a]][,2] <- as.numeric(lista[[a]][,2])

    # Adiciona nomes as colunas do data frame
    # 1? coluna recebe a palavra que ter? a predi??o
    # 2? coluna recebe nome de frequ?ncia
    names(lista[[a]]) <- c(names(lista)[a],"Frequ?ncia")

    # calcula a porcentagem considerando a segunda coluno do dataframe
    porcentagem <- round(lista[[a]][,2]/sum(lista[[a]][,2])*100,3)

    # Cria um data.frame com uma coluna com as porcentagens da vari?vel porcentagem
    porcentagem <- data.frame("Porcentagem" = porcentagem)

    # combina as colunas j? existente na lista com coluna com as porcentagens
    lista[[a]] <- cbind(lista[[a]],porcentagem)

    # soma dos valores absolutos
    sum_abs <- sum(lista[[a]][,2])

    #soma das porcentagens
    sum_porc <- sum(lista[[a]][,3])

    # diferen?a entre as porcentagens somada considerando 100
    sum_porc <- 100 - sum_porc

    if(sum_porc > 0){

      lista[[a]][1,3] <- lista[[a]][1,3] + sum_porc

    }else if(sum_porc < 0){

      lista[[a]][1,3] <- lista[[a]][1,3] - sum_porc
    }
    # Adicionando total, soma dos absolutos e 100%
    lista[[a]][dim(lista[[a]])[1]+1,3] <- 100
    lista[[a]][dim(lista[[a]])[1],2] <- sum_abs
    lista[[a]][dim(lista[[a]])[1],1] <- "Total"
  }

  return(lista)
}
FreqR_MFrase <- function(frases,texto_char){

  FR_Frase <- function(frase, texto){

    cont = 0

    # transforma o texto em um vetor de palavras
    word_texto <- words(texto)

    # transforma a frase em um vetor de palavras
    word_frase <- words(frase)

    vetfr = 0

    i=1

    for(i in 1:length(word_texto)){

      k=1

      if(word_frase[k]==word_texto[i]){

        cont=1

        if(length(word_frase)>=2){

          for(k in 2:length(word_frase)){

            if(i+length(word_frase)-1 <= length(word_texto)){

              if(word_frase[k]==word_texto[i+k-1]){

                cont=cont+1

              }
            }
          }
        }


      }
      if(cont==length(word_frase)){

        vetfr <- 1

      }

      cont=0
    }


    return(vetfr)

  }

  FreqR <- c()

  for(j in 1:length(frases)){

    vet <- c()

    for(p in 1:length(texto_char)){

      vet <- append(vet,FR_Frase(frases[j],texto_char[p]))

    }
    FreqR <- cbind(FreqR,vet)
  }

  num <- 0

  for (j in 1:dim(FreqR)[1]) {

    if(sum(FreqR[j,])>=1){

      num <- num+1

    }
  }

  if(length(frases)>=2){

    frases <- paste(frases,collapse = "/")

  }


  return(data.frame("Frase"=frases,"FreqR"=num/length(texto_char)))

}
Min_Char_Ngram <- function(texto, Numwords){

  comentario <- c()

  for(i in 1:length(texto)){

    text <- words(texto[i])

    if(length(text) >= Numwords){

      comentario <- append(comentario,texto[i])
    }

  }

  comentario <-na.exclude(comentario)

  comentario <- as.character(comentario)

  return(comentario)
}
Achar_Substituir <- function(achar, substituir, texto_char){

  for (i in 1:length(texto_char)){

    sp <- words(texto_char[i])

    for (j in 1:length(sp)) {

      for (k in 1:length(achar)) {

        if(sp[j] == achar[k]){

          sp[j]<- substituir

        }
      }

    }

    texto_char[i] <- str_c(sp, collapse = " ")

  }

  return(texto_char)
}
select_word_vetor <- function(palavra,vetor, posicao){

  # variavel vai guardar a lista de vetores que contem a palavra
  # desejada
  vet <- c()

  for (i in 1:length(vetor[,1])) {

    pal <- words(vetor[i,1])

    if(palavra==pal[posicao]){

      vet <- append(vet, i)
    }
  }

  vetor <- vetor[vet,]

  return(vetor)
}


get_polaridade <- function(x) {
  sentimento <- get_word_sentiment(x)
  texto <- "Word not present in dataset"
  polaridades <- c(ifelse(sentimento$oplexicon_v3.0 == texto, 0, sentimento$oplexicon_v3.0$polarity),
                   ifelse(sentimento$sentilex == texto, 0, sentimento$sentilex$polarity))
  return(sign(sum(polaridades)))
}
get_polaridade_vec <- Vectorize(get_polaridade, SIMPLIFY = FALSE)


plots<-function(x, nome){

my_table<- x %>%
  mutate(ID = 1:nrow(x))%>%
  select(ID, ngrams, freq)
colnames(my_table)<-c("id", "term", "freq")

dtm<-my_table %>%
  cast_dtm(id, term, freq)


ap_lda <- LDA(dtm , k = 4, control = list(seed = 123))
terms(ap_lda, 10)
head(topics(ap_lda), 20)
ap_topics <- tidy(ap_lda, matrix = "beta")

ap_top_terms <- ap_topics %>%
  group_by(topic) %>%
  top_n(20, beta) %>%
  ungroup() %>%
  arrange(topic, -beta)

ap_top_terms %>%
  mutate(term = reorder(term, beta)) %>%
  ggplot(aes(term, beta, fill = factor(topic))) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~ topic, scales = "free") +
  coord_flip()
ggsave(paste0(nome, "_topicos.png"))

beta_spread <- ap_topics %>%
  mutate(topic = paste0("topic", topic)) %>%
  spread(topic, beta) %>%
  filter(topic1 > .001 | topic2 > .001) %>%
  mutate(log_ratio = log2(topic2 / topic1))


beta_spread %>%
  group_by(direction = log_ratio > 0) %>%
  top_n(10, abs(log_ratio)) %>%
  ungroup() %>%
  mutate(term = reorder(term, log_ratio)) %>%
  ggplot(aes(term, log_ratio)) +
  geom_col() +
  labs(y = "Razão logarítmica de beta no tópico 2 / tópico 1") +
  coord_flip()
ggsave(paste0(nome, "_topicos_log.png"))



x %>%
  head(40) %>%
  mutate(ngrams = reorder(ngrams, freq)) %>%
  ggplot(aes(ngrams, freq)) +
  geom_col(fill = "lightblue") +
  scale_y_continuous(labels = comma_format()) +
  coord_flip() +
  labs(title = paste0(nome),
       y = "Frequencia Absoluta")
  ggsave(paste0(nome, "_histograma.png"))


}
