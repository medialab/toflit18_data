*use "/Users/Corentin/Desktop/script/test.dta", clear
use "/Users/Corentin/Desktop/script/testVin.dta", clear

keep if grouping_classification == "Angleterre"

***** NATIONAL
	keep if source_type == "Objet Général" | source_type == "Résumé"| source_type == "Divers - in" | source_type == "National par customs_region"

	drop if source_type == "Résumé" & year == 1787 
	drop if source_type == "Résumé" & year == 1788
	drop if source_type == "Objet Général" & year > 1788
	drop if source_type == "Résumé" & year < 1787
	drop if source_type == "Résumé" & year == 1789

	replace edentreaty_classification = "Coton_detoute_espèce" if edentreaty_classification == "Coton de toute espèce"
	replace edentreaty_classification = "Eau_de_vie_de_France" if edentreaty_classification == "Eau de vie de France"
	replace edentreaty_classification = "Glaces_et_verrerie" if edentreaty_classification == "Glaces et Verrerie"
	replace edentreaty_classification = "Huile_olive_de_France" if edentreaty_classification == "Huile d'olive de France"
	replace edentreaty_classification = "Porcelaine" if edentreaty_classification == "Porcelaine, Fayance, Poterie"
	replace edentreaty_classification = "batistes_et_linons" if edentreaty_classification == "Toiles de batistes et linons"
	replace edentreaty_classification = "lin_et_de_chanvre" if edentreaty_classification == "Toiles de lin et de chanvre"
	replace edentreaty_classification = "Vin_de_France" if edentreaty_classification == "Vin de France"
	replace edentreaty_classification = "Vinaigre_de_France" if edentreaty_classification == "Vinaigre de France"

drop if value == 38455
drop if year < 1773
replace simplification_classification = "vin de Bordeaux" if orthographic_normalization_classification == "vin de Bordeaux"
keep if export_import == "Exports"

keep if edentreaty_classification == "Eau_de_vie_de_France"
replace simplification_classification = "eau-de-vie de grain" if simplification_classification == "eau de grain"
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
	
	predict prixinvln2 if year ==  1771 | year == 1772 | year == 1773 | year == 1774 | year == 1775 | year == 1776 | year == 1777 | year == 1779 | year == 1780   |  year == 1782   |  year == 1787 | year == 1788 | year == 1789
	*predict prixinvln2 if year ==  1771 | year == 1772 | year == 1773 | year == 1774 | year == 1775 | year == 1776 | year == 1777 | year == 1779 | year == 1780   |  year == 1782 |  year == 1783 |  year == 1784   |  year == 1787 | year == 1788 | year == 1789
	
	gen prix_u_predict = 1 / exp(prixinvln2)
	sort year
	replace prix_u = prix_u_predict if prix_u == .
	drop if prix_u == .

	
*** simulation des value
	reg value i.year i.simplification_classification_c
	predict value2 
	replace value = value2 if value == .

	gen ln_quantites_metric_eden_predict = prixinvln2 + ln(value)
	gen quantites_metric_eden_predict = exp(ln_quantites_metric_eden_predict)
	replace quantites_metric_eden = quantites_metric_eden_predict if quantites_metric_eden == .


***

	/*
	*keep if simplification_classification == "eau-de-vie de genièvre"
	*keep if simplification_classification == "eau-de-vie de grain"
	*keep if simplification_classification == "eau-de-vie de vin"
	*keep if simplification_classification == "eau-de-vie double"

	**

*
graph twoway (connected prix_u year if simplification_classification == "eau et huile spiritueuse") (connected prix_u year if simplification_classification == "eau spiritueuse") (connected prix_u year if simplification_classification == "eau-de-vie") (connected prix_u year if simplification_classification == "eau-de-vie de genièvre") (connected prix_u year if simplification_classification == "eau-de-vie de grain") (connected prix_u year if simplification_classification == "eau-de-vie de vin") (connected prix_u year if simplification_classification == "eau-de-vie double") (connected prix_u year if simplification_classification == "eau-de-vie simple"), ylabel()
graph rename prix_u, replace

****
*/

gen pXq = prix_u * quantites_metric_eden
bysort year: egen totpXq = total(pXq)
by year: egen totq = total(quantites_metric_eden)
gen wavg = totpXq / totq
replace prix_u = wavg if wavg != .


graph twoway (connected prix_u year)



/*
gen pXq = prix_u * quantites_metric_eden
bysort year simplification_classification : egen totpXq = total(pXq)
by year simplification_classification : egen totq = total(quantites_metric_eden)
gen wavg = totpXq / totq
replace prix_u = wavg if wavg != . 
graph twoway (connected prix_u year if simplification_classification == "eau et huile spiritueuse") (connected prix_u year if simplification_classification == "eau spiritueuse") (connected prix_u year if simplification_classification == "eau-de-vie") (connected prix_u year if simplification_classification == "eau-de-vie de genièvre") (connected prix_u year if simplification_classification == "eau-de-vie de grain") (connected prix_u year if simplification_classification == "eau-de-vie de vin") (connected prix_u year if simplification_classification == "eau-de-vie double") (connected prix_u year if simplification_classification == "eau-de-vie simple"), ylabel()
*keep if year == 1788
*graph twoway (scatter quantites_metric_eden prix_u)
*graph twoway (scatter prix_u year)
