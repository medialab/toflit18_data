
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



for (Ville_cons in c("Marseille", "Bordeaux", "La Rochelle", "Nantes", "Rennes", "Bayonne")) {
  for (Type in c("Imports", "Exports")) {
    
    Index_composition <- read.csv2("./scripts/Edouard/Composition_index_results.csv", row.names = NULL)
    
    Index_composition <- Index_composition %>%
      filter(Ville == Ville_cons,
             Exports_imports == Type) %>%
      pivot_wider(id_cols = "year", names_from = "Product_sector", values_from = c("Index_value", "Part_value", "Part_flux"))
    
    
    print(paste(Ville_cons, Type))
    reg_compo <- lm(log(All) ~ log(Manufactures) + log(Agriculture) + log(`Non-agricultural primary goods`), 
                    data = Index_composition)
    
    print(summary(reg_compo))
    
    
    
    Index_composition_mod <- Index_composition %>% rowwise() %>%
      mutate(Index_recomp = weighted.mean(c(Index_value_Manufactures, Index_value_Agriculture, `Index_value_Non-agricultural primary goods`), 
                                          c(Part_value_Manufactures, Part_value_Agriculture, `Part_value_Non-agricultural primary goods`)))
    
  }
}
