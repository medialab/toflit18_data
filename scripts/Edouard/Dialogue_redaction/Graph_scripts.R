
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

library(corrplot)

### A définir: emplacement du working directory
setwd("C:/Users/pignede/Documents/GitHub/toflit18_data")
### setwd("/Users/Edouard/Dropbox (IRD)/IRD/Missions/Marchandises_18eme")

### Nettoyage de l'espace de travail
rm(list = ls())



### Graphique de traçage des différents indices sur une même figure


Index_res <- read.csv2("./scripts/Edouard/Index_results.csv", row.names = NULL, dec = ",")


Index_res <- Index_res %>% 
  filter(Outliers == T & Outliers_coef == 10 & Trans_number == 0 & Prod_problems == F &
            Product_select == F & Remove_double == T & Ponderation == T & Pond_log == F) %>%
  select(c("Ville", "Exports_imports", "year", "Index_value")) %>%
  filter(Ville != "Rennes")


Index_res_villes <- pivot_wider(Index_res, names_from = "Ville",
                                values_from = c("Index_value"))


### Imports

Index_res_villes_Imports <- Index_res_villes %>%
  filter(Exports_imports == "Imports") %>%
  select(-c("Exports_imports")) %>%
  arrange(year)



Index_res_villes_Imports <- Index_res_villes_Imports %>%
  mutate(across(starts_with("Index_value"), function(x){return(100*x/x[length(x)])}))



plot(drop_na(Index_res_villes_Imports[c("year", "Index_value_Nantes")]), type = "o", col = "black", ylim = c(18,118), 
     pch = 19, lwd = 2, ylab = "Valeur des indices de prix", xlab = "Année", main = "Indice de prix - Imports") 
lines(drop_na(Index_res_villes_Imports[c("year", "Index_value_Marseille")]), type = "o", col = "red", pch = 19, lwd = 2)
lines(drop_na(Index_res_villes_Imports[c("year", "Index_value_Bordeaux")]), type = "o", col = "blue", pch = 19, lwd = 2)
lines(drop_na(Index_res_villes_Imports[c("year", "Index_value_La Rochelle")]), type = "o", col = "green", pch = 19, lwd = 2)
lines(drop_na(Index_res_villes_Imports[c("year", "Index_value_Bayonne")]), type = "o", col = "orange", pch = 19, lwd = 2)
legend("topleft", legend = c("Nantes", "Marseille", "Bordeaux", "La Rochelle", "Bayonne"),
       col = c("black", "red", "blue", "green", "orange"), lwd = 2)




### Exports

Index_res_villes_Exports <- Index_res_villes %>%
  filter(Exports_imports == "Exports") %>%
  select(-c("Exports_imports")) %>%
  arrange(year)



Index_res_villes_Exports <- Index_res_villes_Exports %>%
  mutate(across(starts_with("Index_value"), function(x){return(100*x/x[length(x)])}))



plot(drop_na(Index_res_villes_Exports[c("year", "Index_value_Nantes")]), type = "o", col = "black", ylim = c(50,120), 
     pch = 19, lwd = 2, ylab = "Valeur des indices de prix", xlab = "Année", main = "Indice de prix - Exports")
lines(drop_na(Index_res_villes_Exports[c("year", "Index_value_Marseille")]), type = "o", col = "red", pch = 19, lwd = 2)
lines(drop_na(Index_res_villes_Exports[c("year", "Index_value_Bordeaux")]), type = "o", col = "blue", pch = 19, lwd = 2)
lines(drop_na(Index_res_villes_Exports[c("year", "Index_value_La Rochelle")]), type = "o", col = "green", pch = 19, lwd = 2)
lines(drop_na(Index_res_villes_Exports[c("year", "Index_value_Bayonne")]), type = "o", col = "orange", pch = 19, lwd = 2)
legend("topleft", legend = c("Nantes", "Marseille", "Bordeaux", "La Rochelle", "Bayonne"),
       col = c("black", "red", "blue", "green", "orange"), lwd = 2)






### Graphique de variation des corrélations entre indices des ports

### Global

### Imports

Cor_ville_Imports <- as.matrix(openxlsx::read.xlsx("./scripts/Edouard/Correlation_matrix_ville.xlsx",
                                                             sheet = "Imports", rowNames = T))


corrplot(Cor_ville_Imports, type = "upper", diag = F,
         outline = T, tl.col = "black", tl.srt = 45)


### Exports

Cor_ville_Exports <- as.matrix(openxlsx::read.xlsx("./scripts/Edouard/Correlation_matrix_ville.xlsx",
                                                   sheet = "Exports", rowNames = T))


corrplot(Cor_ville_Exports, type = "upper", diag = F,
         outline = T, tl.col = "black", tl.srt = 45)



### Par année, début à 1760 et 1750 à 1789

### Imports

Cor_ville_Imports_1700_1760 <- as.matrix(openxlsx::read.xlsx("./scripts/Edouard/Correlation_matrix_ville1700_1760.xlsx",
                                                   sheet = "Imports", rowNames = T))


corrplot(Cor_ville_Imports_1700_1760, type = "upper", diag = F,
         outline = T, tl.col = "black", tl.srt = 45)


Cor_ville_Imports_1750_1900 <- as.matrix(openxlsx::read.xlsx("./scripts/Edouard/Correlation_matrix_ville1750_1900.xlsx",
                                                             sheet = "Imports", rowNames = T))


corrplot(Cor_ville_Imports_1750_1900, type = "upper", diag = F,
         outline = T, tl.col = "black", tl.srt = 45)



### Exports

Cor_ville_Imports_1700_1760 <- as.matrix(openxlsx::read.xlsx("./scripts/Edouard/Correlation_matrix_ville1700_1760.xlsx",
                                                             sheet = "Exports", rowNames = T))


corrplot(Cor_ville_Imports_1700_1760, type = "upper", diag = F,
         outline = T, tl.col = "black", tl.srt = 45)


Cor_ville_Imports_1750_1900 <- as.matrix(openxlsx::read.xlsx("./scripts/Edouard/Correlation_matrix_ville1750_1900.xlsx",
                                                             sheet = "Exports", rowNames = T))


corrplot(Cor_ville_Imports_1750_1900, type = "upper", diag = F,
         outline = T, tl.col = "black", tl.srt = 45)
