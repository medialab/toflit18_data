library(plyr)
library(dplyr)
library(tidyverse)
library(stringr)
library(readr)
library(pracma)

library(IndexNumR)
library(hpiR)


### Calcul des indices de prix : 1er exemple

### A définir
setwd("C:/Users/pignede/Dropbox (IRD)/IRD/Missions/Marchandises_18eme")
### setwd("/Users/Edouard/Dropbox (IRD)/IRD/Missions/Marchandises_18eme")

rm(list = ls())

### On importe l'ensemble des données de La Rochelle en un seul tableau
### Data_Rochelle <- list.files("./Data/La_Rochelle", full.names = T)
### Data_Rochelle <- ldply(List_files_Rochelle, read_csv, col_types = cols(),
###                       .progress = progress_text(char = "."))
### Data_Rochelle <- Data_Rochelle %>% mutate_if(is.character, as.factor)


### On importe la base de données courante
bdd_courante <- read.csv("./Data/bdd courante.csv", encoding = "UTF-8")

Data_Rochelle <- bdd_courante %>%
  select(c("line_number", "year", "customs_region", "export_import", "partner_orthographic",
           "product_simplification", "quantity_unit_metric", "quantities_metric", "unit_price_metric",
           "best_guess_national_prodxpart", "best_guess_national_partner", 
           "best_guess_national_product", "best_guess_national_region",
           "best_guess_region_prodxpart")) %>%
  mutate(Date = as.Date(as.character(year), format = "%Y")) %>%
  ### On selectionne uniquement les produits rangés par régions
  filter(best_guess_region_prodxpart == 1) %>%
  ### On selectionne uniquement le port de La Rochelle
  filter(customs_region == "La Rochelle") %>%
  mutate_if(is.character, as.factor)



Data_Rochelle <- Data_Rochelle %>%
  ### mutate(best_unit_metric = quantity_unit_metric == names(which.max(table(Data_Rochelle$quantity_unit_metric)))) %>%
  group_by(product_simplification) %>%
  mutate(best_unit_metric = names(which.max(table(quantity_unit_metric))))
  


### On observe l'évolution des prix unitaires de tous les produits importés
### plus de 100 fois sur la période
for (prod in levels(Data_Rochelle$product_simplification)) {
  
  if (sum(Data_Rochelle$product_simplification == prod
          & Data_Rochelle$export_import == "Imports"
          & Data_Rochelle$best_unit_metric == T) > 50) {
    
    Data = subset(Data_Rochelle,  product_simplification == prod 
                  & export_import == "Imports"
                  & best_unit_metric == T)
    print(prod)
    print(Data[, c("quantity_unit_metric", "unit_price_metric")])
    plot(Data$year, Data$unit_price_metric, main = prod)
  }
}



### Calcul de l'indice de prix par le méthode des ventes répétées

Rochelle_trans <- rtCreateTrans(trans_df = subset(Data_Rochelle, best_unit_metric == T),
                                prop_id = "product_simplification",
                                trans_id = "line_number",
                                price = "unit_price_metric",
                                date = "Date",
                                periodicity = "yearly")

for (prod in levels(Data_Rochelle$product_simplification)) {
  print(prod)
  print(subset(Data_Rochelle, product_simplification == prod)$quantity_unit_metric)
  }
