
***** NATIONAL
	keep if sourcetype == "Objet Général" | sourcetype == "Résumé"

	drop if sourcetype == "Résumé" & year == 1787 
	drop if sourcetype == "Résumé" & year == 1788
	drop if sourcetype == "Objet Général" & year > 1788
	drop if sourcetype == "Résumé" & year < 1787
/*
	replace eden_classification = "Coton_detoute_espèce" if eden_classification == "Coton de toute espèce"
	replace eden_classification = "Eau_de_vie_de_France" if eden_classification == "Eau de vie de France"
	replace eden_classification = "Glaces_et_verrerie" if eden_classification == "Glaces et Verrerie"
	replace eden_classification = "Huile_olive_de_France" if eden_classification == "Huile d'olive de France"
	replace eden_classification = "Porcelaine" if eden_classification == "Porcelaine, Fayance, Poterie"
	replace eden_classification = "batistes_et_linons" if eden_classification == "Toiles de batistes et linons"
	replace eden_classification = "lin_et_de_chanvre" if eden_classification == "Toiles de lin et de chanvre"
	replace eden_classification = "Vin_de_France" if eden_classification == "Vin de France"
	replace eden_classification = "Vinaigre_de_France" if eden_classification == "Vinaigre de France"


	
	*****
	keep if exportsimports == "Exports"	
	collapse (sum) value, by(year eden_classification) 	
	
	levelsof eden_classification, local(levels)
	foreach l of local levels {
		gen Exports_`l' = value if eden_classification == "`l'"
		twoway (connected Exports_`l' year)
		
		cd "/Users/Corentin/Documents/STAT/EdenTreaty/Sorties Valides/EdenNational/Focus/Exports"	
		graph export  Evolution_Balance_FocusPeriode_eden_classification_`l'.png, replace
	
	 }
	tab year
	
	
	
	
	****
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

***** LOCAL

set more off
keep if sourcetype == "National par direction"  | sourcetype == "Local"

replace direction = "La_Rochelle" if direction == "La Rochelle"
replace direction = "Saint-Malo" if direction == "Saint Malo"
replace direction = "Saint_Malo" if direction == "Saint-Malo"
collapse (sum) value , by(year direction)

levelsof direction, local(levels)
	foreach l of local levels {
	gen `l' = .
	replace `l' = value if direction == "`l'"
    }
keep if year == 1778

	foreach var of varlist Amiens Bayonne Bordeaux Caen La_Rochelle Lille Lorient Marseille Montpellier Nantes Passeports Rouen Saint_Malo Valenciennes {
	tab `var', gen(z`var')
	}

graph  pie z*




