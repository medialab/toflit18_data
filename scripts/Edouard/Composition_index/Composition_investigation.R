
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
    
    dir.create(paste0("./scripts/Edouard/Composition_index/Figures/", Ville_cons, "_", Type))
    
    Index_composition <- Index_composition %>%
      filter(Ville == Ville_cons,
             Exports_imports == Type) %>%
      pivot_wider(id_cols = "year", names_from = "Product_sector", values_from = c("Index_value", "Part_value", "Part_flux")) %>%
      mutate(Part_value_Manufactures_percent = Part_value_Manufactures / Part_value_All,
             `Part_value_Non-agricultural primary goods_percent` = `Part_value_Non-agricultural primary goods` / Part_value_All,
             Part_value_Agriculture_percent = Part_value_Agriculture / Part_value_All)
    
    
    png(paste0("./scripts/Edouard/Composition_index/Figures/", Ville_cons, "_", Type, "/Index_value.png"),      
        width = 5000,
        height = 2700,
        res = 500)
    
    plot(drop_na(Index_composition[, c("year", "Index_value_All")]), type = "o", col = "black", ylim = c(50, 200), 
         main = paste(Ville_cons, Type))
    lines(drop_na(Index_composition[, c("year", "Index_value_Manufactures")]), type = "o", col = "red")
    lines(drop_na(Index_composition[, c("year", "Index_value_Non-agricultural primary goods")]), type = "o", col = "green")
    lines(drop_na(Index_composition[, c("year", "Index_value_Agriculture")]), type = "o", col = "blue")
    legend("topleft", c("All", "Manufactures", "Non-agricultural primary goods", "Agriculture"),
           col = c("black", "red", "green", "blue"), lty = 1)
    
    dev.off()
    
    png(paste0("./scripts/Edouard/Composition_index/Figures/", Ville_cons, "_", Type, "/Composition_volume.png"),      
        width = 5000,
        height = 2700,
        res = 500)
    
    barplot(t(as.matrix(Index_composition[, c("Part_value_Manufactures", 
                                              "Part_value_Non-agricultural primary goods", 
                                              "Part_value_Agriculture")])),
            names.arg = Index_composition$year,
            legend.text = c("Manufactures", "Non-agricultural primary goods", "Agriculture"),
            args.legend = list(x = 40, y = 1.1), 
            main = paste(Ville_cons, Type))
    
    dev.off()
    
    png(paste0("./scripts/Edouard/Composition_index/Figures/", Ville_cons, "_", Type, "/Composition_part.png"),      
        width = 5000,
        height = 2700,
        res = 500)
    
    barplot(t(as.matrix(Index_composition[, c("Part_value_Manufactures_percent", 
                                              "Part_value_Non-agricultural primary goods_percent", 
                                              "Part_value_Agriculture_percent")])),
            names.arg = Index_composition$year,
            legend.text = c("Manufactures", "Non-agricultural primary goods", "Agriculture"),
            args.legend = list(x = "topright"), 
            main = paste(Ville_cons, Type))
    
    dev.off()
    
    
    print(paste(Ville_cons, Type))
    # reg_compo <- lm(log(All) ~ log(Manufactures) + log(Agriculture) + log(`Non-agricultural primary goods`), 
    #                 data = Index_composition)
    # 
    # print(summary(reg_compo))
    # 
    # 
    # 
    # Index_composition_mod <- Index_composition %>% rowwise() %>%
    #   mutate(Index_recomp = weighted.mean(c(Index_value_Manufactures, Index_value_Agriculture, `Index_value_Non-agricultural primary goods`), 
    #                                       c(Part_value_Manufactures, Part_value_Agriculture, `Part_value_Non-agricultural primary goods`)))
    # 
  }
}






### Calcul regression des trends par secteur

Index_composition <- read.csv2("./scripts/Edouard/Composition_index_results.csv", row.names = NULL)
Index_composition <- Index_composition %>%
  mutate_if(is.character, as.factor) %>%
  mutate(Product_sector = relevel(Product_sector, "All"),
         Exports_imports = relevel(Exports_imports, "Imports"))

Reg_trend_categ <- lm(log(Index_value) ~ year + Ville + Ville*year + Product_sector + Product_sector*year + Exports_imports,
                      data = subset(Index_composition, Product_sector %in% c("Manufactures", "Primary coloniaux", "Primary european") & Ville != "Rennes"))

summary(Reg_trend_categ)







Index_composition_global <- read.csv2("./scripts/Edouard/Composition_index_results_global.csv", row.names = NULL)
Index_composition_global <- Index_composition_global %>%
  mutate_if(is.character, as.factor) %>%
  mutate(Product_sector = relevel(Product_sector, "All"))



Reg_trend_categ_global <- lm(log(Index_value) ~ year + Product_sector + Product_sector*year ,
                data = subset(Index_composition_global, Product_sector %in% c("Manufactures", "Primary goods") & Exports_imports == "Exports"))
summary(Reg_trend_categ_global)






Index_composition_global <- read.csv2("./scripts/Edouard/Composition_index_results_global.csv", row.names = NULL)

Terme_echange_pg <- Index_composition_global %>%
  filter(Product_sector == "Primary goods") %>%
  select(c("year", "Index_value", "Exports_imports")) %>%
  spread(Exports_imports, Index_value) %>%
  mutate(Exports = 100 * Exports / Exports[year == 1789],
         Imports = 100 * Imports /Imports[year == 1789],
         Terme_echange_pg = Exports / Imports)

plot(drop_na(Terme_echange_pg[, c("year", "Terme_echange_pg")]), type = "o", pch = 19,
      lwd = 2, col = "blue")



Index_composition_global <- read.csv2("./scripts/Edouard/Composition_index_results_global.csv", row.names = NULL)

Terme_echange_pg <- Index_composition_global %>%
  filter(Product_sector == "Manufactures") %>%
  select(c("year", "Index_value", "Exports_imports")) %>%
  spread(Exports_imports, Index_value) %>%
  mutate(Exports = 100 * Exports / Exports[year == 1789],
         Imports = 100 * Imports /Imports[year == 1789],
         Terme_echange_pg = Exports / Imports)

lines(drop_na(Terme_echange_pg[, c("year", "Terme_echange_pg")]), type = "o", pch = 19,
     lwd = 2, col = "red")







Index_composition_global <- read.csv2("./scripts/Edouard/Composition_index_results_global.csv", row.names = NULL)

Index_manufactures_imports <- Index_composition_global %>%
  filter(Product_sector == "Manufactures" & Exports_imports == "Imports")

plot(drop_na(Index_manufactures_imports[, c("year", "Index_value")]), type = "o", lwd = 2, pch = 19,
     xlab = "Année", ylab = "Valeur de l'indice", 
     main = "Indices des prix des produits manufacturés - Imports") 



Index_manufactures_exports <- Index_composition_global %>%
  filter(Product_sector == "Manufactures" & Exports_imports == "Exports")

plot(drop_na(Index_manufactures_exports[, c("year", "Index_value")]), type = "o", lwd = 2, pch = 19,
     xlab = "Année", ylab = "Valeur de l'indice", 
     main = "Indices des prix des produits manufacturés - Exports") 



Index_colonies_imports <- Index_composition_global %>%
  filter(Product_sector == "Primary coloniaux" & Exports_imports == "Imports")

plot(drop_na(Index_colonies_imports[, c("year", "Index_value")]), type = "o", lwd = 2, pch = 19,
     xlab = "Année", ylab = "Valeur de l'indice",
     main = "Indices des prix des produits primaires (colonies) - Imports") 


Index_colonies_exports <- Index_composition_global %>%
  filter(Product_sector == "Primary coloniaux" & Exports_imports == "Exports")

plot(drop_na(Index_colonies_exports[, c("year", "Index_value")]), type = "o", lwd = 2, pch = 19,
     xlab = "Année", ylab = "Valeur de l'indice", 
     main = "Indices des prix des produits primaire (colonies) - Exports") 



Index_european_imports <- Index_composition_global %>%
  filter(Product_sector == "Primary european" & Exports_imports == "Imports")

plot(drop_na(Index_european_imports[, c("year", "Index_value")]), type = "o", lwd = 2, pch = 19,
     xlab = "Année", ylab = "Valeur de l'indice", 
     main = "Indices des prix des produits primaires (Europe) - Imports") 




Index_european_exports <- Index_composition_global %>%
  filter(Product_sector == "Primary european" & Exports_imports == "Exports")

plot(drop_na(Index_european_exports[, c("year", "Index_value")]), type = "o", lwd = 2, pch = 19,
     xlab = "Année", ylab = "Valeur de l'indice", 
     main = "Indices des prix des produits primaires (Europe) - Exports") 



















