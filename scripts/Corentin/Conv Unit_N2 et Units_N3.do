**** MAJ Fichiers Units_N2 et _N3 pour prendre en compte la nouvelle classification des product 
**** ATTENTION : Script déjà présent dans " Pour BDD courante et MAJ des unités de mesure "

if "`c(username)'"=="Corentin" global dir "/Users/Corentin/Desktop/script/Données Stata" 
cd "$dir"

use "bdd_product_normalisees.dta", clear
	
	sort product_normalisees

save "bdd_product_normalisees.dta", replace

*

*** MAJ fichiers N2 

use "Units_N2.dta", clear

	sort product_normalisees
	joinby product_normalisees using "bdd_product_normalisees.dta"
	drop product_prix	dutchtranslation	englishproduct	unit	alternativenames	source_rg_1774	source_rgbase	source_france	source_sound	source_hambourg	v14	v15	remarques	nbr_lignes_fr	nbr_lignes_hambourg	blok	product_normalisees_inter

*

	merge m:1 product using "bdd_revised_product_normalisees_orthographique.dta"
	drop if _merge==2
	drop _merge

*
	
	merge m:1 orthographic_normalization_classification using "bdd_revised_product_simplifiees.dta"
	drop if _merge==2
	drop _merge	
	
*


drop if simplification_classification==""

drop product_normalisees
drop product
drop orthographic_normalization_classification

bys quantity_unit simplification_classification : keep if _n==1


save "Units_N2_revised.dta", replace


*** MAJ fichiers N3

use "Units_N3.dta", clear

	sort product_normalisees
	joinby product_normalisees using "bdd_product_normalisees.dta"
	drop product_prix	dutchtranslation	englishproduct	unit	alternativenames	source_rg_1774	source_rgbase	source_france	source_sound	source_hambourg	v14	v15	remarques	nbr_lignes_fr	nbr_lignes_hambourg	blok	product_normalisees_inter

*

	merge m:m product using "/Users/Corentin/Desktop/script/Données Stata/bdd_revised_product_normalisees_orthographique.dta"
	drop if _merge==2
	drop _merge

*

	merge m:m orthographic_normalization_classification using "bdd_revised_product_simplifiees.dta"
	drop if _merge==2
	drop _merge	

*

drop product_normalisees
drop product
drop orthographic_normalization_classification

bys quantity_unit simplification_classification export_import grouping_classification : keep if _n==1

save "Units_N3_revised.dta", replace



