
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



### Partner_index_calcul remplie le csv : Composition_index_results qui comprend les valeurs de l'indice
### avec les paramètres par défaut triés par partenaires : Europe_et_Meditérranée ou reste du monde.

Partner_index_calcul <- function() 
  
{
  ### Création des lignes du csv 
  Index_pond <-  data.frame("Ville" = factor(),
                            "Exports_imports" = factor(),
                            "Partner" = factor(),
                            "year" = integer(),
                            "Index_value" = numeric(),
                            "Part_value" = numeric(),
                            "Part_flux" = numeric())
  
  ### Ecriture des lignes du csv
  write.csv2(Index_pond,
             "./scripts/Edouard/Partner_index_results.csv",
             row.names = F)
  
  
  
  ### Ajout au csv de la baseline et de la baseline + changement d'un paramètre pour chaque paramètre
  ### à l'aide de la fonction Add_new_parma défini ci-dessous
  Add_new_partner()
  Add_new_partner("Europe_et_Mediterranee")
  Add_new_partner("Reste_du_monde")
  
  
}



### Ajouter un nouvel index au csv en choisissant les paramètres désirés

Add_new_partner <- function(Partner = "All") 
{
  ### Création des titres des lignes
  Index_pond <-  data.frame("Ville" = factor(),
                            "Exports_imports" = factor(),
                            "Partner" = factor(),
                            "year" = integer(),
                            "Index_value" = numeric(),
                            "Part_value" = numeric(),
                            "Part_flux" = numeric())
  
  for (Ville in c("Nantes", "Marseille", "Bordeaux", "La Rochelle", "Bayonne", "Rennes")) {
    for (Type in c("Imports", "Exports")) {
      
      ### Calcul de l'index pour les paramètres choisis
      Index <- Filter_calcul_index(Ville = Ville,  ### Choix du port d'étude
                                   Exports_imports = Type, ### On conserve les Importations ou les Exportations
                                   Partner = Partner)
      
      ### A jout de l'index et des parts de flux et de valeur dans le commerce total, ainsi que la valeur des paramètres 
      ### au dataframe
      for (i in seq(1,dim(Index)[1])) {
        
        Index_pond <- Index_pond %>%
          add_row(Ville = Ville, 
                  Exports_imports = Type, 
                  Partner = Partner,
                  year = Index$year[i],
                  Index_value = Index$Index[i],
                  Part_value = Index$Part_value[i],
                  Part_flux = Index$Part_flux[i])
        
      }
    }
  }
  
  ### On charge les valeurs actuelles du csv
  Index_res <- read.csv2("./scripts/Edouard/Partner_index_results.csv", row.names = NULL)
  
  ### On ajoute le nouveau dataframe
  Index_res <- rbind(Index_res, Index_pond)
  ### On retire les lignes si elles sont déja présentes dans le csv
  ### Par défaut, le nouveau résultat met à jour le précédent
  Index_res <- Index_res[!duplicated(Index_res[ , 1:7], fromLast = T), ]
  
  ### On écrit le résulat dans le csv
  write.csv2(Index_res,
             "./scripts/Edouard/Partner_index_results.csv",
             row.names = F)
  
  
  
}



source("./scripts/Edouard/Indice_global_scripts/Indice_global_filtre_ville.R")

### On cree aussi un index pour l'indice global

Partner_index_global_calcul <- function()
{
  ### Création des lignes du csv 
  Index_pond <-  data.frame("Exports_imports" = factor(),
                            "Partner" = factor(),
                            "year" = integer(),
                            "Index_value" = numeric(),
                            "Part_value" = numeric(),
                            "Part_flux" = numeric())
  
  ### Ecriture des lignes du csv
  write.csv2(Index_pond,
             "./scripts/Edouard/Partner_index_results_global.csv",
             row.names = F)
  
  
  
  ### Ajout au csv de la baseline et de la baseline + changement d'un paramètre pour chaque paramètre
  ### à l'aide de la fonction Add_new_parma défini ci-dessous
  Add_new_partner_global()
  Add_new_partner_global("Europe_et_Mediterranee")
  Add_new_partner_global("Reste_du_monde")
  
  
}



### Ajout d'un nouveau secteur pour l'indice global

Add_new_partner_global <- function(Partner = "All") 
{
  ### Création des titres des lignes
  Index_pond <-  data.frame("Exports_imports" = factor(),
                            "Partner" = factor(),
                            "year" = integer(),
                            "Index_value" = numeric(),
                            "Part_value" = numeric(),
                            "Part_flux" = numeric())
  
  for (Type in c("Imports", "Exports")) {
    
    ### Calcul de l'index pour les paramètres choisis
    Index <- Filter_calcul_index(Exports_imports = Type, ### On conserve les Importations ou les Exportations
                                 Partner = Partner)
    
    ### A jout de l'index et des parts de flux et de valeur dans le commerce total, ainsi que la valeur des paramètres 
    ### au dataframe
    for (i in seq(1,dim(Index)[1])) {
      
      Index_pond <- Index_pond %>%
        add_row(Exports_imports = Type, 
                Partner = Partner,
                year = Index$year[i],
                Index_value = Index$Index[i],
                Part_value = Index$Part_value[i],
                Part_flux = Index$Part_flux[i])
      
      
    }
  }
  
  ### On charge les valeurs actuelles du csv
  Index_res <- read.csv2("./scripts/Edouard/Partner_index_results_global.csv", row.names = NULL)
  
  ### On ajoute le nouveau dataframe
  Index_res <- rbind(Index_res, Index_pond)
  ### On retire les lignes si elles sont déja présentes dans le csv
  ### Par défaut, le nouveau résultat met à jour le précédent
  Index_res <- Index_res[!duplicated(Index_res[ , 1:6], fromLast = T), ]
  
  ### On écrit le résulat dans le csv
  write.csv2(Index_res,
             "./scripts/Edouard/Partner_index_results_global.csv",
             row.names = F)
  
  
  
}
