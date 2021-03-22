library(dplyr)
library(tidyverse)
library(stringr)
library(readr)
library(pracma)

library(hpiR)

### A définir
setwd("C:/Users/pignede/Documents/GitHub/toflit18_data")
### setwd("/Users/Edouard/Dropbox (IRD)/IRD/Missions/Marchandises_18eme")


rm(list = ls())

### On charge la fonction de filtrage
source("./scripts/Edouard/Filtrage.R")
source("./scripts/Edouard/Ventes_repetees_ponderees.R")


for (Ville in c("Nantes", "Marseille", "Bordeaux", "La Rochelle")) {
  for (Type in c("Imports", "Exports")) {
    
  Index1 <-  Calcul_pond_index(Ville = Ville,  ### Choix du port d'étude
                               Exports_imports = Type,
                               Outliers = T, ### On retire les outliers 
                               Outliers_coef = 3.5, ### Quel niveau d'écart inter Q garde-t-on
                               Trans_number = 0, ### On retire les produits vendus moins de Trans_number fois
                               ### On conserve les Importations ou les Exportations
                               Prod_problems = T,
                               Product_select = T,
                               Remove_double = F,
                               Ponderation = T)
  
  
  Index2 <-  Calcul_pond_index(Ville = Ville,  ### Choix du port d'étude
                               Exports_imports = Type,
                               Outliers = T, ### On retire les outliers
                               Outliers_coef = 3.5, ### Quel niveau d'écart inter Q garde-t-on
                               Trans_number = 0, ### On retire les produits vendus moins de Trans_number fois
                               ### On conserve les Importations ou les Exportations
                               Prod_problems = T,
                               Product_select = T,
                               Remove_double = F,
                               Ponderation = F)
  
  print(c(Ville, Type))

  try(print(cor(Index1, Index2, use = "complete.obs")))
  
  Index1 <- remove_missing(Index1)
  Index2 <- remove_missing(Index2)
  plot(Index1$year, Index1$Index, main = "Index1", type = "o")
  plot(Index2$year, Index2$Index, main = "Index2", type = "o")

  }
}



Calcul_index <- function(Ville,  ### Choix du port d'étude
                         Exports_imports,
                         Outliers = F, ### conservation des outliers 
                         Outliers_coef = 3.5, ### Quel niveau d'écart inter Q garde-t-on
                         Trans_number = 0, ### On retire les produits vendus moins de Trans_number fois
                         ### On conserve les Importations ou les Exportations
                         Prod_problems = T,
                         Product_select = F, ### Conserve-t-on les produits avec des différences de prix très importants
                         Remove_double = F) 
{
  
  Data_filter <- Data_filtrage(Ville = Ville,  ### Choix du port d'étude
                               Outliers = Outliers, ### conservation des outliers 
                               Outliers_coef = Outliers_coef, ### Quel niveau d'écart inter Q garde-t-on
                               Trans_number = Trans_number, ### On retire les produits vendus moins de Trans_number fois
                               Exports_imports = Exports_imports, ### On conserve les Importations ou les Exportations
                               Prod_problems = Prod_problems,
                               Product_select = Product_select,
                               Remove_double = Remove_double) ### Conserve-t-on les produits avec des différences de prix très importants
  
  
  
  ### Creation des colonnes de colonnes
  Data_period <- dateToPeriod(trans_df = Data_filter,
                              date = 'Date',
                              periodicity = 'yearly')
  
  
  ### Création de la base de données des transactions considérées
  Data_trans <- rtCreateTrans(trans_df = Data_period,
                              prop_id = "id_prod_simp",
                              trans_id = "id_trans",
                              price = "unit_price_metric",
                              min_period_dist = 0,
                              seq_only = T)
  
  
  ### Application du modèle
  rt_model <- hpiModel(model_type = "rt",
                       hpi_df = Data_trans,
                       estimator = "weighted",
                       log_dep = T,
                       trim_model = F,
                       mod_spec = NULL)
  
  ### Calacul de l'indice
  rt_index <- modelToIndex(rt_model)
  rt_index$numeric <- as.numeric(rt_index$name)
  rt_index$period <- as.numeric(rt_index$name)
  
  rt_index$value <- na_if(rt_index$value, Inf) 
  
  ### Smooth index
  smooth_index <- smoothIndex(rt_index,
                              order = 5,
                              in_place = T)
  
  ### Affichage du résultat
  ### Indice brut
  plot(rt_index, show_imputed = T)
  ### Smooth index
  plot(smooth_index, smooth = T)
  
  
  
  ### plotting without imputed value
  rt_index_correct <- data.frame("value" = rt_index$value,
                                 "period" = rt_index$numeric,
                                 "imputed" = rt_index$imputed)

  return(rt_index_correct)
  
}







Calcul_pond_index  <- function(Ville,  ### Choix du port d'étude
                               Exports_imports,
                               Outliers = F, ### conservation des outliers 
                               Outliers_coef = 3.5, ### Quel niveau d'écart inter Q garde-t-on
                               Trans_number = 0, ### On retire les produits vendus moins de Trans_number fois
                               ### On conserve les Importations ou les Exportations
                               Prod_problems = T,
                               Product_select = F, ### Conserve-t-on les produits avec des différences de prix très importants
                               Remove_double = F,
                               Ponderation = F) 
{
  
  Data_filter <- Data_filtrage(Ville = Ville,  ### Choix du port d'étude
                               Outliers = Outliers, ### conservation des outliers 
                               Outliers_coef = Outliers_coef, ### Quel niveau d'écart inter Q garde-t-on
                               Trans_number = Trans_number, ### On retire les produits vendus moins de Trans_number fois
                               Exports_imports = Exports_imports, ### On conserve les Importations ou les Exportations
                               Prod_problems = Prod_problems,
                               Product_select = Product_select,
                               Remove_double = Remove_double) ### Conserve-t-on les produits avec des différences de prix très importants
  
  ### Calcul des pondérations
  Product_pond <- Data_filter %>%
    group_by(id_prod_simp) %>%
    summarize(Value_tot_log = log(sum(quantities_metric*unit_price_metric)),
              Value_tot = sum(quantities_metric*unit_price_metric))
  
  ### On 
  Product_pond$Value_part_log <- round(10000 * Product_pond$Value_tot_log / sum(Product_pond$Value_tot_log, na.rm = T)) 
  Product_pond$Value_part <- round(10000 * Product_pond$Value_tot / sum(Product_pond$Value_tot, na.rm = T)) 
  
  
  
  ### Creation de la colonne des périodes
  Data_period <- dateToPeriod(trans_df = Data_filter,
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
    reg <- lm(price_diff ~ time_matrix + 0, weights = Data_trans$Value_part)
  } else {
    reg <- lm(price_diff ~ time_matrix + 0)
  }
  reg$coefficients[1] = 0
  
  
  rt_pond_index <- data.frame("year" = seq(min(Data_filter$year), min(Data_filter$year) + length(reg$coefficients) - 1),
                              "Index" = 100*exp(reg$coefficients),
                              row.names = NULL)
  
  return(rt_pond_index)
  
}


