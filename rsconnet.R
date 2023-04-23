
library(rsconnect)
install.packages("renv")
renv::init()
renv::status()


renv::dependencies()


rsconnect::setAccountInfo(name='8h163l-daphne-spier', token='09C2CA1977C3E13A239A5D45F8189365', secret='LdLWBiHKG849sbvbgzKxvdxhiTi5n32EWUJHb0Lm')
rsconnect::deployApp(appName = "shiny_text_analysis", appDir = "/Users/daphne/IC/Shiny/shiny_text")
