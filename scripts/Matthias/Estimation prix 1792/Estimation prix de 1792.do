 clear all
 set maxvar 32767
 set matsize 11000
 use "/Users/Matthias/Données Stata/bdd courante.dta", clear
 keep if year==1789
 drop if value_unit==.
 drop if value_unit==0
 drop if quantity_unit==""
 drop if product=="Nom flou"
 gen lnPrix=ln(value_unit)
 gen product_et_quantités = simplification_classification + quantity_unit
 encode product_et_quantités, gen(product_et_quantités_num)
 bysort product_et_quantités_num: drop if _N<=1
 regress lnPrix i.product_et_quantités_num
 predict lnPrix_pred if e(sample)
 gen prix_predit = exp(lnPrix_pred)
 sort product_et_quantités
 bysort product_et_quantités: drop if _n>1
 keep product_et_quantités simplification_classification quantity_unit prix_predit
 save "/Users/Matthias/Données Stata/prix de 1789.dta", replace
 
 use "/Users/Matthias/Données Stata/bdd courante.dta", clear
 keep if year==1792
 keep if value==.
 gen product_et_quantités = simplification_classification + quantity_unit
 sort product_et_quantités
 merge m:1 product_et_quantités using "/Users/Matthias/Données Stata/prix de 1789.dta"
 keep product_et_quantités simplification_classification quantity_unit prix_predit u_conv q_conv
 export delimited using "/Users/Matthias/Données Stata/prix_1792.csv", replace	
 
 * Je complète à la main les données pouvant être complétées grâce aux unités conventionnelles 
 * -> je les mets dans la colonne prix_calculé
 * Par exemple, pour une même marchandise s'il y a les prix en livres je peux les avoir en quintaux
 
 use "/Users/Matthias/Données Stata/bdd courante.dta", clear
 keep if year==1792
 keep if value==.
 gen product_et_quantités = simplification_classification + quantity_unit
 sort product_et_quantités
 keep line_number filepath export_import year sheet product partner ///
      simplification_classification quantity value_unit quantity_unit u_conv q_conv ///
	  product_et_quantités
 export delimited using "/Users/Matthias/Données Stata/1792.csv", replace
 
 * J'organise le fichier de la même manière que celui des prix (ordre alphabétique product_et_quantités)
 * Je copie colle les colonnes prix_prédit et prix_calculé
 * Une fois cela effectué, j'ai donc obtenu un fichier avec les prix pour tous les flux sans valeur totale
 * Si ces estimations conviennent, je pourrai donc copier coller ces prix dans le fichier initial 1792 

