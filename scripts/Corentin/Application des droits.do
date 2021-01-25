clear all

/// Fichier de merge
import delimited "/Users/Corentin/Desktop/script/conversion finale.csv", varnames(1) encoding(UTF-8)clear
save "/Users/Corentin/Desktop/script/conversion finale.dta", replace


/// base
//////// Nouveaux droits
use "/Users/Corentin/Desktop/script/Base_Eden_Mesure.dta", clear

keep value_part_of_bundle product grouping_classification customs_region edentreaty_classification export_import orthographic_normalization_classification simplification_classification q_conv  quantity quantites_metric  quantitépourlesdroits quantity_unit quantity_unit_ajustees quantity_unit_orthographe sitc_classification filepath source_type u_conv  unitépourlesdroits value year


	merge m:1 edentreaty_classification u_conv using "/Users/Corentin/Desktop/script/conversion finale.dta"
	drop if _merge == 2
	drop _merge
	*destring q_conv_eden, replace
	gen quantites_metric_eden = quantites_metric / q_conv_eden 
	*destring quantites_metric_eden, replace
	
	*tab edentreaty_classification
	generate droit_eden_valorem = 0.30 if  edentreaty_classification == "Bière" & year > 1786
	replace droit_eden_valorem = 0.15 if edentreaty_classification == "Sellerie" & year > 1786
	replace droit_eden_valorem = 0.12 if edentreaty_classification == "Coton de toute espèce" & year > 1786
	replace droit_eden_valorem = 0.12 if edentreaty_classification == "Lainage" & year > 1786
	replace droit_eden_valorem = 0.12 if edentreaty_classification == "Modes" & year > 1786
	replace droit_eden_valorem = 0.12 if edentreaty_classification == "Porcelaine, Fayance, Poterie" & year > 1786
	replace droit_eden_valorem = 0.12 if edentreaty_classification == "Glaces et Verrerie"	 & year > 1786
	replace droit_eden_valorem = 0.10 if edentreaty_classification == "Hardware" & year > 1786
	replace droit_eden_valorem = 0.10 if edentreaty_classification == "Gazes" & year > 1786


sort filepath-value grouping_classification-year q_conv_eden-u_conv_eden droit_eden_valorem
collapse (sum) quantites_metric_eden, by(filepath-value grouping_classification-year q_conv_eden-u_conv_eden droit_eden_valorem)
	
	

gen droit_eden_value = value * droit_eden_valorem if year > 1786
	destring  droit_eden_value, replace
	destring quantites_metric_eden, replace
	replace droit_eden_value = (quantites_metric_eden * 7 * 25) / 20 if edentreaty_classification == "Eau de vie de France" & year > 1786
	replace droit_eden_value = (quantites_metric_eden * 32.945 * 25) if edentreaty_classification == "Vinaigre de France" & year > 1786
	replace droit_eden_value = (quantites_metric_eden * 29.4 * 25) if edentreaty_classification == "Vin de France" & year > 1786
	
	
	replace droit_eden_valorem = (droit_eden_value / value) if edentreaty_classification == "Eau de vie de France" & year > 1786
	replace droit_eden_valorem = (droit_eden_value / value) if edentreaty_classification == "Vinaigre de France" & year > 1786
	replace droit_eden_valorem = (droit_eden_value / value) if edentreaty_classification == "Vin de France" & year > 1786
	
	
//////// Anciens droits
	replace droit_eden_value = (quantites_metric_eden * 9.55 * 25) / 20 if edentreaty_classification == "Eau de vie de France" & year < 1787
	replace droit_eden_value = (quantites_metric_eden * 67.265 * 25) if edentreaty_classification == "Vinaigre de France" & year < 1787
	replace droit_eden_value = (quantites_metric_eden * 96.2 * 25) if edentreaty_classification == "Vin de France" & year < 1787
	
	
	replace droit_eden_valorem = (droit_eden_value / value) if edentreaty_classification == "Eau de vie de France" & year < 1787
	replace droit_eden_valorem = (droit_eden_value / value) if edentreaty_classification == "Vinaigre de France" & year < 1787
	replace droit_eden_valorem = (droit_eden_value / value) if edentreaty_classification == "Vin de France" & year < 1787

	
		su droit_eden_valorem if edentreaty_classification == "Vinaigre de France" & year < 1787
		su droit_eden_valorem if edentreaty_classification == "Vinaigre de France" & year > 1786
		su droit_eden_valorem if edentreaty_classification == "Eau de vie de France" & year < 1787
		su droit_eden_valorem if edentreaty_classification == "Eau de vie de France" & year > 1786
		su droit_eden_valorem if edentreaty_classification == "Vin de France" & year < 1787
		su droit_eden_valorem if edentreaty_classification == "Vin de France" & year > 1786
	
gen prohibition = 0
replace prohibition = 1 if edentreaty_classification == "Soie"
replace prohibition = 1 if edentreaty_classification == "Prohibé"
replace prohibition = 1 if edentreaty_classification == "Coton de toute espèce" & year < 1787 & export_import == "Imports"
replace prohibition = 1 if edentreaty_classification == "Hardware" & year < 1787 & export_import == "Imports"
replace prohibition = 1 if edentreaty_classification == "Lainage" & year < 1787 & export_import == "Imports"

save "/Users/Corentin/Desktop/script/test.dta", replace
