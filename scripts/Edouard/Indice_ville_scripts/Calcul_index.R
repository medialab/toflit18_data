
### Chargement des différents packages utilisés
### S'ils ne sont pas installés sur la machine, procéder à leur installation 
### via la commande install.packages("nom_du_package")

library(dplyr)
library(tidyverse)
library(stringr)
library(readr)
library(pracma)

library(openxlsx)

library(hpiR)


### A définir: emplacement du working directory
setwd("C:/Users/pignede/Documents/GitHub/toflit18_data")
### setwd("/Users/Edouard/Dropbox (IRD)/IRD/Missions/Marchandises_18eme")

### Nettoyage de l'espace de travail
rm(list = ls())

### On charge les fonctions des scripts Filtrage.R et Ventes_repetees_ponderees.R
source("./scripts/Edouard/Indice_ville_scripts/Ventes_repetees_ponderees.R")


### La fonction Update_base crée le csv Index_results.csv qui calcule l'indice des prix 
### pour l'ensemble des parmètres par défaut :
# Outliers = T,
# Outliers_coef = 3.5,
# Trans_number = 0,
# Prod_problems = F,
# Product_select = F,
# Remove_double = T,
# Ponderation = T,
# Pond_log = F
### ainsi que pour l'autre valeur de chaque paramètre avec les valueurs par défaut

Update_base <- function(Smooth = F) 
  
{
  ### Création des lignes du csv 
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
                            "Part_value" = numeric(),
                            "Part_flux" = numeric())
  
  if (!Smooth) {
  ### Ecriture des lignes du csv
  write.csv2(Index_pond,
             "./scripts/Edouard/Index_results.csv",
             row.names = F)
    
  } else {
    ### Ecriture des lignes du csv
    write.csv2(Index_pond,
               "./scripts/Edouard/Index_results_Smooth.csv",
               row.names = F)
  }
                            
                            
  
  ### Ajout au csv de la baseline et de la baseline + changement d'un paramètre pour chaque paramètre
  ### à l'aide de la fonction Add_new_parma défini ci-dessous
  Add_new_param(Smooth = Smooth)
  Add_new_param(Outliers = F, Smooth = Smooth)
  Add_new_param(Outliers_coef = 3.5, Smooth = Smooth)
  Add_new_param(Trans_number = 20, Smooth = Smooth)
  Add_new_param(Prod_problems = T, Smooth = Smooth)
  Add_new_param(Product_select = T, Smooth = Smooth)
  Add_new_param(Remove_double = F, Smooth = Smooth)
  Add_new_param(Ponderation = F, Smooth = Smooth)
  Add_new_param(Pond_log = T, Smooth = Smooth)


}
    
    
 
### Ajouter un nouvel index au csv en choisissant les paramètres désirés

Add_new_param <- function(Outliers = T,
                          Outliers_coef = 10,
                          Trans_number = 0,
                          Prod_problems = F,
                          Product_select = F,
                          Remove_double = T,
                          Ponderation = T,
                          Pond_log = F,
                          Smooth = F) 
{
  ### Création des titres des lignes
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
                            "Part_value" = numeric(),
                            "Part_flux" = numeric())
  
  for (Ville in c("Nantes", "Marseille", "Bordeaux", "La Rochelle", "Bayonne", "Rennes")) {
    for (Type in c("Imports", "Exports")) {
      
      ### Calcul de l'index pour les paramètres choisis
      Index <- Filter_calcul_index(Ville = Ville,  ### Choix du port d'étude
                                   Exports_imports = Type, ### On conserve les Importations ou les Exportations
                                   Outliers = Outliers, ### Retire-t-on les outliers ? 
                                   Outliers_coef = Outliers_coef, ### Quel niveau d'écart inter Q garde-t-on pour le calcul des outliers ?
                                   Trans_number = Trans_number, ### On retire les produits vendus moins de Trans_number fois
                                   Prod_problems = Prod_problems, ### Enleve-t-on les produits avec des différences de prix trop importantes
                                   Product_select = Product_select, ### Conserve-t-on uniquement les produits sélectionnés par Loïc
                                   Remove_double = Remove_double, ### Retire-t-on les doublons
                                   Ponderation = Ponderation, ### Calcul de l'indice avec ponderation ?
                                   Pond_log = Pond_log,
                                   Smooth = Smooth)
      
      ### A jout de l'index et des parts de flux et de valeur dans le commerce total, ainsi que la valeur des paramètres 
      ### au dataframe
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
                  Part_value = Index$Part_value[i],
                  Part_flux = Index$Part_flux[i])
        
      }
    }
  }
  
  if (!Smooth) {
    ### On charge les valeurs actuelles du csv
    Index_res <- read.csv2("./scripts/Edouard/Index_results.csv", row.names = NULL)
    
    ### On ajoute le nouveau dataframe
    Index_res <- rbind(Index_res, Index_pond)
    ### On retire les lignes si elles sont déja présentes dans le csv
    ### Par défaut, le nouveau résultat met à jour le précédent
    Index_res <- Index_res[!duplicated(Index_res[ , 1:11], fromLast = T), ]
    
    ### On écrit le résulat dans le csv
    write.csv2(Index_res,
              "./scripts/Edouard/Index_results.csv",
              row.names = F)
  
  } else {
    ### On charge les valeurs actuelles du csv
    Index_res <- read.csv2("./scripts/Edouard/Index_results_Smooth.csv", row.names = NULL)
    
    ### On ajoute le nouveau dataframe
    Index_res <- rbind(Index_res, Index_pond)
    ### On retire les lignes si elles sont déja présentes dans le csv
    ### Par défaut, le nouveau résultat met à jour le précédent
    Index_res <- Index_res[!duplicated(Index_res[ , 1:11], fromLast = T), ]
    
    ### On écrit le résulat dans le csv
    write.csv2(Index_res,
               "./scripts/Edouard/Index_results_Smooth.csv",
               row.names = F)
  }
  
}
    
    
    
    
    