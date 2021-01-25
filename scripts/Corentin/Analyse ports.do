***** PREPARATION NATIONAL *****
use "/Users/Corentin/Desktop/script/test.dta", clear

	keep if source_type == "Objet Général" | source_type == "Résumé"

	drop if source_type == "Résumé" & year == 1787 
	drop if source_type == "Résumé" & year == 1788
	drop if source_type == "Objet Général" & year > 1788
	drop if source_type == "Résumé" & year < 1787

	*keep if edentreaty_classification == "Vin de France" // A ajouter pour analyse vin
	*keep if edentreaty_classification == "Hardware" // A ajouter pour analyse Hardware
	*keep if edentreaty_classification == "Coton de toute espèce"
	*keep if export_import == "Exports"
	sort year export_import
	
	collapse (sum) value, by(year) 
	rename value totalN
	*keep if year == 1782 | year == 1789

save "/Users/Corentin/Desktop/script/test2.dta", replace

***** LOCAL

use "/Users/Corentin/Desktop/script/test.dta", clear


set more off
keep if source_type == "National par customs_region"  | source_type == "Local"

replace customs_region = "La_Rochelle" if customs_region == "La Rochelle"
replace customs_region = "Saint-Malo" if customs_region == "Saint Malo"
replace customs_region = "Saint_Malo" if customs_region == "Saint-Malo"
replace customs_region = "Passeport_du_roy" if customs_region == "Passeport du roy"
collapse (sum) value , by(year customs_region)


merge m:1 year using "/Users/Corentin/Desktop/script/test2.dta"
drop if _merge == 2
drop _merge

gen proportiondir = value / totalN * 100

keep if year == 1789

levelsof customs_region, local(levels)
	foreach l of local levels {
	gen `l' = .
	replace `l' = proportiondir if customs_region == "`l'"
    }

set obs 17
replace year = 1789 in 17
gen Autres = .	
egen temp = total(proportiondir)
replace Autres = (100 - temp) in 17
graph  bar Autres Amiens Bayonne Bordeaux Caen Charleville  Lille Lorient Marseille Montpellier Nantes Narbonne Passeport_du_roy Passeports  Rouen Saint_Malo Valenciennes 

*graph  bar Autres Bayonne Bordeaux La_Rochelle Rennes Nantes 

*/
*/
********* Evolution
/*
use "/Users/Corentin/Desktop/script/test.dta", clear


set more off
keep if source_type == "National par customs_region"  | source_type == "Local"

replace customs_region = "La_Rochelle" if customs_region == "La Rochelle"
replace customs_region = "Saint-Malo" if customs_region == "Saint Malo"
replace customs_region = "Saint_Malo" if customs_region == "Saint-Malo"
replace customs_region = "Passeport_du_roy" if customs_region == "Passeport du roy"
collapse (sum) value , by(year customs_region export_import)

by year customs_region export_import, sort: gen nvals = _n == 1 

by year customs_region : replace nvals = sum(nvals)
by year customs_region : replace nvals = nvals[_N]
drop if nvals == 1

collapse (sum) value , by(year customs_region)


merge m:1 year using "/Users/Corentin/Desktop/script/test2.dta"
drop if _merge == 2
drop _merge

gen Proportion = value / totalN * 100

levelsof customs_region, local(levels)
	foreach l of local levels {
	gen `l' = .
	replace `l' = Proportion if customs_region == "`l'"
    }
rename year Year
graph twoway (connected Proportion Year if customs_region == "Bordeaux"  ) (connected Proportion Year if customs_region == "Rouen"  ), legend(label(1 "Bordeaux") label(2 "Rouen"))
*/
*/
****************** EVOLUTION EXPORTS
/*
use "/Users/Corentin/Desktop/script/test.dta", clear


set more off
keep if source_type == "National par customs_region"  | source_type == "Local"

replace customs_region = "La_Rochelle" if customs_region == "La Rochelle"
replace customs_region = "Saint-Malo" if customs_region == "Saint Malo"
replace customs_region = "Saint_Malo" if customs_region == "Saint-Malo"
replace customs_region = "Passeport_du_roy" if customs_region == "Passeport du roy"
collapse (sum) value , by(year customs_region export_import)

keep if export_import == "Exports"

collapse (sum) value , by(year customs_region)


merge m:1 year using "/Users/Corentin/Desktop/script/test2.dta"
drop if _merge == 2
drop _merge

gen Proportion = value / totalN * 100

levelsof customs_region, local(levels)
	foreach l of local levels {
	gen `l' = .
	replace `l' = Proportion if customs_region == "`l'"
    }

rename year Year
graph twoway (connected Proportion Year if customs_region == "Caen"  )  (connected Proportion Year if customs_region == "Bordeaux"  ) (connected Proportion Year if customs_region == "Rouen"  ) (connected Proportion Year if customs_region == "Bayonne"  ) (connected Proportion Year if customs_region == "Nantes"  ), legend(label(1 "Caen") label(2 "Bordeaux") label(3 "Rouen") label(4 "Bayonne") label(5 "Nantes") )
*/
*/

****************** EVOLUTION IMPORTS
/*
use "/Users/Corentin/Desktop/script/test.dta", clear


set more off
keep if source_type == "National par customs_region"  | source_type == "Local"

replace customs_region = "La_Rochelle" if customs_region == "La Rochelle"
replace customs_region = "Saint-Malo" if customs_region == "Saint Malo"
replace customs_region = "Saint_Malo" if customs_region == "Saint-Malo"
replace customs_region = "Passeport_du_roy" if customs_region == "Passeport du roy"
collapse (sum) value , by(year customs_region export_import)

keep if export_import == "Imports"

collapse (sum) value , by(year customs_region)


merge m:1 year using "/Users/Corentin/Desktop/script/test2.dta"
drop if _merge == 2
drop _merge

gen Proportion = value / totalN * 100

levelsof customs_region, local(levels)
	foreach l of local levels {
	gen `l' = .
	replace `l' = Proportion if customs_region == "`l'"
    }

rename year Year
graph twoway (connected Proportion Year if customs_region == "Bordeaux"  ) (connected Proportion Year if customs_region == "Rouen"  ) , legend(label(1 "Bordeaux") label(2 "Rouen") )
*/
*/
********* Vin
/*
use "/Users/Corentin/Desktop/script/test.dta", clear
keep if edentreaty_classification == "Vin de France"


set more off
keep if source_type == "National par customs_region"  | source_type == "Local"

replace customs_region = "La_Rochelle" if customs_region == "La Rochelle"
replace customs_region = "Saint-Malo" if customs_region == "Saint Malo"
replace customs_region = "Saint_Malo" if customs_region == "Saint-Malo"
replace customs_region = "Passeport_du_roy" if customs_region == "Passeport du roy"
collapse (sum) value , by(year customs_region)


merge m:1 year using "/Users/Corentin/Desktop/script/test2.dta"
drop if _merge == 2
drop _merge

gen proportiondir = value / totalN * 100

keep if year == 1789

levelsof customs_region, local(levels)
	foreach l of local levels {
	gen `l' = .
	replace `l' = proportiondir if customs_region == "`l'"
    }

set obs 17
replace year = 1789 in 17
gen Autres = .	
egen temp = total(proportiondir)
replace Autres = (100 - temp) in 17
drop if Autres < 0
graph  pie Autres Amiens Bordeaux Caen Lille Lorient Marseille Passeport_du_roy Passeports  Rouen Saint_Malo , plabel(3 percent)
graph rename test, replace

use "/Users/Corentin/Desktop/script/test2.dta", clear
graph twoway (connected totalN year)
*/
*/
********* Hardware
/*
use "/Users/Corentin/Desktop/script/test.dta", clear
keep if edentreaty_classification == "Hardware"


set more off
keep if source_type == "National par customs_region"  | source_type == "Local"

replace customs_region = "La_Rochelle" if customs_region == "La Rochelle"
replace customs_region = "Saint-Malo" if customs_region == "Saint Malo"
replace customs_region = "Saint_Malo" if customs_region == "Saint-Malo"
replace customs_region = "Passeport_du_roy" if customs_region == "Passeport du roy"
collapse (sum) value , by(year customs_region)


merge m:1 year using "/Users/Corentin/Desktop/script/test2.dta"
drop if _merge == 2
drop _merge

gen proportiondir = value / totalN * 100

keep if year == 1789

levelsof customs_region, local(levels)
	foreach l of local levels {
	gen `l' = .
	replace `l' = proportiondir if customs_region == "`l'"
    }

set obs 17
replace year = 1789 in 17
gen Autres = .	
egen temp = total(proportiondir)
replace Autres = (100 - temp) in 17
drop if Autres < 0
graph  pie Autres Amiens Bordeaux Caen Lille Lorient Marseille Passeport_du_roy Passeports  Rouen Saint_Malo , plabel(5 percent)
graph rename test, replace

use "/Users/Corentin/Desktop/script/test2.dta", clear
graph twoway (connected totalN year)
*/
*/
********* Coton
/*
use "/Users/Corentin/Desktop/script/test.dta", clear
keep if edentreaty_classification == "Coton de toute espèce"


set more off
keep if source_type == "National par customs_region"  | source_type == "Local"

replace customs_region = "La_Rochelle" if customs_region == "La Rochelle"
replace customs_region = "Saint-Malo" if customs_region == "Saint Malo"
replace customs_region = "Saint_Malo" if customs_region == "Saint-Malo"
replace customs_region = "Passeport_du_roy" if customs_region == "Passeport du roy"
collapse (sum) value , by(year customs_region)


merge m:1 year using "/Users/Corentin/Desktop/script/test2.dta"
drop if _merge == 2
drop _merge

gen proportiondir = value / totalN * 100

keep if year == 1789

levelsof customs_region, local(levels)
	foreach l of local levels {
	gen `l' = .
	replace `l' = proportiondir if customs_region == "`l'"
    }

set obs 17
replace year = 1789 in 17
gen Autres = .	
egen temp = total(proportiondir)
replace Autres = (100 - temp) in 17
drop if Autres < 0
graph  pie Autres Amiens Bordeaux Caen Lille Lorient Marseille  Rouen Saint_Malo , plabel(5 percent)
graph rename test, replace

use "/Users/Corentin/Desktop/script/test2.dta", clear
graph twoway (connected totalN year)
*/

*/
********* Proportion classifications 
/*
use "/Users/Corentin/Desktop/script/test.dta", clear

	keep if source_type == "Objet Général" | source_type == "Résumé"

	drop if source_type == "Résumé" & year == 1787 
	drop if source_type == "Résumé" & year == 1788
	drop if source_type == "Objet Général" & year > 1788
	drop if source_type == "Résumé" & year < 1787

	sort year
	collapse (sum) value, by(year edentreaty_classification)
	replace edentreaty_classification = "Autres" if edentreaty_classification == ""
	
	merge m:1 year using "/Users/Corentin/Desktop/script/test2.dta"
	drop if _merge == 2
	drop _merge
	
	set more off
	replace edentreaty_classification = "Coton_detoute_espèce" if edentreaty_classification == "Coton de toute espèce"
	replace edentreaty_classification = "Eau_de_vie_de_France" if edentreaty_classification == "Eau de vie de France"
	replace edentreaty_classification = "Glaces_et_verrerie" if edentreaty_classification == "Glaces et Verrerie"
	replace edentreaty_classification = "Huile_olive_de_France" if edentreaty_classification == "Huile d'olive de France"
	replace edentreaty_classification = "Porcelaine" if edentreaty_classification == "Porcelaine, Fayance, Poterie"
	replace edentreaty_classification = "batistes_et_linons" if edentreaty_classification == "Toiles de batistes et linons"
	replace edentreaty_classification = "lin_et_de_chanvre" if edentreaty_classification == "Toiles de lin et de chanvre"
	replace edentreaty_classification = "Vin_de_France" if edentreaty_classification == "Vin de France"
	replace edentreaty_classification = "Vinaigre_de_France" if edentreaty_classification == "Vinaigre de France"


	gen proportiondir = value / totalN * 100

	levelsof edentreaty_classification, local(levels)
		foreach l of local levels {
		gen `l' = .
		replace `l' = proportiondir if edentreaty_classification == "`l'"
		}
	keep if year == 1778

	graph bar Autres Bière Gazes Hardware Lainage Modes Prohibé Sellerie Soie Vinaigre_de_France Vin_de_France lin_et_de_chanvre batistes_et_linons Porcelaine Huile_olive_de_France Glaces_et_verrerie Eau_de_vie_de_France Coton_detoute_espèce 
	*keep if year == 1782 | year == 1789
	*graph twoway (connected proportiondir year if edentreaty_classification == "Soie"  ) (connected proportiondir year if edentreaty_classification == "Sellerie"  ) (connected proportiondir year if edentreaty_classification == "Prohibé"  ) (connected proportiondir year if edentreaty_classification == "Modes"  ) (connected proportiondir year if edentreaty_classification == "Lainage"  ) (connected proportiondir year if edentreaty_classification == "Hardware"  ) (connected proportiondir year if edentreaty_classification == "Gazes"  ) (connected proportiondir year if edentreaty_classification == "Bière"  ) (connected proportiondir year if edentreaty_classification == "Autres"  ) (connected proportiondir year if edentreaty_classification == "Coton_detoute_espèce"  )  (connected proportiondir year if edentreaty_classification == "Eau_de_vie_de_France"  ) (connected proportiondir year if edentreaty_classification == "Glaces_et_verrerie"  ) (connected proportiondir year if edentreaty_classification == "Huile_olive_de_France"  ) (connected proportiondir year if edentreaty_classification == "Porcelaine"  ) (connected proportiondir year if edentreaty_classification == "batistes_et_linons"  ) (connected proportiondir year if edentreaty_classification == "lin_et_de_chanvre"  ) (connected proportiondir year if edentreaty_classification == "Vin_de_France"  ) (connected proportiondir year if edentreaty_classification == "Vinaigre_de_France"  ),/*
	**/legend(label(1 "Soie") label(2 "Sellerie") label(3 "Prohibé") label(4 "Modes") label(5 "Lainage") label(6 "Hardware") label(7 "Gazes") label(8 "Bière") label(9 "Autres") label(10 "Coton_detoute_espèce") label(11 "Eau_de_vie_de_France") label(12 "Glaces_et_verrerie") label(13 "Huile_olive_de_France") label(14 "Porcelaine") label(15 "batistes_et_linons") label(16 "lin_et_de_chanvre") label(17 "Vin_de_France") label(18 "Vinaigre_de_France"))
	*/
	
********* only local
/*
levelsof customs_region, local(levels)
	foreach l of local levels {
	gen `l' = .
	replace `l' = value if customs_region == "`l'"
    }
keep if year == 1789

	foreach var of varlist Amiens Bayonne Bordeaux Caen La_Rochelle Lille Lorient Marseille Montpellier Nantes Passeports Rouen Saint_Malo Valenciennes Passeport_du_roy {
	tab `var', gen(z`var')
	}

graph  pie Amiens Bayonne Bordeaux Caen Charleville La_Rochelle Lille Lorient Marseille Montpellier Nantes Narbonne Passeport_du_roy Passeports Rennes Rouen Saint_Malo Valenciennes, plabel(_all percent)




