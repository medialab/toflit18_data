 * Principaux partenaires commerciaux de la France
 
 use "/Users/Matthias/Données Stata/bdd courante.dta", clear

 codebook pays_grouping
 tab pays_grouping
 keep if pays_grouping!=""
 bysort pays_grouping: gen nb_occurrences_pays=_N
 gen pays_grouping2=pays_grouping
 replace pays_grouping2="Autres" if nb_occurrences_pays<25000
 
 graph pie, over (pays_grouping2) ///
 plabel (_all percent, color(white) size (medlarge)) ///
 title (Partenaires commerciaux de la France)
 
 * Principales marchandises échangées
 
 use "/Users/Matthias/Données Stata/bdd courante.dta", clear
 
 codebook marchandises_norm_ortho
 keep if marchandises_norm_ortho!=""
 bysort marchandises_norm_ortho: gen nb_occurrences_marchandises=_N 
 keep if nb_occurrences_marchandises>2000
 gsort +nb_occurrences_marchandises 
 tab marchandises_norm_ortho 
 
 use "/Users/Matthias/Données Stata/bdd courante.dta", clear
 
 codebook marchandises_simplification
 keep if marchandises_simplification!=""
 bysort marchandises_simplification: gen nb_occurrences_marchandises_S=_N 
 keep if nb_occurrences_marchandises_S>2200
 gsort +nb_occurrences_marchandises_S 
 tab marchandises_simplification
 
 
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
  keep if pays_grouping=="Italie"
  keep if marchandises_norm_ortho!=""
  codebook marchandises_norm_ortho
  bysort marchandises_norm_ortho: gen nb_occurrences_marchandises_I=_N 
  keep if nb_occurrences_marchandises_I>400
  tab marchandises_norm_ortho

 * Année où les échanges sont les plus importants
 
 use "/Users/Matthias/Données Stata/bdd courante.dta", clear
 bysort year: gen nb_occurrences_year=_N
 keep if nb_occurrences_year>13000
 tab year
  
 * Pays davantage exportateur ou importateur ?
 
 use "/Users/Matthias/Données Stata/bdd courante.dta", clear
 tab exportsimports
 
 * Principale exportation
 
 use "/Users/Matthias/Données Stata/bdd courante.dta", clear
 keep if exportsimports=="Exports"
 bysort marchandises_simplification: gen nb_occurrences_marchandises_Exp=_N 
 keep if nb_occurrences_marchandises_Exp>2200
 gsort +nb_occurrences_marchandises_Exp 
 tab marchandises_simplification
  
  
  
  
  
  
  
  
  
  
  
  
