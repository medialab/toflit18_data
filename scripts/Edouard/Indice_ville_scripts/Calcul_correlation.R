
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


### A définir: emplacement du working directory
setwd("C:/Users/pignede/Documents/GitHub/toflit18_data")
### setwd("/Users/Edouard/Dropbox (IRD)/IRD/Missions/Marchandises_18eme")

### Nettoyage de l'espace de travail
rm(list = ls())


### Cette fonction permet de remplir l'excel Correlation_matrix.xlsx
### Cette excel possède un onglet par Ville + Type avec Type = Imports ou Exports
### Pour chaque indice il calcule les corrélations possibles entre l'ensemble des variations des paramètres 
### utilisés dans le fichier csv Index_results.csv

Calcul_correlation_matrix <- function()
  
{

  ### On charge les valeurs de Index_results.csv
  Index_res <- read.csv2("./scripts/Edouard/Index_results.csv", row.names = NULL, dec = ",")
  
  ### Création d'un workbook (objet comparable à un excel et converti en excel à la fin)
  Cor_matrix_workbook <- createWorkbook()
  
  ### On récupère l'ensemble des villes du csv des indices
  liste_ville <- unique(Index_res[ , 1])
  
  for (Ville_cons in liste_ville) {
    for (Type in c("Imports", "Exports")) {
  
      ### On récupère l'ensemble des configurations possibles avec les variables
      Var_used <- unique(Index_res[ , 3:10])
      
      ### col_names est égal à la suite de l'ensemble des configurations possibles avec les variables
      col_names <- c()
      for (Row in seq(1, dim(Var_used)[1])) {
        name <- c()
        for (Col in 1:8) {
          name <- paste(name, names(Var_used)[Col], ":", as.character(Var_used[Row, Col]), ";")
        }
        col_names <- c(col_names, name)
      }
      
      ### Création de la matrice de corrélation les noms des lignes et des colonnes sont égales à col_names
      Correlation_matrix <- matrix(nrow = dim(Var_used)[1], ncol = dim(Var_used)[1],
                                   dimnames = list(col_names, col_names))
      
      
      ### Pour chaque configuration possible on calcule les corrélations 2 à 2 des indices
      for (i in seq(1, dim(Var_used)[1])) {
        for (j in seq(1, dim(Var_used)[1])) {
          
          ### Récupération de l'indice Configuration 1
          Index1 <- Index_res %>%
            filter(Ville == Ville_cons,
                   Exports_imports == Type,
                   Outliers == Var_used$Outliers[i],
                   Outliers_coef == Var_used$Outliers_coef[i],
                   Trans_number == Var_used$Trans_number[i],
                   Prod_problems == Var_used$Prod_problems[i],
                   Product_select == Var_used$Product_select[i],
                   Remove_double == Var_used$Remove_double[i],
                   Ponderation == Var_used$Ponderation[i],
                   Pond_log == Var_used$Pond_log[i]) %>%
              select(c("year", "Index_value"))
          
          ### Récupération de l'indice configuration 2
          Index2 <- Index_res %>%
            filter(Ville == Ville_cons,
                   Exports_imports == Type,
                   Outliers == Var_used$Outliers[j],
                   Outliers_coef == Var_used$Outliers_coef[j],
                   Trans_number == Var_used$Trans_number[j],
                   Prod_problems == Var_used$Prod_problems[j],
                   Product_select == Var_used$Product_select[j],
                   Remove_double == Var_used$Remove_double[j],
                   Ponderation == Var_used$Ponderation[j],
                   Pond_log == Var_used$Pond_log[j]) %>%
            select(c("year", "Index_value"))
          
          ### Calcul de la correlation
          cor <- cor(Index1, Index2, use = "complete.obs")
          
          ### si les années sont bien comparables entre les indices (cor[1,1] > 0.99) alors on remplit la matrix de correlation
          ### sinon on met NA
          if (cor[1,1] > 0.99) {
            Correlation_matrix[i, j] = cor[2,2]
          } else {
            Correlation_matrix[i, j] = NA
          }
        }
      }
      
      ### On crée un nouvel onglet ville type au workbook
      addWorksheet(Cor_matrix_workbook, sheetName = paste(Ville_cons, Type))
      
      ### On ajoute la matrice de corrélation dans l'onglet ville type
      writeData(Cor_matrix_workbook,
                sheet = paste(Ville_cons, Type),
                x = Correlation_matrix,
                rowNames = T,
                colNames = T)
      
    }
  }
  
  ### On sauvegarde le workbook dans l'excel Correlation_matrix.xlsx    
  saveWorkbook(Cor_matrix_workbook, "./scripts/Edouard/Correlation_matrix.xlsx",
               overwrite = T)      
        
}





### Calcul de la corrélation des indices entre les différentes villes étudiées
### uniquement pour la baseline


Calcul_correlation_matrix_ville <- function(year_deb = 1700, year_fin = 1900) 
  
{
  ### On charge les valeurs de Index_results.csv
  Index_res <- read.csv2("./scripts/Edouard/Index_results.csv", row.names = NULL, dec = ",")
  
  ### On conserve uniquement la baseline
  Index_res_baseline <- Index_res %>%
    filter(Outliers == T & Outliers_coef == 10 & Trans_number == 0 & Prod_problems == F &
             Product_select == F & Remove_double == T & Ponderation == T & Pond_log == F)
  
  ### Création d'un workbook (objet comparable à un excel et converti en excel à la fin)
  Cor_matrix_workbook <- createWorkbook()
  
  ### On récupère l'ensemble des villes du csv des indices
  liste_ville <- unique(Index_res[ , 1])
  
  for (Type in c("Imports", "Exports")) {
    
    ### Création de la matrice de corrélation les noms des lignes et des colonnes sont égales à col_names
    Correlation_matrix <- matrix(nrow = length(liste_ville), ncol = length(liste_ville),
                                 dimnames = list(liste_ville, liste_ville))
    
    
    for (i in seq(1,length(liste_ville))) {
      for (j in seq(1,length(liste_ville))) {
        
        Index1 <- Index_res_baseline %>%
          filter(Ville == liste_ville[i], Exports_imports == Type) %>%
          select(c("year", "Index_value")) %>%
          filter(year >= year_deb & year <= year_fin) %>%
          drop_na()
        
        Index2 <- Index_res_baseline %>%
          filter(Ville == liste_ville[j], Exports_imports == Type) %>%
          select(c("year", "Index_value")) %>%
          drop_na() %>%
          filter(year %in% Index1$year)
        
        Index1 <- Index1 %>% filter(year %in% Index2$year)
        
        
        cor <- cor(Index1, Index2, use = "complete.obs")
        
        
        if (cor[1,1] > 0.99) {
          Correlation_matrix[i, j] = cor[2,2]
        } else {
          Correlation_matrix[i, j] = NA
        }
      }
    }
        
    ### On crée un nouvel onglet ville type au workbook
    addWorksheet(Cor_matrix_workbook, sheetName = paste(Type))
    
    ### On ajoute la matrice de corrélation dans l'onglet ville type
    writeData(Cor_matrix_workbook,
              sheet = paste(Type),
              x = Correlation_matrix,
              rowNames = T,
              colNames = T)
        
  }
  
### On sauvegarde le workbook dans l'excel Correlation_matrix.xlsx    
saveWorkbook(Cor_matrix_workbook, paste0("./scripts/Edouard/Correlation_matrix_ville", 
                                         year_deb, "_", year_fin,".xlsx"),
             overwrite = T)    
}



### Test de cointégration entre les différents indices de chaque ville


Smooth = F

if (!Smooth) {
  ### On charge les valeurs de Index_results.csv
  Index_res <- read.csv2("./scripts/Edouard/Index_results.csv", row.names = NULL, dec = ",")


  ### On conserve uniquement la baseline
  Index_res_baseline <- Index_res %>%
    filter(Outliers == T & Outliers_coef == 10 & Trans_number == 0 & Prod_problems == F &
             Product_select == F & Remove_double == T & Ponderation == T & Pond_log == F)
  
} else {

  Index_smooth <- read.csv2("./scripts/Edouard/Index_results_Smooth.csv", row.names = NULL, dec = ",")
  
  Index_res_baseline <- Index_smooth

}

Type = "Imports"

Index_res_baseline <- Index_res_baseline %>%
  filter(Exports_imports == Type)


Index_Marseille <- Index_res_baseline %>%
  filter (Ville == "Marseille") %>%
  select(c("year", "Index_value")) %>%
  rename("Index_Marseille" = "Index_value")

Index_Bordeaux <- Index_res_baseline %>%
  filter (Ville == "Bordeaux") %>%
  select(c("year", "Index_value")) %>%
  rename("Index_Bordeaux" = "Index_value")

Index_Nantes <- Index_res_baseline %>%
  filter (Ville == "Nantes") %>%
  select(c("year", "Index_value")) %>%
  rename("Index_Nantes" = "Index_value")

Index_La_Rochelle <- Index_res_baseline %>%
  filter (Ville == "La Rochelle") %>%
  select(c("year", "Index_value")) %>%
  rename("Index_La_Rochelle" = "Index_value")

Index_Rennes <- Index_res_baseline %>%
  filter (Ville == "Rennes") %>%
  select(c("year", "Index_value")) %>%
  rename("Index_Rennes" = "Index_value")

Index_Bayonne <- Index_res_baseline %>%
  filter (Ville == "Bayonne") %>%
  select(c("year", "Index_value")) %>%
  rename("Index_Bayonne" = "Index_value")


Index_villes <- Index_Marseille %>%
  full_join(Index_Bordeaux, by = "year") %>%
  full_join(Index_La_Rochelle, by = "year") %>%
  full_join(Index_Nantes, by = "year") %>%
  full_join(Index_Bayonne, by = "year") %>%
  full_join(Index_Rennes, by = "year") %>%
  arrange(year)
  
  


library(urca)

matrix_cointeg <- matrix(nrow = 6, ncol = 6,
                         dimnames = list(names(Index_villes[,2:7]), names(Index_villes[,2:7])))

for (i in 2:6) {
  for (j in seq(i+1,7)) {
    jotest = ca.jo(Index_villes[, c(i,j)], type = "trace", ecdet = "none", spec = "longrun")
    res = summary(jotest)
    
    jotest_sign <- names(res@cval[2,])[c(res@teststat[2] > res@cval[2,1] & res@teststat[2] < res@cval[2,2],
                                         res@teststat[2] > res@cval[2,2] & res@teststat[2] < res@cval[2,3],
                                         res@teststat[2] > res@cval[2,3])]
    
    
    if (length(jotest_sign) == 0){jotest_sign <- "Non Sign"}
    
    matrix_cointeg[i-1,j-1] = jotest_sign
  }
}

print(matrix_cointeg)









 
    
