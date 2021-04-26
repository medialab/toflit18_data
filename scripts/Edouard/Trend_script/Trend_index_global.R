
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
library(openxlsx)
library(officer)
library(flextable)

rm(list = ls())

### A définir
setwd("C:/Users/pignede/Documents/GitHub/toflit18_data")
### setwd("/Users/Edouard/Dropbox (IRD)/IRD/Missions/Marchandises_18eme")

### Chargement des fonctions de récuprétion des valeurs des indices
source("./scripts/Edouard/Trend_script/Recuperation_index_value.R")




Regression_global <- list()

for (Type in c("Imports", "Exports")) {

  for (Filtre_ville in c(TRUE, FALSE)) {


    Index <- Recuperation_Index_global(Filtre_ville = Filtre_ville, Exports_imports = Type)
    
    
    Index <- merge(Index, War_data_frame,
                   "year" = "year",
                   all.x = T, all.y = F)
    
    
    trend <- lm(log(Index) ~ year + War_var + War_duree, 
                weight = Part_value_national, data = Index)
    
    
    if (Type == "Imports") {
      if (Filtre_ville) {
        Regression_global[[paste0("trend_Imports_Filtre_ville")]] = trend
        
      } else {
        Regression_global[[paste0("trend_Imports_sans_filtre")]] = trend
        
      }
    }
    if (Type == "Exports") {
      if (Filtre_ville) {
        Regression_global[[paste0("trend_Exports_Filtre_ville")]] = trend
        
      } else {
        Regression_global[[paste0("trend_Exports_sans_filtre")]] = trend
        
      }
    }
    
    
  }
}    
    
Table = export_summs(Regression_global, error.pos = "right",
                 model.names = names(Regression_global),
                 error_pos = "right",
                 to.file = "xlsx",
                 file.name = "./scripts/Edouard/Regression_results/Regression_global.xlsx",
                 digits = 4)

print(Table)

    


