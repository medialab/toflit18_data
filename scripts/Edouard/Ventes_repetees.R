library(dplyr)
library(tidyverse)
library(stringr)
library(readr)
library(pracma)

library(hpiR)



### Calcul des indices de prix : 1er exemple

### A définir
setwd("C:/Users/pignede/Documents/GitHub/toflit18_data")
### setwd("/Users/Edouard/Dropbox (IRD)/IRD/Missions/Marchandises_18eme")


rm(list = ls())

### On charge la fonction de filtrage
source("./scripts/Edouard/Filtrage.R")

### On filtre la bdd courante :


Data_filter <- Data_filtrage(Ville = "Bordeaux",  ### Choix du port d'étude
                             Outliers = F, ### conservation des outliers 
                             Outliers_coef = 1.5, ### Quel niveau d'écart inter Q garde-t-on
                             Trans_number = 0, ### On retire les produits vendus moins de Trans_number fois
                             Exports_imports = "Exports", ### On conserve les Importations ou les Exportations
                             Prod_problems = T,
                             Product_select = T) ### Conserve-t-on les produits avec des différences de prix très importants




# 
# Data_export <- Data_filter %>%
#   group_by(product_simplification) %>%
#   summarize(Trans_number = mean(trans_number)) %>%
#   as.data.frame() %>%
#   mutate(Ville = "Bordeaux",
#          Type = "Exports")
# 
# Data_export <- Data_export[, c("Ville", "Type", "product_simplification")]
# 
# write.csv(Data_export, 
#           file = "C:/Users/pignede/Dropbox (IRD)/IRD/Missions/Marchandises_18eme/Data_export.csv", 
#           fileEncoding = "UTF-8")
# 
# 




### Creation des colonnes de colonnes
Data_period <- dateToPeriod(trans_df = Data_filter,
                           date = 'Date',
                           periodicity = 'yearly')


### Création de la base de données des transactions considérées
Data_trans <- rtCreateTrans(trans_df = Data_period,
                                prop_id = "id_prod_simp",
                                trans_id = "id_trans",
                                price = "unit_price_metric",
                                min_period_dist = 0,
                                seq_only = T)


### Application du modèle
rt_model <- hpiModel(model_type = "rt",
                     hpi_df = Data_trans,
                     estimator = "weighted",
                     log_dep = T,
                     trim_model = F,
                     mod_spec = NULL)

### Calacul de l'indice
rt_index <- modelToIndex(rt_model)
rt_index$numeric <- as.numeric(rt_index$name)
rt_index$period <- as.numeric(rt_index$name)

rt_index$value <- na_if(rt_index$value, Inf) 

### Smooth index
smooth_index <- smoothIndex(rt_index,
                            order = 5,
                            in_place = T)

### Affichage du résultat
### Indice brut
plot(rt_index, show_imputed = T, main = "Index")
### Smooth index
plot(smooth_index, smooth = T)



### plotting without imputed value
rt_index_correct <- data.frame("value" = rt_index$value,
                               "period" = rt_index$numeric,
                               "imputed" = rt_index$imputed)
plot(subset(rt_index_correct, imputed == 0)$period,
     subset(rt_index_correct, imputed == 0)$value,
     type = "l")


index_vol <- calcVolatility(index = rt_index$value,
                            window = 3)



### Evaluation de l'indice
rt_index <- rtIndex(trans_df = Data_trans,
                    estimator = 'weighted',
                    log_dep = TRUE,
                    trim_model = TRUE,
                    smooth = TRUE,
                    smooth_order = 5)
### Calcul de la volatilité
index_vol <- calcVolatility(index = rt_index$index$value,
                            window = 3)
plot(index_vol)

### Calcul de la précision
rt_accuracy <- calcAccuracy(hpi_obj = rt_index,
                            test_type = 'rt',
                            test_method = 'kfold',
                            k = 10,
                            seed = 123,
                            smooth = T)

plot(rt_accuracy)


rt_series <- createSeries(hpi_obj = rt_index,
                          train_period = 24,
                          max_period = 30)

plot(rt_series)

rt_series <- calcSeriesAccuracy(series_obj = rt_series,
                                test_method = 'forecast',
                                test_type = 'rt',
                                smooth = TRUE,
                                in_place = TRUE)



### On observe l'évolution des prix unitaires de tous les produits importés
### plus de xxxx fois sur la période
for (prod in levels(Data_filter$product_simplification)) {
  
    Data_prod <- subset(Data_filter, product_simplification == prod)
    
    if (dim(Data_prod)[1] > 0) {
    
    print(Data_prod[, c("quantity_unit_metric", "unit_price_metric")])
    plot(Data_prod$year, Data_prod$unit_price_metric, main = prod)
    }
}




  

