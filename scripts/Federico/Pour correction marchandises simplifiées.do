

version 14

**pour mettre les bases dans stata + mettre à jour les .csv
** version 2 : pour travailler avec la nouvelle organisation

global dir "/Users/guillaumedaudin/Documents/Recherche/Commerce International Français XVIIIe.xls/Balance du commerce/Retranscriptions_Commerce_France"
cd "$dir"
capture log using "`c(current_time)' `c(current_date)'"


use "Données Stata/bdd_revised_product_simplifiees.dta", clear


rename orthographic_normalization_classification orthographic_normalization_classification_old

rename  simplification_classification orthographic_normalization_classification

merge m:1 orthographic_normalization_classification using "Données Stata/bdd_revised_product_simplifiees.dta"

drop simplification_classification
rename orthographic_normalization_classification simplification_classification
rename orthographic_normalization_classification_old orthographic_normalization_classification
bys orthographic_normalization_classification : keep if _n==1


tabulate _merge
drop if _merge==2
rename _merge PasdansNormOrtho
replace PasdansNormOrtho=0 if PasdansNormOrtho==3

*bys simplification_classification: replace simplification_classification = orthographic_normalization_classification if _N==1
*bys simplification_classification: replace PasdansNormOrtho = 0 if _N==1

export delimited "Données Stata/bdd_revised_BIS_product_simplifiees.csv", replace



 
