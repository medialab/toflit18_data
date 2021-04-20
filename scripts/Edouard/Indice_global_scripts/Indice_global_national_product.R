
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


rm(list = ls())

### A définir
setwd("C:/Users/pignede/Documents/GitHub/toflit18_data")
### setwd("/Users/Edouard/Dropbox (IRD)/IRD/Missions/Marchandises_18eme")


### Cette fonction permet le filtrage de la base de données selon les paramètres suivants pour la réalisation de l'indice global 
### calculé à partir d'un filtre prod/ville

Data_filtrage <- function(Exports_imports = "Imports") 
  
{
  ### Lecture de la base de données courante et filtrage par la ville et le type (Imports ou Exports)
  ### Conservation uniquement des variables suivantes : "year", "customs_region", "export_import", "partner_orthographic",
  ### "product_simplification", "quantity_unit_metric", "quantities_metric", "unit_price_metric", "value", "best_guess_region_prodxpart"
  ### Création d'un indice de transaction et d'un indice de produit
  ### Conservation uniquement des produits dans la meilleure unité considérée (unité la plus vendue en terme de transctions)
  ### Calcul également de la valeur totale du commerce et du flux initiale
  Res <- Read_bdd_courante(Exports_imports)
  ### Data est la base de données filtrée sans les paramètres complémentaires
  Data <- Res[[1]]
  ### Value_com_tot correspond aux valeurs de la valeur totale du flux et du commerce par année
  Value_com_tot <- Res[[2]]
  
  ### On retire les outliers 
  Data <- Detect_outliers(Data, 10)
  
  Data <- Remove_outliers(Data)
  
  
  ### si Remove_double == T, on rassemble les produits vendus plus de deux fois la même année
  Data <- Remove_double_val(Data)
  
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




### Cette fonction calcule l'index des ventes répétés à partir d'un objet Data retourné
### par la fonction Data_filtrage du script filtrage
Calcul_index <- function(Data, Ponderation = T, Pond_log = F) {
  
  ### Calcul des pondérations
  Product_pond <- Data %>%
    group_by(id_prod_simp) %>%
    summarize(Value_tot_log = log(sum(value)),
              Value_tot = sum(value))
  
  ### On 
  Product_pond$Value_part_log <- round(10000 * Product_pond$Value_tot_log / sum(Product_pond$Value_tot_log, na.rm = T)) 
  Product_pond$Value_part <- round(10000 * Product_pond$Value_tot / sum(Product_pond$Value_tot, na.rm = T)) 
  
  
  
  ### Creation de la colonne des périodes
  Data_period <- dateToPeriod(trans_df = Data,
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
  
  
  ### Calcul de l'indice
  
  ### price_diff et le log de la différence de prix pour chaque transationn considérée
  price_diff <- log(Data_trans$price_2) - log(Data_trans$price_1)
  ### time_matrix est obtenue à partir de la fonction rtTimeMatrix du package hpiR. Cette fonction permet
  ### de renvoyer une matrice qui considèrera chaque transaction à sa place dans le calcule de l'indice
  time_matrix <- rtTimeMatrix(Data_trans)
  
  ### On ajoute à la matrice des transactions, les pondérations calculées précedemment
  Data_trans <- Data_trans %>%
    left_join(Product_pond, by = c("prop_id" = "id_prod_simp"))
  
  ### Calcul de la régression selon que l'on est choisi de pondéré par la part dans la valeur totale 
  ### ou par le log de la valeur totale ou pas de pondération
  if (Ponderation) {
    if (Pond_log) {
      reg <- lm(price_diff ~ time_matrix + 0, weights = Data_trans$Value_part_log) ### + 0 permet de supprimer l'intercept
    } else {
      reg <- lm(price_diff ~ time_matrix + 0, weights = Data_trans$Value_part)
    }
  } else {
    reg <- lm(price_diff ~ time_matrix + 0)
  }
  
  ### Construction de l'indice     
  rt_pond_index <- data.frame("year" = seq(min(Data$year), min(Data$year) + length(reg$coefficients)),
                              "Index" = 100*exp(c(0, reg$coefficients)),
                              row.names = NULL)
  ### On retourne l'indice
  return(rt_pond_index)
  
}

### Cette fonction prend en entrée l'Index obtenue avec la fonction Calcul_index ainsi que les parts dans le commerce
### et renvoie e graphe associé
Plot_index <- function(Index, ### Choix du port d'étude
                       Exports_imports = "Imports") ### On conserve les Importations ou les Exportations 
  
{
  
  ### Nom du fichier
  Title = paste0("Global_national_product_", Exports_imports)
  
  
  ### Ouverture d'une fenêtre pour l'enregistrement du graphique
  png(filename = paste0("./scripts/Edouard/Figure_index_global/", Title, ".png"),
      width = 5000,
      height = 2700,
      res = 500)
  
  # 1- Ouvrir une nouvelle fenêtre graphique
  plot.new()
  # 2- Programmer des marges larges pour l'ajout ultérieur des titres des axes
  par(mar=c(4,4,3,4))
  # 3- On récupère dans position la position de chaque barre
  position = barplot(Index$Part_value, 
                     col = rgb(0.220, 0.220, 0.220, alpha = 0.2),
                     names.arg = Index$year,
                     axes = F,
                     ylab = "", xlab = "",
                     main = Title,
                     ylim = c(0,1), 
                     las = 2, space = 0, cex.main = 0.8)
  # las = 2 : ce paramètre permet d'orienter le label de chaque barre verticalement
  # 4- Configurer la couleur de l'axe de gauche (correspondant ici aux barres)
  axis(4, col = "black", at = seq(0, 1, by = 0.2), lab = scales::percent(seq(0, 1, by = 0.2), accuracy = 1))
  # 5- Superposer la courbe
  par(new = TRUE, mar = c(4, 4, 3, 4))
  maximal = max(position) + (position[2] - position[1])
  plot(position[!is.na(Index$Index)], Index$Index[!is.na(Index$Index)], 
       col = "black", type = "o", lwd = 2,
       pch = 16, axes = F, ylab = "", xlab = "", 
       xlim = c(0, length(Index$Index)),
       ylim = c(min(Index$Index, na.rm = T) - 5, max(Index$Index, na.rm = T) + 5))
  # 6- Configurer l'axe de droite, correspondant à la coube
  axis(2, col.axis = "black", col = "black")
  box();grid()
  mtext("Index value",side=2,line=2,cex=1.1)
  mtext("Part de la valeur dans le commerce", side = 4, col = "black", line = 2, cex = 1.1)
  
  ### Fermeture de la fenêtre
  dev.off()
  
}

### Cette fonction prend en entrée l'ensemble des paramètres pour construire l'indice des prix, réalise le filtrage de la base de données,
### puis calcul l'indice des prix, renvoie l'indice et le plot
### On renvoie également pour chaque année de calcul de l'indice la part du commerce considérée et la part du flux considérée

Filter_calcul_index <- function(Exports_imports = "Imports") ### On conserve les Importations ou les Exportations
{
  ### Filtrage de la base de données avec la fonction du scrip Filtrage.R
  Data_filter <- Data_filtrage(Exports_imports = Exports_imports) ### On conserve les Importations ou les Exportations
  
  
  ### Calcul de l'indice avec la fonction Calcul_index
  rt_index <- Calcul_index(Data_filter)
  
  
  
  
  ### On calcul la part pris en compte dans le flux total et dans le commerce totale du port et du type en question
  Data_part <- Data_filter %>%
    group_by(year) %>%
    summarise(Part_value = mean(Part_value),
              Part_flux = mean(Part_flux)) %>%
    as.data.frame()
  
  ### On ajoute à l'indice les colonnes de Part_value et Part_flux
  rt_index <- merge(rt_index, Data_part[ , c("year", "Part_value", "Part_flux")], "year" = "year", all.x = T,
                    all.y = F)
  
  ### On plot l'index avec la fonction Plot_index
  Plot_index(rt_index, Exports_imports = Exports_imports)
  ### On retourne l'indice obtenu
  return(rt_index)
  
}







### Lecture de la base de donnée courante. Conservation Exports ou Imports d'une ville
Read_bdd_courante <- function(Exports_imports) {
  ### On importe la base de données courante
  bdd_courante <- read.csv(unz("./base/bdd courante.csv.zip", "bdd courante.csv") , encoding = "UTF-8")
  
  ### Calcule de la valeur totale du flux et du commerce initiale
  Value_com_tot <- bdd_courante %>%
    filter(best_guess_national_product == 1) %>%
    filter(export_import == Exports_imports) %>%
    group_by(year) %>%
    summarize(Value_tot = sum(value, na.rm = T),
              Flux_tot = n()) %>%
    as.data.frame()
  
  
  ### Filtrage initiale de la base de données
  Data <- bdd_courante %>%
    select(c("year", "export_import",
             "product_simplification", "quantity_unit_metric", "quantities_metric", 
             "unit_price_metric", "value", "best_guess_national_product")) %>%
    mutate(Date = as.Date(as.character(year), format = "%Y")) %>%
    ### On selectionne uniquement les produits rangés par régions
    filter(best_guess_national_product == 1) %>%
    ### Les chaînes de charatères sont transformés en type facteur
    mutate_if(is.character, as.factor) %>%
    ### Correction des valuers manquantes
    mutate(unit_price_metric = case_when(is.na(unit_price_metric) ~ value / quantities_metric,
                                         !is.na(unit_price_metric) ~ unit_price_metric)) %>%
    mutate(quantities_metric = case_when(is.na(quantities_metric) ~ value / unit_price_metric,
                                         !is.na(quantities_metric) ~ quantities_metric)) %>%
    
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
    select(-c("best_unit_metric", "best_guess_national_product"))
  
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
    select(-c("id_trans")) %>%
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





