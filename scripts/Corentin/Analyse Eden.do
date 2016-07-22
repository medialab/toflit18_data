***** PREPARATION NATIONAL *****
use "/Users/Corentin/Desktop/script/test.dta", clear

	keep if sourcetype == "Objet Général" | sourcetype == "Résumé"

	drop if sourcetype == "Résumé" & year == 1787 
	drop if sourcetype == "Résumé" & year == 1788
	drop if sourcetype == "Objet Général" & year > 1788
	drop if sourcetype == "Résumé" & year < 1787

	keep if eden_classification == "Vin de France" // A ajouter pour analyse vin
	*keep if eden_classification == "Hardware" // A ajouter pour analyse Hardware
	*keep if eden_classification == "Coton de toute espèce"
	keep if exportsimports == "Exports"
	sort year exportsimports
	
	collapse (sum) value, by(year) 
	rename value totalN
	*keep if year == 1782 | year == 1789

save "/Users/Corentin/Desktop/script/test2.dta", replace


***************


use "/Users/Corentin/Desktop/script/test.dta", clear


***** NATIONAL
	keep if sourcetype == "Objet Général" | sourcetype == "Résumé"

	drop if sourcetype == "Résumé" & year == 1787 
	drop if sourcetype == "Résumé" & year == 1788
	drop if sourcetype == "Objet Général" & year > 1788
	drop if sourcetype == "Résumé" & year < 1787

	replace eden_classification = "Coton_detoute_espèce" if eden_classification == "Coton de toute espèce"
	replace eden_classification = "Eau_de_vie_de_France" if eden_classification == "Eau de vie de France"
	replace eden_classification = "Glaces_et_verrerie" if eden_classification == "Glaces et Verrerie"
	replace eden_classification = "Huile_olive_de_France" if eden_classification == "Huile d'olive de France"
	replace eden_classification = "Porcelaine" if eden_classification == "Porcelaine, Fayance, Poterie"
	replace eden_classification = "batistes_et_linons" if eden_classification == "Toiles de batistes et linons"
	replace eden_classification = "lin_et_de_chanvre" if eden_classification == "Toiles de lin et de chanvre"
	replace eden_classification = "Vin_de_France" if eden_classification == "Vin de France"
	replace eden_classification = "Vinaigre_de_France" if eden_classification == "Vinaigre de France"

	/*
	****
	keep if exportsimports == "Imports"	
	*keep if eden_classification == "Eau_de_vie_de_France"
	*keep if marchandises_norm_ortho == "vin de France de Bordeaux au muid" | marchandises_norm_ortho == "vin de Bordeaux de haut"  | marchandises_norm_ortho == "vin de Bordeaux au muid" | marchandises_norm_ortho == "vin de Bordeaux" | marchandises_norm_ortho == "vin de Bordeaux de ville"

	collapse (sum) value, by(year) 	
	
	merge m:1 year using "/Users/Corentin/Desktop/script/test2Totale.dta"
	drop if _merge == 2
	drop _merge
	
	replace value = value / 1000000
	*gen proportion = value / totalN * 100
	twoway (connected value year)

	
	
	
	
	
	
	/*
	
	*****
	keep if exportsimports == "Exports"	
	collapse (sum) value, by(year eden_classification) 	
	
	levelsof eden_classification, local(levels)
	foreach l of local levels {
		gen Exports_`l' = value if eden_classification == "`l'"
		twoway (connected Exports_`l' year)
		
		cd "/Users/Corentin/Documents/STAT/EdenTreaty/Sorties Valides/EdenNational/Focus/Exports"	
		*graph export  Evolution_Balance_FocusPeriode_eden_classification_`l'.png, replace
	
	 }
	tab year
	
	
*/
	
	****
	/*
	collapse (sum) value, by(year  exportsimports eden_classification) 
	
	gen exports = value if exportsimports == "Exports"
	gen imports = value if exportsimports == "Imports"
	 
	levelsof eden_classification, local(levels)
	foreach l of local levels {
		collapse (sum) exports imports, by(year eden_classification)
		gen balance_`l' = exports - imports if eden_classification == "`l'"
		twoway (connected balance_`l' year)
		
		cd "/Users/Corentin/Documents/STAT/EdenTreaty/Sorties Valides/EdenNational/Focus/Balance"	
		graph export  Evolution_Balance_FocusPeriode_Eden_`l'.png, replace
	
	 }
	*/
****** Balance totale
/*
collapse (sum) value, by(year  exportsimports) 
	
	gen exports = value if exportsimports == "Exports"
	gen imports = value if exportsimports == "Imports"
	 
		collapse (sum) exports imports, by(year)
		gen balance = exports - imports
		twoway (connected balance year)
		graph rename test1, replace
		
		twoway (connected exports year)
		graph rename test2, replace
		
		twoway (connected imports year)
		graph rename test3, replace

*/		
		
	*/
	
******* PRIX UNITAIRE
drop if year == 1771
replace marchandises_simplification = "vin de Bordeaux" if marchandises_norm_ortho == "vin de Bordeaux"
keep if exportsimports == "Exports"
keep if eden_classification == "Vin_de_France"

drop if value == .
*keep if marchandises_norm_ortho ==  "vin de Bourgogne"
*keep if marchandises_norm_ortho == "vin de France de Bordeaux au muid" | marchandises_norm_ortho == "vin de Bordeaux de haut"  | marchandises_norm_ortho == "vin de Bordeaux au muid" | marchandises_norm_ortho == "vin de Bordeaux" | marchandises_norm_ortho == "vin de Bordeaux de ville"
gen prix_u = value / quantites_metric_eden

	replace quantites_metric_eden = . if quantites_metric_eden == 0
		fillin year marchandises_simplification

	gen prixinvln = ln(quantites_metric_eden / value)
	encode marchandises_simplification, gen(marchandises_simplification_c)
	set more off
	
	sort year marchandises_simplification
	reg prixinvln i.year i.marchandises_simplification_c [iweight=value]
	predict prixinvln2 if year ==  1771 | year == 1772 | year == 1773 | year == 1774 | year == 1775 | year == 1776 | year == 1777 | year == 1779 | year == 1780   |  year == 1782   |  year == 1787 | year == 1788
	gen prix_u_predict = 1 / exp(prixinvln2)
	sort year
	replace prix_u = prix_u_predict if prix_u == .

	
	*gen ln_quantites_metric_eden_predict = prixinvln2 + ln(value)
	*gen quantites_metric_eden_predict = exp(ln_quantites_metric_eden_predict)
	*replace quantites_metric_eden = quantites_metric_eden_predict if quantites_metric_eden == .

	drop if prix_u == .

	keep if marchandises_simplification == "vin de Bordeaux de ville"

*keep if marchandises_norm_ortho == "vin de France de Bordeaux au muid" | marchandises_norm_ortho == "vin de Bordeaux de haut"  | marchandises_norm_ortho == "vin de Bordeaux au muid" | marchandises_norm_ortho == "vin de Bordeaux" | marchandises_norm_ortho == "vin de Bordeaux de ville"

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
*	keep if marchandises_simplification == "vin de Bordeaux"

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


collapse (mean) prix_u, by(year  exportsimports eden_classification) 
keep if exportsimports == "Exports"
keep if year > 1772

*keep if eden_classification == "Eau_de_vie_de_France"
keep if eden_classification == "Vinaigre_de_France"
graph twoway (connected prix_u year)


*graph twoway (connected prix_u year if eden_classification == "Vin_de_France"  ) (connected prix_u year if eden_classification == "Eau_de_vie_de_France"  ) (connected prix_u year if eden_classification == "Vinaigre_de_France"  ) ,/*
	**/legend(label(1 "Vin de France") label(2 "Eau de vie de France") label(3 "Vinaigre de France") )

*/
*/
*/	
***** COMPOSITION DES ECHANGES SITC	
/*
set more off
keep if exportsimports == "Exports"	

	replace sitc18_rev3 = "Inconnu" if sitc18_rev3 == ""
	replace sitc18_rev3 = "Inconnu" if sitc18_rev3 == "???"
	replace sitc18_rev3 = "0" if sitc18_rev3 == "0a" | sitc18_rev3 == "0b"
	replace sitc18_rev3 = "6" if sitc18_rev3 == "6a" | sitc18_rev3 == "6b" | sitc18_rev3 == "6c"| sitc18_rev3 == "6d"| sitc18_rev3 == "6e"| sitc18_rev3 == "6f" | sitc18_rev3 == "6g"| sitc18_rev3 == "6h" | sitc18_rev3 == "6i"| sitc18_rev3 == "6j"| sitc18_rev3 == "6k"
	replace sitc18_rev3 = "9" if sitc18_rev3 == "9a" | sitc18_rev3 == "9b"
	

collapse (sum) value, by(year sitc18_rev3) 	

	merge m:1 year using "/Users/Corentin/Desktop/script/test2.dta"
	drop if _merge == 2
	drop _merge

	gen proportion = value / totalN * 100

	
	levelsof sitc18_rev3, local(levels)
		foreach l of local levels {
		gen SITC`l' = .
		replace SITC`l' = proportion if sitc18_rev3 == "`l'"
		}
	keep if year == 1788
	egen test = total(proportion)
	graph bar SITCInconnu SITC0 SITC1 SITC2 SITC4 SITC5 SITC6 SITC7 SITC8 SITC9

	
