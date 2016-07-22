***** PREPARATION NATIONAL *****
use "/Users/Corentin/Desktop/script/test.dta", clear

	keep if sourcetype == "Objet Général" | sourcetype == "Résumé"

	drop if sourcetype == "Résumé" & year == 1787 
	drop if sourcetype == "Résumé" & year == 1788
	drop if sourcetype == "Objet Général" & year > 1788
	drop if sourcetype == "Résumé" & year < 1787

	*keep if eden_classification == "Vin de France" // A ajouter pour analyse vin
	*keep if eden_classification == "Hardware" // A ajouter pour analyse Hardware
	*keep if eden_classification == "Coton de toute espèce"
	*keep if exportsimports == "Exports"
	sort year exportsimports
	
	collapse (sum) value, by(year) 
	rename value totalN
	*keep if year == 1782 | year == 1789

save "/Users/Corentin/Desktop/script/test2.dta", replace
/*
***** LOCAL

use "/Users/Corentin/Desktop/script/test.dta", clear


set more off
keep if sourcetype == "National par direction"  | sourcetype == "Local"

replace direction = "La_Rochelle" if direction == "La Rochelle"
replace direction = "Saint-Malo" if direction == "Saint Malo"
replace direction = "Saint_Malo" if direction == "Saint-Malo"
replace direction = "Passeport_du_roy" if direction == "Passeport du roy"
collapse (sum) value , by(year direction)


merge m:1 year using "/Users/Corentin/Desktop/script/test2.dta"
drop if _merge == 2
drop _merge

gen proportiondir = value / totalN * 100

keep if year == 1789

levelsof direction, local(levels)
	foreach l of local levels {
	gen `l' = .
	replace `l' = proportiondir if direction == "`l'"
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

use "/Users/Corentin/Desktop/script/test.dta", clear


set more off
keep if sourcetype == "National par direction"  | sourcetype == "Local"

replace direction = "La_Rochelle" if direction == "La Rochelle"
replace direction = "Saint-Malo" if direction == "Saint Malo"
replace direction = "Saint_Malo" if direction == "Saint-Malo"
replace direction = "Passeport_du_roy" if direction == "Passeport du roy"
collapse (sum) value , by(year direction exportsimports)

by year direction exportsimports, sort: gen nvals = _n == 1 

by year direction : replace nvals = sum(nvals)
by year direction : replace nvals = nvals[_N]
drop if nvals == 1

collapse (sum) value , by(year direction)


merge m:1 year using "/Users/Corentin/Desktop/script/test2.dta"
drop if _merge == 2
drop _merge

gen Proportion = value / totalN * 100

levelsof direction, local(levels)
	foreach l of local levels {
	gen `l' = .
	replace `l' = Proportion if direction == "`l'"
    }
rename year Year
graph twoway (connected Proportion Year if direction == "Bordeaux"  ) (connected Proportion Year if direction == "Rouen"  ), legend(label(1 "Bordeaux") label(2 "Rouen"))
*/
*/
****************** EVOLUTION EXPORTS
/*
use "/Users/Corentin/Desktop/script/test.dta", clear


set more off
keep if sourcetype == "National par direction"  | sourcetype == "Local"

replace direction = "La_Rochelle" if direction == "La Rochelle"
replace direction = "Saint-Malo" if direction == "Saint Malo"
replace direction = "Saint_Malo" if direction == "Saint-Malo"
replace direction = "Passeport_du_roy" if direction == "Passeport du roy"
collapse (sum) value , by(year direction exportsimports)

keep if exportsimports == "Exports"

collapse (sum) value , by(year direction)


merge m:1 year using "/Users/Corentin/Desktop/script/test2.dta"
drop if _merge == 2
drop _merge

gen Proportion = value / totalN * 100

levelsof direction, local(levels)
	foreach l of local levels {
	gen `l' = .
	replace `l' = Proportion if direction == "`l'"
    }

rename year Year
graph twoway (connected Proportion Year if direction == "Caen"  )  (connected Proportion Year if direction == "Bordeaux"  ) (connected Proportion Year if direction == "Rouen"  ) (connected Proportion Year if direction == "Bayonne"  ) (connected Proportion Year if direction == "Nantes"  ), legend(label(1 "Caen") label(2 "Bordeaux") label(3 "Rouen") label(4 "Bayonne") label(5 "Nantes") )
*/
*/

****************** EVOLUTION IMPORTS
/*
use "/Users/Corentin/Desktop/script/test.dta", clear


set more off
keep if sourcetype == "National par direction"  | sourcetype == "Local"

replace direction = "La_Rochelle" if direction == "La Rochelle"
replace direction = "Saint-Malo" if direction == "Saint Malo"
replace direction = "Saint_Malo" if direction == "Saint-Malo"
replace direction = "Passeport_du_roy" if direction == "Passeport du roy"
collapse (sum) value , by(year direction exportsimports)

keep if exportsimports == "Imports"

collapse (sum) value , by(year direction)


merge m:1 year using "/Users/Corentin/Desktop/script/test2.dta"
drop if _merge == 2
drop _merge

gen Proportion = value / totalN * 100

levelsof direction, local(levels)
	foreach l of local levels {
	gen `l' = .
	replace `l' = Proportion if direction == "`l'"
    }

rename year Year
graph twoway (connected Proportion Year if direction == "Bordeaux"  ) (connected Proportion Year if direction == "Rouen"  ) , legend(label(1 "Bordeaux") label(2 "Rouen") )
*/
*/
********* Vin
/*
use "/Users/Corentin/Desktop/script/test.dta", clear
keep if eden_classification == "Vin de France"


set more off
keep if sourcetype == "National par direction"  | sourcetype == "Local"

replace direction = "La_Rochelle" if direction == "La Rochelle"
replace direction = "Saint-Malo" if direction == "Saint Malo"
replace direction = "Saint_Malo" if direction == "Saint-Malo"
replace direction = "Passeport_du_roy" if direction == "Passeport du roy"
collapse (sum) value , by(year direction)


merge m:1 year using "/Users/Corentin/Desktop/script/test2.dta"
drop if _merge == 2
drop _merge

gen proportiondir = value / totalN * 100

keep if year == 1789

levelsof direction, local(levels)
	foreach l of local levels {
	gen `l' = .
	replace `l' = proportiondir if direction == "`l'"
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
keep if eden_classification == "Hardware"


set more off
keep if sourcetype == "National par direction"  | sourcetype == "Local"

replace direction = "La_Rochelle" if direction == "La Rochelle"
replace direction = "Saint-Malo" if direction == "Saint Malo"
replace direction = "Saint_Malo" if direction == "Saint-Malo"
replace direction = "Passeport_du_roy" if direction == "Passeport du roy"
collapse (sum) value , by(year direction)


merge m:1 year using "/Users/Corentin/Desktop/script/test2.dta"
drop if _merge == 2
drop _merge

gen proportiondir = value / totalN * 100

keep if year == 1789

levelsof direction, local(levels)
	foreach l of local levels {
	gen `l' = .
	replace `l' = proportiondir if direction == "`l'"
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
keep if eden_classification == "Coton de toute espèce"


set more off
keep if sourcetype == "National par direction"  | sourcetype == "Local"

replace direction = "La_Rochelle" if direction == "La Rochelle"
replace direction = "Saint-Malo" if direction == "Saint Malo"
replace direction = "Saint_Malo" if direction == "Saint-Malo"
replace direction = "Passeport_du_roy" if direction == "Passeport du roy"
collapse (sum) value , by(year direction)


merge m:1 year using "/Users/Corentin/Desktop/script/test2.dta"
drop if _merge == 2
drop _merge

gen proportiondir = value / totalN * 100

keep if year == 1789

levelsof direction, local(levels)
	foreach l of local levels {
	gen `l' = .
	replace `l' = proportiondir if direction == "`l'"
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

	keep if sourcetype == "Objet Général" | sourcetype == "Résumé"

	drop if sourcetype == "Résumé" & year == 1787 
	drop if sourcetype == "Résumé" & year == 1788
	drop if sourcetype == "Objet Général" & year > 1788
	drop if sourcetype == "Résumé" & year < 1787

	sort year
	collapse (sum) value, by(year eden_classification)
	replace eden_classification = "Autres" if eden_classification == ""
	
	merge m:1 year using "/Users/Corentin/Desktop/script/test2.dta"
	drop if _merge == 2
	drop _merge
	
	set more off
	replace eden_classification = "Coton_detoute_espèce" if eden_classification == "Coton de toute espèce"
	replace eden_classification = "Eau_de_vie_de_France" if eden_classification == "Eau de vie de France"
	replace eden_classification = "Glaces_et_verrerie" if eden_classification == "Glaces et Verrerie"
	replace eden_classification = "Huile_olive_de_France" if eden_classification == "Huile d'olive de France"
	replace eden_classification = "Porcelaine" if eden_classification == "Porcelaine, Fayance, Poterie"
	replace eden_classification = "batistes_et_linons" if eden_classification == "Toiles de batistes et linons"
	replace eden_classification = "lin_et_de_chanvre" if eden_classification == "Toiles de lin et de chanvre"
	replace eden_classification = "Vin_de_France" if eden_classification == "Vin de France"
	replace eden_classification = "Vinaigre_de_France" if eden_classification == "Vinaigre de France"


	gen proportiondir = value / totalN * 100

	levelsof eden_classification, local(levels)
		foreach l of local levels {
		gen `l' = .
		replace `l' = proportiondir if eden_classification == "`l'"
		}
	keep if year == 1778

	graph bar Autres Bière Gazes Hardware Lainage Modes Prohibé Sellerie Soie Vinaigre_de_France Vin_de_France lin_et_de_chanvre batistes_et_linons Porcelaine Huile_olive_de_France Glaces_et_verrerie Eau_de_vie_de_France Coton_detoute_espèce 
	*keep if year == 1782 | year == 1789
	*graph twoway (connected proportiondir year if eden_classification == "Soie"  ) (connected proportiondir year if eden_classification == "Sellerie"  ) (connected proportiondir year if eden_classification == "Prohibé"  ) (connected proportiondir year if eden_classification == "Modes"  ) (connected proportiondir year if eden_classification == "Lainage"  ) (connected proportiondir year if eden_classification == "Hardware"  ) (connected proportiondir year if eden_classification == "Gazes"  ) (connected proportiondir year if eden_classification == "Bière"  ) (connected proportiondir year if eden_classification == "Autres"  ) (connected proportiondir year if eden_classification == "Coton_detoute_espèce"  )  (connected proportiondir year if eden_classification == "Eau_de_vie_de_France"  ) (connected proportiondir year if eden_classification == "Glaces_et_verrerie"  ) (connected proportiondir year if eden_classification == "Huile_olive_de_France"  ) (connected proportiondir year if eden_classification == "Porcelaine"  ) (connected proportiondir year if eden_classification == "batistes_et_linons"  ) (connected proportiondir year if eden_classification == "lin_et_de_chanvre"  ) (connected proportiondir year if eden_classification == "Vin_de_France"  ) (connected proportiondir year if eden_classification == "Vinaigre_de_France"  ),/*
	**/legend(label(1 "Soie") label(2 "Sellerie") label(3 "Prohibé") label(4 "Modes") label(5 "Lainage") label(6 "Hardware") label(7 "Gazes") label(8 "Bière") label(9 "Autres") label(10 "Coton_detoute_espèce") label(11 "Eau_de_vie_de_France") label(12 "Glaces_et_verrerie") label(13 "Huile_olive_de_France") label(14 "Porcelaine") label(15 "batistes_et_linons") label(16 "lin_et_de_chanvre") label(17 "Vin_de_France") label(18 "Vinaigre_de_France"))
	*/
	
********* only local
/*
levelsof direction, local(levels)
	foreach l of local levels {
	gen `l' = .
	replace `l' = value if direction == "`l'"
    }
keep if year == 1789

	foreach var of varlist Amiens Bayonne Bordeaux Caen La_Rochelle Lille Lorient Marseille Montpellier Nantes Passeports Rouen Saint_Malo Valenciennes Passeport_du_roy {
	tab `var', gen(z`var')
	}

graph  pie Amiens Bayonne Bordeaux Caen Charleville La_Rochelle Lille Lorient Marseille Montpellier Nantes Narbonne Passeport_du_roy Passeports Rennes Rouen Saint_Malo Valenciennes, plabel(_all percent)




