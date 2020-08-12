* Est-ce que le traité permet de faire croitre des ports au niveau mondial (pas seulement le commerce anglais) ? (En pourcentage)

***** PREPARATION NATIONAL *****
use "/Users/Corentin/Desktop/script/Base_Eden_Mesure_Totale.dta", clear
keep product grouping_classification tax_department edentreaty_classification export_import orthographic_normalization_classification simplification_classification q_conv  quantity quantites_metric  quantitépourlesdroits quantity_unit quantity_unit_ajustees quantity_unit_orthographe sitc_classification filepath source_type u_conv  unitépourlesdroits value year

	keep if source_type == "Objet Général" | source_type == "Résumé"

	drop if source_type == "Résumé" & year == 1787 
	drop if source_type == "Résumé" & year == 1788
	drop if source_type == "Objet Général" & year > 1788
	drop if source_type == "Résumé" & year < 1787
	
	keep if export_import == "Exports"
	
	sort year
	collapse (sum) value, by(year)
	rename value totalN
	*keep if year == 1782 | year == 1789

save "/Users/Corentin/Desktop/script/test2Totale.dta", replace

****** EVOLUTION 
use "/Users/Corentin/Desktop/script/Base_Eden_Mesure_Totale.dta", clear


set more off
keep if source_type == "National par tax_department"  | source_type == "Local"

replace tax_department = "La_Rochelle" if tax_department == "La Rochelle"
replace tax_department = "Saint-Malo" if tax_department == "Saint Malo"
replace tax_department = "Saint_Malo" if tax_department == "Saint-Malo"
replace tax_department = "Passeport_du_roy" if tax_department == "Passeport du roy"
replace tax_department = "Saint_Quentin" if tax_department == "Saint Quentin"
replace tax_department = "Saint_Quentin" if tax_department == "Saint-Quentin"

*********** TOTALE
/*
collapse (sum) value , by(year tax_department export_import)

by year tax_department export_import, sort: gen nvals = _n == 1 

by year tax_department : replace nvals = sum(nvals)
by year tax_department : replace nvals = nvals[_N]
drop if nvals == 1

collapse (sum) value , by(year tax_department)


merge m:1 year using "/Users/Corentin/Desktop/script/test2Totale.dta"
drop if _merge == 2
drop _merge

gen proportiondir = value / totalN * 100

keep if year == 1789

levelsof tax_department, local(levels)
	foreach l of local levels {
	gen `l' = .
	replace `l' = proportiondir if tax_department == "`l'"
    }

set obs 25
replace year = 1789 in 25
gen Autres = .	
egen temp = total(proportiondir)
replace Autres = (100 - temp) in 25

* POUR 1778
*graph  pie Autres   Bayonne  Bordeaux La_Rochelle    , plabel(3 percent)
*graph  pie Autres   Bayonne  Bordeaux La_Rochelle  Rennes , plabel(3 percent)

* POUR 1789
graph  pie Autres  Auch Bordeaux Grenoble Lille Lorient Marseille Nantes Narbonne Rouen Saint_Malo Saint_Quentin  Soissons Valenciennes, plabel(3 percent)
*/


********** EXPORTS
/*
collapse (sum) value , by(year tax_department export_import)
keep if export_import == "Exports"
collapse (sum) value , by(year tax_department)


merge m:1 year using "/Users/Corentin/Desktop/script/test2Totale.dta"
drop if _merge == 2
drop _merge

gen proportiondir = value / totalN * 100

keep if year == 1778

levelsof tax_department, local(levels)
	foreach l of local levels {
	gen `l' = .
	replace `l' = proportiondir if tax_department == "`l'"
    }

set obs 25
replace year = 1789 in 25
gen Autres = .	
egen temp = total(proportiondir)
replace Autres = (100 - temp) in 25

* POUR 1778
graph  pie Autres   Bayonne  Bordeaux La_Rochelle    , plabel(3 percent)
*graph  pie Autres   Bayonne  Bordeaux La_Rochelle  Rennes , plabel(3 percent)

* POUR 1789
*graph  pie Autres  Auch Bordeaux Grenoble Lille Lorient Marseille Nantes Narbonne Rouen Saint_Malo Saint_Quentin  Soissons Valenciennes, plabel(3 percent)
*/
********** IMPORTS
/*
collapse (sum) value , by(year tax_department export_import)
keep if export_import == "Imports"
collapse (sum) value , by(year tax_department)


merge m:1 year using "/Users/Corentin/Desktop/script/test2Totale.dta"
drop if _merge == 2
drop _merge

gen proportiondir = value / totalN * 100

keep if year == 1778

levelsof tax_department, local(levels)
	foreach l of local levels {
	gen `l' = .
	replace `l' = proportiondir if tax_department == "`l'"
    }

set obs 25
replace year = 1789 in 25
gen Autres = .	
egen temp = total(proportiondir)
replace Autres = (100 - temp) in 25

* POUR 1778
graph  pie Autres   Bayonne  Bordeaux La_Rochelle    , plabel(3 percent)
*graph  pie Autres   Bayonne  Bordeaux La_Rochelle  Rennes , plabel(3 percent)

* POUR 1789
*graph  pie Autres  Auch Bordeaux Grenoble Lille Lorient Marseille Nantes Narbonne Rouen Saint_Malo Saint_Quentin  Soissons Valenciennes, plabel(3 percent)
*/
*******
