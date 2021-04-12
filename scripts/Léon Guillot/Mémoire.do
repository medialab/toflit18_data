clear all
import excel "C:\Users\leong\Desktop\MEMOIRE\Données\Résumé du Markovitch.xlsx", sheet("Feuil1")

ren A Région
ren B Généralité
ren C Ville
ren Picesdb103 Piècesdéb
ren Picesfin Piècesfin
foreach var of varlist Piècesdéb Superfdb {
generate `var'hab = (`var'/Popdeb)*10^3
}
foreach var of varlist Piècesfin Superffin {
generate `var'hab = (`var'/Popfin)*10^3
}
foreach var of varlist Piècesdéb Piècesfin Superfdb Superffin Valeursdb Valeursfin Prixdb Prixfin Piècesdébhab Superfdbhab Piècesfinhab Superffinhab {
generate log`var' = log(`var')
}
gen col = (Ville=="Rouen"|Ville=="Montpellier"|Ville=="Poitiers"|Ville=="Rennes"|Ville=="La Rochelle"|Ville=="Bordeaux"|Ville=="Aix")
gen diffPièces=Piècesfin-Piècesdéb
gen col2 = (Ville=="Rouen"|Ville=="Montpellier"|Ville=="Rennes"|Ville=="La Rochelle"|Ville=="Bordeaux"|Ville=="Aix")
gen diffPièceshab
gen col3 = (Ville=="Rouen"|Ville=="Montpellier"|Ville=="Rennes"|Ville=="La Rochelle"|Ville=="Bordeaux"|Ville=="Aix"|Ville=="Paris")

gen lPièceshab = logPiècesfinhab - logPiècesdébhab
gen lSuperfhab = logSuperffinhab - logSuperfdbhab
gen lPrix = logPrixfin-logPrixdb

reg diffPièces col2
reg lPièceshab col2
reg lSuperfhab col2
reg lPrix col2
reg lPrix col3
reg lPrix col
