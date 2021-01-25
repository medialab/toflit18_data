* A/ Principales unités utilisées

* 1/  Unités présentes dans les sources

 use "/Users/Matthias/Données Stata/bdd courante.dta", clear
  codebook quantity_unit, m
  bysort quantity_unit: gen nb_occurrences_unit=_N 
  keep if nb_occurrences_unit>10000
  codebook quantity_unit, m 
  tab quantity_unit, m sort 
  
* 2/ Unités normalisées orthographiquement 
  
 use "/Users/Matthias/Données Stata/bdd courante.dta", clear 
 merge m:1 quantity_unit using "/Users/Matthias/Données Stata/Units_Normalisation_Orthographique.dta"
  codebook quantity_unit_ortho
  replace quantity_unit_ortho="unité manquante" if quantity_unit==""
  bysort quantity_unit_ortho: gen nb_occurrences_unités=_N 
  keep if nb_occurrences_unités>10000
  tab quantity_unit_ortho, m sort
 
* 3-4/ Unités ajustées et conventionnelles
 
 use "/Users/Matthias/Données Stata/bdd courante.dta", clear
 merge m:1 quantity_unit using "/Users/Matthias/Données Stata/Units_Normalisation_Orthographique.dta"
 drop _merge
 replace quantity_unit_ortho="unité manquante" if quantity_unit==""
 merge m:1 quantity_unit_ortho using "/Users/Matthias/Données Stata/Units_Normalisation_Métrique1.dta"
 replace u_conv="unité manquante" if quantity_unit_ortho=="unité manquante"
 * codebook quantity_unit_ajustees
 * tab quantity_unit_ajustees, m sort
 codebook u_conv
 tab u_conv, m sort
 
* 5/ Principales unités utilisées selon les product (catégories SITC)
 
 use "/Users/Matthias/Données Stata/bdd courante.dta", clear
 merge m:1 quantity_unit using "/Users/Matthias/Données Stata/Units_Normalisation_Orthographique.dta"
 drop _merge
 replace quantity_unit_ortho="unité manquante" if quantity_unit==""
 merge m:1 quantity_unit_ortho using "/Users/Matthias/Données Stata/Units_Normalisation_Métrique1.dta"
 replace u_conv="unité manquante" if quantity_unit_ortho=="unité manquante"
 codebook sitc_classification
 tab sitc_classification u_conv, m
 
* 6/ Principales unités utilisées selon les différents ports
 
 use "/Users/Matthias/Données Stata/bdd courante.dta", clear
 merge m:1 quantity_unit using "/Users/Matthias/Données Stata/Units_Normalisation_Orthographique.dta"
 drop _merge
 replace quantity_unit_ortho="unité manquante" if quantity_unit==""
 merge m:1 quantity_unit_ortho using "/Users/Matthias/Données Stata/Units_Normalisation_Métrique1.dta"
 replace u_conv="unité manquante" if quantity_unit_ortho=="unité manquante"
 codebook customs_region
 bysort customs_region: gen nb_occurrences_customs_region=_N 
 keep if nb_occurrences_customs_region>1000
 tab customs_region u_conv, m
