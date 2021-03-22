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

Index_pond <-  data.frame("Ville" = factor(),
                          "Exports_imports" = factor(),
                          "Outliers" = logical(),
                          "Outliers_coef" = numeric(),
                          "Trans_number" = integer(),
                          "Prod_problems" = logical(),
                          "Product_select" = logical(),
                          "Remove_double" = logical(),
                          "Ponderation" = logical(),
                          "Pond_log" = logical(),
                          "year" = integer(),
                          "Index_value" = numeric(),
                          "Part_value" = numeric())

for (Ville in c("Nantes", "Marseille", "Bordeaux", "La Rochelle")) {
  for (Type in c("Imports", "Exports")) {
    
    Outliers = T
    Outliers_coef = 10
    Trans_number = 0
    Prod_problems = T
    Product_select = F
    Remove_double = T
    Ponderation = T
    Pond_log = F
    
    Index <- Filter_calcul_index(Ville = Ville,  ### Choix du port d'étude
                                 Exports_imports = Type, ### On conserve les Importations ou les Exportations
                                 Outliers = Outliers, ### Retire-t-on les outliers ? 
                                 Outliers_coef = Outliers_coef, ### Quel niveau d'écart inter Q garde-t-on pour le calcul des outliers ?
                                 Trans_number = Trans_number, ### On retire les produits vendus moins de Trans_number fois
                                 Prod_problems = Prod_problems, ### Enleve-t-on les produits avec des différences de prix trop importantes
                                 Product_select = Product_select, ### Conserve-t-on uniquement les produits sélectionnés par Loïc
                                 Remove_double = Remove_double, ### Retire-t-on les doublons
                                 Ponderation = Ponderation, ### Calcul de l'indice avec ponderation ?
                                 Pond_log = Pond_log)
    
    for (i in seq(1,dim(Index)[1])) {
      
      Index_pond <- Index_pond %>%
        add_row(Ville = Ville, 
                Exports_imports = Type, 
                Outliers = Outliers, 
                Outliers_coef = Outliers_coef,
                Trans_number = Trans_number,
                Prod_problems = Prod_problems,
                Product_select = Product_select,
                Remove_double = Remove_double,
                Ponderation = Ponderation,
                Pond_log = Pond_log,
                year = Index$year[i],
                Index_value = Index$Index[i],
                Part_value = Index$Part_value[i])
      
    }
  }
}


Index_res <- read.csv("./scripts/Edouard/Index_results.csv", row.names = 1)

Index_res <- rbind(Index_res, Index_pond)
Index_res <- Index_res[!duplicated(Index_res[ , 1:11]), ]


write.csv(Index_res,
          "./scripts/Edouard/Index_results.csv")

    
    
    
    
    
    
    
    