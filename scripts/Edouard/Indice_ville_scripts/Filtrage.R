library(dplyr)
library(tidyverse)
library(stringr)
library(readr)
library(pracma)

library(modern)

rm(list = ls())

### A définir
setwd("C:/Users/pignede/Documents/GitHub/toflit18_data")
### setwd("/Users/Edouard/Dropbox (IRD)/IRD/Missions/Marchandises_18eme")


### Cette fonction permet le filtrage de la base de données selon les parmètres suivants (valeurs par défaut):
# Ville, ==> port considéré
# Exports_imports = "Imports", ==> Type : Exports ou Imports
# Outliers = T, ==> Retire-t-on les outliers ? T ou F, outliers d'une loi log-normale avec z-score modifié (https://www.itl.nist.gov/div898/handbook/eda/section3/eda35h.htm)
# Outliers_coef = 10, ==> outliers_coef utilisé, nombre positif, plus il est grand plus le nombre d'outliers diminue
# Trans_number = 0, ==> Retire les produits apparaissant moins de Trans_number fois dans la base filtrée, entier positif
# Prod_problems = F, ==> Retire-t-on les produits avec un écart interquartile (3rd - 1st quartile) > 10 ? T ou F
# Product_select = F, ==> Conserve-t-on uniquement les produits de la sélection réalisée par Loïc ? T ou F
# Remove_double = T ==> Rassemble-t-on les produits vendus plus de deux fois dans la même année 
# Correction_indice_Ag

Data_filtrage <- function(Ville,
                          Exports_imports = "Imports",
                          Outliers = T,
                          Outliers_coef = 10,
                          Trans_number = 0,
                          Prod_problems = F,
                          Product_select = F,
                          Remove_double = T,
                          Correction_indice_Ag = T,
                          Product_sector = "All",
                          Partner = "All") 
  
{
  ### Lecture de la base de données courante et filtrage par la ville et le type (Imports ou Exports)
  ### Conservation uniquement des variables suivantes : "year", "customs_region", "export_import", "partner_orthographic",
  ### "product_simplification", "quantity_unit_metric", "quantities_metric", "unit_price_metric", "value", "best_guess_region_prodxpart"
  ### Création d'un indice de transaction et d'un indice de produit
  ### Conservation uniquement des produits dans la meilleure unité considérée (unité la plus vendue en terme de transctions)
  ### Calcul également de la valeur totale du commerce et du flux initiale
  Res <- Read_bdd_courante(Ville, Exports_imports, Correction_indice_Ag, Product_sector, Partner)
  ### Data est la base de données filtrée sans les paramètres complémentaires
  Data <- Res[[1]]
  ### Value_com_tot correspond aux valeurs de la valeur totale du flux et du commerce par année
  Value_com_tot <- Res[[2]]
  
  ### si Outliers == T, on retire les outliers 
  if (Outliers) {
    Data <- Detect_outliers(Data,
                    Outliers_coef)
    
    Data <- Remove_outliers(Data)
  }
  
  ### si Prod_problems == T, on retire les produits "problématiques"
  if (Prod_problems) {
    Data <- Remove_prod_problems(Data)
  }
  
  ### si Remove_double == T, on rassemble les produits vendus plus de deux fois la même année
  if (Remove_double) {
    Data <- Remove_double_val(Data)
  }
  
  ### si prod_select == T, on conserve uniquement les produits sélectionnés par Loïc
  if (Product_select) {
    Data <- Keep_prod_select(Data)
  }
  
  ### si Trans_number != 0, on conserve uniquement les produits échangés plus de Trans_numer fois
  if (Trans_number != 0) {
    Data <- Keep_trans_number(Data,
                              Trans_number) 
  }
  
  ### On calcule la valeur du flux et du commerce finale
  Value_com_final <- Data %>%
    group_by(year) %>%
    summarize(Value_finale = sum(value),
              Flux_final = n()) %>%
    as.data.frame()
  
  ### On calcule la part du commerce et du flux en divisant final/total
  Part_value <- merge(Value_com_final, Value_com_tot, "year" = "year", all = T)
  Part_value$Part_value <- Part_value$Value_finale / Part_value$Value_tot
  Part_value$Part_flux <- Part_value$Flux_final / Part_value$Flux_tot
  
  ### On rajoute à la base de données filtrées la part du commerce et du flux totale
  Data <- merge(Data, Part_value[, c("year", "Part_value", "Part_flux")], "year" = "year", all.x = T)
    
  ### On retourne la base de données obtenue
  return(Data)
  
}  



### Lecture de la base de donnée courante. Conservation Exports ou Imports d'une ville
### Correction de l'indice par la valeur de l'argent
## Tri par secteur et par partenaire possible
Read_bdd_courante <- function(Ville, Exports_imports, Correction_indice_Ag, Product_sector, Partner) {
  ### On importe la base de données courante
  bdd_courante <- read.csv(unz("./base/bdd courante.csv.zip", "bdd courante.csv") , encoding = "UTF-8")
  

  ### Filtrage initiale de la base de données
  Data <- bdd_courante %>%
    select(c("year", "customs_region", "export_import", "partner_orthographic",
             "product_simplification", "quantity_unit_metric", "quantities_metric", 
             "unit_price_metric", "value", "best_guess_region_prodxpart", 
             "product_threesectors", "product_threesectorsM", "partner_grouping", "product_reexportations")) %>%
    mutate(Date = as.Date(as.character(year), format = "%Y")) %>%
    ### On selectionne uniquement les produits rangés par régions
    filter(best_guess_region_prodxpart == 1) %>%
    ### On selectionne uniquement le port de Marseille
    filter(customs_region == Ville) %>%
    ### Les chaînes de charatères sont transformés en type facteur
    mutate_if(is.character, as.factor) %>%
    ### Création ID product_simplification et ID transaction
    mutate(id_prod_simp = as.numeric(product_simplification),
           id_trans = row_number()) %>%
    ### Si aucun prix n'est affiché, on le complète par valeur /quantité
    mutate(unit_price_metric = coalesce(unit_price_metric, value / quantities_metric)) %>%
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
  
  
  
  ### Correction indice Ag
  if (Correction_indice_Ag) {
    ### Chargement de la base de données de la valeur de l'argent
    Ag_value <- read.csv2("./scripts/Edouard/Silver_price/Silver_equivalent_of_the_lt_and_franc_(Hoffman).csv")
    ### On fusionne les deux bases de données
    bdd_courante <- merge(bdd_courante, Ag_value, "year" = "year", all.x = T)
    ### On corrige les valeurs des prix
    bdd_courante <- bdd_courante %>%
      mutate(value = value * Value_of_livre) %>%
      select(-c("Value_of_livre"))
    
  }
  
  
  ### Calcule de la valeur totale du flux et du commerce initiale
  Value_com_tot <- bdd_courante %>%
    filter(best_guess_region_prodxpart == 1) %>%
    filter(customs_region == Ville) %>%
    filter(export_import == Exports_imports) %>%
    group_by(year) %>%
    summarize(Value_tot = sum(value, na.rm = T),
              Flux_tot = n()) %>%
    as.data.frame()
  
  
  ### Correction indice Ag
  if (Correction_indice_Ag) {
    ### Chargement de la base de données de la valeur de l'argent
    Ag_value <- read.csv2("./scripts/Edouard/Silver_price/Silver_equivalent_of_the_lt_and_franc_(Hoffman).csv")
    ### On fusionne les deux bases de données
    Data <- merge(Data, Ag_value, "year" = "year", all.x = T)
    ### On corrige les valeurs des prix
    Data <- Data %>%
      mutate(unit_price_metric = unit_price_metric * Value_of_livre,
             value = value * Value_of_livre) %>%
      select(-c("Value_of_livre"))
    
  }
  
  
  
  if(Product_sector != "All") {
    if (Product_sector == "Primary goods") {
      Data <- Data %>%
        filter(product_threesectors == "Agriculture" | product_threesectors == "Non-agricultural primary goods")
    } else if (Product_sector == "Primary coloniaux") { 
      Data <- Data %>%
        filter((product_threesectors == "Agriculture" | product_threesectors == "Non-agricultural primary goods") 
               & product_reexportations == "Réexportation")
    } else if (Product_sector == "Primary european") {
      Data <- Data %>%
        filter((product_threesectors == "Agriculture" | product_threesectors == "Non-agricultural primary goods") 
             & product_reexportations != "Réexportation")
    } else if (Product_sector == "Manufactures") {
      Data <- Data %>%
        filter(product_threesectors == "Manufactures")
    }
  }
  
  
  if (Partner == "Europe_et_Mediterranee") {
    Data <- Data %>%
      filter(partner_grouping %in% c("Allemagne", "Angleterre", "Espagne",
                                   "Flandre et autres états de l'Empereur",
                                   "Hollande", "France", "Italie", "Levant et Barbarie",
                                   "Nord", "Portugal", "Suisse"))
  } 
  
  if (Partner == "Reste_du_monde") {
    Data <- Data %>%
      filter(partner_grouping %in% c("Afrique", "Amériques", "Asie", "Etats-Unis d'Amérique", 
                                     "Monde", "Outre-mers"))
  }
  

  

  
  ### On conserve uniquement les données dans la meilleure unité
  Data <- Data %>%
    filter(best_unit_metric == T
            & export_import == Exports_imports) %>%
    select(-c("best_unit_metric", "best_guess_region_prodxpart", "product_threesectors", 
              "product_threesectorsM", "partner_grouping", "product_reexportations"))
  
  return(list(Data, Value_com_tot))
} 
  

### Détéetction valeurs aberrantes pour une loi log-normale par la méthode
### du Z-score modifié :
### https://www.itl.nist.gov/div898/handbook/eda/section3/eda35h.htm
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
    filter(Product_selection == 1)
  
  Data <- Data %>%
    filter(product_simplification %in% Product_selection$product_simplification)
  
  return(Data)
    
  }
  

### On retire les produits apparaissant plus de Number_trans fois  
Keep_trans_number <- function(Data, Trans_number = 0) {  
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

