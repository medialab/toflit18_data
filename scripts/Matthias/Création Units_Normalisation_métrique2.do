 use "/Users/Matthias/Données Stata/bdd courante.dta", clear
 merge m:1 quantity_unit using "/Users/Matthias/Données Stata/Units_Normalisation_Orthographique.dta"
 drop _merge
 merge m:1 quantity_unit_ortho using "/Users/Matthias/Données Stata/Units_Normalisation_Métrique1.dta"
 drop _merge
 keep if need_marchandises=="1" 
 keep marchandises_simplification quantity_unit_ortho quantity_unit_ajustees u_conv q_conv exportsimports pays_grouping
 order exportsimports pays_grouping marchandises_simplification quantity_unit_ortho quantity_unit_ajustees u_conv q_conv 
 drop if marchandises_simplification==""
 sort exportsimports quantity_unit_ortho marchandises_simplification
 bysort quantity_unit_ortho marchandises_simplification: keep if _n==1
 save "/Users/Matthias/Données Stata/Units_Normalisation_Métrique2.dta", replace
 export delimited "/Users/Matthias/Données Stata/Units_Normalisation_Métrique2.csv", replace
