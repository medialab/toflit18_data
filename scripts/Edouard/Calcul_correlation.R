library(dplyr)
library(tidyverse)
library(stringr)
library(readr)
library(pracma)

library(openxlsx)

library(hpiR)

### A définir
setwd("C:/Users/pignede/Documents/GitHub/toflit18_data")
### setwd("/Users/Edouard/Dropbox (IRD)/IRD/Missions/Marchandises_18eme")


rm(list = ls())


Calcul_correlation_matrix <- function()
  
{

  ### On charge les valeurs actuelles du csv
  Index_res <- read.csv2("./scripts/Edouard/Index_results.csv", row.names = 1, dec = ",")
  
  
  Cor_matrix_workbook <- createWorkbook()
  
  for (Ville in c("Nantes", "Marseille", "Bordeaux", "La Rochelle")) {
    for (Type in c("Imports", "Exports")) {
  
      
      Var_used <- unique(Index_res[ , 3:10])
      
      col_names <- c()
      for (Row in seq(1, dim(Var_used)[1])) {
        name <- c()
        for (Col in 1:8) {
          name <- paste(name, names(Var_used)[Col], ":", as.character(Var_used[Row, Col]), ";")
        }
        col_names <- c(col_names, name)
      }
      
      Correlation_matrix <- matrix(nrow = dim(Var_used)[1], ncol = dim(Var_used),
                                   dimnames = list(col_names, col_names))
      
      
      for (i in seq(1, dim(Var_used)[1])) {
        for (j in seq(1, dim(Var_used)[1])) {
          Index1 <- Index_res %>%
            filter(Ville == Ville,
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
          
          Index2 <- Index_res %>%
            filter(Ville == Ville,
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
          
          cor <- cor(Index1, Index2, use = "complete.obs")
          
          if (cor[1,1] > 0.99) {
            Correlation_matrix[i, j] = cor[2,2]
          } else {
            Correlation_matrix[i, j] = NA
          }
        }
      }
      
      addWorksheet(Cor_matrix_workbook, sheetName = paste(Ville, Type))
      
      writeData(Cor_matrix_workbook,
                sheet = paste(Ville, Type),
                x = Correlation_matrix,
                rowNames = T,
                colNames = T)
      
    }
  }
        
  saveWorkbook(Cor_matrix_workbook, "./scripts/Edouard/Correlation_matrix.xlsx",
               overwrite = T)      
        
}
    
    
