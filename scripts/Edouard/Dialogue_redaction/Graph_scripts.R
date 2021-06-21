
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

library(corrplot)
library(ggplot2)

library(reshape2)
library(gdata)

### A définir: emplacement du working directory
setwd("C:/Users/pignede/Documents/GitHub/toflit18_data")
### setwd("/Users/Edouard/Dropbox (IRD)/IRD/Missions/Marchandises_18eme")

### Nettoyage de l'espace de travail
rm(list = ls())

layout(matrix(1:2,2))



### Graphique index global ----

Index_res_global_Imports <- read.csv2("./scripts/Edouard/Indice_global_value/Indice_global_filtre_ville_imports.csv", 
                              row.names = NULL, dec = ",")

Index_res_global_Imports$Index <- 100*Index_res_global_Imports$Index/Index_res_global_Imports$Index[Index_res_global_Imports$year == 1789]



# 2- Programmer des marges larges pour l'ajout ultérieur des titres des axes
par(mar=c(4,4,3,5))
# 3- On récupère dans position la position de chaque barre
position = barplot(Index_res_global_Imports$Part_value_national, 
                   col = rgb(0.220, 0.220, 0.220, alpha = 0.2),
                   names.arg = Index_res_global_Imports$year,
                   axes = F,
                   ylab = "", xlab = "",
                   main = "Indice global - Imports",
                   ylim = c(0,1), 
                   las = 2, space = 0, cex.main = 1)
# las = 2 : ce paramètre permet d'orienter le label de chaque barre verticalement
# 4- Configurer la couleur de l'axe de gauche (correspondant ici aux barres)
axis(4, col = "black", at = seq(0, 1, by = 0.2), lab = scales::percent(seq(0, 1, by = 0.2), accuracy = 1))
# 5- Superposer la courbe
par(new = TRUE, mar = c(4, 4, 3, 5))
maximal = max(position) + (position[2] - position[1])
plot(position[!is.na(Index_res_global_Imports$Index)], Index_res_global_Imports$Index[!is.na(Index_res_global_Imports$Index)], 
     col = "black", type = "o", lwd = 2,
     pch = 16, axes = F, ylab = "", xlab = "", 
     xlim = c(0, length(Index_res_global_Imports$Index)),
     ylim = c(40, 122))
# 6- Configurer l'axe de droite, correspondant à la coube
axis(2, col.axis = "black", col = "black")
box();grid()
mtext("Index value",side=2,line=2,cex = 0.8)
mtext("Part du commerce prise en compte dans l’indice \n(en valeur)", side = 4, col = "black", line = 3, cex = 0.8)




Index_res_global_Exports <- read.csv2("./scripts/Edouard/Indice_global_value/Indice_global_filtre_ville_exports.csv", 
                                      row.names = NULL, dec = ",")

Index_res_global_Exports$Index <- 100*Index_res_global_Exports$Index/Index_res_global_Exports$Index[Index_res_global_Exports$year == 1789]


# 2- Programmer des marges larges pour l'ajout ultérieur des titres des axes
par(mar=c(4,4,3,5))
# 3- On récupère dans position la position de chaque barre
position = barplot(Index_res_global_Exports$Part_value_national, 
                   col = rgb(0.220, 0.220, 0.220, alpha = 0.2),
                   names.arg = Index_res_global_Exports$year,
                   axes = F,
                   ylab = "", xlab = "",
                   main = "Indice global - Exports",
                   ylim = c(0,1), 
                   las = 2, space = 0, cex.main = 1)
# las = 2 : ce paramètre permet d'orienter le label de chaque barre verticalement
# 4- Configurer la couleur de l'axe de gauche (correspondant ici aux barres)
axis(4, col = "black", at = seq(0, 1, by = 0.2), lab = scales::percent(seq(0, 1, by = 0.2), accuracy = 1))
# 5- Superposer la courbe
par(new = TRUE, mar = c(4, 4, 3, 5))
maximal = max(position) + (position[2] - position[1])
plot(position[!is.na(Index_res_global_Exports$Index)], Index_res_global_Exports$Index[!is.na(Index_res_global_Exports$Index)], 
     col = "black", type = "o", lwd = 2,
     pch = 16, axes = F, ylab = "", xlab = "", 
     xlim = c(0, length(Index_res_global_Exports$Index)),
     ylim = c(40, 122))
# 6- Configurer l'axe de droite, correspondant à la coube
axis(2, col.axis = "black", col = "black")
box();grid()
mtext("Index value",side = 2,line = 2,cex = 0.8)
mtext("Part du commerce prise en compte dans l’indice\n (en valeur)", side = 4, col = "black", line = 3, cex = 0.8)






### Terme de l'échange - Indice global ----

### Indice global

Index_res_global_Imports <- read.csv2("./scripts/Edouard/Indice_global_value/Indice_global_filtre_ville_imports.csv", 
                                      row.names = NULL, dec = ",")

Index_res_global_Imports$Index <- 100*Index_res_global_Imports$Index/Index_res_global_Imports$Index[Index_res_global_Imports$year == 1789]


Index_res_global_Exports <- read.csv2("./scripts/Edouard/Indice_global_value/Indice_global_filtre_ville_exports.csv", 
                                      row.names = NULL, dec = ",")

Index_res_global_Exports$Index <- 100*Index_res_global_Exports$Index/Index_res_global_Exports$Index[Index_res_global_Exports$year == 1789]


Terme_echange <- merge(Index_res_global_Imports, Index_res_global_Exports, by = "year",
                       suffixes = c("_Imports", "_Exports"))

Terme_echange$Terme_echange <- Terme_echange$Index_Exports/Terme_echange$Index_Imports



plot(drop_na(Terme_echange[ , c("year", "Terme_echange")]), type = "o", pch = 19,
     lwd = 2, ylab = "Termes de léchange", xlab = "Année", main = "Evolution des termes de l'échange",
     panel.first = grid(), ylim = c(0.4, 3.7))

Index_partner_global <- read.csv2("./scripts/Edouard/Partner_index_results_global.csv", row.names = NULL)

Terme_echange_rdm <- Index_partner_global %>%
  filter(Partner == "Reste_du_monde") %>%
  select(c("year", "Index_value", "Exports_imports")) %>%
  spread(Exports_imports, Index_value) %>%
  mutate(Exports = 100 * Exports / Exports[year == 1789],
         Imports = 100 * Imports /Imports[year == 1789],
         Terme_echange_rdm = Exports / Imports)

lines(drop_na(Terme_echange_rdm[, c("year", "Terme_echange_rdm")]), type = "o", pch = 19,
      lwd = 2, col = "red")




Index_partner_global <- read.csv2("./scripts/Edouard/Partner_index_results_global.csv", row.names = NULL)

Terme_echange_eem <- Index_partner_global %>%
  filter(Partner == "Europe_et_Mediterranee") %>%
  select(c("year", "Index_value", "Exports_imports")) %>%
  spread(Exports_imports, Index_value) %>%
  mutate(Exports = 100 * Exports / Exports[year == 1789],
         Imports = 100 * Imports /Imports[year == 1789],
         Terme_echange_eem = Exports / Imports)

lines(drop_na(Terme_echange_eem[, c("year", "Terme_echange_eem")]), type = "o", pch = 19,
     lwd = 2, col = "blue")

legend("topright", legend = c("Total", "Europe et Méditérranée", "Reste du monde"),
       col = c("black", "blue", "red"), lwd = 2) 



### Indice sectoriel


Composition_index <- read.csv2("./scripts/Edouard/Composition_index_results_global.csv", 
                                      row.names = NULL, dec = ",")

Index_global_col_agr_imports <- Composition_index %>%
  filter(Exports_imports == "Imports" & Product_sector == "Primary coloniaux") %>%
  select(c("year", "Index_value", "Part_value"))

Index_global_col_agr_imports$Index_value <- 100*Index_global_col_agr_imports$Index_value/Index_global_col_agr_imports$Index_value[Index_global_col_agr_imports$year == 1789]

Index_global_col_agr_exports <- Composition_index %>%
  filter(Exports_imports == "Exports" & Product_sector == "Primary coloniaux") %>%
  select(c("year", "Index_value", "Part_value"))

Index_global_col_agr_exports$Index_value <- 100*Index_global_col_agr_exports$Index_value/Index_global_col_agr_exports$Index_value[Index_global_col_agr_exports$year == 1789]


Index_global_manufactures_imports <- Composition_index %>%
  filter(Exports_imports == "Imports" & Product_sector == "Manufactures") %>%
  select(c("year", "Index_value", "Part_value"))

Index_global_manufactures_imports$Index_value <- 100*Index_global_manufactures_imports$Index_value/Index_global_manufactures_imports$Index_value[Index_global_manufactures_imports$year == 1789]


Index_global_manufactures_exports <- Composition_index %>%
  filter(Exports_imports == "Exports" & Product_sector == "Manufactures") %>%
  select(c("year", "Index_value", "Part_value"))

Index_global_manufactures_exports$Index_value <- 100*Index_global_manufactures_exports$Index_value/Index_global_manufactures_exports$Index_value[Index_global_manufactures_exports$year == 1789]


Index_global_eur_agr_imports <- Composition_index %>%
  filter(Exports_imports == "Imports" & Product_sector == "Primary european") %>%
  select(c("year", "Index_value", "Part_value"))

Index_global_eur_agr_imports$Index_value <- 100*Index_global_eur_agr_imports$Index_value/Index_global_eur_agr_imports$Index_value[Index_global_eur_agr_imports$year == 1789]


Index_global_eur_agr_exports <- Composition_index %>%
  filter(Exports_imports == "Exports" & Product_sector == "Primary european") %>%
  select(c("year", "Index_value", "Part_value"))

Index_global_eur_agr_exports$Index_value <- 100*Index_global_eur_agr_exports$Index_value/Index_global_eur_agr_exports$Index_value[Index_global_eur_agr_exports$year == 1789]



plot(drop_na(Index_global_col_agr_imports[, c("year", "Index_value")]), type = "o", pch = 19,
      lwd = 2)
lines(drop_na(Index_global_manufactures_imports[, c("year", "Index_value")]), type = "o", pch = 19,
     lwd = 2, col = "blue")
lines(drop_na(Index_global_eur_agr_imports[, c("year", "Index_value")]), type = "o", pch = 19,
     lwd = 2, col = "red")


plot(drop_na(Index_global_col_agr_exports[, c("year", "Index_value")]), type = "o", pch = 19,
     lwd = 2)
lines(drop_na(Index_global_manufactures_exports[, c("year", "Index_value")]), type = "o", pch = 19,
     lwd = 2, col = "blue")
lines(drop_na(Index_global_eur_agr_exports[, c("year", "Index_value")]), type = "o", pch = 19,
     lwd = 2, col = "red")



Terme_echange_col_agr <- merge(Index_global_col_agr_imports, Index_global_col_agr_exports,
                                   by = "year", suffixes = c("_Imports", "_Exports"))
Terme_echange_manufactures <- merge(Index_global_manufactures_imports, Index_global_manufactures_exports,
                                   by = "year", suffixes = c("_Imports", "_Exports"))
Terme_echange_eur_agr <- merge(Index_global_eur_agr_imports, Index_global_eur_agr_exports,
                                   by = "year", suffixes = c("_Imports", "_Exports"))
Terme_echange_col_agr$Terme_echange <- Terme_echange_col_agr$Index_value_Exports / Terme_echange_col_agr$Index_value_Imports

Terme_echange_manufactures$Terme_echange <- Terme_echange_manufactures$Index_value_Exports / Terme_echange_manufactures$Index_value_Imports

Terme_echange_eur_agr$Terme_echange <- Terme_echange_eur_agr$Index_value_Exports / Terme_echange_eur_agr$Index_value_Imports


plot(drop_na(Terme_echange[ , c("year", "Terme_echange")]), type = "o", pch = 19,
     lwd = 2, ylab = "Termes de léchange", xlab = "Année", main = "Evolution des termes de l'échange",
     panel.first = grid())

plot(drop_na(Terme_echange_col_agr[ , c("year", "Terme_echange")]), type = "o", pch = 19,
     lwd = 2, col = "blue")
lines(drop_na(Terme_echange_manufactures[ , c("year", "Terme_echange")]), type = "o", pch = 19,
      lwd = 2, col = "red")
lines(drop_na(Terme_echange_eur_agr[ , c("year", "Terme_echange")]), type = "o", pch = 19,
      lwd = 2, col = "green")






### Graphique de traçage des différents indices sur une même figure ----


Index_res <- read.csv2("./scripts/Edouard/Index_results.csv", row.names = NULL, dec = ",")


Index_res <- Index_res %>% 
  filter(Outliers == T & Outliers_coef == 10 & Trans_number == 0 & Prod_problems == F &
            Product_select == F & Remove_double == T & Ponderation == T & Pond_log == F) %>%
  select(c("Ville", "Exports_imports", "year", "Index_value", "Part_value")) %>%
  filter(Ville != "Rennes")


Index_res_villes <- pivot_wider(Index_res, names_from = "Ville",
                                values_from = c("Index_value", "Part_value"))


### Imports

Index_res_villes_Imports <- Index_res_villes %>%
  filter(Exports_imports == "Imports") %>%
  select(-c("Exports_imports")) %>%
  arrange(year)



Index_res_villes_Imports <- Index_res_villes_Imports %>%
  mutate(across(starts_with("Index_value"), function(x){return(100*x/x[length(x)])}))



plot(drop_na(Index_res_villes_Imports[c("year", "Index_value_Nantes")]), type = "o", col = "black", ylim = c(18,118), xlim = c(1715, 1790),
     pch = 19, lwd = 2, ylab = "Valeur des indices de prix", xlab = "Année", main = "Indice de prix - Imports") 
lines(drop_na(Index_res_villes_Imports[c("year", "Index_value_Marseille")]), type = "o", col = "red", pch = 19, lwd = 2)
lines(drop_na(Index_res_villes_Imports[c("year", "Index_value_Bordeaux")]), type = "o", col = "blue", pch = 19, lwd = 2)
lines(drop_na(Index_res_villes_Imports[c("year", "Index_value_La Rochelle")]), type = "o", col = "green", pch = 19, lwd = 2)
lines(drop_na(Index_res_villes_Imports[c("year", "Index_value_Bayonne")]), type = "o", col = "orange", pch = 19, lwd = 2)
legend("topleft", legend = c("Nantes", "Marseille", "Bordeaux", "La Rochelle", "Bayonne"),
       col = c("black", "red", "blue", "green", "orange"), lwd = 2)





# 2- Programmer des marges larges pour l'ajout ultérieur des titres des axes
par(mar=c(4,4,3,5))
# 3- On récupère dans position la position de chaque barre
position = barplot(Index_res_villes_Exports$Part_value_Bordeaux, 
                   col = rgb(0.220, 0.220, 0.220, alpha = 0.2),
                   names.arg = Index_res_villes_Exports$year,
                   axes = F,
                   ylab = "", xlab = "",
                   main = "Indice Bordeaux - Exports",
                   ylim = c(0,1), 
                   las = 2, space = 0, cex.main = 1)
# las = 2 : ce paramètre permet d'orienter le label de chaque barre verticalement
# 4- Configurer la couleur de l'axe de gauche (correspondant ici aux barres)
axis(4, col = "black", at = seq(0, 1, by = 0.2), lab = scales::percent(seq(0, 1, by = 0.2), accuracy = 1))
# 5- Superposer la courbe
par(new = TRUE, mar = c(4, 4, 3, 5))
maximal = max(position) + (position[2] - position[1])
plot(position[!is.na(Index_res_villes_Exports$Index_value_Bordeaux)], Index_res_villes_Exports$Index_value_Bordeaux[!is.na(Index_res_villes_Exports$Index_value_Bordeaux)], 
     col = "black", type = "o", lwd = 2,
     pch = 16, axes = F, ylab = "", xlab = "", 
     xlim = c(0, length(Index_res_villes_Exports$Index_value_Bordeaux)),
     ylim = c(18, 118))
# 6- Configurer l'axe de droite, correspondant à la coube
axis(2, col.axis = "black", col = "black")
box();grid()
mtext("Valeur de l'indice",side=2,line=2,cex = 1)
mtext("Part du commerce prise en compte dans l’indice \n(en valeur)", side = 4, col = "black", line = 3, cex = 1)






### Exports

Index_res_villes_Exports <- Index_res_villes %>%
  filter(Exports_imports == "Exports") %>%
  select(-c("Exports_imports")) %>%
  arrange(year)



Index_res_villes_Exports <- Index_res_villes_Exports %>%
  mutate(across(starts_with("Index_value"), function(x){return(100*x/x[length(x)])}))



plot(drop_na(Index_res_villes_Exports[c("year", "Index_value_Nantes")]), type = "o", col = "black", ylim = c(50,120), xlim = c(1720,1790),
     pch = 19, lwd = 2, ylab = "Valeur des indices de prix", xlab = "Année", main = "Indice de prix - Exports")
lines(drop_na(Index_res_villes_Exports[c("year", "Index_value_Marseille")]), type = "o", col = "red", pch = 19, lwd = 2)
lines(drop_na(Index_res_villes_Exports[c("year", "Index_value_Bordeaux")]), type = "o", col = "blue", pch = 19, lwd = 2)
lines(drop_na(Index_res_villes_Exports[c("year", "Index_value_La Rochelle")]), type = "o", col = "green", pch = 19, lwd = 2)
lines(drop_na(Index_res_villes_Exports[c("year", "Index_value_Bayonne")]), type = "o", col = "orange", pch = 19, lwd = 2)
legend("topleft", legend = c("Nantes", "Marseille", "Bordeaux", "La Rochelle", "Bayonne"),
       col = c("black", "red", "blue", "green", "orange"), lwd = 2)







### Graphique de variation des corrélations entre indices des ports ----

### Global

### Imports

Cor_ville_Imports <- as.matrix(openxlsx::read.xlsx("./scripts/Edouard/Correlation_matrix_ville.xlsx",
                                                             sheet = "Imports", rowNames = T))


corrplot(Cor_ville_Imports, type = "upper", diag = F,
         method = "ellipse",
         outline = T, tl.col = "black", tl.srt = 45)


### Exports

Cor_ville_Exports <- as.matrix(openxlsx::read.xlsx("./scripts/Edouard/Correlation_matrix_ville.xlsx",
                                                   sheet = "Exports", rowNames = T))


corrplot(Cor_ville_Exports, type = "upper", diag = F,
         outline = T, tl.col = "black", tl.srt = 45)



### Par année, début à 1760 et 1750 à 1789

### Imports

Cor_ville_Imports_1700_1760 <- as.matrix(openxlsx::read.xlsx("./scripts/Edouard/Correlation_matrix_ville1700_1760.xlsx",
                                                   sheet = "Imports", rowNames = T))


corrplot(Cor_ville_Imports_1700_1760, type = "upper", diag = F,
         outline = T, tl.col = "black", tl.srt = 45)


Cor_ville_Imports_1750_1900 <- as.matrix(openxlsx::read.xlsx("./scripts/Edouard/Correlation_matrix_ville1750_1900.xlsx",
                                                             sheet = "Imports", rowNames = T))


corrplot(Cor_ville_Imports_1750_1900, type = "upper", diag = F,
         outline = T, tl.col = "black", tl.srt = 45)



### Exports

Cor_ville_Imports_1700_1760 <- as.matrix(openxlsx::read.xlsx("./scripts/Edouard/Correlation_matrix_ville1700_1760.xlsx",
                                                             sheet = "Exports", rowNames = T))


corrplot(Cor_ville_Imports_1700_1760, type = "upper", diag = F,
         outline = T, tl.col = "black", tl.srt = 45)


Cor_ville_Imports_1750_1900 <- as.matrix(openxlsx::read.xlsx("./scripts/Edouard/Correlation_matrix_ville1750_1900.xlsx",
                                                             sheet = "Exports", rowNames = T))


corrplot(Cor_ville_Imports_1750_1900, type = "upper", diag = F,
         outline = T, tl.col = "black", tl.srt = 45)







### Graphique des corrélations avec décroissance et croissance de la corrélation ----


Cor_ville_Imports <- as.matrix(openxlsx::read.xlsx("./scripts/Edouard/Correlation_matrix_ville.xlsx",
                                                   sheet = "Imports", rowNames = T))
Cor_ville_Imports_1700_1760 <- as.matrix(openxlsx::read.xlsx("./scripts/Edouard/Correlation_matrix_ville1700_1760.xlsx",
                                                             sheet = "Imports", rowNames = T))
Cor_ville_Imports_1750_1900 <- as.matrix(openxlsx::read.xlsx("./scripts/Edouard/Correlation_matrix_ville1750_1900.xlsx",
                                                             sheet = "Imports", rowNames = T))


Cor_diff <- (Cor_ville_Imports_1750_1900 - Cor_ville_Imports_1700_1760)/Cor_ville_Imports_1700_1760

Cor_diff_pos <- pmax(Cor_diff, 0)
Cor_diff_pos <- pmin(Cor_diff_pos, 0.95)

Cor_diff_neg <- pmin(Cor_diff, 0)
Cor_diff_neg <- pmax(Cor_diff_neg, -0.95)


source("./scripts/Edouard/Cor_dif.R")



corrplot(Cor_ville_Imports_1750_1900, type = "upper", diag = F,
         method = "circle",
         is.corr = F,
         tl.pos = "td",
         outline = T, tl.col = "black", tl.srt = 30,
         lowCI.mat = Cor_diff_neg,
         uppCI.mat = Cor_diff_pos,
         plotCI = "rect",
         title = "Evolution des corrélations entre les différents indices des ports - Imports",
         mar = c(0,0,2,0))

# lowerTriangle(Cor_diff, diag = T, byrow = F) <- NA
# lowerTriangle(Cor_ville_Imports, diag = T, byrow = F) <- NA
# Cor_ville_Imports <- melt(Cor_ville_Imports, na.rm = F, value.name = "Cor_value")
# Cor_diff <- melt(Cor_diff, na.rm = F, value.name = "Diff")
# Cor_diff_pos <- melt(Cor_diff_pos, na.rm = T, value.name = "Diff_pos")
# Cor_diff_neg <- melt(Cor_diff_neg, na.rm = T, value.name = "Diff_neg")
# 
# 
# Cor_data2 <- merge(Cor_ville_Imports, Cor_diff, by = c("Var1", "Var2"))
# 
# Cor_data <- merge(merge(Cor_ville_Imports, Cor_diff_pos, by = c("Var1", "Var2")), Cor_diff_neg, by = c("Var1", "Var2"))
# 
# ggplot(drop_na(Cor_data2), aes(x = factor(0), y = Diff, fill = Cor_value)) +
#   geom_col() +
#   scale_y_continuous(name = "Evolution de la Correlation", limits=c(-1.5, 1.5)) +
#   facet_wrap(Var1 ~ Var2) + 
#   theme(
#     strip.background = element_blank(),
#     strip.text.x = element_blank(), 
#     panel.background = element_rect(fill = "transparent", colour = "black",
#                                     size = 1, linetype = "solid")) +
#   scale_fill_gradient2(low = "red", high = "blue", mid = "white", 
#                                             midpoint = 0, limit = c(-1,1), space = "Lab", 
#                                             name="Correlation")
#   
#   
  
  
  
  
  
  # scale_fill_gradient2(low = "blue", high = "red", mid = "white", 
  #                      midpoint = 0, limit = c(-1,1), space = "Lab", 
  #                      name="Pearson\nCorrelation") +
  # geom_point(aes(color = value, size = abs(value)))+
  # geom_tile(color = "black", fill = "white")+
  # 
  # scale_color_gradient2(low = "green", mid = "white", midpoint = 0, high = "red", name = "")+
  # scale_size_continuous(range = c(5,15), name = "")+
  # geom_text(data = corr_pval, aes(label = Label), size = 8, vjust = 0.7, hjust = 0.5)




































