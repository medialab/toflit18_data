
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
library(trend)
library(smooth)

library(jtools)


rm(list = ls())

### A définir
setwd("C:/Users/pignede/Documents/GitHub/toflit18_data")
### setwd("/Users/Edouard/Dropbox (IRD)/IRD/Missions/Marchandises_18eme")

### Chargement des fonctions de récuprétion des valeurs des indices
source("./scripts/Edouard/Trend_script/Recuperation_index_value.R")



for (Type in c("Imports", "Exports")) {
  
    Index_reg_trend <- list()
    
    for (Port in c("Marseille", "Bordeaux", "La Rochelle", "Nantes", "Bayonne", "Rennes")) {
      
      Index <- Recuperation_Index_port(Port = Port, Type = Type)
      
      
      Index <- merge(Index, War_data_frame,
                     "year" = "year",
                     all.x = T, all.y = F)
      
      
      trend <- lm(log(Index_value) ~ War_non_ter + War_duree_non_ter, 
                  weight = Part_value, data = Index)
      
      
      Index_reg_trend[[paste0("trend_", Port, "_", Type)]] = trend
      
    }     
    
    
    
    Table_trend = export_summs(Index_reg_trend, error.pos = "right",
                               model.names = names(Index_reg_trend),
                               error_pos = "right",
                               to.file = "xlsx",
                               file.name = paste0("./scripts/Edouard/Regression_results/Regression_results_trend_", Type, ".xlsx"),
                               digits = 4)
    
    print(Table_trend)
    
    
    matrix_coefficient_test <- matrix(nrow = length(Index_reg_trend), ncol = length(Index_reg_trend),
                                          dimnames = list(names(Index_reg_trend), names(Index_reg_trend)))
    
    Coef = 2
    
    
    for (model1 in seq(1,length(Index_reg_trend))) {
      for (model2 in seq(1, length(Index_reg_trend))) {
        
        matrix_coefficient_test[model1, model2] = (Index_reg_trend[[model1]]$coefficients[Coef] - Index_reg_trend[[model2]]$coefficients[Coef]) /
          sqrt(diag(vcov(Index_reg_trend[[model1]]))[Coef] + diag(vcov(Index_reg_trend[[model2]]))[Coef])
        
      }
    }
    
  print(matrix_coefficient_test)
  
}


