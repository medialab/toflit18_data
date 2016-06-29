**** MAJ Fichiers Units_N2 et _N3 pour prendre en compte la nouvelle classification des marchandises 
**** ATTENTION : Script déjà présent dans " Pour BDD courante et MAJ des unités de mesure "

if "`c(username)'"=="Corentin" global dir "/Users/Corentin/Desktop/script/Données Stata" 
cd "$dir"

use "bdd_marchandises_normalisees.dta", clear
	
	sort marchandises_normalisees

save "bdd_marchandises_normalisees.dta", replace

*

*** MAJ fichiers N2 

use "Units_N2.dta", clear

	sort marchandises_normalisees
	joinby marchandises_normalisees using "bdd_marchandises_normalisees.dta"
	drop product_prix	dutchtranslation	englishproduct	unit	alternativenames	source_rg_1774	source_rgbase	source_france	source_sound	source_hambourg	v14	v15	remarques	nbr_lignes_fr	nbr_lignes_hambourg	blok	marchandises_normalisees_inter

*

	merge m:1 marchandises using "bdd_revised_marchandises_normalisees_orthographique.dta"
	drop if _merge==2
	drop _merge

*
	
	merge m:1 marchandises_norm_ortho using "bdd_revised_marchandises_simplifiees.dta"
	drop if _merge==2
	drop _merge	
	
*


drop if marchandises_simplification==""

drop marchandises_normalisees
drop marchandises
drop marchandises_norm_ortho

bys quantity_unit marchandises_simplification : keep if _n==1


save "Units_N2_revised.dta", replace


*** MAJ fichiers N3

use "Units_N3.dta", clear

	sort marchandises_normalisees
	joinby marchandises_normalisees using "bdd_marchandises_normalisees.dta"
	drop product_prix	dutchtranslation	englishproduct	unit	alternativenames	source_rg_1774	source_rgbase	source_france	source_sound	source_hambourg	v14	v15	remarques	nbr_lignes_fr	nbr_lignes_hambourg	blok	marchandises_normalisees_inter

*

	merge m:m marchandises using "/Users/Corentin/Desktop/script/Données Stata/bdd_revised_marchandises_normalisees_orthographique.dta"
	drop if _merge==2
	drop _merge

*

	merge m:m marchandises_norm_ortho using "bdd_revised_marchandises_simplifiees.dta"
	drop if _merge==2
	drop _merge	

*

drop marchandises_normalisees
drop marchandises
drop marchandises_norm_ortho

bys quantity_unit marchandises_simplification exportsimports pays_grouping : keep if _n==1

save "Units_N3_revised.dta", replace



