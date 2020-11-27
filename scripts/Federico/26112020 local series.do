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

*** count number of parners for each year, direction across all categories

egen n_partners=nvals(partner_simplification), by(year natlocal importexport)


***drop national
drop if natlocal=="National"
***total trade of grains for each locality, 

bys year natlocal importexport  : egen total_value = sum(value)
bys year natlocal importexport grains_num  : egen total_value_category = sum(value)

***collapse over all grain types
collapse(sum) value quantity, by(year natlocal importexport grains_num total_value n_partners quantity_unit_orthographic value_per_unit total_value_category)

***graph of different value categories local

***collapse to have total_value_category as target variable
collapse(mean) total_value_category, by(year natlocal importexport grains_num total_value n_partners)
reshape wide n_partners total_value_category total_value, i(grains_num year natlocal) j(importexport)
reshape wide n_partners0 total_value0 total_value_category0 n_partners1 total_value1 total_value_category1, i(year natlocal) j(grains_num)
*partners
unab xvars: n_partners01 n_partners02  n_partners03  n_partners04  n_partners05
local xarg : subinstr local xvars " " ",", all
generate import_partners = max(`xarg')

unab xvars: n_partners11 n_partners12  n_partners13  n_partners14  n_partners15
local xarg : subinstr local xvars " " ",", all
generate export_partners = max(`xarg')
drop n_partners01 n_partners11 n_partners02 n_partners12 n_partners03 n_partners13 n_partners04 n_partners14 n_partners05 n_partners15

**total value per year and location
unab xvars: total_value01 total_value02 total_value03 total_value04 total_value05 
local xarg : subinstr local xvars " " ",", all
generate imports = max(`xarg')

unab xvars: total_value11 total_value12 total_value13 total_value14 total_value15
local xarg : subinstr local xvars " " ",", all
generate exports = max(`xarg')
drop total_value01 total_value11 total_value02 total_value12 total_value03 total_value13 total_value04 total_value14 total_value05 total_value15

***categories
rename total_value_category01 import_other_cereals
rename total_value_category11 export_other_cereals
rename total_value_category02 import_wheat
rename total_value_category12 export_wheat
rename total_value_category03 import_flower
rename total_value_category13 export_flower
rename total_value_category04 import_lesser_grains
rename total_value_category14 export_lesser_grains
rename total_value_category05 import_substitutes
rename total_value_category15 export_substitutes

foreach x of varlist import_partners imports import_other_cereals export_partners exports export_other_cereals import_wheat export_wheat import_flower export_flower import_lesser_grains export_lesser_grains import_substitutes export_substitutes {
  label variable `x'
}
*create panel
keep if natlocal=="Bayonne" | natlocal=="Bordeaux" | natlocal=="La Rochelle" | natlocal=="Marseille" | natlocal=="Nantes" | natlocal=="Rennes" | natlocal=="Rouen"

replace year=1806 if year==1805.75
encode natlocal, generate(locality) label(natlocal) 
xtset locality year
foreach x of varlist import_partners imports import_other_cereals export_partners exports export_other_cereals import_wheat export_wheat import_flower export_flower import_lesser_grains export_lesser_grains import_substitutes export_substitutes {
  replace `x' = 0 if(`x' == .)
}
tsfill
*netexport
gen nxports=exports-imports
gen nxport_other_cereals=export_other_cereals-import_other_cereals
gen nxport_wheat= export_wheat-import_wheat  
gen nxport_flower=export_flower-import_flower 
gen nxport_lesser_grains= export_lesser_grains-import_lesser_grains  
gen nxport_substitutes=export_substitutes-import_substitutes



*graphs nxport 
sparkline  nxport_flower nxports  export_partners import_partners  year if natlocal=="Bayonne", yline(0) yline(0) yline(0) yline(0) cmissing(no) ytitle("livres tournois") xlabel(#15,grid)  xmtick(##15) ylabel(#5,grid)  ymtick(##5)


Click image for larger version Name: friedrich.png Views: 1 Size: 12.1 KB ID: 1329368
twoway (tsline nxport_flower nxports if natlocal=="Bayonne", cmissing(no) yaxis(1) ytitle("livre tournois") xlabel(#15,grid)  xmtick(##15))  (scatter export_partners import_partners year if natlocal=="Bayonne", yaxis(2)) 
graph export "C:\Users\federico.donofrio\Dropbox\Papier Grains\112020bayonne_nxports.png", replace

twoway (tsline nxport_flower nxports if natlocal=="Bordeaux", cmissing(no) yaxis(1) ytitle("livres tournois") xlabel(#15,grid)  xmtick(##15))  (scatter export_partners import_partners year if natlocal=="Bordeaux", yaxis(2)) 
graph export "C:\Users\federico.donofrio\Dropbox\Papier Grains\112020bordeaux_nxports.png", replace

twoway (tsline nxport_flower nxports if natlocal=="La Rochelle", cmissing(no) yaxis(1) ytitle("livres tournois") xlabel(#15,grid)  xmtick(##15))  (scatter export_partners import_partners year if natlocal=="La Rochelle", yaxis(2)) 
graph export "C:\Users\federico.donofrio\Dropbox\Papier Grains\112020larochelle_nxports.png", replace

twoway (tsline nxport_flower nxports if natlocal=="Marseille", cmissing(no) yaxis(1) ytitle("livres tournois") xlabel(#15,grid)  xmtick(##15))  (scatter export_partners import_partners year if natlocal=="Marseille", yaxis(2)) 
graph export "C:\Users\federico.donofrio\Dropbox\Papier Grains\112020marseille_nxports.png", replace

twoway (tsline nxport_flower nxports if natlocal=="Nantes", cmissing(no) yaxis(1) ytitle("livres tournois") xlabel(#15,grid)  xmtick(##15))  (scatter export_partners import_partners year if natlocal=="Nantes", yaxis(2)) 
graph export "C:\Users\federico.donofrio\Dropbox\Papier Grains\112020nantes_nxports.png", replace

twoway (tsline nxport_flower nxports if natlocal=="Rennes", cmissing(no) yaxis(1) ytitle("livres tournois") xlabel(#15,grid)  xmtick(##15))  (scatter export_partners import_partners year if natlocal=="Rennes", yaxis(2)) 
graph export "C:\Users\federico.donofrio\Dropbox\Papier Grains\112020rennes_nxports.png", replace

twoway (tsline nxport_flower nxports if natlocal=="Rouen", cmissing(no) yaxis(1) ytitle("livres tournois") xlabel(#15,grid)  xmtick(##15))  (scatter export_partners import_partners year if natlocal=="Rouen", yaxis(2)) 
graph export "C:\Users\federico.donofrio\Dropbox\Papier Grains\112020rouen_nxports.png", replace

*graphs export 
twoway (tsline export_flower exports if natlocal=="Bayonne", cmissing(no) yaxis(1) ytitle("livres tournois") xlabel(#15,grid)  xmtick(##15))  (scatter export_partners year if natlocal=="Bayonne", yaxis(2)) 
graph export "C:\Users\federico.donofrio\Dropbox\Papier Grains\112020bayonne_exports.png", replace

twoway (tsline export_flower exports if natlocal=="Bordeaux", cmissing(no) yaxis(1) ytitle("livres tournois") xlabel(#15,grid)  xmtick(##15))  (scatter export_partners year if natlocal=="Bordeaux", yaxis(2)) 
graph export "C:\Users\federico.donofrio\Dropbox\Papier Grains\112020bordeaux_exports.png", replace

twoway (tsline export_flower exports if natlocal=="La Rochelle", cmissing(no) yaxis(1) ytitle("livres tournois") xlabel(#15,grid)  xmtick(##15))  (scatter export_partners year if natlocal=="La Rochelle", yaxis(2)) 
graph export "C:\Users\federico.donofrio\Dropbox\Papier Grains\112020larochelle_exports.png", replace

twoway (tsline export_flower exports if natlocal=="Marseille", cmissing(no) yaxis(1) ytitle("livres tournois") xlabel(#15,grid)  xmtick(##15))  (scatter export_partners year if natlocal=="Marseille", yaxis(2)) 
graph export "C:\Users\federico.donofrio\Dropbox\Papier Grains\112020marseille_exports.png", replace

twoway (tsline export_flower exports if natlocal=="Nantes", cmissing(no) yaxis(1) ytitle("livres tournois") xlabel(#15,grid)  xmtick(##15))  (scatter export_partners year if natlocal=="Nantes", yaxis(2)) 
graph export "C:\Users\federico.donofrio\Dropbox\Papier Grains\112020nantes_exports.png", replace

twoway (tsline export_flower exports if natlocal=="Rennes", cmissing(no) yaxis(1) ytitle("livres tournois") xlabel(#15,grid)  xmtick(##15))  (scatter export_partners year if natlocal=="Rennes", yaxis(2)) 
graph export "C:\Users\federico.donofrio\Dropbox\Papier Grains\112020rennes_exports.png", replace

twoway (tsline export_flower exports if natlocal=="Rouen", cmissing(no) yaxis(1) ytitle("livres tournois") xlabel(#15,grid)  xmtick(##15))  (scatter export_partners year if natlocal=="Rouen", yaxis(2)) 
graph export "C:\Users\federico.donofrio\Dropbox\Papier Grains\112020rouen_exports.png", replace
