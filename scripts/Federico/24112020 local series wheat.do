if "`c(username)'" =="federico.donofrio" {
	*import delimited "C:\Users\federico.donofrio\Documents\TOFLIT desktop\Données Stata\bdd courante.csv", varnames(1) encoding(UTF-8) 
	**GD20200710 Déjà, cela c’est assez suspect. Il faut exploiter le .zip qui est intégré dans le git, plutôt ? Tu peux unzipper depuis stata
	*avec la commande unzipfile
	*save "C:\Users\federico.donofrio\Documents\GitHub\Données Stata\bdd courante.dta", replace
	global dir "C:\Users\federico.donofrio\Documents\GitHub\"
	
}

if "`c(username)'" =="guillaumedaudin" {
	global dir "~/Documents/Recherche/Commerce International Français XVIIIe.xls/Balance du commerce/Retranscriptions_Commerce_France"
}


clear
cd `"$dir"'
capture log using "`c(current_time)' `c(current_date)'"
*À faire pour récupérer les données
unzipfile "toflit18_data_GIT\base/bdd courante.csv.zip", replace
insheet using "toflit18_data_GIT\base/bdd courante.csv", clear
save "Données Stata/bdd courante.dta", replace
*/


use "Données Stata/bdd courante.dta", clear


codebook product_grains


*** dummy importexport
gen importexport=0
replace importexport=1 if (export_import=="Export" | export_import=="Exports"| export_import=="Sortie")



*** deal with missing values and generate value ** Devrait être fait dand la base 
if "`c(username)'" =="federico.donofrio" {
	*import delimited "C:\Users\federico.donofrio\Documents\TOFLIT desktop\Données Stata\bdd courante.csv", varnames(1) encoding(UTF-8) 
	**GD20200710 Déjà, cela c’est assez suspect. Il faut exploiter le .zip qui est intégré dans le git, plutôt ? Tu peux unzipper depuis stata
	*avec la commande unzipfile
	*save "C:\Users\federico.donofrio\Documents\GitHub\Données Stata\bdd courante.dta", replace
	global dir "C:\Users\federico.donofrio\Documents\GitHub\"
	
}

if "`c(username)'" =="guillaumedaudin" {
	global dir "~/Documents/Recherche/Commerce International Français XVIIIe.xls/Balance du commerce/Retranscriptions_Commerce_France"
}


clear
cd `"$dir"'
capture log using "`c(current_time)' `c(current_date)'"
*À faire pour récupérer les données
unzipfile "toflit18_data_GIT\base/bdd courante.csv.zip", replace
insheet using "toflit18_data_GIT\base/bdd courante.csv", clear
save "Données Stata/bdd courante.dta", replace
*/


use "Données Stata/bdd courante.dta", clear


codebook product_grains


*** dummy importexport
gen importexport=0
replace importexport=1 if (export_import=="Export" | export_import=="Exports"| export_import=="Sortie")



*** deal with missing values and generate value ** Devrait être fait dand la base 
/*
generate value=value
replace value=prix_unitaire*quantit if value==. & prix_unitaire!=.
drop if value==.
drop if value==0
*/



***garder quand on a le commerce national complet ou les flux locaux complets
****Je garde 1789 (pour du local) car il ne manque que le commerce avec les Indes.
keep if best_guess_national_prodxpart==1 | best_guess_region_prodxpart==1 | (year==1789 & source_type=="National toutes directions partenaires manquants")
drop if customs_region =="Colonies Françaises de l'Amérique"




*create national and local
gen natlocal=customs_region

**Pour traiter 1750, qui a à la fois du local et du national. Du coup, on le met 2 fois
save temp.dta, replace
keep if year==1750
replace natlocal="National"
append using temp.dta
erase temp.dta

replace natlocal="National" if best_guess_national_prodxpart==1 & year !=1750
drop if natlocal=="[vide]"



*** isolate grains (Rq : il faut faire le fillin avant !)
drop if product_grains=="Pas grain (0)"
drop if product_grains=="."
encode product_grains, generate(grains_num)label(grains)

*********************************************Fin de la préparation des données

*** count number of parners for each year, direction across all categories

egen n_partners=nvals(partner_simplification), by(year natlocal importexport)


***drop national
drop if natlocal=="National"
***total trade of grains for each locality, 

bys year natlocal importexport  : egen total_value = sum(value)
bys year natlocal importexport grains_num  : egen total_value_category = sum(value)

***exceptional replace
replace quantity_unit_orthographic="boisseau" if quantity_unit_orthographic =="boisseaux"
replace quantity_unit_orthographic="quart" if quantity_unit_orthographic=="quarts"
****limit natloc
keep if natlocal=="Bayonne" | natlocal=="Bordeaux" | natlocal=="La Rochelle" | natlocal=="Marseille" | natlocal=="Nantes" | natlocal=="Rennes" | natlocal=="Rouen"
****farine GUILLAUME CHECK THIS IDEA
keep if grains_num==2

***convert measures
gen unifiedmeasure=quantity
gen unifiedmeasure2=quantity 
***BAYONNE
*a conque is steadily equal to 2 mesures
replace unifiedmeasure=quantity*120 if quantity_unit_orthographic=="mesures" & natlocal=="Bayonne"
* The ratio or prices conque/livres is not stable, it obscillates around 70:1, but Savary claims there are 60 livres in a conques de Bayonne
replace unifiedmeasure=quantity*60 if quantity_unit_orthographic=="conques"& natlocal=="Bayonne"
replace unifiedmeasure=quantity*100 if quantity_unit_orthographic=="quintaux" & natlocal=="Bayonne"

***convert measures without hypothesis

replace unifiedmeasure2=quantity*140 if quantity_unit_orthographic=="mesures" & natlocal=="Bayonne"
* The ratio or prices conque/livres is not stable, it obscillates around 70:1, but Savary claims there are 60 livres in a conques de Bayonne
replace unifiedmeasure2=quantity*70 if quantity_unit_orthographic=="conques" & natlocal=="Bayonne"
replace unifiedmeasure2=quantity*100 if quantity_unit_orthographic=="quintaux" & natlocal=="Bayonne"

***BORDEAUX
*a boisseau de bordeaux according to dictionnaire Leopold =2 setiers de Paris, that is approx 120 livres, but if the grain is good then 124.
replace unifiedmeasure=quantity*124 if quantity_unit_orthographic=="boisseau" & natlocal=="Bordeaux"
*a 1 quartier de blaye corresponds according to brutails to 1.25 boisseaux de Bordeaux, that is about 152 livres (1 boisseau de bordeaux ==122 livres)
replace unifiedmeasure=quantity*152 if quantity_unit_orthographic=="quartiers mesure de blaye"& natlocal=="Bordeaux"
* Leopold claims 1 last=38 boisseaux de bordeaux
replace unifiedmeasure=quantity*38*124 if quantity_unit_orthographic=="last" & natlocal=="Bordeaux"
*based on : the universal cambist, the quintal in bordeaux is actually 101 lpdm
replace unifiedmeasure=quantity*101 if quantity_unit_orthographic=="quintal" & natlocal=="Bordeaux"
***based on universal cambist sack of wheat from holland should be about 127 lpdm, but 120 seems more accurate, i.e. == boisseaux
replace unifiedmeasure=quantity*120 if quantity_unit_orthographic=="sacs" & partner_orthographic=="Hollande"  & natlocal=="Bordeaux"
*** theoretically a sack from England should be equal to 4 bushels (James Sheppard, the British corn merchant's and farmer's manual), that is 259 livres de pdm, but this does not make any sense for us.
replace unifiedmeasure=quantity*259 if quantity_unit_orthographic=="sacs" & partner_orthographic=="Angleterre"  & natlocal=="Bordeaux"
***not very significant, retrieved from price ratio with boisseau (1 pots at 2,7=0,45 boisseaux at 6 livres t)
replace unifiedmeasure=quantity*55.8 if quantity_unit_orthographic=="pots"  & natlocal=="Bordeaux"
**despite the similarity with the measure "quarter", it seems that quartier is similar to quartier mesure de blaye and therefore 1,25 boisseaux
replace unifiedmeasure=quantity*152 if quantity_unit_orthographic=="quartiers"  & natlocal=="Bordeaux"
replace unifiedmeasure=quantity*240 if quantity_unit_orthographic=="setiers"  & natlocal=="Bordeaux"
*according to Savary: 1 tonneau==20 boisseaux, 2880 livres
replace unifiedmeasure=quantity*2880 if quantity_unit_orthographic=="tonneaux"  & natlocal=="Bordeaux"
** selon le Dictionnaire universel de commerce, banque, manufactures, douanes, 1805, la fanègue pèse autour des 150 livres pdm but it is too little, still better than the usual estimation at 95
replace unifiedmeasure=quantity*150 if quantity_unit_orthographic=="fanègues" & natlocal=="Bordeaux"

***LOWER LIMIT convert measures without hypothesis that boisseaux==120 livres, which is very low.

replace unifiedmeasure2=quantity*120 if quantity_unit_orthographic=="boisseau"  & natlocal=="Bordeaux"

replace unifiedmeasure2=quantity*150 if quantity_unit_orthographic=="quartiers mesure de blaye" & natlocal=="Bordeaux"
* Leopold claims 1 last=38 boisseaux de bordeaux
replace unifiedmeasure2=quantity*38*120 if quantity_unit_orthographic=="last" & natlocal=="Bordeaux"
*based on : the universal cambist, the quintal in bordeaux is actually 101 lpdm
replace unifiedmeasure2=quantity*100 if quantity_unit_orthographic=="quintal" & natlocal=="Bordeaux"
***based on universal cambist sack of wheat from holland should be about 127 lpdm, but 120 seems more accurate, i.e. == boisseaux
replace unifiedmeasure2=quantity*120 if quantity_unit_orthographic=="sacs" & partner_orthographic=="Hollande" & natlocal=="Bordeaux"
*** theoretically a sack from England should be equal to 4 bushels (James Sheppard, the British corn merchant's and farmer's manual), that is 259 livres de pdm, but this does not make any sense for us.
replace unifiedmeasure2=quantity*259 if quantity_unit_orthographic=="sacs" & partner_orthographic=="Angleterre" & natlocal=="Bordeaux"
* boisseaux at 120, pots at 0,45 boisseaux
replace unifiedmeasure2=quantity*54 if quantity_unit_orthographic=="pots" & natlocal=="Bordeaux"
**despite the similarity with the measure "quarter", it seems that quartier is similar to quartier mesure de blaye and therefore 1,25 boisseaux
replace unifiedmeasure2=quantity*152 if quantity_unit_orthographic=="quartiers" & natlocal=="Bordeaux" 
replace unifiedmeasure2=quantity*240 if quantity_unit_orthographic=="setiers" & natlocal=="Bordeaux"
*according to Savary: 1 tonneau==20 boisseaux, 2880 livres
replace unifiedmeasure2=quantity*2880 if quantity_unit_orthographic=="tonneaux" & natlocal=="Bordeaux"
** selon le Dictionnaire universel de commerce, banque, manufactures, douanes, 1805, la fanègue pèse autour des 150 livres pdm but it is too little, still better than the usual estimation at 95
replace unifiedmeasure2=quantity*150 if quantity_unit_orthographic=="fanègues" & natlocal=="Bordeaux"

***LA ROCHELLE

 *** it's unclear why, but Savary is certainly wrong when he claims 32boisseaux de Rochelle=19setiers de Paris. It seems instead that 36 boisseaux=1 tonneau=9 setier de paris
replace unifiedmeasure=quantity*71 if quantity_unit_orthographic=="boisseau" & natlocal=="La Rochelle"
replace unifiedmeasure=quantity*100 if quantity_unit_orthographic=="quintaux" & natlocal=="La Rochelle"
***based on Le négoce d'Amsterdam ou Traité de sa banque, de ses changes, des Compagnies ...by Jacques Le Moine de l'Espine
* sacs are1/36th of a last d'Amsterdam, we deduce therefore that 1 setiers=1,9 sacs and therefore 150 livres pdm
replace unifiedmeasure=quantity*150 if quantity_unit_orthographic=="sacs" & natlocal=="La Rochelle"
*** theoretically a sack from England should be equal to 4 bushels (James Sheppard, the British corn merchant's and farmer's manual), that is 259 livres de pdm, but this does not make any sense for us. 
*Or to 3 bushels (boisseau?)
replace unifiedmeasure=quantity*250 if quantity_unit_orthographic=="sacs" & partner_orthographic=="Angleterre" & natlocal=="La Rochelle"
***let's assume it works easily
replace unifiedmeasure=quantity*480 if quantity_unit_orthographic=="cartier du pied de 480 livres" & natlocal=="La Rochelle"
*** retrive it from the price ratio with tonneaux
replace unifiedmeasure=quantity*60 if quantity_unit_orthographic=="barils" & year==1752 & natlocal=="La Rochelle"
replace unifiedmeasure=quantity*192 if quantity_unit_orthographic=="barils" & year==1739 & natlocal=="La Rochelle"

**despite the similarity with the measure "quarter", it seems that quartier is similar to quartier mesure de blaye and therefore 1,25 boisseaux
replace unifiedmeasure=quantity*152 if quantity_unit_orthographic=="quartiers" & natlocal=="La Rochelle"
replace unifiedmeasure=quantity*240 if quantity_unit_orthographic=="setiers" & natlocal=="La Rochelle"
*according to Savary: 1 tonneau==19 boisseaux, that is between 2160 livres and 2560. prices seem to justify the higher estimate at least for the later period
replace unifiedmeasure=quantity*2560 if quantity_unit_orthographic=="tonneaux" & natlocal=="La Rochelle"
*no clear info, retrive from price ratio
replace unifiedmeasure=quantity*285 if quantity_unit_orthographic=="barriques" & natlocal=="La Rochelle"
*the flacon is probably a mistake for sac, then a value around 1/14 of a tonneau de la Rochelle
replace unifiedmeasure=quantity*182 if quantity_unit_orthographic=="flacons" & natlocal=="La Rochelle"
replace unifiedmeasure=quantity*150 if quantity_unit_orthographic=="poches" & natlocal=="La Rochelle"

***LOWER LIMIT convert measures without hypothesis that boisseaux==120 livres, which is very low.

*** it's unclear why, but Savary is certainly wrong when he claims 32boisseaux de Rochelle=19setiers de Paris. It seems instead that 36 boisseaux=1 tonneau=9 setier de paris
replace unifiedmeasure2=quantity*60 if quantity_unit_orthographic=="boisseau" & natlocal=="La Rochelle"

* Leopold claims 1 last=38 boisseaux de bordeaux
replace unifiedmeasure2=quantity*38*120 if quantity_unit_orthographic=="last" & natlocal=="La Rochelle"
***let's assume it works easily
replace unifiedmeasure=quantity*480 if quantity_unit_orthographic=="cartier du pied de 480 livres" & natlocal=="La Rochelle"
*** retrive it from the price ratio with tonneaux
replace unifiedmeasure2=quantity*50 if quantity_unit_orthographic=="barils" & year==1752 & natlocal=="La Rochelle"
replace unifiedmeasure2=quantity*162 if quantity_unit_orthographic=="barils" & year==1739 & natlocal=="La Rochelle"
replace unifiedmeasure2=quantity*100 if quantity_unit_orthographic=="quintaux"
***based on Le négoce d'Amsterdam ou Traité de sa banque, de ses changes, des Compagnies ...by Jacques Le Moine de l'Espine
* sacs are1/36th of a last d'Amsterdam, we deduce therefore that 1 setiers=1,9 sacs and therefore, if 1:setier=240 livres pdm, 126 livres ==1 sacs
replace unifiedmeasure2=quantity*126 if quantity_unit_orthographic=="sacs"  & natlocal=="La Rochelle"
*** theoretically a sack from England should be equal to 4 bushels (James Sheppard, the British corn merchant's and farmer's manual), that is 259 livres de pdm, but this does not make any sense for us.
replace unifiedmeasure2=quantity*250 if quantity_unit_orthographic=="sacs" & partner_orthographic=="Angleterre" & natlocal=="La Rochelle"
***let's assume it works easily & natlocal=="La Rochelle"
replace unifiedmeasure2=quantity*480 if quantity_unit_orthographic=="cartier du pied de 480 livres" & natlocal=="La Rochelle"
**despite the similarity with the measure "quarter", it seems that quartier is similar to quartier mesure de blaye and therefore 1,25 boisseaux
replace unifiedmeasure2=quantity*152 if quantity_unit_orthographic=="quartiers" & natlocal=="La Rochelle"
replace unifiedmeasure2=quantity*240 if quantity_unit_orthographic=="setiers" & natlocal=="La Rochelle"
*according to Savary: 1 tonneau==9 setiers de Paris of 240 livres, then 2160
replace unifiedmeasure2=quantity*2160 if quantity_unit_orthographic=="tonneaux" & natlocal=="La Rochelle"
*no clear info, retrive from price ratio
replace unifiedmeasure2=quantity*240 if quantity_unit_orthographic=="barriques" & natlocal=="La Rochelle"
*the flacon is probably a mistake for sac, then a value around 1/14 of a tonneau de la Rochelle
replace unifiedmeasure2=quantity*154 if quantity_unit_orthographic=="flacons" & natlocal=="La Rochelle"
replace unifiedmeasure2=quantity*150 if quantity_unit_orthographic=="poches" & natlocal=="La Rochelle"

***MARSEILLE
***convert measures without hypothesis

replace unifiedmeasure=quantity*240 if quantity_unit_orthographic=="charges" & natlocal=="Marseille"
replace unifiedmeasure=quantity*240 if quantity_unit_orthographic=="charge de 300 livres" & natlocal=="Marseille"
replace unifiedmeasure=quantity*100 if quantity_unit_orthographic=="quintal" & natlocal=="Marseille"
replace unifiedmeasure=quantity*90 if quantity_unit_orthographic=="setiers" & natlocal=="Marseille"
replace unifiedmeasure=quantity*60 if quantity_unit_orthographic=="mines" & natlocal=="Marseille"
keep if quantity_unit_orthographic=="charges" | quantity_unit_orthographic=="charge de 300 livres" | quantity_unit_orthographic=="livres"| quantity_unit_orthographic=="quintal" | quantity_unit_orthographic=="mines"| quantity_unit_orthographic=="setiers"

***NANTES
***convert measures
replace unifiedmeasure=quantity*2400 if quantity_unit_orthographic=="tonneaux" & natlocal=="Nantes"
replace unifiedmeasure=quantity*32.5 if quantity_unit_orthographic=="boisseau" & natlocal=="Nantes"
* The ratio tonneaux/sacs is not stable, but we can deduce from here that it is 117 livres (it does not fit well with our data, but the q is relatively small): https://www.persee.fr/doc/pharm_0035-2349_1972_num_60_212_7117
replace unifiedmeasure=quantity*117 if quantity_unit_orthographic=="sacs" & natlocal=="Nantes"
replace unifiedmeasure=quantity*240 if quantity_unit_orthographic=="setiers" & natlocal=="Nantes"
***ROUEN
**1muids=12 setiers=144 boisseux=24 mines, 1 setier==240livres
replace unifiedmeasure=quantity*20 if quantity_unit_orthographic=="boisseau" & natlocal=="Rouen"

replace unifiedmeasure=quantity*120 if quantity_unit_orthographic=="mines" & natlocal=="Rouen"

replace unifiedmeasure=quantity*240 if quantity_unit_orthographic=="setiers" & natlocal=="Rouen"

replace unifiedmeasure=quantity*2880 if quantity_unit_orthographic=="muids" & natlocal=="Rouen"

***collapse by year
collapse (sum) value unifiedmeasure unifiedmeasure2, by (year importexport)


*** tsset

reshape wide value unifiedmeasure unifiedmeasure2 , i(year) j(importexport)
tsset year
rename unifiedmeasure0 qimport
rename unifiedmeasure1 qexport
rename unifiedmeasure20 qimport_corrected
rename unifiedmeasure21 qexport_corrected
rename value0 vimport
rename value1 vexport
foreach x of varlist vimport qimport vexport qexport {
  label variable `x'
}
foreach x of varlist vimport qimport vexport qexport {
  replace `x' = 0 if(`x' == .)
}
tsfill
* graph for import

gen pimport=vimport/qexport
gen pexport=vexport/qexport
