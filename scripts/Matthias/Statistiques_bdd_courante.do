 * Principaux partenaires commerciaux de la France
 
 use "/Users/Matthias/Données Stata/bdd courante.dta", clear

 codebook grouping_classification
 tab grouping_classification
 keep if grouping_classification!=""
 bysort grouping_classification: gen nb_occurrences_partner=_N
 gen grouping_classification2=grouping_classification
 replace grouping_classification2="Autres" if nb_occurrences_partner<25000
 
 graph pie, over (grouping_classification2) ///
 plabel (_all percent, color(white) size (medlarge)) ///
 title (Partenaires commerciaux de la France)
 
 * Principales product échangées
 
 use "/Users/Matthias/Données Stata/bdd courante.dta", clear
 
 codebook orthographic_normalization_classification
 keep if orthographic_normalization_classification!=""
 bysort orthographic_normalization_classification: gen nb_occurrences_product=_N 
 keep if nb_occurrences_product>2000
 gsort +nb_occurrences_product 
 tab orthographic_normalization_classification 
 
 use "/Users/Matthias/Données Stata/bdd courante.dta", clear
 
 codebook simplification_classification
 keep if simplification_classification!=""
 bysort simplification_classification: gen nb_occurrences_product_S=_N 
 keep if nb_occurrences_product_S>2200
 gsort +nb_occurrences_product_S 
 tab simplification_classification
 
 
 * Principales unités utilisées
 
 use "/Users/Matthias/Données Stata/bdd courante.dta", clear
 
 merge m:1 quantity_unit using "/Users/Matthias/Données Stata/Units_Normalisation_Orthographique.dta"
 codebook quantity_unit_ortho
 keep if quantity_unit_ortho!=""
 bysort quantity_unit_ortho: gen nb_occurrences_unités=_N 
 keep if nb_occurrences_unités>10000
 tab quantity_unit_ortho
 
 * Unités métriques
  
 use "/Users/Matthias/Données Stata/bdd courante.dta", clear
 
 merge m:1 quantity_unit using "/Users/Matthias/Données Stata/Units_Normalisation_Orthographique.dta"
 drop _merge
 merge m:1 quantity_unit_ortho using "/Users/Matthias/Données Stata/Units_Normalisation_Métrique1.dta", force
 codebook quantity_unit_ajustees
 codebook u_conv
 tab u_conv, m
 
 * Principaux échanges avec l'Italie
 
  use "/Users/Matthias/Données Stata/bdd courante.dta", clear
  keep if grouping_classification=="Italie"
  keep if orthographic_normalization_classification!=""
  codebook orthographic_normalization_classification
  bysort orthographic_normalization_classification: gen nb_occurrences_product_I=_N 
  keep if nb_occurrences_product_I>400
  tab orthographic_normalization_classification

 * Année où les échanges sont les plus importants
 
 use "/Users/Matthias/Données Stata/bdd courante.dta", clear
 bysort year: gen nb_occurrences_year=_N
 keep if nb_occurrences_year>13000
 tab year
  
 * Pays davantage exportateur ou importateur ?
 
 use "/Users/Matthias/Données Stata/bdd courante.dta", clear
 tab export_import
 
 * Principale exportation
 
 use "/Users/Matthias/Données Stata/bdd courante.dta", clear
 keep if export_import=="Exports"
 bysort simplification_classification: gen nb_occurrences_product_Exp=_N 
 keep if nb_occurrences_product_Exp>2200
 gsort +nb_occurrences_product_Exp 
 tab simplification_classification
  
  
  
  
  
  
  
  
  
  
  
  
