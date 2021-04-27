
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
           

Regression_global <- list()

for (Type in c("Imports", "Exports")) {

  for (Filtre_ville in c(TRUE, FALSE)) {


    Index <- Recuperation_Index_global(Filtre_ville = Filtre_ville, Exports_imports = Type)
    
    
    Index <- merge(Index, War_data_frame,
                   "year" = "year",
                   all.x = T, all.y = F)
    
    
    trend <- lm(log(Index) ~ year + War_non_ter, 
                weight = Part_value_national, data = Index)
    
    trend_duree <- lm(log(Index) ~ year + War_non_ter + War_duree_non_ter, 
                     weight = Part_value_national, data = Index)
    
    if (Type == "Imports") {
      if (Filtre_ville) {
        Regression_global[[paste0("trend_Imports_Filtre_ville")]] = trend
        Regression_global[[paste0("trend_duree_Imports_Filtre_ville")]] = trend_duree
        
      } else {
        Regression_global[[paste0("trend_Imports_sans_filtre")]] = trend
        Regression_global[[paste0("trend_duree_Imports_sans_filtre")]] = trend_duree
        
      }
    }
    if (Type == "Exports") {
      if (Filtre_ville) {
        Regression_global[[paste0("trend_Exports_Filtre_ville")]] = trend
        Regression_global[[paste0("trend_duree_Exports_Filtre_ville")]] = trend_duree
        
      } else {
        Regression_global[[paste0("trend_Exports_sans_filtre")]] = trend
        Regression_global[[paste0("trend_duree_Exports_sans_filtre")]] = trend_duree
        
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

    



for (Type in c("Imports", "Exports")) {
  
  if (Type == "Imports") {
    
    Imports_reg_trend <- list()
    Imports_reg_trend_duree <- list()
    
    for (Port in c("Marseille", "Bordeaux", "La Rochelle", "Nantes", "Bayonne", "Rennes")) {
    
      Index <- Recuperation_Index_port(Port = Port, Type = Type)
      
      
      Index <- merge(Index, War_data_frame,
                     "year" = "year",
                     all.x = T, all.y = F)
      
      
      trend <- lm(log(Index_value) ~ year + War_non_ter, 
                  weight = Part_value, data = Index)
      
      trend_duree <- lm(log(Index_value) ~ year + War_non_ter + War_duree_non_ter, 
                       weight = Part_value, data = Index)
      
      
      Imports_reg_trend[[paste0("trend_", Port, "_", Type)]] = trend
      Imports_reg_trend_duree[[paste0("trendduree_", Port, "_", Type)]] = trend_duree
      
      # 
      # 
      # Table = export_summs(trend, trend_duree, error.pos = "right",
      #                      model.names = c("Simple_trend", "dureeratic_trend"),
      #                      error_pos = "right")
      
     
    }     
      

    
    Table_trend = export_summs(Imports_reg_trend, error.pos = "right",
                               model.names = names(Imports_reg_trend),
                               error_pos = "right",
                               to.file = "xlsx",
                               file.name = "./scripts/Edouard/Regression_results/Regression_results_trend_imports.xlsx",
                               digits = 4)
    
    Table_trend_duree = export_summs(Imports_reg_trend_duree, error.pos = "right",
                                    model.names = names(Imports_reg_trend_duree),
                                    error_pos = "right",
                                    to.file = "xlsx",
                                    file.name = "./scripts/Edouard/Regression_results/Regression_results_trend_duree_imports.xlsx",
                                    digits = 4)
    
     print(Table_trend)
     print(Table_trend_duree)
     
  } 
  
  
  if (Type == "Exports") {
    
    Exports_reg_trend <- list()
    Exports_reg_trend_duree <- list()
    
    for (Port in c("Marseille", "Bordeaux", "La Rochelle", "Nantes", "Bayonne", "Rennes")) {
      
      Index <- Recuperation_Index_port(Port = Port, Type = Type)
      
      
      Index <- merge(Index, War_data_frame,
                     "year" = "year",
                     all.x = T, all.y = F)
      
      
      trend <- lm(log(Index_value) ~ year + War_non_ter, 
                  weight = Part_value, data = Index)
      
      trend_duree <- lm(log(Index_value) ~ year + War_non_ter + War_duree_non_ter, 
                       weight = Part_value, data = Index)
      
      
      Exports_reg_trend[[paste0("trend_", Port, "_", Type)]] = trend
      Exports_reg_trend_duree[[paste0("trendduree_", Port, "_", Type)]] = trend_duree
      
      # 
      # 
      # Table = export_summs(trend, trend_duree, error.pos = "right",
      #                      model.names = c("Simple_trend", "dureeratic_trend"),
      #                      error_pos = "right")
      
      
    }     
    
    
    
    Table_trend = export_summs(Imports_reg_trend, error.pos = "right",
                               model.names = names(Exports_reg_trend),
                               error_pos = "right",
                               to.file = "xlsx",
                               file.name = "./scripts/Edouard/Regression_results/Regression_results_trend_exports.xlsx",
                               digits = 4)
    
    Table_trend_duree = export_summs(Imports_reg_trend_duree, error.pos = "right",
                                    model.names = names(Exports_reg_trend_duree),
                                    error_pos = "right",
                                    to.file = "xlsx",
                                    file.name = "./scripts/Edouard/Regression_results/Regression_results_trend_duree_exports.xlsx",
                                    digits = 4)
    
    print(Table_trend)
    print(Table_trend_duree)
    
  } 
  
}







Termes_reg_trend <- list()
Termes_reg_trend_duree <- list()

for (Port in c("Marseille", "Bordeaux", "La Rochelle", "Nantes", "Bayonne", "Rennes")) {
  
  Termes_echange <- Recuperation_termes_echange(Port = Port)
  
  
  Termes_echange <- merge(Termes_echange, War_data_frame,
                 "year" = "year",
                 all.x = T, all.y = F)
  
  
  trend <- lm(log(Termes_echange_value) ~ year + War_non_ter, data = Termes_echange)
  
  trend_duree <- lm(log(Termes_echange_value) ~ year + War_non_ter + War_duree_non_ter, data = Termes_echange)
  
  
  Termes_reg_trend[[paste0("trend_", Port, "_")]] = trend
  Termes_reg_trend_duree[[paste0("trend_duree_", Port, "_")]] = trend_duree
  
  # 
  # 
  # Table = export_summs(trend, trend_duree, error.pos = "right",
  #                      model.names = c("Simple_trend", "dureeratic_trend"),
  #                      error_pos = "right")
  
  
}     



Table_trend = export_summs(Termes_reg_trend, error.pos = "right",
                           model.names = names(Termes_reg_trend),
                           error_pos = "right",
                           to.file = "xlsx",
                           file.name = "./scripts/Edouard/Regression_results/Regression_results_termes_echange_trend.xlsx",
                           digits = 4)

Table_trend_duree = export_summs(Termes_reg_trend_duree, error.pos = "right",
                                 model.names = names(Termes_reg_trend_duree),
                                 error_pos = "right",
                                 to.file = "xlsx",
                                 file.name = "./scripts/Edouard/Regression_results/Regression_results_termes_echange_trend_duree.xlsx",
                                 digits = 4)

print(Table_trend)
print(Table_trend_duree)





