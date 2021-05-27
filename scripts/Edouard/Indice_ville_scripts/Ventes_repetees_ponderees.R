
### Chargement des différents packages utilisés
### S'ils ne sont pas installés sur la machine, procéder à leur installation 
### via la commande install.packages("nom_du_package")

library(dplyr)
library(tidyverse)
library(stringr)
library(readr)
library(pracma)

library(nlme)
library(lmtest)
library(caTools)
library(skedastic)

library(hpiR)




### A définir: emplacement du working directory
setwd("C:/Users/pignede/Documents/GitHub/toflit18_data")
### setwd("/Users/Edouard/Dropbox (IRD)/IRD/Missions/Marchandises_18eme")

### Nettoyage de l'espace de travail
rm(list = ls())

### On charge la fonction du script Filtrage.R
source("./scripts/Edouard/Indice_ville_scripts/Filtrage.R")


### Cette fonction calcule l'index des ventes répétés à partir d'un objet Data retourné
### par la fonction Data_filtrage du script filtrage
Calcul_index <- function(Data, Ponderation = T, Pond_log = F, Regression_type = "OLS", Smooth = F) {

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
  
  
  # Data_reg = cbind(data.frame("Price_diff" = price_diff, "Year" = Data_trans$period_2), as.data.frame(time_matrix[]))
  
  ### Calcul de la régression selon que l'on est choisi de pondéré par la part dans la valeur totale 
  ### ou par le log de la valeur totale ou pas de pondération
  if (Regression_type == "OLS") {
    if (Ponderation) {
      if (Pond_log) {
        reg <- lm(price_diff ~ time_matrix + 0, weights = Data_trans$Value_part_log) ### + 0 permet de supprimer l'intercept
      } else {
        reg <- lm(price_diff ~ time_matrix + 0, weights = Data_trans$Value_part)
      }
    } else {
      reg <- lm(price_diff ~ time_matrix + 0)
    }
  } 
  
  
  ### Calcul de la regréssion avec la correstion de Schiller & Case
  if (Regression_type == "WLS") {
    if (Ponderation) {
      if (Pond_log) {
        reg <-gls(price_diff ~ time_matrix + 0, weights = Data_trans$Value_part_log) ### + 0 permet de supprimer l'intercept
      } else {
        Data_trans$time_diff <- Data_trans$period_2 - Data_trans$period_1
        lm_model <- lm(price_diff ~ time_matrix + 0, weights = Data_trans$Value_part)
        err_fit <- stats::lm((stats::residuals(lm_model) ^ 2) ~ log(Data_trans$time_diff))
        wgts <- stats::fitted(err_fit)*Data_trans$Value_part
        reg <- stats::lm(price_diff ~ time_matrix + 0, weights = wgts)
      }
    } else {
      reg <- gls(price_diff ~ time_matrix + 0)
    }
  } 
  
  
  ### Impression du résultat du test de Breusch - Pagan
  # print(bptest(reg))
  
  
  ### Construction de l'indice     
  rt_pond_index <- data.frame("year" = seq(min(Data$year), min(Data$year) + length(reg$coefficients)),
                              "Index" = 100*exp(c(0, reg$coefficients)),
                              row.names = NULL)
  
  ### Réalise la moyenne mobile de l'indice sur l'ensemble de la période
  if (Smooth) {
    rt_pond_index$Index <- runmean(na.approx(rt_pond_index$Index), k = 3, 
                                   alg = "C", endrule = "keep", align = "right")
  }
  
  
  ### On retourne l'indice
  return(rt_pond_index)

}

### Cette fonction prend en entrée l'Index obtenue avec la fonction Calcul_index ainsi que les parts dans le commerce
### et renvoie e graphe associé
Plot_index <- function(Index, 
                       Ville,  ### Choix du port d'étude
                       Exports_imports = "Imports", ### On conserve les Importations ou les Exportations
                       Outliers = T, ### Retire-t-on les outliers ? 
                       Outliers_coef = 10, ### Quel niveau d'écart inter Q garde-t-on pour le calcul des outliers ?
                       Trans_number = 0, ### On retire les produits vendus moins de Trans_number fois
                       Prod_problems = F, ### Enleve-t-on les produits avec des différences de prix trop importantes
                       Product_select = F, ### Conserve-t-on uniquement les produits sélectionnés par Loïc
                       Remove_double = T, ### Retire-t-on les doublons
                       Ponderation = T, ### Calcul de l'indice avec ponderation ?
                       Pond_log = F,
                       Smooth = F) 
  
{
  
  ### Nom du fichier
  Title_file = paste0("Ville_", Ville, "+",
                      "Type_", Exports_imports, "+",
                      "Outliers_", as.character(Outliers),  "+",
                      "Outliers_coef_", as.character(Outliers_coef), "+",
                      "Trans_number_", as.character(Trans_number), "+",
                      "Prod_problems_", as.character(Prod_problems), "+",
                      "Product_select_", as.character(Product_select), "+",
                      "Remove_double_", as.character(Remove_double), "+",
                      "Ponderation_", as.character(Ponderation), "+",
                      "Pond_log_", as.character(Pond_log))
  
  
  Title_graph = paste("Ville =", Ville, ";",
                      "Type =", Exports_imports, ";",
                      "Outliers =", as.character(Outliers),  ";",
                      "Outliers_coef =", as.character(Outliers_coef), ";",
                      "Trans_number =", as.character(Trans_number), ";",
                      "\nProd_problems =", as.character(Prod_problems), ";",
                      "Product_select =", as.character(Product_select), ";",
                      "Remove_double =", as.character(Remove_double), ";",
                      "Ponderation =", as.character(Ponderation), ";",
                      "Pond_log =", as.character(Pond_log))
  
  
  ### Ouverture d'une fenêtre pour l'enregistrement du graphique
  if (!Smooth) {
    png(filename = paste0("./scripts/Edouard/Figure_index/", Title_file, ".png"),
        width = 5000,
        height = 2700,
        res = 500)
    
  } else {
    png(filename = paste0("./scripts/Edouard/Figure_index_Smooth/", Title_file, ".png"),
        width = 5000,
        height = 2700,
        res = 500)
  }
  

        
  
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
                     main = Title_graph,
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

Filter_calcul_index <- function(Ville,  ### Choix du port d'étude
                                Exports_imports = "Imports", ### On conserve les Importations ou les Exportations
                                Outliers = T, ### Retire-t-on les outliers ? 
                                Outliers_coef = 10, ### Quel niveau d'écart inter Q garde-t-on pour le calcul des outliers ?
                                Trans_number = 0, ### On retire les produits vendus moins de Trans_number fois
                                Prod_problems = F, ### Enleve-t-on les produits avec des différences de prix trop importantes
                                Product_select = F, ### Conserve-t-on uniquement les produits sélectionnés par Loïc
                                Remove_double = T, ### Retire-t-on les doublons
                                Ponderation = T, ### Calcul de l'indice avec ponderation ?
                                Pond_log = F, ### Si ponderation == T, pondère-t-on par le log de la part dans la valeur totale ?
                                Correction_indice_Ag = T, #### Correction de l'indie par la aleur de l'Ag l'année observée
                                Product_sector = "All", ### Utile uniquement pour la construction des indices par composition
                                Partner = "All", ### Utile uniquement pour l'indice par partenaire (All, Europe_et_Méditérannée ou Reste_du_monde)
                                Smooth = F) ### Réalisation de la moyenne courante de l'indice et approximation des valeurs manquantes
{
  ### Filtrage de la base de données avec la fonction du scrip Filtrage.R
  Data_filter <- Data_filtrage(Ville = Ville,  ### Choix du port d'étude
                               Exports_imports = Exports_imports, ### On conserve les Importations ou les Exportations
                               Outliers = Outliers, ### conservation des outliers 
                               Outliers_coef = Outliers_coef, ### Quel niveau d'écart inter Q garde-t-on
                               Trans_number = Trans_number, ### On retire les produits vendus moins de Trans_number fois
                               Prod_problems = Prod_problems, ### Enleve-t-on les produits avec des différences de prix très importants
                               Product_select = Product_select, ### Selection des produits par Charles Loic
                               Remove_double = Remove_double, ### On retire les doublons
                               Correction_indice_Ag = Correction_indice_Ag,
                               Product_sector = Product_sector, ### Utile uniquement pour la construction des indices par composition
                               Partner = Partner) ### Utile uniquement pour l'indice par partenaire (All, Europe_et_Méditérannée ou Reste_du_monde)
                               
  ### Calcul de l'indice avec la fonction Calcul_index
  rt_index <- Calcul_index(Data_filter, Ponderation = Ponderation, Pond_log = Pond_log, Smooth = Smooth)
  
  

  
  ### On calcul la part pris en compte dans le flux total et dans le commerce totale du port et du type en question
  Data_part <- Data_filter %>%
    group_by(year) %>%
    summarise(Part_value = mean(Part_value),
              Part_flux = mean(Part_flux)) %>%
    as.data.frame()
  
  ### On ajoute à l'indice les colonnes de Part_value et Part_flux
  rt_index <- merge(rt_index, Data_part[ , c("year", "Part_value", "Part_flux")], "year" = "year", all.x = T,
                    all.y = F)
  
  if(Product_sector == "All" & Partner == "All") {
  ### On plot l'index avec la fonction Plot_index
    Plot_index(rt_index, Ville = Ville, Exports_imports = Exports_imports,
               Outliers = Outliers, Outliers_coef = Outliers_coef,
               Trans_number = Trans_number, Prod_problems = Prod_problems, 
               Product_select = Product_select, Remove_double = Remove_double,
               Ponderation = Ponderation, Pond_log = Pond_log, Smooth = Smooth)
  }
    
  ### On retourne l'indice obtenu
  return(rt_index)
  
}





### Calcul du test de Breusch - Pagan

# for (Ville_cons in c("Nantes", "Marseille", "Bayonne", "Bordeaux", "Rennes", "La Rochelle")){
#   for (Type in c("Imports", "Exports")) {
#     print(paste(Ville_cons, Type))
#     Filter_calcul_index(Ville = Ville_cons, Exports_imports = Type)
#   }
# }




### Calcul de l'indice par la méthode de Guillaume Daudin
# 
# 
# Data = Data_filtrage(Ville = "Marseille", Exports_imports = "Exports")
# 
# 
# 
# ### Calcul des pondérations
# Product_pond <- Data %>%
#   group_by(id_prod_simp) %>%
#   summarize(Value_tot_log = log(sum(value)),
#             Value_tot = sum(value))
# 
# ### On
# Product_pond$Value_part_log <- round(10000 * Product_pond$Value_tot_log / sum(Product_pond$Value_tot_log, na.rm = T))
# Product_pond$Value_part <- round(10000 * Product_pond$Value_tot / sum(Product_pond$Value_tot, na.rm = T))
# 
# 
# Data = merge(Data, Product_pond, by = "id_prod_simp",
#              all.x = T)
# 
# 
# model = lm(log(unit_price_metric) ~ factor(year) + factor(id_prod_simp),
#            weights = Part_value,
#            data = Data)
# 
# reg_correction = lm(log(unit_price_metric) ~ factor(year) + factor(id_prod_simp),
#                     weights = Data$Part_value / resid(model)**2,
#                     data = Data)
# 
# plot(reg_correction$residuals)
# 
# white_lm(reg_correction)
# 
# 
# ### BP test
# reg_bptest <- lm(reg_vp_guillaume$residuals**2 ~ factor(Data$year) + factor(Data$id_prod_simp))
# 
# 
# library(sandwich)
# 
# robust_reg = coeftest(model, vcov = sandwich)
# 
# 
# 
# 
# reg_correction$coefficients[1] = 0
# 
# Index = data.frame("year" = as.numeric(levels(factor(Data$year))),
#                    Index_value = 100*exp(reg_correction$coefficients[1:length(levels(factor(Data$year)))]))
# 
# plot(Index, type = "o")

