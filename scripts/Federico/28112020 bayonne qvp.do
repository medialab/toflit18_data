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
*create geography

encode natlocal, generate(geography) label(natlocal)

drop if year==.
drop if geography==.
drop if geography!=3
drop geography


***only wheat
keep if grains_num==2
***convert measures
gen unifiedmeasure=quantity 
*a conque is steadily equal to 2 mesures
replace unifiedmeasure=quantity*120 if quantity_unit_orthographic=="mesures"
* The ratio or prices conque/livres is not stable, it obscillates around 70:1, but Savary claims there are 60 livres in a conques de Bayonne
replace unifiedmeasure=quantity*60 if quantity_unit_orthographic=="conques"
replace unifiedmeasure=quantity*100 if quantity_unit_orthographic=="quintaux"

***convert measures without hypothesis
gen unifiedmeasure2=quantity
replace unifiedmeasure2=quantity*140 if quantity_unit_orthographic=="mesures"
* The ratio or prices conque/livres is not stable, it obscillates around 70:1, but Savary claims there are 60 livres in a conques de Bayonne
replace unifiedmeasure2=quantity*70 if quantity_unit_orthographic=="conques"
replace unifiedmeasure2=quantity*100 if quantity_unit_orthographic=="quintaux"

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
