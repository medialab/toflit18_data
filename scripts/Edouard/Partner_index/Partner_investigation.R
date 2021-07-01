
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
    
    Index_partner <- read.csv2("./scripts/Edouard/Partner_index_results.csv", row.names = NULL)
    
    dir.create(paste0("./scripts/Edouard/Partner_index/Figures/", Ville_cons, "_", Type))
    
    Index_partner <- Index_partner %>%
      filter(Ville == Ville_cons,
             Exports_imports == Type) %>%
      pivot_wider(id_cols = "year", names_from = "Partner", values_from = c("Index_value", "Part_value", "Part_flux")) %>%
      mutate(Part_value_Europe_et_Mediterranee_percent = Part_value_Europe_et_Mediterranee / Part_value_All,
             Part_value_Reste_du_monde_percent = Part_value_Reste_du_monde / Part_value_All)
    
    
    png(paste0("./scripts/Edouard/Partner_index/Figures/", Ville_cons, "_", Type, "/Index_value.png"),      
        width = 5000,
        height = 2700,
        res = 500)
    
    plot(drop_na(Index_partner[, c("year", "Index_value_All")]), type = "o", col = "black", ylim = c(50, 200), 
         main = paste(Ville_cons, Type))
    lines(drop_na(Index_partner[, c("year", "Index_value_Europe_et_Mediterranee")]), type = "o", col = "red")
    lines(drop_na(Index_partner[, c("year", "Index_value_Reste_du_monde")]), type = "o", col = "green")
    legend("topleft", c("All", "Europe_et_mediterranee", "Reste_du_monde"),
           col = c("black", "red", "green"), lty = 1)
    
    dev.off()
    
    png(paste0("./scripts/Edouard/Partner_index/Figures/", Ville_cons, "_", Type, "/Composition_volume.png"),      
        width = 5000,
        height = 2700,
        res = 500)
    
    barplot(t(as.matrix(Index_partner[, c("Part_value_Europe_et_Mediterranee", 
                                              "Part_value_Reste_du_monde")])),
            names.arg = Index_partner$year,
            legend.text = c("Europe_et_mediteranee", "Reste_du_monde"),
            args.legend = list(x = 40, y = 1.1), 
            main = paste(Ville_cons, Type))
    
    dev.off()
    
    png(paste0("./scripts/Edouard/Partner_index/Figures/", Ville_cons, "_", Type, "/Composition_part.png"),      
        width = 5000,
        height = 2700,
        res = 500)
    
    barplot(t(as.matrix(Index_partner[, c("Part_value_Europe_et_Mediterranee_percent", 
                                              "Part_value_Reste_du_monde_percent")])),
            names.arg = Index_partner$year,
            legend.text = c("Europe_et_Mediterranee", "Reste_du_monde"),
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

Index_partner <- read.csv2("./scripts/Edouard/Partner_index_results.csv", row.names = NULL)
Index_partner <- Index_partner %>%
  mutate_if(is.character, as.factor) %>%
  mutate(Partner = relevel(Partner, "All"),
         Exports_imports = relevel(Exports_imports, "Imports")) %>%
  filter(Ville != "Rennes")


plot(Index_partner$year, Index_partner$Index_value, type = "o")

Reg_trend_categ <- lm(log(Index_value) ~ year + Ville + Ville*year + Partner + Partner*year,
                      data = subset(Index_partner, Exports_imports == "Exports" & Partner != "All"))

summary(Reg_trend_categ)







Index_partner_global <- read.csv2("./scripts/Edouard/Partner_index_results_global.csv", row.names = NULL)
Index_partner_global <- Index_partner_global %>%
  mutate_if(is.character, as.factor) %>%
  filter(Exports_imports == "Exports", Partner != "All")

plot(Index_partner_global$year, Index_partner_global$Index_value, type = "o")


Reg_trend_partner_global <- lm(log(Index_value) ~ year + Partner + Partner*year ,
                             data = subset(Index_partner_global, Exports_imports == "Imports"))
summary(Reg_trend_partner_global)




Index_partner_global <- read.csv2("./scripts/Edouard/Partner_index_results_global.csv", row.names = NULL)

Terme_echange_rdm <- Index_partner_global %>%
  filter(Partner == "Reste_du_monde") %>%
  select(c("year", "Index_value", "Exports_imports")) %>%
  spread(Exports_imports, Index_value) %>%
  mutate(Exports = 100 * Exports / Exports[year == 1789],
         Imports = 100 * Imports /Imports[year == 1789],
         Terme_echange_rdm = Exports / Imports)

plot(drop_na(Terme_echange_rdm[, c("year", "Terme_echange_rdm")]), type = "o")




Index_partner_global <- read.csv2("./scripts/Edouard/Partner_index_results_global.csv", row.names = NULL)

Terme_echange_eem <- Index_partner_global %>%
  filter(Partner == "Europe_et_Mediterranee") %>%
  select(c("year", "Index_value", "Exports_imports")) %>%
  spread(Exports_imports, Index_value) %>%
  mutate(Exports = 100 * Exports / Exports[year == 1789],
         Imports = 100 * Imports /Imports[year == 1789],
         Terme_echange_eem = Exports / Imports)

plot(drop_na(Terme_echange_eem[, c("year", "Terme_echange_eem")]), type = "o")







Index_partner_global <- read.csv2("./scripts/Edouard/Partner_index_results_global.csv", row.names = NULL)

Index_eur_imports <- Index_partner_global %>%
  filter(Partner == "Europe_et_Mediterranee" & Exports_imports == "Imports")

plot(drop_na(Index_eur_imports[, c("year", "Index_value")]), type = "o", lwd = 2, pch = 19,
     xlab = "Année", ylab = "Valeur de l'indice", 
     main = "Indices des prix d'Europe et Méditérranée - Imports") 

Index_eur_exports <- Index_partner_global %>%
  filter(Partner == "Europe_et_Mediterranee" & Exports_imports == "Exports")

plot(drop_na(Index_eur_exports[, c("year", "Index_value")]), type = "o", lwd = 2, pch = 19,
     xlab = "Année", ylab = "Valeur de l'indice", 
     main = "Indices des prix d'Europe et Méditérranée - Exports") 


Index_rdm_imports <- Index_partner_global %>%
  filter(Partner == "Reste_du_monde" & Exports_imports == "Imports")

plot(drop_na(Index_rdm_imports[, c("year", "Index_value")]), type = "o", lwd = 2, pch = 19,
     xlab = "Année", ylab = "Valeur de l'indice", 
     main = "Indices des prix du reste du monde - Imports") 


Index_rdm_exports <- Index_partner_global %>%
  filter(Partner == "Reste_du_monde" & Exports_imports == "Exports")

plot(drop_na(Index_rdm_exports[, c("year", "Index_value")]), type = "o", lwd = 2, pch = 19,
     xlab = "Année", ylab = "Valeur de l'indice", 
     main = "Indices des prix du reste du monde - Exports") 





