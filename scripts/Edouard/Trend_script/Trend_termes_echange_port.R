
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




Termes_reg_trend <- list()
Termes_reg_trend_duree <- list()

for (Port in c("Marseille", "Bordeaux", "La Rochelle", "Nantes", "Bayonne", "Rennes")) {
  
  Termes_echange <- Recuperation_termes_echange(Port = Port)
  
  
  Termes_echange <- merge(Termes_echange, War_data_frame,
                          "year" = "year",
                          all.x = T, all.y = F)
  
  
  trend <- lm(log(Termes_echange_value) ~ War_non_ter, data = Termes_echange)
  
  trend_duree <- lm(log(Termes_echange_value) ~ War_non_ter + War_duree_non_ter, data = Termes_echange)
  
  
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





