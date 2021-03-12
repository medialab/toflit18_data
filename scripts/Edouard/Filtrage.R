library(dplyr)
library(tidyverse)
library(stringr)
library(readr)
library(pracma)

library(modern)


Data_filtrage <- function(Ville, 
                          Outliers = F,
                          Outliers_coef = 3.5,
                          Trans_number = 0,
                          Exports_imports = "Imports",
                          Prod_problems = T,
                          Product_select = F,
                          Remove_double = T) {
  
  ### On fixe la ville que l'on veut étudier
  ville = Ville
  
  ### On importe la base de données courante
  bdd_courante <- read.csv("./base/bdd courante.csv", encoding = "UTF-8")
  
  Data <- bdd_courante %>%
    select(c("year", "customs_region", "export_import", "partner_orthographic",
             "product_simplification", "quantity_unit_metric", "quantities_metric", "unit_price_metric",
             "best_guess_national_prodxpart", "best_guess_national_partner", 
             "best_guess_national_product", "best_guess_national_region",
             "best_guess_region_prodxpart")) %>%
    mutate(Date = as.Date(as.character(year), format = "%Y")) %>%
    ### On selectionne uniquement les produits rangés par régions
    filter(best_guess_region_prodxpart == 1) %>%
    ### On selectionne uniquement le port de Marseille
    filter(customs_region == ville) %>%
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
    mutate(best_unit_metric = best_unit_metric == quantity_unit_metric )
  
  
  
  
  
  
  ### Détéection valeurs aberrantes
  # outliers_trans <- c()
  # for (prod in levels(Data$product_simplification)) {
  #   
  #   Data_outliers = subset(Data,  product_simplification == prod 
  #                         & export_import == Exports_imports
  #                         & best_unit_metric == T)
  # 
  #   
  #   
  #   outliers_trans <- c(outliers_trans,
  #                       Data_outliers$id_trans[which(Data_outliers$unit_price_metric %in% 
  #                                                     boxplot.stats(Data_outliers$unit_price_metric, coef = Outliers_coef)$out)])
  # }
  # 
  # Data <- Data %>%
  #   mutate(outliers = id_trans %in% outliers_trans)
  # 
  # 
  # 
  # 

  ### Détéetction valeurs aberrantes pour une loi log-normale par la méthode
  ### du Z-score modifié :
  ### https://www.itl.nist.gov/div898/handbook/eda/section3/eda35h.htm
  
  outliers_trans <- c()
  for (prod in levels(Data$product_simplification)) {
    
    Data_outliers = subset(Data,  product_simplification == prod 
                          & export_import == Exports_imports
                          & best_unit_metric == T)
    
    Data_outliers$Price_unit_outliers <- iglewicz_hoaglin(log(Data_outliers$unit_price_metric),
                                       threshold = Outliers_coef)
    
    
    outliers_trans <- c(outliers_trans,
                        Data_outliers$id_trans[which(Data_outliers$Price_unit_outliers %in% NA)])
    
 }
  
  Data <- Data %>%
    mutate(outliers = id_trans %in% outliers_trans)
  
  
  
  
  ### filtrage de la base de données 
  
  Data_filter <- Data %>%
    filter(best_unit_metric == T
           & export_import == Exports_imports
           & outliers == Outliers) %>%
    select("year", "Date", "product_simplification", "quantities_metric",
           "unit_price_metric", "id_prod_simp", "id_trans", "partner_orthographic")
    
   
    
  if(Remove_double) {
    Data_filter <- Data_filter %>%
      select("year", "Date", "product_simplification", "quantities_metric",
             "unit_price_metric") %>%
      group_by(year, product_simplification) %>%
      summarise(unit_price_metric = weighted.mean(unit_price_metric, quantities_metric),
                quantities_metric = sum(quantities_metric)) %>%
      as.data.frame() %>%
      mutate(id_prod_simp = as.numeric(product_simplification),
             id_trans = row_number())
  }  
    
    
    
    
    
  
  ### ON selectionne les produits pour lesquels il existe une différence trop importante de prix :
  ### multiplication des prix par 10 entre le plus petit et le plus grand quartile 
  prod_problems <- c()
  for (prod in levels(Data$product_simplification)) {
    
    Data_prod <- subset(Data_filter, product_simplification == prod)
    
    if (dim(Data_prod)[1] > 0) {
      
      if(quantile(Data_prod$unit_price_metric, probs = 3/4)/quantile(Data_prod$unit_price_metric, probs = 1/4) > 10) {
        prod_problems <- c(prod_problems, prod) 
      }
    }
  }
  
  
  
  if (Prod_problems == T) {
  Data_filter <- Data_filter %>%
    filter(!product_simplification %in% prod_problems)
  
  }
  
  
  
  
  ### On conserve uniquement les produits selectionnés par Loic Charles
  
  if (Product_select == T) {
    Product_selection <- read.csv2("./scripts/Edouard/Product_selection.csv")
    
    Product_selection <- Product_selection %>%
      filter(Ville == Ville & Type == Exports_imports & Product_selection == 1)
    
    Data_filter <- Data_filter %>%
      filter(product_simplification %in% Product_selection$product_simplification)
  }
  
  ### On compte le nombre de transactions sur la base de données filtrées 
  Data_filter <- Data_filter %>%  
    group_by(product_simplification) %>%
    mutate(trans_number = length(id_trans),
           Date = as.Date(as.character(year), format = "%Y")) %>%
    ungroup() %>%
    as.data.frame() %>%
    
    ### On filtre le nombre de transactions utilisées dans la méthode
    filter(trans_number > Trans_number)
  
  
  return(Data_filter)
  
}
