/// 1 : Différence national / Local

***** PREPARATION NATIONAL *****
use "/Users/Corentin/Desktop/script/test.dta", clear

	keep if sourcetype == "Objet Général" | sourcetype == "Résumé"

	drop if sourcetype == "Résumé" & year == 1787 
	drop if sourcetype == "Résumé" & year == 1788
	drop if sourcetype == "Objet Général" & year > 1788
	drop if sourcetype == "Résumé" & year < 1787
	
	sort year exportsimports
	
	collapse (sum) value, by(year) 
	rename value totalN

save "/Users/Corentin/Desktop/script/test2.dta", replace 

***** LOCAL

use "/Users/Corentin/Desktop/script/test.dta", clear

set more off
keep if sourcetype == "National par direction"  | sourcetype == "Local"
collapse (sum) value , by(year)

merge m:1 year using "/Users/Corentin/Desktop/script/test2.dta"
drop if _merge == 2
drop _merge

gen proportion = value / totalN * 100

graph twoway (connected proportion year)

/// 2 
/*
use "/Users/Corentin/Desktop/script/test.dta", clear

	keep if sourcetype == "Objet Général" | sourcetype == "Résumé"

	drop if sourcetype == "Résumé" & year == 1787 
	drop if sourcetype == "Résumé" & year == 1788
	drop if sourcetype == "Objet Général" & year > 1788
	drop if sourcetype == "Résumé" & year < 1787
	
	sort year exportsimports
		
	replace edentreaty_classification = "Autres" if edentreaty_classification == ""
	collapse (sum) value, by(year edentreaty_classification)
	
	merge m:1 year using "/Users/Corentin/Desktop/script/test2.dta"
	drop if _merge == 2
	drop _merge
	
	gen proportion = 100 - value / totalN * 100
	
	graph twoway (connected proportion year if edentreaty_classification == "Autres")
	
