**** MAJ Fichiers Units_N2 et _N3 pour prendre en compte la nouvelle classification des marchandises 
**** ATTENTION : Script déjà présent dans " Pour BDD courante et MAJ des unités de mesure "

if "`c(username)'"=="Corentin" global dir "/Users/Corentin/Desktop/script/Données Stata" 
cd "$dir"

*** MAJ fichiers N2 

use "/Users/Corentin/Desktop/script/Données Stata/Units_N2.dta", clear

	merge m:m marchandises_normalisees using "/Users/Corentin/Desktop/script/Données Stata/bdd_marchandises_normalisees.dta"
	drop if _merge==2
	drop _merge

save "/Users/Corentin/Desktop/script/Données Stata/Units_N2.dta", replace

*

use "/Users/Corentin/Desktop/script/Données Stata/Units_N2.dta", clear

	merge m:m marchandises using "/Users/Corentin/Desktop/script/Données Stata/bdd_revised_marchandises_normalisees_orthographique.dta"
	drop if _merge==2
	drop _merge

save "/Users/Corentin/Desktop/script/Données Stata/Units_N2.dta", replace

*

drop marchandises_normalisees
drop marchandises

sort quantity_unit marchandises_norm_ortho
quietly by quantity_unit marchandises_norm_ortho:  gen dup = cond(_N==1,0,_n)
drop if dup>1
drop dup

save "/Users/Corentin/Desktop/script/Données Stata/Units_N2.dta", replace


*** MAJ fichiers N3

use "/Users/Corentin/Desktop/script/Données Stata/Units_N3.dta", clear

	merge m:m marchandises_normalisees using "/Users/Corentin/Desktop/script/Données Stata/bdd_marchandises_normalisees.dta"
	drop if _merge==2
	drop _merge

save "/Users/Corentin/Desktop/script/Données Stata/Units_N3.dta", replace

*

use "/Users/Corentin/Desktop/script/Données Stata/Units_N3.dta", clear

	merge m:m marchandises using "/Users/Corentin/Desktop/script/Données Stata/bdd_revised_marchandises_normalisees_orthographique.dta"
	drop if _merge==2
	drop _merge

save "/Users/Corentin/Desktop/script/Données Stata/Units_N3.dta", replace

*

drop marchandises_normalisees
drop marchandises

sort quantity_unit marchandises_norm_ortho exportsimports pays_grouping
quietly by quantity_unit marchandises_normalisees exportsimports pays_grouping:  gen dup = cond(_N==1,0,_n)
drop if dup>1
drop dup

save "/Users/Corentin/Desktop/script/Données Stata/Units_N3.dta", replace



