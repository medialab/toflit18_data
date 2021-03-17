library(dplyr)
library(tidyverse)
library(stringr)
library(readr)
library(pracma)

library(hpiR)



### Calcul des indices de prix : 1er exemple

### A définir
setwd("C:/Users/pignede/Documents/GitHub/toflit18_data")
### setwd("/Users/Edouard/Dropbox (IRD)/IRD/Missions/Marchandises_18eme")


rm(list = ls())

### On charge la fonction de filtrage
source("./scripts/Edouard/Filtrage.R")

### On filtre la bdd courante :


Data_filter <- Data_filtrage(Ville = "La Rochelle",  ### Choix du port d'étude
                             Outliers = F, ### conservation des outliers 
                             Outliers_coef = 3.5, ### Quel niveau d'écart inter Q garde-t-on
                             Trans_number = 0, ### On retire les produits vendus moins de Trans_number fois
                             Exports_imports = "Imports", ### On conserve les Importations ou les Exportations
                             Prod_problems = T, ### Enleve-t-on les produits avec des différences de prix très importants
                             Product_select = F, ### Selection des produits par Charles Loic
                             Remove_double = T) ### On retire les doublons








### Calcul des pondérations
Product_pond <- Data_filter %>%
  group_by(id_prod_simp) %>%
  summarize(Value_tot_log = log(sum(quantities_metric*unit_price_metric)),
            Value_tot = sum(quantities_metric*unit_price_metric))

### On 
Product_pond$Value_part_log <- round(10000 * Product_pond$Value_tot_log / sum(Product_pond$Value_tot_log)) 
Product_pond$Value_part <- round(10000 * Product_pond$Value_tot / sum(Product_pond$Value_tot)) 



### Creation de la colonne des périodes
Data_period <- dateToPeriod(trans_df = Data_filter,
                            date = 'Date',
                            periodicity = 'yearly')


### Creation de la base de données des transactions

### Création de la base de données des transactions considérées
Data_trans <- rtCreateTrans(trans_df = Data_period,
                            prop_id = "id_prod_simp",
                            trans_id = "id_trans",
                            price = "unit_price_metric",
                            min_period_dist = 0,
                            seq_only = T)



price_diff <- log(Data_trans$price_2) - log(Data_trans$price_1)
time_matrix <- rtTimeMatrix(Data_trans)

Data_trans <- Data_trans %>%
  left_join(Product_pond, by = c("prop_id" = "id_prod_simp"))



reg <- lm(price_diff ~ time_matrix + 0, weights = Data_trans$Value_part_log)
reg$coefficients[1] = 0


rt_pond_index <- data.frame("year" = seq(min(Data_filter$year), min(Data_filter$year) + length(reg$coefficients) - 1),
                            "Index" = 100*exp(reg$coefficients),
                            row.names = NULL)

rt_pond_index <- remove_missing(rt_pond_index)
                            

plot(rt_pond_index$year, rt_pond_index$Index, type = "o")

### Creation des colonnes de colonnes
Data_period <- dateToPeriod(trans_df = Data_filter,
                            date = 'Date',
                            periodicity = 'yearly')













### On observe l'évolution des prix unitaires de tous les produits importés
### plus de xxxx fois sur la période
for (prod in levels(Data_filter$product_simplification)) {
  
  Data_prod <- subset(Data_filter, product_simplification == prod)
  
  if (dim(Data_prod)[1] > 20) {
    
    plot(Data_prod$year, Data_prod$unit_price_metric, main = prod)
  }
}
