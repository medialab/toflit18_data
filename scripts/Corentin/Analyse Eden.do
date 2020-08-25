***** PREPARATION NATIONAL *****
use "/Users/Corentin/Desktop/script/test.dta", clear

	keep if source_type == "Objet Général" | source_type == "Résumé" | source_type == "Divers - in"

	drop if source_type == "Résumé" & year == 1787 
	drop if source_type == "Résumé" & year == 1788
	drop if source_type == "Objet Général" & year > 1788
	drop if source_type == "Résumé" & year < 1787

	*keep if edentreaty_classification == "Vin de France" // A ajouter pour analyse vin
	*keep if edentreaty_classification == "Hardware" // A ajouter pour analyse Hardware
	*keep if edentreaty_classification == "Coton de toute espèce"
	keep if export_import == "Imports"
keep if sitc_classification == "6a" | sitc_classification == "6b" | sitc_classification == "6c"| sitc_classification == "6d"| sitc_classification == "6e"| sitc_classification == "6f" | sitc_classification == "6g"| sitc_classification == "6h" | sitc_classification == "6i"| sitc_classification == "6j"| sitc_classification == "6k"

	sort year export_import
	
	collapse (sum) value, by(year) 
	rename value totalN
	*keep if year == 1782 | year == 1789

save "/Users/Corentin/Desktop/script/test2.dta", replace


***************


use "/Users/Corentin/Desktop/script/test.dta", clear


***** NATIONAL
	keep if source_type == "Objet Général" | source_type == "Résumé" | source_type == "Divers - in"

	drop if source_type == "Résumé" & year == 1787 
	drop if source_type == "Résumé" & year == 1788
	drop if source_type == "Objet Général" & year > 1788
	drop if source_type == "Résumé" & year < 1787

	replace edentreaty_classification = "Coton_detoute_espèce" if edentreaty_classification == "Coton de toute espèce"
	replace edentreaty_classification = "Eau_de_vie_de_France" if edentreaty_classification == "Eau de vie de France"
	replace edentreaty_classification = "Glaces_et_verrerie" if edentreaty_classification == "Glaces et Verrerie"
	replace edentreaty_classification = "Huile_olive_de_France" if edentreaty_classification == "Huile d'olive de France"
	replace edentreaty_classification = "Porcelaine" if edentreaty_classification == "Porcelaine, Fayance, Poterie"
	replace edentreaty_classification = "batistes_et_linons" if edentreaty_classification == "Toiles de batistes et linons"
	replace edentreaty_classification = "lin_et_de_chanvre" if edentreaty_classification == "Toiles de lin et de chanvre"
	replace edentreaty_classification = "Vin_de_France" if edentreaty_classification == "Vin de France"
	replace edentreaty_classification = "Vinaigre_de_France" if edentreaty_classification == "Vinaigre de France"

	/*
	****
	keep if export_import == "Imports"	
	*keep if edentreaty_classification == "Eau_de_vie_de_France"
	*keep if orthographic_normalization_classification == "vin de France de Bordeaux au muid" | orthographic_normalization_classification == "vin de Bordeaux de haut"  | orthographic_normalization_classification == "vin de Bordeaux au muid" | orthographic_normalization_classification == "vin de Bordeaux" | orthographic_normalization_classification == "vin de Bordeaux de ville"

	collapse (sum) value, by(year) 	
	
	merge m:1 year using "/Users/Corentin/Desktop/script/test2Totale.dta"
	drop if _merge == 2
	drop _merge
	
	replace value = value / 1000000
	*gen proportion = value / totalN * 100
	twoway (connected value year)

	
	
	
	
	
	
	/*
	
	*****
	keep if export_import == "Exports"	
	collapse (sum) value, by(year edentreaty_classification) 	
	
	levelsof edentreaty_classification, local(levels)
	foreach l of local levels {
		gen Exports_`l' = value if edentreaty_classification == "`l'"
		twoway (connected Exports_`l' year)
		
		cd "/Users/Corentin/Documents/STAT/EdenTreaty/Sorties Valides/EdenNational/Focus/Exports"	
		*graph export  Evolution_Balance_FocusPeriode_edentreaty_classification_`l'.png, replace
	
	 }
	tab year
	
	
*/
	*/
	****
	
	collapse (sum) value, by(year  export_import edentreaty_classification) 
	
	gen exports = value if export_import == "Exports"
	gen imports = value if export_import == "Imports"
	 
	levelsof edentreaty_classification, local(levels)
			collapse (sum) exports imports, by(year edentreaty_classification)

	foreach l of local levels {
		gen balance_`l' = (exports - imports)/1000000 if edentreaty_classification == "`l'"
		twoway (connected balance_`l' year)
		
		cd "/Users/Corentin/Documents/STAT/EdenTreaty/Sorties Valides/EdenNational/Focus/Balance"	
		graph export  Evolution_Balance_FocusPeriode_Eden_`l'.png, replace
	
	 }
	*/
	*/
****** Balance totale
/*
collapse (sum) value, by(year  export_import) 
	
	gen exports = value/1000000 if export_import == "Exports"
	gen imports = value/1000000 if export_import == "Imports"
	 
		collapse (sum) exports imports, by(year)
		gen balance = exports - imports
		twoway (connected balance year)
		graph rename test1, replace
		
		twoway (connected exports year)
		graph rename test2, replace
		
		twoway (connected imports year)
		graph rename test3, replace

*/		
		/*
		
	
******* PRIX UNITAIRE
drop if year == 1771
replace simplification_classification = "vin de Bordeaux" if orthographic_normalization_classification == "vin de Bordeaux"
keep if export_import == "Exports"
keep if edentreaty_classification == "Vin_de_France"

drop if value == .
*keep if orthographic_normalization_classification ==  "vin de Bourgogne"
*keep if orthographic_normalization_classification == "vin de France de Bordeaux au muid" | orthographic_normalization_classification == "vin de Bordeaux de haut"  | orthographic_normalization_classification == "vin de Bordeaux au muid" | orthographic_normalization_classification == "vin de Bordeaux" | orthographic_normalization_classification == "vin de Bordeaux de ville"
gen prix_u = value / quantites_metric_eden

	replace quantites_metric_eden = . if quantites_metric_eden == 0
		fillin year simplification_classification

	gen prixinvln = ln(quantites_metric_eden / value)
	encode simplification_classification, gen(simplification_classification_c)
	set more off
	
	sort year simplification_classification
	reg prixinvln i.year i.simplification_classification_c [iweight=value]
	predict prixinvln2 if year ==  1771 | year == 1772 | year == 1773 | year == 1774 | year == 1775 | year == 1776 | year == 1777 | year == 1779 | year == 1780   |  year == 1782   |  year == 1787 | year == 1788
	gen prix_u_predict = 1 / exp(prixinvln2)
	sort year
	replace prix_u = prix_u_predict if prix_u == .

	
	*gen ln_quantites_metric_eden_predict = prixinvln2 + ln(value)
	*gen quantites_metric_eden_predict = exp(ln_quantites_metric_eden_predict)
	*replace quantites_metric_eden = quantites_metric_eden_predict if quantites_metric_eden == .

	drop if prix_u == .

	keep if simplification_classification == "vin de Bordeaux de ville"

*keep if orthographic_normalization_classification == "vin de France de Bordeaux au muid" | orthographic_normalization_classification == "vin de Bordeaux de haut"  | orthographic_normalization_classification == "vin de Bordeaux au muid" | orthographic_normalization_classification == "vin de Bordeaux" | orthographic_normalization_classification == "vin de Bordeaux de ville"

***************Evolution ad valorem fabriqué
/*
gen aXq = droit_eden_valorem * quantites_metric_eden
bysort year: egen totaXq = total(aXq)
by year: egen atotq = total(quantites_metric_eden)

gen wava = totaXq / atotq
keep if year > 1772

graph twoway (connected wava year)
graph rename adval, replace
*/
****************Evolution Prix Unitaire pour non ad valorem
*	keep if simplification_classification == "vin de Bordeaux"

*drop if year == 1771

gen pXq = prix_u * quantites_metric_eden
bysort year: egen totpXq = total(pXq)
by year: egen totq = total(quantites_metric_eden)

gen wavg = totpXq / totq
replace prix_u = wavg if wavg != .


*
graph twoway (connected prix_u year)
graph rename prix_u, replace
*
/*
collapse (sum) value, by(year)
twoway (connected value year)

****************Evolution Prix Unitaire pour  ad valorem

/*

**********************************************

*use "/Users/Corentin/Desktop/script/test.dta", clear
gen prix_u = value / quantites_metric_eden
drop if prix_u == .


collapse (mean) prix_u, by(year  export_import edentreaty_classification) 
keep if export_import == "Exports"
keep if year > 1772

*keep if edentreaty_classification == "Eau_de_vie_de_France"
keep if edentreaty_classification == "Vinaigre_de_France"
graph twoway (connected prix_u year)


*graph twoway (connected prix_u year if edentreaty_classification == "Vin_de_France"  ) (connected prix_u year if edentreaty_classification == "Eau_de_vie_de_France"  ) (connected prix_u year if edentreaty_classification == "Vinaigre_de_France"  ) ,/*
	**/legend(label(1 "Vin de France") label(2 "Eau de vie de France") label(3 "Vinaigre de France") )

*/
*/
*/	
***** COMPOSITION DES ECHANGES SITC	
/*
set more off
keep if export_import == "Imports"	

/*
	replace sitc_classification = "Inconnu" if sitc_classification == ""
	replace sitc_classification = "Inconnu" if sitc_classification == "???"
	replace sitc_classification = "0" if sitc_classification == "0a" | sitc_classification == "0b"
	replace sitc_classification = "6" if sitc_classification == "6a" | sitc_classification == "6b" | sitc_classification == "6c"| sitc_classification == "6d"| sitc_classification == "6e"| sitc_classification == "6f" | sitc_classification == "6g"| sitc_classification == "6h" | sitc_classification == "6i"| sitc_classification == "6j"| sitc_classification == "6k"
	replace sitc_classification = "9" if sitc_classification == "9a" | sitc_classification == "9b"
*/
keep if sitc_classification == "6a" | sitc_classification == "6b" | sitc_classification == "6c"| sitc_classification == "6d"| sitc_classification == "6e"| sitc_classification == "6f" | sitc_classification == "6g"| sitc_classification == "6h" | sitc_classification == "6i"| sitc_classification == "6j"| sitc_classification == "6k"


collapse (sum) value, by(year sitc_classification) 	

	merge m:1 year using "/Users/Corentin/Desktop/script/test2.dta"
	drop if _merge == 2
	drop _merge

	gen proportion = value / totalN * 100

	
	levelsof sitc_classification, local(levels)
		foreach l of local levels {
		gen SITC`l' = .
		replace SITC`l' = proportion if sitc_classification == "`l'"
		}
	keep if year == 1788
	egen test = total(proportion)
	
	graph bar SITC6a SITC6b SITC6c SITC6d SITC6e SITC6f SITC6g SITC6h SITC6i SITC6j SITC6k
/*
	graph bar SITCInconnu SITC0 SITC1 SITC2 SITC3 SITC4 SITC5 SITC6 SITC7 SITC8 SITC9

	
