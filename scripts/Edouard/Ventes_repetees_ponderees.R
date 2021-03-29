library(dplyr)
library(tidyverse)
library(stringr)
library(readr)
library(pracma)

library(hpiR)



### Calcul des indices de prix : 1er exemple

### A définir
setwd("C:/Users/pignede/Documents/GitHub/toflit18_data")
### setwd("/Users/Edouard/Dropbox (IRD)/IRD/Missions/Marchandises_18eme")


rm(list = ls())

### On charge la fonction de filtrage
source("./scripts/Edouard/Filtrage.R")

### On filtre la bdd courante :


# Data_filter <- Data_filtrage(Ville = "Marseille",  ### Choix du port d'étude
#                              Exports_imports = "Imports", ### On conserve les Importations ou les Exportations
#                              Outliers = T, ### conservation des outliers 
#                              Outliers_coef = 3.5, ### Quel niveau d'écart inter Q garde-t-on
#                              Trans_number = 0, ### On retire les produits vendus moins de Trans_number fois
#                              Prod_problems = T, ### Enleve-t-on les produits avec des différences de prix très importants
#                              Product_select = F, ### Selection des produits par Charles Loic
#                              Remove_double = T) ### On retire les doublons

### Calcul l'indice des ventes répétées avec Ponderation par la part dans le commerce (Ponderation == T)
### ou avec pondération par le log de la part dans le commerce (Ponderation == T & Pond_log = T)

Calcul_index <- function(Data, Ponderation = T, Pond_log = T) {

  ### Calcul des pondérations
  Product_pond <- Data %>%
    group_by(id_prod_simp) %>%
    summarize(Value_tot_log = log(sum(value)),
              Value_tot = sum(value))
  
  ### On 
  Product_pond$Value_part_log <- round(10000 * Product_pond$Value_tot_log / sum(Product_pond$Value_tot_log, na.rm = T)) 
  Product_pond$Value_part <- round(10000 * Product_pond$Value_tot / sum(Product_pond$Value_tot, na.rm = T)) 
  
  
  
  ### Creation de la colonne des périodes
  Data_period <- dateToPeriod(trans_df = Data,
                              date = 'Date',
                              periodicity = 'yearly')
  
  
  ### Creation de la base de données des transactions
  
  ### Création de la base de données des transactions considérées
  Data_trans <- rtCreateTrans(trans_df = Data_period,
                              prop_id = "id_prod_simp",
                              trans_id = "id_trans",
                              price = "unit_price_metric",
                              min_period_dist = 0,
                              seq_only = T)
  
  
  
  price_diff <- log(Data_trans$price_2) - log(Data_trans$price_1)
  time_matrix <- rtTimeMatrix(Data_trans)
  
  Data_trans <- Data_trans %>%
    left_join(Product_pond, by = c("prop_id" = "id_prod_simp"))
  
  if (Ponderation) {
    if (Pond_log) {
      reg <- lm(price_diff ~ time_matrix + 0, weights = Data_trans$Value_part_log)
    } else {
      reg <- lm(price_diff ~ time_matrix + 0, weights = Data_trans$Value_part)
    }
  } else {
    reg <- lm(price_diff ~ time_matrix + 0)
  }
      
  rt_pond_index <- data.frame("year" = seq(min(Data$year), min(Data$year) + length(reg$coefficients)),
                              "Index" = 100*exp(c(0, reg$coefficients)),
                              row.names = NULL)
  
  return(rt_pond_index)

}

Plot_index <- function(Index, Ville = "", Type = "", smooth = F, show_NA = F) {
  Index = remove_missing(Index)
  plot(Index, type = "o", main = paste(Ville, Type))
  
  
}


Filter_calcul_index <- function(Ville,  ### Choix du port d'étude
                                Exports_imports = "Imports", ### On conserve les Importations ou les Exportations
                                Outliers = T, ### Retire-t-on les outliers ? 
                                Outliers_coef = 3.5, ### Quel niveau d'écart inter Q garde-t-on pour le calcul des outliers ?
                                Trans_number = 0, ### On retire les produits vendus moins de Trans_number fois
                                Prod_problems = T, ### Enleve-t-on les produits avec des différences de prix trop importantes
                                Product_select = F, ### Conserve-t-on uniquement les produits sélectionnés par Loïc
                                Remove_double = T, ### Retire-t-on les doublons
                                Ponderation = T, ### Calcul de l'indice avec ponderation ?
                                Pond_log = T) ### Si ponderation == T, pondère-t-on par le log de la part dans la valeur totale ?
{
  Data_filter <- Data_filtrage(Ville = Ville,  ### Choix du port d'étude
                               Exports_imports = Exports_imports, ### On conserve les Importations ou les Exportations
                               Outliers = Outliers, ### conservation des outliers 
                               Outliers_coef = Outliers_coef, ### Quel niveau d'écart inter Q garde-t-on
                               Trans_number = Trans_number, ### On retire les produits vendus moins de Trans_number fois
                               Prod_problems = Prod_problems, ### Enleve-t-on les produits avec des différences de prix très importants
                               Product_select = Product_select, ### Selection des produits par Charles Loic
                               Remove_double = Remove_double) ### On retire les doublons
  

  rt_index <- Calcul_index(Data_filter, Ponderation = Ponderation, Pond_log = Pond_log)
  
  Plot_index(rt_index, Ville = Ville, Type = Exports_imports)
  
  Data_part <- Data_filter %>%
    group_by(year) %>%
    summarise(Part_value = mean(Part_value),
              Part_flux = mean(Part_flux)) %>%
    as.data.frame()
  
  
  rt_index <- merge(rt_index, Data_part[ , c("year", "Part_value", "Part_flux")], "year" = "year", all.x = T,
                    all.y = F)
  
  return(rt_index)
  
}








### On observe l'évolution des prix unitaires de tous les produits importés
### plus de xxxx fois sur la période
# for (prod in levels(Data_filter$product_simplification)) {
#   
#   Data_prod <- subset(Data_filter, product_simplification == prod)
#   
#   if (dim(Data_prod)[1] > 20) {
#     
#     plot(Data_prod$year, Data_prod$unit_price_metric, main = prod)
#   }
# }
