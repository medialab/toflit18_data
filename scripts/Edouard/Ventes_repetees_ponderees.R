
### Chargement des différents packages utilisés
### S'ils ne sont pas installés sur la machine, procéder à leur installation 
### via la commande install.packages("nom_du_package")

library(dplyr)
library(tidyverse)
library(stringr)
library(readr)
library(pracma)

library(hpiR)


### A définir: emplacement du working directory
setwd("C:/Users/pignede/Documents/GitHub/toflit18_data")
### setwd("/Users/Edouard/Dropbox (IRD)/IRD/Missions/Marchandises_18eme")

### Nettoyage de l'espace de travail
rm(list = ls())

### On charge la fonction du script Filtrage.R
source("./scripts/Edouard/Filtrage.R")


### Cette fonction calcule l'index des ventes répétés à partir d'un objet Data retourné
### par la fonction Data_filtrage du script filtrage
Calcul_index <- function(Data, Ponderation = T, Pond_log = T) {

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

### Cette fonction prend en entrée l'Index obtenue avec la fonctin Calcul_index et renvoie 
### le graphe associé
Plot_index <- function(Index, Ville = "", Type = "", smooth = F, show_NA = F) {
  ### ON retire les valeurs manquantes
  Index = remove_missing(Index)
  
  ### on plot l'indice
  plot(Index, type = "o", main = paste(Ville, Type))
  
  
}

### Cette fonction prend en entrée l'ensemble des paramètres pour construire l'indice des prix, réalise le filtrage de la base de données,
### puis calcul l'indice des prix, renvoie l'indice et le plot
### On renvoie également pour chaque année de calcul de l'indice la part du commerce considérée et la part du flux considérée

Filter_calcul_index <- function(Ville,  ### Choix du port d'étude
                                Exports_imports = "Imports", ### On conserve les Importations ou les Exportations
                                Outliers = T, ### Retire-t-on les outliers ? 
                                Outliers_coef = 3.5, ### Quel niveau d'écart inter Q garde-t-on pour le calcul des outliers ?
                                Trans_number = 0, ### On retire les produits vendus moins de Trans_number fois
                                Prod_problems = T, ### Enleve-t-on les produits avec des différences de prix trop importantes
                                Product_select = F, ### Conserve-t-on uniquement les produits sélectionnés par Loïc
                                Remove_double = T, ### Retire-t-on les doublons
                                Ponderation = T, ### Calcul de l'indice avec ponderation ?
                                Pond_log = T) ### Si ponderation == T, pondère-t-on par le log de la part dans la valeur totale ?
{
  ### Filtrage de la base de données avec la fonction du scrip Filtrage.R
  Data_filter <- Data_filtrage(Ville = Ville,  ### Choix du port d'étude
                               Exports_imports = Exports_imports, ### On conserve les Importations ou les Exportations
                               Outliers = Outliers, ### conservation des outliers 
                               Outliers_coef = Outliers_coef, ### Quel niveau d'écart inter Q garde-t-on
                               Trans_number = Trans_number, ### On retire les produits vendus moins de Trans_number fois
                               Prod_problems = Prod_problems, ### Enleve-t-on les produits avec des différences de prix très importants
                               Product_select = Product_select, ### Selection des produits par Charles Loic
                               Remove_double = Remove_double) ### On retire les doublons
  
  ### Calcul de l'indice avec la fonction Calcul_index
  rt_index <- Calcul_index(Data_filter, Ponderation = Ponderation, Pond_log = Pond_log)
  
  ### On plot l'index avec la fonction Plot_index
  Plot_index(rt_index, Ville = Ville, Type = Exports_imports)
  
  ### On calcul la part pris en compte dans le flux total et dans le commerce totale du port et du type en question
  Data_part <- Data_filter %>%
    group_by(year) %>%
    summarise(Part_value = mean(Part_value),
              Part_flux = mean(Part_flux)) %>%
    as.data.frame()
  
  ### On ajoute à l'indice les colonnes de Part_value et Part_flux
  rt_index <- merge(rt_index, Data_part[ , c("year", "Part_value", "Part_flux")], "year" = "year", all.x = T,
                    all.y = F)
  
  ### On retourne l'indice obtenu
  return(rt_index)
  
}




