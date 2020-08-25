/// 1 : Différence national / Local

***** PREPARATION NATIONAL *****
use "/Users/Corentin/Desktop/script/test.dta", clear

	keep if source_type == "Objet Général" | source_type == "Résumé"

	drop if source_type == "Résumé" & year == 1787 
	drop if source_type == "Résumé" & year == 1788
	drop if source_type == "Objet Général" & year > 1788
	drop if source_type == "Résumé" & year < 1787
	
	sort year export_import
	
	collapse (sum) value, by(year) 
	rename value totalN

save "/Users/Corentin/Desktop/script/test2.dta", replace 

***** LOCAL

use "/Users/Corentin/Desktop/script/test.dta", clear

set more off
keep if source_type == "National par tax_department"  | source_type == "Local"
collapse (sum) value , by(year)

merge m:1 year using "/Users/Corentin/Desktop/script/test2.dta"
drop if _merge == 2
drop _merge

gen proportion = value / totalN * 100

graph twoway (connected proportion year)

/// 2 
/*
use "/Users/Corentin/Desktop/script/test.dta", clear

	keep if source_type == "Objet Général" | source_type == "Résumé"

	drop if source_type == "Résumé" & year == 1787 
	drop if source_type == "Résumé" & year == 1788
	drop if source_type == "Objet Général" & year > 1788
	drop if source_type == "Résumé" & year < 1787
	
	sort year export_import
		
	replace edentreaty_classification = "Autres" if edentreaty_classification == ""
	collapse (sum) value, by(year edentreaty_classification)
	
	merge m:1 year using "/Users/Corentin/Desktop/script/test2.dta"
	drop if _merge == 2
	drop _merge
	
	gen proportion = 100 - value / totalN * 100
	
	graph twoway (connected proportion year if edentreaty_classification == "Autres")
	
