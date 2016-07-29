*use "/Users/Corentin/Desktop/script/test.dta", clear
use "/Users/Corentin/Desktop/script/testVin.dta", clear

keep if pays_grouping == "Angleterre"

***** NATIONAL
	keep if sourcetype == "Objet Général" | sourcetype == "Résumé"| sourcetype == "Divers - in" | sourcetype == "National par direction"

	drop if sourcetype == "Résumé" & year == 1787 
	drop if sourcetype == "Résumé" & year == 1788
	drop if sourcetype == "Objet Général" & year > 1788
	drop if sourcetype == "Résumé" & year < 1787
	drop if sourcetype == "Résumé" & year == 1789

	replace eden_classification = "Coton_detoute_espèce" if eden_classification == "Coton de toute espèce"
	replace eden_classification = "Eau_de_vie_de_France" if eden_classification == "Eau de vie de France"
	replace eden_classification = "Glaces_et_verrerie" if eden_classification == "Glaces et Verrerie"
	replace eden_classification = "Huile_olive_de_France" if eden_classification == "Huile d'olive de France"
	replace eden_classification = "Porcelaine" if eden_classification == "Porcelaine, Fayance, Poterie"
	replace eden_classification = "batistes_et_linons" if eden_classification == "Toiles de batistes et linons"
	replace eden_classification = "lin_et_de_chanvre" if eden_classification == "Toiles de lin et de chanvre"
	replace eden_classification = "Vin_de_France" if eden_classification == "Vin de France"
	replace eden_classification = "Vinaigre_de_France" if eden_classification == "Vinaigre de France"

drop if value == 38455
drop if year < 1773
replace marchandises_simplification = "vin de Bordeaux" if marchandises_norm_ortho == "vin de Bordeaux"
keep if exportsimports == "Exports"

keep if eden_classification == "Eau_de_vie_de_France"
replace marchandises_simplification = "eau-de-vie de grain" if marchandises_simplification == "eau de grain"
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
	
	predict prixinvln2 if year ==  1771 | year == 1772 | year == 1773 | year == 1774 | year == 1775 | year == 1776 | year == 1777 | year == 1779 | year == 1780   |  year == 1782   |  year == 1787 | year == 1788 | year == 1789
	*predict prixinvln2 if year ==  1771 | year == 1772 | year == 1773 | year == 1774 | year == 1775 | year == 1776 | year == 1777 | year == 1779 | year == 1780   |  year == 1782 |  year == 1783 |  year == 1784   |  year == 1787 | year == 1788 | year == 1789
	
	gen prix_u_predict = 1 / exp(prixinvln2)
	sort year
	replace prix_u = prix_u_predict if prix_u == .
	drop if prix_u == .

	
*** simulation des value
	reg value i.year i.marchandises_simplification_c
	predict value2 
	replace value = value2 if value == .

	gen ln_quantites_metric_eden_predict = prixinvln2 + ln(value)
	gen quantites_metric_eden_predict = exp(ln_quantites_metric_eden_predict)
	replace quantites_metric_eden = quantites_metric_eden_predict if quantites_metric_eden == .


***

	/*
	*keep if marchandises_simplification == "eau-de-vie de genièvre"
	*keep if marchandises_simplification == "eau-de-vie de grain"
	*keep if marchandises_simplification == "eau-de-vie de vin"
	*keep if marchandises_simplification == "eau-de-vie double"

	**

*
graph twoway (connected prix_u year if marchandises_simplification == "eau et huile spiritueuse") (connected prix_u year if marchandises_simplification == "eau spiritueuse") (connected prix_u year if marchandises_simplification == "eau-de-vie") (connected prix_u year if marchandises_simplification == "eau-de-vie de genièvre") (connected prix_u year if marchandises_simplification == "eau-de-vie de grain") (connected prix_u year if marchandises_simplification == "eau-de-vie de vin") (connected prix_u year if marchandises_simplification == "eau-de-vie double") (connected prix_u year if marchandises_simplification == "eau-de-vie simple"), ylabel()
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
bysort year marchandises_simplification : egen totpXq = total(pXq)
by year marchandises_simplification : egen totq = total(quantites_metric_eden)
gen wavg = totpXq / totq
replace prix_u = wavg if wavg != . 
graph twoway (connected prix_u year if marchandises_simplification == "eau et huile spiritueuse") (connected prix_u year if marchandises_simplification == "eau spiritueuse") (connected prix_u year if marchandises_simplification == "eau-de-vie") (connected prix_u year if marchandises_simplification == "eau-de-vie de genièvre") (connected prix_u year if marchandises_simplification == "eau-de-vie de grain") (connected prix_u year if marchandises_simplification == "eau-de-vie de vin") (connected prix_u year if marchandises_simplification == "eau-de-vie double") (connected prix_u year if marchandises_simplification == "eau-de-vie simple"), ylabel()
*keep if year == 1788
*graph twoway (scatter quantites_metric_eden prix_u)
*graph twoway (scatter prix_u year)
