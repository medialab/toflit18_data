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


source("./scripts/Edouard/Filtrage.R")


Data_filter <- Data_filtrage(Ville = "Marseille",  ### Choix du port d'étude
                             Outliers = F, ### conservation des outliers 
                             Outliers_coef = 1.5, ### Quel niveau d'écart inter Q garde-t-on
                             Trans_number = 0, ### On retire les produits vendus moins de Trans_number fois
                             Exports_imports = "Imports", ### On conserve les Importations ou les Exportations
                             Prod_problems = T) ### Conserve-t-on les produits avec des différences de prix très importants



### On supprime les années manquantes pour construire l'indice,
### en stockant toutes les années manquantes en les metttant dans Year
Year <- sort(as.numeric(levels(as.factor(Data_filter$year))))

Data_filter_recombine <- Data_filter %>%
  mutate(year_index = as.factor(yearIndex(Data_filter$Date)))
levels(Data_filter_recombine$year_index) <- as.character(seq(1:length(levels(Data_filter_recombine$year_index))))

Data_filter_recombine <- Data_filter_recombine %>%
  mutate(year_index = as.numeric(year_index))


### On calcule l'indice des pric par la méthode chaînée
Chained_index <- priceIndex(Data_filter_recombine,
                            pvar = "unit_price_metric",
                            qvar = "quantities_metric",
                            pervar = "year_index",
                            prodID = "id_prod_simp",
                            indexMethod = "fisher",
                            sample = "matched",
                            output = "pop",
                            chainMethod = "pop",
                            sigma = 1.0001,
                            basePeriod = 1,
                            biasAdjust = T)

### On observe le résultat
plot(Year, Chained_index, type = 'l', ylim = c(0,2))
