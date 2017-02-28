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
 keep marchandises_et_quantités marchandises_simplification quantity_unit prix_predit
 export delimited using "/Users/Matthias/Données Stata/prix_1792.csv", replace	
 
 /*
 
 use "/Users/Matthias/Données Stata/bdd courante.dta", clear
 keep if year==1792
 sort marchandises quantity_unit
 merge 1:1 marchandises quantity_unit using "/Users/Matthias/Données Stata/prix de 1789.dta"
 sort sourcepath numrodeligne
 keep numrodeligne sourcepath exportsimports year sheet marchandises pays ///
      quantit prix_unitaire quantity_unit prix_predit
 export delimited using "/Users/Matthias/Données Stata/1792.csv", replace
