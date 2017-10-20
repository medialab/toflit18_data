 clear all
 set maxvar 32767
 set matsize 11000
 use "/Users/Matthias/Données Stata/bdd courante.dta", clear
 keep if year==1789
 drop if prix_unitaire==.
 drop if prix_unitaire==0
 drop if quantity_unit==""
 drop if marchandises=="Nom flou"
 gen lnPrix=ln(prix_unitaire)
 gen marchandises_et_quantités = marchandises_simplification + quantity_unit
 encode marchandises_et_quantités, gen(marchandises_et_quantités_num)
 bysort marchandises_et_quantités_num: drop if _N<=1
 regress lnPrix i.marchandises_et_quantités_num
 predict lnPrix_pred if e(sample)
 gen prix_predit = exp(lnPrix_pred)
 sort marchandises_et_quantités
 bysort marchandises_et_quantités: drop if _n>1
 keep marchandises_et_quantités marchandises_simplification quantity_unit prix_predit
 save "/Users/Matthias/Données Stata/prix de 1789.dta", replace
 
 use "/Users/Matthias/Données Stata/bdd courante.dta", clear
 keep if year==1792
 keep if value==.
 gen marchandises_et_quantités = marchandises_simplification + quantity_unit
 sort marchandises_et_quantités
 merge m:1 marchandises_et_quantités using "/Users/Matthias/Données Stata/prix de 1789.dta"
 keep marchandises_et_quantités marchandises_simplification quantity_unit prix_predit u_conv q_conv
 export delimited using "/Users/Matthias/Données Stata/prix_1792.csv", replace	
 
 * Je complète à la main les données pouvant être complétées grâce aux unités conventionnelles 
 * -> je les mets dans la colonne prix_calculé
 * Par exemple, pour une même marchandise s'il y a les prix en livres je peux les avoir en quintaux
 
 use "/Users/Matthias/Données Stata/bdd courante.dta", clear
 keep if year==1792
 keep if value==.
 gen marchandises_et_quantités = marchandises_simplification + quantity_unit
 sort marchandises_et_quantités
 keep numrodeligne sourcepath exportsimports year sheet marchandises pays ///
      marchandises_simplification quantit prix_unitaire quantity_unit u_conv q_conv ///
	  marchandises_et_quantités
 export delimited using "/Users/Matthias/Données Stata/1792.csv", replace
 
 * J'organise le fichier de la même manière que celui des prix (ordre alphabétique marchandises_et_quantités)
 * Je copie colle les colonnes prix_prédit et prix_calculé
 * Une fois cela effectué, j'ai donc obtenu un fichier avec les prix pour tous les flux sans valeur totale
 * Si ces estimations conviennent, je pourrai donc copier coller ces prix dans le fichier initial 1792 

