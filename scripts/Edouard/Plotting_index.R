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


### Affichage de l'index pour les quatres villes suivantes


for (ville in c("Nantes", "Marseille", "Bordeaux", "La Rochelle")) {
  for (Type in c("Imports", "Exports")) {
    
    Plot_index(Ville = ville,  ### Choix du port d'étude
               Exports_imports = Type,
               Outliers = F, ### conservation des outliers 
               Outliers_coef = 3.5, ### Quel niveau d'écart inter Q garde-t-on
               Trans_number = 0, ### On retire les produits vendus moins de Trans_number fois
               ### On conserve les Importations ou les Exportations
               Prod_problems = T, ### Enleve-t-on les produits avec des différences de prix très importants
               Product_select = T,
               Remove_double = T)
    
    
  }
}


Plot_index(Ville = "Bordeaux",  ### Choix du port d'étude
           Exports_imports = "Exports",
           Outliers = F, ### conservation des outliers 
           Outliers_coef = 3.5, ### Quel niveau d'écart inter Q garde-t-on
           Trans_number = 0, ### On retire les produits vendus moins de Trans_number fois
           ### On conserve les Importations ou les Exportations
           Prod_problems = T,
           Product_select = T,
           Remove_double = T)







### Fonction qui plot l'indice de prix de la ville pour différents paramètres

Plot_index <- function(Ville,  ### Choix du port d'étude
                       Exports_imports,
                       Outliers = F, ### conservation des outliers 
                       Outliers_coef = 3.5, ### Quel niveau d'écart inter Q garde-t-on
                       Trans_number = 0, ### On retire les produits vendus moins de Trans_number fois
                        ### On conserve les Importations ou les Exportations
                       Prod_problems = T,
                       Product_select = F, ### Conserve-t-on les produits avec des différences de prix très importants
                       Remove_double = T) 
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
                              date = 'year',
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
  plot(subset(rt_index_correct, imputed == 0)$period,
       subset(rt_index_correct, imputed == 0)$value,
       type = "o",
       main = paste(Ville, Exports_imports, "/ Trans_number >", Trans_number, "/ Outliers =", Outliers),
       xlab = "Annee",
       ylab = "Indice de prix")

}



