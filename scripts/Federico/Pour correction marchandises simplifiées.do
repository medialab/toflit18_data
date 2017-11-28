

version 14

**pour mettre les bases dans stata + mettre à jour les .csv
** version 2 : pour travailler avec la nouvelle organisation

global dir "/Users/guillaumedaudin/Documents/Recherche/Commerce International Français XVIIIe.xls/Balance du commerce/Retranscriptions_Commerce_France"
cd "$dir"
capture log using "`c(current_time)' `c(current_date)'"


use "Données Stata/bdd_revised_marchandises_simplifiees.dta", clear


rename marchandises_norm_ortho marchandises_norm_ortho_old

rename  marchandises_simplification marchandises_norm_ortho

merge m:1 marchandises_norm_ortho using "Données Stata/bdd_revised_marchandises_simplifiees.dta"

drop marchandises_simplification
rename marchandises_norm_ortho marchandises_simplification
rename marchandises_norm_ortho_old marchandises_norm_ortho
bys marchandises_norm_ortho : keep if _n==1


tabulate _merge
drop if _merge==2
rename _merge PasdansNormOrtho
replace PasdansNormOrtho=0 if PasdansNormOrtho==3

*bys marchandises_simplification: replace marchandises_simplification = marchandises_norm_ortho if _N==1
*bys marchandises_simplification: replace PasdansNormOrtho = 0 if _N==1

export delimited "Données Stata/bdd_revised_BIS_marchandises_simplifiees.csv", replace



 
