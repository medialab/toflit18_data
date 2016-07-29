
***** PREPARATION NATIONAL *****
use "/Users/Corentin/Desktop/script/Base_Eden_Mesure_Totale.dta", clear

keep marchandises pays_grouping direction eden_classification exportsimports marchandises_norm_ortho marchandises_simplification q_conv  quantit quantites_metric  quantitépourlesdroits quantity_unit quantity_unit_ajustees quantity_unit_orthographe sitc18_rev3 sourcepath sourcetype u_conv  unitépourlesdroits value year

	keep if sourcetype == "Objet Général" | sourcetype == "Résumé" 

	drop if sourcetype == "Résumé" & year == 1787 
	drop if sourcetype == "Résumé" & year == 1788
	drop if sourcetype == "Objet Général" & year > 1788
	drop if sourcetype == "Résumé" & year < 1787
	
	keep if exportsimports == "Imports"	
	*keep if eden_classification == "Vin de France"
	
	sort year
	collapse (sum) value, by(year)
	rename value totalN
	*keep if year == 1782 | year == 1789

save "/Users/Corentin/Desktop/script/test2Totale.dta", replace

**********

use "/Users/Corentin/Desktop/script/Base_Eden_Mesure_Totale.dta", clear
keep marchandises pays_grouping direction eden_classification exportsimports marchandises_norm_ortho marchandises_simplification q_conv  quantit quantites_metric  quantitépourlesdroits quantity_unit quantity_unit_ajustees quantity_unit_orthographe sitc18_rev3 sourcepath sourcetype u_conv  unitépourlesdroits value year


***** NATIONAL
	keep if sourcetype == "Objet Général" | sourcetype == "Résumé" | sourcetype == "Divers - in"

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


***** COMPOSITION DES ECHANGES SITC	TOTALE

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
	keep if year == 1778
	egen test = total(proportion)
	graph bar SITCInconnu SITC0 SITC1 SITC2 SITC4 SITC5 SITC6 SITC7 SITC8 SITC9

*/	
******** Proportion destinations dans exportations

	set more off
	keep if exportsimports == "Imports"
	*keep if eden_classification == "Eau_de_vie_de_France"
	*keep if marchandises_norm_ortho == "vin de France de Bordeaux au muid" | marchandises_norm_ortho == "vin de Bordeaux de haut"  | marchandises_norm_ortho == "vin de Bordeaux au muid" | marchandises_norm_ortho == "vin de Bordeaux" | marchandises_norm_ortho == "vin de Bordeaux de ville"
	
	collapse (sum) value, by(year pays_grouping) 	

	replace pays_grouping = "Inconnu" if pays_grouping == "?"
	replace pays_grouping = "Inconnu" if pays_grouping == "????"
	replace pays_grouping = "Allemagne_et_Pologne" if pays_grouping == "Allemagne et Pologne (par terre)"
	replace pays_grouping = "Colonies_Françaises" if pays_grouping == "Colonies françaises"
	replace pays_grouping = "Colonies_Etrangères" if pays_grouping == "Colonies étrangères"
	replace pays_grouping = "Duché_de_Bouillon" if pays_grouping == "Duché de Bouillon"
	replace pays_grouping = "Flandre" if pays_grouping == "Flandre et autres états de l'Empereur"
	replace pays_grouping = "Levant_et_Barbarie" if pays_grouping == "Levant et Barbarie"
	replace pays_grouping = "Etats_Unis" if pays_grouping == "États-Unis d'Amérique"
	replace pays_grouping = "Expagne_Portugal" if pays_grouping == "Espagne-Portugal"

	merge m:1 year using "/Users/Corentin/Desktop/script/test2Totale.dta"
	drop if _merge == 2
	drop _merge
	
	gen proportion = value / totalN * 100

	levelsof pays_grouping, local(levels)
	foreach l of local levels {
		gen `l' = .
		replace `l' = proportion if pays_grouping == "`l'"
		}
	
	*drop if proportion < 5 & year == 1788
	*bysort pays_grouping : drop if _N < 7
	sort year
	*tab pays_grouping
	*drop if pays_grouping == "Colonies_Françaises"
	
	keep if pays_grouping == "Colonies_Françaises"  | pays_grouping == "Flandre" | pays_grouping == "Levant_et_Barbarie" | pays_grouping == "Angleterre" | pays_grouping == "Espagne" | pays_grouping == "Hollande" | pays_grouping == "Italie" | pays_grouping == "Nord"
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
keep if exportsimports == "Exports"
keep if eden_classification == "Vin_de_France"
keep if pays_grouping == "Angleterre"

collapse (sum) value, by(year) 	

	merge m:1 year using "/Users/Corentin/Desktop/script/test2Totale.dta"
	drop if _merge == 2
	drop _merge
	
gen proportion = value / totalN * 100

twoway (connected proportion year), xline(1787)

