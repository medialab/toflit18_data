* Est-ce que le traité permet de faire croitre des ports au niveau mondial (pas seulement le commerce anglais) ? (En pourcentage)

***** PREPARATION NATIONAL *****
use "/Users/Corentin/Desktop/script/Base_Eden_Mesure_Totale.dta", clear
keep product grouping_classification customs_region edentreaty_classification export_import orthographic_normalization_classification simplification_classification q_conv  quantity quantites_metric  quantitépourlesdroits quantity_unit quantity_unit_ajustees quantity_unit_orthographe sitc_classification filepath source_type u_conv  unitépourlesdroits value year

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
keep if source_type == "National par customs_region"  | source_type == "Local"

replace customs_region = "La_Rochelle" if customs_region == "La Rochelle"
replace customs_region = "Saint-Malo" if customs_region == "Saint Malo"
replace customs_region = "Saint_Malo" if customs_region == "Saint-Malo"
replace customs_region = "Passeport_du_roy" if customs_region == "Passeport du roy"
replace customs_region = "Saint_Quentin" if customs_region == "Saint Quentin"
replace customs_region = "Saint_Quentin" if customs_region == "Saint-Quentin"

*********** TOTALE
/*
collapse (sum) value , by(year customs_region export_import)

by year customs_region export_import, sort: gen nvals = _n == 1 

by year customs_region : replace nvals = sum(nvals)
by year customs_region : replace nvals = nvals[_N]
drop if nvals == 1

collapse (sum) value , by(year customs_region)


merge m:1 year using "/Users/Corentin/Desktop/script/test2Totale.dta"
drop if _merge == 2
drop _merge

gen proportiondir = value / totalN * 100

keep if year == 1789

levelsof customs_region, local(levels)
	foreach l of local levels {
	gen `l' = .
	replace `l' = proportiondir if customs_region == "`l'"
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
collapse (sum) value , by(year customs_region export_import)
keep if export_import == "Exports"
collapse (sum) value , by(year customs_region)


merge m:1 year using "/Users/Corentin/Desktop/script/test2Totale.dta"
drop if _merge == 2
drop _merge

gen proportiondir = value / totalN * 100

keep if year == 1778

levelsof customs_region, local(levels)
	foreach l of local levels {
	gen `l' = .
	replace `l' = proportiondir if customs_region == "`l'"
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
collapse (sum) value , by(year customs_region export_import)
keep if export_import == "Imports"
collapse (sum) value , by(year customs_region)


merge m:1 year using "/Users/Corentin/Desktop/script/test2Totale.dta"
drop if _merge == 2
drop _merge

gen proportiondir = value / totalN * 100

keep if year == 1778

levelsof customs_region, local(levels)
	foreach l of local levels {
	gen `l' = .
	replace `l' = proportiondir if customs_region == "`l'"
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
