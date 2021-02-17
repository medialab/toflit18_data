library(dplyr)
library(tidyverse)
library(stringr)
library(readr)
library(pracma)

library(IndexNumR)
library(hpiR)


### Calcul des indices de prix : 1er exemple

### A définir
setwd("C:/Users/pignede/Documents/GitHub/toflit18_data")
### setwd("/Users/Edouard/Dropbox (IRD)/IRD/Missions/Marchandises_18eme")

rm(list = ls())


### On importe la base de données courante
bdd_courante <- read.csv("./base/bdd courante.csv", encoding = "UTF-8")

Data_Rochelle <- bdd_courante %>%
  select(c("year", "customs_region", "export_import", "partner_orthographic",
           "product_simplification", "quantity_unit_metric", "quantities_metric", "unit_price_metric",
           "best_guess_national_prodxpart", "best_guess_national_partner", 
           "best_guess_national_product", "best_guess_national_region",
           "best_guess_region_prodxpart")) %>%
  mutate(Date = as.Date(as.character(year), format = "%Y")) %>%
  ### On selectionne uniquement les produits rangés par régions
  filter(best_guess_region_prodxpart == 1) %>%
  ### On selectionne uniquement le port de La Rochelle
  filter(customs_region == "La Rochelle") %>%
  mutate_if(is.character, as.factor) %>%
  ### Création ID product_simplification et ID transaction
  mutate(id_prod_simp = as.numeric(product_simplification),
         id_trans = row_number()) %>%
  ### On enlève les transactions sans prix et les transactions avec un prix nul
  mutate(unit_price_metric = na_if(unit_price_metric, 0)) %>%
  drop_na(unit_price_metric) %>%
  ### On crée une dummy variable best_unit_metric qui pour chaque transaction vaut 1 
  ### si la transacton est dans l'unité métrique la plus utilisée pour le produit
  group_by(product_simplification) %>%
  mutate(best_unit_metric = names(which.max(table(quantity_unit_metric)))) %>%
  ungroup() %>%
  as.data.frame() %>%
  mutate(best_unit_metric = best_unit_metric == quantity_unit_metric ) %>%
  ### Création d'une variable qui récupère pour chaque produits le nombre de transactions
  ### dans la meilleure unité métrique
  group_by(product_simplification) %>%
  mutate(trans_number = sum(best_unit_metric)) %>%
  ungroup() %>%
  as.data.frame()






### On observe l'évolution des prix unitaires de tous les produits importés
### plus de xxxx fois sur la période
for (prod in levels(Data_Rochelle$product_simplification)) {
  
  if (sum(Data_Rochelle$product_simplification == prod
          & Data_Rochelle$export_import == "Imports"
          & Data_Rochelle$best_unit_metric == T) > 20) {
    
    Data = subset(Data_Rochelle,  product_simplification == prod 
                  & export_import == "Imports"
                  & best_unit_metric == T)
    print(prod)
    print(Data[, c("quantity_unit_metric", "unit_price_metric")])
    plot(Data$year, Data$unit_price_metric, main = prod)
  }
}



### Détéection valeurs aberrantes
outliers_trans <- c()
for (prod in levels(Data_Rochelle$product_simplification)) {
  
  Data_imports = subset(Data_Rochelle,  product_simplification == prod 
                        & export_import == "Imports"
                        & best_unit_metric == T)
  
  Data_exports = subset(Data_Rochelle,  product_simplification == prod 
                        & export_import == "Exports"
                        & best_unit_metric == T)
  
  
  outliers_trans <- c(outliers_trans,
                      Data_imports$id_trans[which(Data_imports$unit_price_metric %in% 
                                                    boxplot.stats(Data_imports$unit_price_metric, coef = 10)$out)])
}

Data_Rochelle <- Data_Rochelle %>%
  mutate(outliers = id_trans %in% outliers_trans)





### On observe l'évolution des prix unitaires de tous les produits importés
### plus de xxxx fois sur la période
for (prod in levels(Data_Rochelle$product_simplification)) {
  
  if (sum(Data_Rochelle$product_simplification == prod
          & Data_Rochelle$export_import == "Imports"
          & Data_Rochelle$best_unit_metric == T) > 20) {
    
    Data = subset(Data_Rochelle,  product_simplification == prod 
                  & export_import == "Imports"
                  & best_unit_metric == T
                  & outliers == F)
    print(prod)
    print(Data[, c("quantity_unit_metric", "unit_price_metric")])
    plot(Data$year, Data$unit_price_metric, main = prod)
  }
}








### Calcul de l'indice de prix par le méthode des ventes répétées
### https://cran.r-project.org/web/packages/hpiR/vignettes/introduction.html

### Création de la base de données des transactions considérées
Rochelle_trans <- rtCreateTrans(trans_df = subset(Data_Rochelle, best_unit_metric == T 
                                                   & trans_number > 1
                                                   & export_import == "Imports"
                                                   & outliers == F),
                                 prop_id = "id_prod_simp",
                                 trans_id = "id_trans",
                                 price = "unit_price_metric",
                                 date = "Date",
                                 periodicity = "yearly",
                                 min_period_dist = 5,
                                 seq_only = F)

### Application du modèle
rt_model <- hpiModel(model_type = "rt",
                     hpi_df = Rochelle_trans,
                     estimator = "base",
                     log_dep = T)

### Calacul de l'indice
rt_index <- modelToIndex(rt_model)

### Affichage du résultat
plot(rt_index$period, rt_index$value, type = "l")


