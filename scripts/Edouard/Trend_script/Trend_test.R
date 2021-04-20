
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


rm(list = ls())

### A définir
setwd("C:/Users/pignede/Documents/GitHub/toflit18_data")
### setwd("/Users/Edouard/Dropbox (IRD)/IRD/Missions/Marchandises_18eme")


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
                             TRUE ~ 0))


Index <- Recuperation_Index()


Index <- merge(Index, War_data_frame,
               "year" = "year",
               all.x = T, all.y = F)


trend <- lm(log(Index) ~ year + War_var, 
            weight = Part_value_national, data = Index)

trend_quad <- lm(log(Index) ~ year + War_var + War_var * year, 
                 weight = Part_value_national, data = Index)



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


Recuperation_index_port <- function(Port = "Marseille",
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



