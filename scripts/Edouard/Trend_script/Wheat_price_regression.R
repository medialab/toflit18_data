
### Chargement des différents packages utilisés
### S'ils ne sont pas installés sur la machine, procéder à leur installation 
### via la commande install.packages("nom_du_package")

library(dplyr)
library(tidyverse)
library(stringr)
library(readr)
library(pracma)


### Chargement des données de prix des commodités

Wheat_price <- read.xlsx("./scripts/Edouard/Wheat_price/Wheat_prices_FRANCE(Epstein-Federico-Schulze-Volckart_data-base).xlsx")


Index_res <- read.csv2("./scripts/Edouard/Index_results.csv", row.names = NULL, dec = ",")



for (Ville_cons in c("Marseille", "Bordeaux", "Rennes")) {

  Index_res_ville <- Index_res %>%
    ### On conserve uniquement la baseline
    filter(Ville == Ville_cons, Exports_imports == "Imports", Outliers == T & Outliers_coef == 10 & Trans_number == 0 & Prod_problems == F &
             Product_select == F & Remove_double == T & Ponderation == T & Pond_log == F) %>%
    select(c("year", "Index_value"))
  
  
  Index_and_commodity <- merge(Index_res_ville, Wheat_price[, c("Market", Ville_cons)], 
                               by.x = "year", by.y = "Market", all.x = T)
  names(Index_and_commodity) <- c("year", "Index_value", "Wheat_price")
  
  
  print(Ville_cons)
  reg <- lm(Index_value ~ Wheat_price, data = Index_and_commodity)
  print(summary(reg))
  
  
  plot(Index_value ~ year, data = Index_and_commodity, type = "o")
  plot(Wheat_price ~ year, data = Index_and_commodity, type = "o")
  
  print(cor(Index_and_commodity, use = "complete.obs"))
  

}


"Nantes" = "Chateau-Gontier"

