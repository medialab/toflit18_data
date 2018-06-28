 use "/Users/Matthias/Données Stata/bdd courante.dta", clear
 merge m:1 quantity_unit using "/Users/Matthias/Données Stata/Units_Normalisation_Orthographique.dta"
 drop _merge
 merge m:1 quantity_unit_ortho using "/Users/Matthias/Données Stata/Units_Normalisation_Métrique1.dta"
 drop _merge
 keep if need_marchandises=="1" 
 keep simplification_classification quantity_unit_ortho quantity_unit_ajustees u_conv q_conv exportsimports grouping_classification
 order exportsimports grouping_classification simplification_classification quantity_unit_ortho quantity_unit_ajustees u_conv q_conv 
 drop if simplification_classification==""
 sort exportsimports quantity_unit_ortho simplification_classification
 bysort quantity_unit_ortho simplification_classification: keep if _n==1
 save "/Users/Matthias/Données Stata/Units_Normalisation_Métrique2.dta", replace
 export delimited "/Users/Matthias/Données Stata/Units_Normalisation_Métrique2.csv", replace
