library(dplyr)
library(tidyverse)
library(stringr)
library(readr)
library(pracma)

library(IndexNumR)

### Calcul des indices de prix : 1er exemple

### A définir
setwd("C:/Users/pignede/Documents/GitHub/toflit18_data")
### setwd("/Users/Edouard/Dropbox (IRD)/IRD/Missions/Marchandises_18eme")

rm(list = ls())


source(Filtrage.R)


Data_filter <- Data_filtrage(Ville = "Nantes",  ### Choix du port d'étude
                             Outliers = F, ### conservation des outliers 
                             Outliers_coef = 1.5, ### Quel niveau d'écart inter Q garde-t-on
                             Trans_number = 0, ### On retire les produits vendus moins de Trans_number fois
                             Exports_imports = "Imports", ### On conserve les Importations ou les Exportations
                             Prod_problems = T) ### Conserve-t-on les produits avec des différences de prix très importants

Data_filter_recombine <- Data_filter %>%
  mutate(year_index = as.factor(yearIndex(Data_filter$Date)))
levels(Data_filter_recombine$year_index) <- as.character(seq(1:length(levels(Data_filter_recombine$year_index))))

Data_filter_recombine <- Data_filter_recombine %>%
  mutate(year_index = as.numeric(year_index))


Chained_index <- priceIndex(Data_filter_recombine,
                            pvar = "unit_price_metric",
                            qvar = "quantities_metric",
                            pervar = "year_index",
                            prodID = "id_prod_simp")

plot(Chained_index)
