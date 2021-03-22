library(dplyr)
library(tidyverse)
library(stringr)
library(readr)
library(pracma)

library(modern)

rm(list = ls())

Data_filtrage <- function(Ville,
                          Exports_imports = "Imports",
                          Outliers = T,
                          Outliers_coef = 3.5,
                          Trans_number = 0,
                          Prod_problems = T,
                          Product_select = F,
                          Remove_double = T) 
  
{
  Res <- Read_bdd_courante(Ville, Exports_imports)
  Data <- Res[[1]]
  Value_com_tot <- Res[[2]]
  
  if (Outliers) {
    Data <- Detect_outliers(Data,
                    Outliers_coef)
    
    Data <- Remove_outliers(Data)
  }
  

  if (Prod_problems) {
    Data <- Remove_prod_problems(Data)
  }
  
  if (Remove_double) {
    Data <- Remove_double_val(Data)
  }
  
  if (Product_select) {
    Data <- Keep_prod_select(Data)
  }
  
  if (Trans_number != 0) {
    Data <- Keep_trans_number(Data,
                              Trans_number) 
  }
  
  Value_com_final <- Data %>%
    group_by(year) %>%
    summarize(Value_finale = sum(value)) %>%
    as.data.frame()
  
  Part_value <- merge(Value_com_final, Value_com_tot, "year" = "year", all = T)
  Part_value$Part_value <- Part_value$Value_finale / Part_value$Value_tot
  
  Data <- merge(Data, Part_value[, c("year", "Part_value")], "year" = "year", all.x = T)
    
 
  return(Data)
  
}  



### Lecture de la base de donnée courante. Conservation Exports ou Imports d'une ville
Read_bdd_courante <- function(Ville, Exports_imports) {
  ### On importe la base de données courante
  bdd_courante <- read.csv(unz("./base/bdd courante.csv.zip", "bdd courante.csv") , encoding = "UTF-8")
  
  Value_com_tot <- bdd_courante %>%
    filter(best_guess_region_prodxpart == 1) %>%
    filter(customs_region == Ville) %>%
    filter(export_import == Exports_imports) %>%
    group_by(year) %>%
    summarize(Value_tot = sum(value)) %>%
    as.data.frame()
      
  
  
  Data <- bdd_courante %>%
    select(c("year", "customs_region", "export_import", "partner_orthographic",
             "product_simplification", "quantity_unit_metric", "quantities_metric", 
             "unit_price_metric", "value", "best_guess_region_prodxpart")) %>%
    mutate(Date = as.Date(as.character(year), format = "%Y")) %>%
    ### On selectionne uniquement les produits rangés par régions
    filter(best_guess_region_prodxpart == 1) %>%
    ### On selectionne uniquement le port de Marseille
    filter(customs_region == Ville) %>%
    mutate_if(is.character, as.factor) %>%
    ### Création ID product_simplification et ID transaction
    mutate(id_prod_simp = as.numeric(product_simplification),
           id_trans = row_number()) %>%
    ### On enlève les transactions sans prix et les transactions avec un prix nul
    mutate(unit_price_metric = na_if(unit_price_metric, 0),
           quantities_metric = na_if(quantities_metric, 0)) %>%
    drop_na() %>%
    ### On crée une dummy variable best_unit_metric qui pour chaque transaction vaut 1 
    ### si la transacton est dans l'unité métrique la plus utilisée pour le produit
    group_by(product_simplification) %>%
    mutate(best_unit_metric = names(which.max(table(quantity_unit_metric)))) %>%
    ungroup() %>%
    as.data.frame() %>%
    mutate(best_unit_metric = best_unit_metric == quantity_unit_metric )
  
  ### On conserve uniquement les données dans la meilleure unité
  Data <- Data %>%
    filter(best_unit_metric == T
            & export_import == Exports_imports) %>%
    select(-c("best_unit_metric", "best_guess_region_prodxpart"))
  
  return(list(Data, Value_com_tot))
} 
  

### Détéetction valeurs aberrantes pour une loi log-normale par la méthode
### du Z-score modifié :
### https://www.itl.nist.gov/div898/handbook/eda/section3/eda35h.html
Detect_outliers <- function(Data, Outliers_coef) {
  
  outliers_trans <- c()
  for (prod in levels(Data$product_simplification)) {
    
    Data_outliers = subset(Data,  product_simplification == prod)
    
    Data_outliers$Price_unit_outliers <- iglewicz_hoaglin(log(Data_outliers$unit_price_metric),
                                       threshold = Outliers_coef)
    
    
    outliers_trans <- c(outliers_trans,
                        Data_outliers$id_trans[which(Data_outliers$Price_unit_outliers %in% NA)])
    
 }
  
  Data <- Data %>%
    mutate(outliers = id_trans %in% outliers_trans)
  
  return(Data)
  
} 
  

### filtrage de la base de données 
Remove_outliers <- function(Data) {
    Data <- Data %>%
      filter(outliers == F) %>%
      select(-c("outliers"))
    
    return(Data)
  }
   

### On retire les produits vendues deux fois la même année
Remove_double_val <- function(Data) {
    Data <- Data %>%
      select(-c("partner_orthographic", "id_trans")) %>%
      group_by(year, product_simplification) %>%
      summarise(unit_price_metric = weighted.mean(unit_price_metric, quantities_metric),
                quantities_metric = sum(quantities_metric),
                value = sum(value),
                quantity_unit_metric = names(which.max(table(quantity_unit_metric))),
                id_prod_simp = names(which.max(table(id_prod_simp))),
                Date = names(which.max(table(Date)))) %>%
      as.data.frame() %>%
      mutate(id_trans = row_number(),
             Date = as.Date(Date)) %>%
      mutate_if(is.character, as.factor)
      
    
    return(Data)
}   

    
### ON selectionne les produits pour lesquels il existe une différence trop importante de prix :
### multiplication des prix par 10 entre le plus petit et le plus grand quartile 
Remove_prod_problems <- function(Data) {
  prod_problems <- c()
  for (prod in levels(Data$product_simplification)) {
    
    Data_prod <- subset(Data, product_simplification == prod)
    
    if (dim(Data_prod)[1] > 0) {
      
      if(quantile(Data_prod$unit_price_metric, probs = 3/4)/quantile(Data_prod$unit_price_metric, probs = 1/4) > 10) {
        prod_problems <- c(prod_problems, prod) 
      }
    }
  }
  
  
  Data <- Data %>%
    filter(!product_simplification %in% prod_problems)
  
  return(Data)
  
}
  
  
### On conserve uniquement les produits selectionnés par Loic Charles
Keep_prod_select <- function(Data) {
  Product_selection <- read.csv2("./scripts/Edouard/Product_selection.csv")
  
  Product_selection <- Product_selection %>%
    filter(Ville == Ville & Type == Exports_imports & Product_selection == 1)
  
  Data <- Data %>%
    filter(product_simplification %in% Product_selection$product_simplification)
  
  return(Data)
    
  }
  

### On retire les produits apparaissant plus de Number_trans fois  
Keep_trans_number <- function(Data, Number_trans = 0) {  
  ### On compte le nombre de transactions sur la base de données filtrées 
  Data <- Data %>%  
    group_by(product_simplification) %>%
    mutate(trans_number = length(id_trans),
           Date = as.Date(as.character(year), format = "%Y")) %>%
    ungroup() %>%
    as.data.frame() %>%
    
    ### On filtre le nombre de transactions utilisées dans la méthode
    filter(trans_number > Trans_number)
  
  
  return(Data)
  
}
