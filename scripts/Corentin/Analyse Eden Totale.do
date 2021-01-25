
***** PREPARATION NATIONAL *****
use "/Users/Corentin/Desktop/script/Base_Eden_Mesure_Totale.dta", clear

keep product grouping_classification customs_region edentreaty_classification export_import orthographic_normalization_classification simplification_classification q_conv  quantity quantites_metric  quantitépourlesdroits quantity_unit quantity_unit_ajustees quantity_unit_orthographe sitc_classification filepath source_type u_conv  unitépourlesdroits value year

	keep if source_type == "Objet Général" | source_type == "Résumé" 

	drop if source_type == "Résumé" & year == 1787 
	drop if source_type == "Résumé" & year == 1788
	drop if source_type == "Objet Général" & year > 1788
	drop if source_type == "Résumé" & year < 1787
	
	keep if export_import == "Imports"	
	*keep if edentreaty_classification == "Vin de France"
	
	sort year
	collapse (sum) value, by(year)
	rename value totalN
	*keep if year == 1782 | year == 1789

save "/Users/Corentin/Desktop/script/test2Totale.dta", replace

**********

use "/Users/Corentin/Desktop/script/Base_Eden_Mesure_Totale.dta", clear
keep product grouping_classification customs_region edentreaty_classification export_import orthographic_normalization_classification simplification_classification q_conv  quantity quantites_metric  quantitépourlesdroits quantity_unit quantity_unit_ajustees quantity_unit_orthographe sitc_classification filepath source_type u_conv  unitépourlesdroits value year


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

****** Balance totale
/*
collapse (sum) value, by(year  export_import) 
	
	gen exports = value if export_import == "Exports"
	gen imports = value if export_import == "Imports"
	 
		collapse (sum) exports imports, by(year)
		gen balance = exports - imports
		twoway (connected balance year)
		graph rename test1, replace
		
		twoway (connected exports year)
		graph rename test2, replace
		
		twoway (connected imports year)
		graph rename test3, replace


***** COMPOSITION DES ECHANGES SITC	TOTALE

set more off
keep if export_import == "Exports"	

	replace sitc_classification = "Inconnu" if sitc_classification == ""
	replace sitc_classification = "Inconnu" if sitc_classification == "???"
	replace sitc_classification = "0" if sitc_classification == "0a" | sitc_classification == "0b"
	replace sitc_classification = "6" if sitc_classification == "6a" | sitc_classification == "6b" | sitc_classification == "6c"| sitc_classification == "6d"| sitc_classification == "6e"| sitc_classification == "6f" | sitc_classification == "6g"| sitc_classification == "6h" | sitc_classification == "6i"| sitc_classification == "6j"| sitc_classification == "6k"
	replace sitc_classification = "9" if sitc_classification == "9a" | sitc_classification == "9b"
	

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
	keep if year == 1778
	egen test = total(proportion)
	graph bar SITCInconnu SITC0 SITC1 SITC2 SITC4 SITC5 SITC6 SITC7 SITC8 SITC9

*/	
******** Proportion destinations dans exportations

	set more off
	keep if export_import == "Imports"
	*keep if edentreaty_classification == "Eau_de_vie_de_France"
	*keep if orthographic_normalization_classification == "vin de France de Bordeaux au muid" | orthographic_normalization_classification == "vin de Bordeaux de haut"  | orthographic_normalization_classification == "vin de Bordeaux au muid" | orthographic_normalization_classification == "vin de Bordeaux" | orthographic_normalization_classification == "vin de Bordeaux de ville"
	
	collapse (sum) value, by(year grouping_classification) 	

	replace grouping_classification = "Inconnu" if grouping_classification == "?"
	replace grouping_classification = "Inconnu" if grouping_classification == "????"
	replace grouping_classification = "Allemagne_et_Pologne" if grouping_classification == "Allemagne et Pologne (par terre)"
	replace grouping_classification = "Colonies_Françaises" if grouping_classification == "Colonies françaises"
	replace grouping_classification = "Colonies_Etrangères" if grouping_classification == "Colonies étrangères"
	replace grouping_classification = "Duché_de_Bouillon" if grouping_classification == "Duché de Bouillon"
	replace grouping_classification = "Flandre" if grouping_classification == "Flandre et autres états de l'Empereur"
	replace grouping_classification = "Levant_et_Barbarie" if grouping_classification == "Levant et Barbarie"
	replace grouping_classification = "Etats_Unis" if grouping_classification == "États-Unis d'Amérique"
	replace grouping_classification = "Expagne_Portugal" if grouping_classification == "Espagne-Portugal"

	merge m:1 year using "/Users/Corentin/Desktop/script/test2Totale.dta"
	drop if _merge == 2
	drop _merge
	
	gen proportion = value / totalN * 100

	levelsof grouping_classification, local(levels)
	foreach l of local levels {
		gen `l' = .
		replace `l' = proportion if grouping_classification == "`l'"
		}
	
	*drop if proportion < 5 & year == 1788
	*bysort grouping_classification : drop if _N < 7
	sort year
	*tab grouping_classification
	*drop if grouping_classification == "Colonies_Françaises"
	
	keep if grouping_classification == "Colonies_Françaises"  | grouping_classification == "Flandre" | grouping_classification == "Levant_et_Barbarie" | grouping_classification == "Angleterre" | grouping_classification == "Espagne" | grouping_classification == "Hollande" | grouping_classification == "Italie" | grouping_classification == "Nord"
	bysort year : egen test = total(proportion)
	gen Autres = 100 - test
	sort year proportion
	
	collapse (mean) Autres (sum) Colonies_Françaises Flandre Levant_et_Barbarie Angleterre Espagne Hollande Italie Nord, by(year)
	sort year 
	*Colonies_Françaises Flandre Levant_et_Barbarie Angleterre Espagne Hollande Italie Nord year,  cmissing(n)
	gen ItalieG = Angleterre + Italie
	gen Levant_et_BarbarieG = ItalieG + Levant_et_Barbarie
	gen EspagneG = Levant_et_BarbarieG + Espagne
	gen FlandreG = EspagneG + Flandre
	gen HollandeG = FlandreG + Hollande
	gen NordG = HollandeG + Nord
	gen Colonies_FrançaisesG = NordG + Colonies_Françaises
	gen AutresG = Colonies_FrançaisesG + Autres
	*twoway area Colonies_Françaises FlandreG Levant_et_BarbarieG AngleterreG EspagneG HollandeG ItalieG NordG year,  cmissing(n)
	
	drop if year > 1781 & year < 1788

	twoway area AutresG Colonies_FrançaisesG NordG HollandeG FlandreG EspagneG Levant_et_BarbarieG ItalieG Angleterre year , cmissing(n) 
	*twoway  (connected Colonies_Françaises year) (connected Flandre year) (connected Levant_et_Barbarie year) (connected Angleterre year) (connected Espagne year) (connected Hollande year) (connected Italie year) (connected Nord year) , ylabel(, angle(horizontal)) 
	/*

twoway (connected Colonies_Françaises year) (connected Flandre year) (connected Levant_et_Barbarie year) (connected Angleterre year) (connected Espagne year) (connected Hollande year) (connected Italie year) (connected Nord year), ylabel(, angle(horizontal)) 
*/
/*
****** Proportion vin vers angleterre dans total
*/
/*
keep if export_import == "Exports"
keep if edentreaty_classification == "Vin_de_France"
keep if grouping_classification == "Angleterre"

collapse (sum) value, by(year) 	

	merge m:1 year using "/Users/Corentin/Desktop/script/test2Totale.dta"
	drop if _merge == 2
	drop _merge
	
gen proportion = value / totalN * 100

twoway (connected proportion year), xline(1787)

