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
replace value=prix_unitaire*quantity if value==. & prix_unitaire!=.
drop if value==.
drop if value==0
*/



***garder quand on a le commerce national complet ou les flux locaux complets
****Je garde 1789 (pour du local) car il ne manque que le commerce avec les Indes.
keep if best_guess_national_prodxpart==1 | best_guess_department_prodxpart==1 | (year==1789 & source_type=="National toutes directions partenaires manquants")
drop if tax_department =="Colonies Françaises de l'Amérique"




*create national and local
gen natlocal=tax_department

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
*create geography

encode natlocal, generate(geography) label(natlocal)

drop if year==.
drop if geography==.
drop if geography!=14
drop geography


***only wheat
keep if grains_num==2
***convert measures 

gen unifiedmeasure=quantity 
*** it's unclear why, but Savary is certainly wrong when he claims 32boisseaux de Rochelle=19setiers de Paris. It seems instead that 36 boisseaux=1 tonneau=9 setier de paris
replace unifiedmeasure=quantity*71 if quantity_unit_orthographic=="boisseau"
replace unifiedmeasure=quantity*100 if quantity_unit_orthographic=="quintaux"
***based on Le négoce d'Amsterdam ou Traité de sa banque, de ses changes, des Compagnies ...by Jacques Le Moine de l'Espine
* sacs are1/36th of a last d'Amsterdam, we deduce therefore that 1 setiers=1,9 sacs and therefore 150 livres pdm
replace unifiedmeasure=quantity*150 if quantity_unit_orthographic=="sacs"
*** theoretically a sack from England should be equal to 4 bushels (James Sheppard, the British corn merchant's and farmer's manual), that is 259 livres de pdm, but this does not make any sense for us. 
*Or to 3 bushels (boisseau?)
replace unifiedmeasure=quantity*250 if quantity_unit_orthographic=="sacs" & partner_orthographic=="Angleterre"
***let's assume it works easily
replace unifiedmeasure=quantity*480 if quantity_unit_orthographic=="cartier du pied de 480 livres"
*** retrive it from the price ratio with tonneaux
replace unifiedmeasure=quantity*60 if quantity_unit_orthographic=="barils" & year==1752
replace unifiedmeasure=quantity*192 if quantity_unit_orthographic=="barils" & year==1739

**despite the similarity with the measure "quarter", it seems that quartier is similar to quartier mesure de blaye and therefore 1,25 boisseaux
replace unifiedmeasure=quantity*152 if quantity_unit_orthographic=="quartiers"
replace unifiedmeasure=quantity*240 if quantity_unit_orthographic=="setiers"
*according to Savary: 1 tonneau==19 boisseaux, that is between 2160 livres and 2560. prices seem to justify the higher estimate at least for the later period
replace unifiedmeasure=quantity*2560 if quantity_unit_orthographic=="tonneaux"
*no clear info, retrive from price ratio
replace unifiedmeasure=quantity*285 if quantity_unit_orthographic=="barriques"
*the flacon is probably a mistake for sac, then a value around 1/14 of a tonneau de la Rochelle
replace unifiedmeasure=quantity*182 if quantity_unit_orthographic=="flacons"
replace unifiedmeasure=quantity*150 if quantity_unit_orthographic=="poches"

***LOWER LIMIT convert measures without hypothesis that boisseaux==120 livres, which is very low.
gen unifiedmeasure2=quantity
*** it's unclear why, but Savary is certainly wrong when he claims 32boisseaux de Rochelle=19setiers de Paris. It seems instead that 36 boisseaux=1 tonneau=9 setier de paris
replace unifiedmeasure2=quantity*60 if quantity_unit_orthographic=="boisseau"

* Leopold claims 1 last=38 boisseaux de bordeaux
replace unifiedmeasure2=quantity*38*120 if quantity_unit_orthographic=="last"
***let's assume it works easily
replace unifiedmeasure=quantity*480 if quantity_unit_orthographic=="cartier du pied de 480 livres"
*** retrive it from the price ratio with tonneaux
replace unifiedmeasure2=quantity*50 if quantity_unit_orthographic=="barils" & year==1752
replace unifiedmeasure2=quantity*162 if quantity_unit_orthographic=="barils" & year==1739
replace unifiedmeasure2=quantity*100 if quantity_unit_orthographic=="quintaux"
***based on Le négoce d'Amsterdam ou Traité de sa banque, de ses changes, des Compagnies ...by Jacques Le Moine de l'Espine
* sacs are1/36th of a last d'Amsterdam, we deduce therefore that 1 setiers=1,9 sacs and therefore, if 1:setier=240 livres pdm, 126 livres ==1 sacs
replace unifiedmeasure2=quantity*126 if quantity_unit_orthographic=="sacs" 
*** theoretically a sack from England should be equal to 4 bushels (James Sheppard, the British corn merchant's and farmer's manual), that is 259 livres de pdm, but this does not make any sense for us.
replace unifiedmeasure2=quantity*250 if quantity_unit_orthographic=="sacs" & partner_orthographic=="Angleterre"
***let's assume it works easily
replace unifiedmeasure2=quantity*480 if quantity_unit_orthographic=="cartier du pied de 480 livres"
**despite the similarity with the measure "quarter", it seems that quartier is similar to quartier mesure de blaye and therefore 1,25 boisseaux
replace unifiedmeasure2=quantity*152 if quantity_unit_orthographic=="quartiers"
replace unifiedmeasure2=quantity*240 if quantity_unit_orthographic=="setiers"
*according to Savary: 1 tonneau==9 setiers de Paris of 240 livres, then 2160
replace unifiedmeasure2=quantity*2160 if quantity_unit_orthographic=="tonneaux"
*no clear info, retrive from price ratio
replace unifiedmeasure2=quantity*240 if quantity_unit_orthographic=="barriques"
*the flacon is probably a mistake for sac, then a value around 1/14 of a tonneau de la Rochelle
replace unifiedmeasure2=quantity*154 if quantity_unit_orthographic=="flacons"
replace unifiedmeasure2=quantity*150 if quantity_unit_orthographic=="poches"

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
