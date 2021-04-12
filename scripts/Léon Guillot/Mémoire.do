clear all
import excel "C:\Users\leong\Desktop\MEMOIRE\Données\Résumé du Markovitch.xlsx", sheet("Feuil1") firstrow

ren A Région
ren B Généralité
ren C Ville
ren Piècesdéb103 Piècesdéb
ren Piècesfin Piècesfin
foreach var of varlist Piècesdéb Superfdéb {
generate `var'hab = (`var'/Popdeb)*10^3
}
foreach var of varlist Piècesfin Superffin {
generate `var'hab = (`var'/Popfin)*10^3
}
foreach var of varlist Piècesdéb Piècesfin Superfdéb Superffin Valeursdéb Valeursfin Prixdéb Prixfin Piècesdébhab Superfdébhab Piècesfinhab Superffinhab {
generate log`var' = log(`var')
}
drop Colonial
gen col = (Ville=="Rouen"|Ville=="Montpellier"|Ville=="Poitiers"|Ville=="Rennes"|Ville=="La Rochelle"|Ville=="Bordeaux"|Ville=="Aix")
gen diffPièces=Piècesfin-Piècesdéb
gen col2 = (Ville=="Rouen"|Ville=="Montpellier"|Ville=="Rennes"|Ville=="La Rochelle"|Ville=="Bordeaux"|Ville=="Aix")
gen diffPièceshab=Piècesfinhab-Piècesdébhab
gen col3 = (Ville=="Rouen"|Ville=="Montpellier"|Ville=="Rennes"|Ville=="La Rochelle"|Ville=="Bordeaux"|Ville=="Aix"|Ville=="Paris")

gen lPièceshab = logPiècesfinhab - logPiècesdébhab
gen lSuperfhab = logSuperffinhab - logSuperfdébhab
gen lPrix = logPrixfin-logPrixdéb

reg diffPièces col2
reg lPièceshab col2
reg lSuperfhab col2
reg lPrix col2
reg lPrix col3
reg lPrix col

