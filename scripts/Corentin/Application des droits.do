clear all

/// Fichier de merge
import delimited "/Users/Corentin/Desktop/script/conversion finale.csv", varnames(1) encoding(UTF-8)clear
save "/Users/Corentin/Desktop/script/conversion finale.dta", replace


/// base
//////// Nouveaux droits
use "/Users/Corentin/Desktop/script/Base_Eden_Mesure.dta", clear

keep marchandises pays_grouping direction eden_classification exportsimports marchandises_norm_ortho marchandises_simplification q_conv  quantit quantites_metric  quantitépourlesdroits quantity_unit quantity_unit_ajustees quantity_unit_orthographe sitc18_rev3 sourcepath sourcetype u_conv  unitépourlesdroits value year


	merge m:1 eden_classification u_conv using "/Users/Corentin/Desktop/script/conversion finale.dta"
	drop if _merge == 2
	drop _merge
	*destring q_conv_eden, replace
	gen quantites_metric_eden = quantites_metric / q_conv_eden 
	*destring quantites_metric_eden, replace
	
	*tab eden_classification
	generate droit_eden_valorem = 0.30 if  eden_classification == "Bière" & year > 1786
	replace droit_eden_valorem = 0.15 if eden_classification == "Sellerie" & year > 1786
	replace droit_eden_valorem = 0.12 if eden_classification == "Coton de toute espèce" & year > 1786
	replace droit_eden_valorem = 0.12 if eden_classification == "Modes" & year > 1786
	replace droit_eden_valorem = 0.12 if eden_classification == "Porcelaine, Fayance, Poterie" & year > 1786
	replace droit_eden_valorem = 0.12 if eden_classification == "Glaces et Verrerie"	 & year > 1786
	replace droit_eden_valorem = 0.10 if eden_classification == "Hardware" & year > 1786
	replace droit_eden_valorem = 0.10 if eden_classification == "Gazes" & year > 1786

gen droit_eden_value = value * droit_eden_valorem if year > 1786
	destring  droit_eden_value, replace
	destring quantites_metric_eden, replace
	replace droit_eden_value = (quantites_metric_eden * 7 * 25) / 20 if eden_classification == "Eau de vie de France" & year > 1786
	replace droit_eden_value = (quantites_metric_eden * 32.945 * 25) if eden_classification == "Vinaigre de France" & year > 1786
	replace droit_eden_value = (quantites_metric_eden * 29.4 * 25) if eden_classification == "Vin de France" & year > 1786
	
	
	replace droit_eden_valorem = (droit_eden_value / value) if eden_classification == "Eau de vie de France" & year > 1786
	replace droit_eden_valorem = (droit_eden_value / value) if eden_classification == "Vinaigre de France" & year > 1786
	replace droit_eden_valorem = (droit_eden_value / value) if eden_classification == "Vin de France" & year > 1786
	
	
//////// Anciens droits
	replace droit_eden_value = (quantites_metric_eden * 9.55 * 25) / 20 if eden_classification == "Eau de vie de France" & year < 1786
	replace droit_eden_value = (quantites_metric_eden * 67.265 * 25) if eden_classification == "Vinaigre de France" & year < 1786
	replace droit_eden_value = (quantites_metric_eden * 96.2 * 25) if eden_classification == "Vin de France" & year < 1786
	
	
	replace droit_eden_valorem = (droit_eden_value / value) if eden_classification == "Eau de vie de France" & year < 1786
	replace droit_eden_valorem = (droit_eden_value / value) if eden_classification == "Vinaigre de France" & year < 1786
	replace droit_eden_valorem = (droit_eden_value / value) if eden_classification == "Vin de France" & year < 1786

	
		su droit_eden_valorem if eden_classification == "Vinaigre de France" & year < 1786
		su droit_eden_valorem if eden_classification == "Vinaigre de France" & year > 1786
		su droit_eden_valorem if eden_classification == "Eau de vie de France" & year < 1786
		su droit_eden_valorem if eden_classification == "Eau de vie de France" & year > 1786
		su droit_eden_valorem if eden_classification == "Vin de France" & year < 1786
		su droit_eden_valorem if eden_classification == "Vin de France" & year > 1786
	
