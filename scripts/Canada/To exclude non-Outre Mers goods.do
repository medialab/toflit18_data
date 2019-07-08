
****In simplification, excluding goods that cannot come at all from Canada thanks to their origin

use "/Users/guillaumedaudin/Documents/Recherche/Commerce International Français XVIIIe.xls/Balance du commerce/Retranscriptions_Commerce_France/Données Stata/bdd courante.dta", clear

format value %-15.2fc
format quantities_metric %-15.2fc

**Ici je ne prends que parmi les partenaires présents avant 1765
drop surement_pas_canada
gen surement_pas_canada=1

tab country_simplification if year <=1765

replace surement_pas_canada=0 if exportsimports == "Imports"  &  ( ///
		country_simplification == "Îles françaises de l'Amérique" | ///
		country_simplification == "Îles françaises" | ///
		country_simplification == "Îles de l'Amérique" | ///
		country_simplification == "Îles" | ///
		country_simplification == "Louisiane" | ///
		country_simplification == "Indes" | ///
		country_simplification == "Barbarie dans l'Océan et Îles françaises d'Amérique")
		
collapse (min) surement_pas_canada, by(product_simplification)

rename product_simplification simplification
merge 1:1 simplification using "/Users/guillaumedaudin/Documents/Recherche/Commerce International Français XVIIIe.xls/Balance du commerce/Retranscriptions_Commerce_France/Données Stata/classification_product_canada.dta", force

replace canada = "Pas importé en France depuis l'Atlantique avant 1765" if _merge==2
drop _merge
replace canada = "Pas importé en France depuis l'Atlantique avant 1765" if surement_pas_canada==1

replace canada="Peut-être Canada" if canada=="Peut être Canada"

sort simplification

export delimited using "/Users/guillaumedaudin/Documents/Recherche/Commerce International Français XVIIIe.xls/Balance du commerce/Retranscriptions_Commerce_France/toflit18_data_GIT/base/classification_product_canada.csv", replace


		
		
