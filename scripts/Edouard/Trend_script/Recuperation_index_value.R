
### Chargement des différents packages utilisés
### S'ils ne sont pas installés sur la machine, procéder à leur installation 
### via la commande install.packages("nom_du_package")

library(dplyr)
library(tidyverse)
library(stringr)
library(readr)
library(pracma)

library(hpiR)
library(modern)

library(jtools)


rm(list = ls())

### A définir
setwd("C:/Users/pignede/Documents/GitHub/toflit18_data")
### setwd("/Users/Edouard/Dropbox (IRD)/IRD/Missions/Marchandises_18eme")

### Création de la variable guerre et de la variable duree de la guerre
War_data_frame <- data.frame("year" = 1688:1815)

War_data_frame <- War_data_frame %>%
  mutate(War_var = case_when((year >= 1688 & year <= 1697) ~ 1,
                             (year >= 1702 & year <= 1713) ~ 1,
                             (year >= 1733 & year <= 1738) ~ 1,
                             (year >= 1740 & year <= 1744) ~ 1,
                             (year >= 1744 & year <= 1748) ~ 1,
                             (year >= 1756 & year <= 1763) ~ 1,
                             (year >= 1778 & year <= 1783) ~ 1,
                             (year >= 1793 & year <= 1802) ~ 1,
                             (year >= 1803 & year <= 1807) ~ 1,
                             (year >= 1807 & year <= 1815) ~ 1,
                             TRUE ~ 0)) %>%
  mutate(War_non_ter = case_when((year >= 1744 & year <= 1748) ~ 1,
                                 (year >= 1756 & year <= 1763) ~ 1,
                                 (year >= 1778 & year <= 1783) ~ 1,
                                 (year >= 1793 & year <= 1802) ~ 1,
                                 (year >= 1803 & year <= 1807) ~ 1,
                                 TRUE ~ 0)) %>%
  mutate(War_duree = c(0:9, rep(0, 4), 0:11, rep(0, 19), 0:5, rep(0, 1), 0:3, 0:4,
                       rep(0,7), 0:7, rep(0,14), 0:5, rep(0,9), 0:9, 0:4, 0:7),
         War_duree_non_ter = c(rep(0, 56), 0:4,
                               rep(0,7), 0:7, rep(0,14), 0:5, rep(0,9), 0:9, 0:4, 0:7))


### Récupère les valeurs
Recuperation_Index_global <- function(Filtre_ville = T,
                                      Exports_imports = "Imports")
  
{
  if (Filtre_ville) {
    if(Exports_imports == "Imports") {
      Index = read.csv2("./scripts/Edouard/Indice_global_value/Indice_global_filtre_ville_imports.csv")
    } else {
      Index = read.csv2("./scripts/Edouard/Indice_global_value/Indice_global_filtre_ville_exports.csv")
    }
  }
  
  if (!Filtre_ville) {
    if(Exports_imports == "Imports") {
      Index = read.csv2("./scripts/Edouard/Indice_global_value/Indice_global_sans_filtre_imports.csv")
    } else {
      Index = read.csv2("./scripts/Edouard/Indice_global_value/Indice_global_sans_filtre_exports.csv")
    }
  }
  
  return(Index)
  
  
}


Recuperation_Index_port <- function(Port = "Marseille",
                                    Type = "Imports")
  
{
  Index <- read.csv2("./scripts/Edouard/Index_results.csv")
  
  Index <- Index %>%
    filter(Ville == Port,
           Exports_imports == Type,
           Outliers == T,
           Outliers_coef == 10,
           Trans_number == 0,
           Prod_problems == F,
           Product_select == F,
           Remove_double == T,
           Ponderation == T,
           Pond_log == F) %>%
    select("year", "Index_value", "Part_value", "Part_flux")
  
  return(Index)
}



Recuperation_termes_echange <- function(Port = "Marseille")
  
{
  Termes_echange = read.csv2("./scripts/Edouard/Termes_echange_results.csv")
  
  Termes_echange <- Termes_echange %>%
    filter(Ville == Port) %>%
    select("year", "Termes_echange_value")
  
  return(Termes_echange)
}
