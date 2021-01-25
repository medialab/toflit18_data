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

encode natlocal, generate(geography) label(natlocal)

drop if year==.
drop if geography==.
drop if geography!=21
drop geography




***only wheat
keep if grains_num==2
***convert measures
gen unifiedmeasure=quantity
replace unifiedmeasure=quantity*2400 if quantity_unit_orthographic=="tonneaux" 
replace unifiedmeasure=quantity*32.5 if quantity_unit_orthographic=="boisseau"
* The ratio tonneaux/sacs is not stable, but we can deduce from here that it is 117 livres (it does not fit well with our data, but the q is relatively small): https://www.persee.fr/doc/pharm_0035-2349_1972_num_60_212_7117
replace unifiedmeasure=quantity*117 if quantity_unit_orthographic=="sacs"
replace unifiedmeasure=quantity*240 if quantity_unit_orthographic=="setiers"




***collapse by year
collapse (sum) value unifiedmeasure, by (year importexport)




*** tsset


reshape wide value unifiedmeasure , i(year) j(importexport)
tsset year
rename value0 vimport
rename value1 vexport
rename unifiedmeasure0 qimport
rename unifiedmeasure1 qexport
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
