
****To get Ulrich's data

use "/Users/guillaumedaudin/Documents/Recherche/Commerce International Français XVIIIe.xls/Balance du commerce/Retranscriptions_Commerce_France/Données Stata/bdd courante.dta", clear

format value %-15.2fc
format quantites_metric %-15.2fc

keep if grouping =="Allemagne" | grouping=="Nord"
drop if ulrich_classification=="out"

export delimited using "/Users/guillaumedaudin/Documents/Recherche/Commerce International Français XVIIIe.xls/Balance du commerce/Retranscriptions_Commerce_France/Données Stata/Ulrich.csv", replace


