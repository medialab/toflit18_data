* Est-ce que le traité permet de faire croitre des ports au niveau mondial (pas seulement le commerce anglais) ? (En pourcentage)

***** PREPARATION NATIONAL *****
use "/Users/Corentin/Desktop/script/Base_Eden_Mesure_Totale.dta", clear
keep marchandises pays_grouping direction eden_classification exportsimports marchandises_norm_ortho marchandises_simplification q_conv  quantit quantites_metric  quantitépourlesdroits quantity_unit quantity_unit_ajustees quantity_unit_orthographe sitc18_rev3 sourcepath sourcetype u_conv  unitépourlesdroits value year

	keep if sourcetype == "Objet Général" | sourcetype == "Résumé"

	drop if sourcetype == "Résumé" & year == 1787 
	drop if sourcetype == "Résumé" & year == 1788
	drop if sourcetype == "Objet Général" & year > 1788
	drop if sourcetype == "Résumé" & year < 1787
	
	keep if exportsimports == "Exports"
	
	sort year
	collapse (sum) value, by(year)
	rename value totalN
	*keep if year == 1782 | year == 1789

save "/Users/Corentin/Desktop/script/test2Totale.dta", replace

****** EVOLUTION 
use "/Users/Corentin/Desktop/script/Base_Eden_Mesure_Totale.dta", clear


set more off
keep if sourcetype == "National par direction"  | sourcetype == "Local"

replace direction = "La_Rochelle" if direction == "La Rochelle"
replace direction = "Saint-Malo" if direction == "Saint Malo"
replace direction = "Saint_Malo" if direction == "Saint-Malo"
replace direction = "Passeport_du_roy" if direction == "Passeport du roy"
replace direction = "Saint_Quentin" if direction == "Saint Quentin"
replace direction = "Saint_Quentin" if direction == "Saint-Quentin"

*********** TOTALE
/*
collapse (sum) value , by(year direction exportsimports)

by year direction exportsimports, sort: gen nvals = _n == 1 

by year direction : replace nvals = sum(nvals)
by year direction : replace nvals = nvals[_N]
drop if nvals == 1

collapse (sum) value , by(year direction)


merge m:1 year using "/Users/Corentin/Desktop/script/test2Totale.dta"
drop if _merge == 2
drop _merge

gen proportiondir = value / totalN * 100

keep if year == 1789

levelsof direction, local(levels)
	foreach l of local levels {
	gen `l' = .
	replace `l' = proportiondir if direction == "`l'"
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
collapse (sum) value , by(year direction exportsimports)
keep if exportsimports == "Exports"
collapse (sum) value , by(year direction)


merge m:1 year using "/Users/Corentin/Desktop/script/test2Totale.dta"
drop if _merge == 2
drop _merge

gen proportiondir = value / totalN * 100

keep if year == 1778

levelsof direction, local(levels)
	foreach l of local levels {
	gen `l' = .
	replace `l' = proportiondir if direction == "`l'"
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
collapse (sum) value , by(year direction exportsimports)
keep if exportsimports == "Imports"
collapse (sum) value , by(year direction)


merge m:1 year using "/Users/Corentin/Desktop/script/test2Totale.dta"
drop if _merge == 2
drop _merge

gen proportiondir = value / totalN * 100

keep if year == 1778

levelsof direction, local(levels)
	foreach l of local levels {
	gen `l' = .
	replace `l' = proportiondir if direction == "`l'"
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
