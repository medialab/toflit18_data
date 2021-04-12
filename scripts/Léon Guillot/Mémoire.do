clear all
import excel "C:\Users\leong\Desktop\MEMOIRE\Donn�es\R�sum� du Markovitch.xlsx", sheet("Feuil1")

ren A R�gion
ren B G�n�ralit�
ren C Ville
ren Picesdb103 Pi�cesd�b
ren Picesfin Pi�cesfin
foreach var of varlist Pi�cesd�b Superfdb {
generate `var'hab = (`var'/Popdeb)*10^3
}
foreach var of varlist Pi�cesfin Superffin {
generate `var'hab = (`var'/Popfin)*10^3
}
foreach var of varlist Pi�cesd�b Pi�cesfin Superfdb Superffin Valeursdb Valeursfin Prixdb Prixfin Pi�cesd�bhab Superfdbhab Pi�cesfinhab Superffinhab {
generate log`var' = log(`var')
}
gen col = (Ville=="Rouen"|Ville=="Montpellier"|Ville=="Poitiers"|Ville=="Rennes"|Ville=="La Rochelle"|Ville=="Bordeaux"|Ville=="Aix")
gen diffPi�ces=Pi�cesfin-Pi�cesd�b
gen col2 = (Ville=="Rouen"|Ville=="Montpellier"|Ville=="Rennes"|Ville=="La Rochelle"|Ville=="Bordeaux"|Ville=="Aix")
gen diffPi�ceshab
gen col3 = (Ville=="Rouen"|Ville=="Montpellier"|Ville=="Rennes"|Ville=="La Rochelle"|Ville=="Bordeaux"|Ville=="Aix"|Ville=="Paris")

gen lPi�ceshab = logPi�cesfinhab - logPi�cesd�bhab
gen lSuperfhab = logSuperffinhab - logSuperfdbhab
gen lPrix = logPrixfin-logPrixdb

reg diffPi�ces col2
reg lPi�ceshab col2
reg lSuperfhab col2
reg lPrix col2
reg lPrix col3
reg lPrix col
