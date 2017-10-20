 * Sans utiliser les unités métriques
 
 clear all
 set maxvar 32767
 set matsize 11000
 use "/Users/Matthias/Données Stata/bdd courante.dta", clear
 drop if prix_unitaire==.
 drop if prix_unitaire==0
 keep if u_conv==""
 drop if quantit==.
 drop if quantity_unit==""
 gen lnPrix=ln(prix_unitaire)
 encode marchandises_simplification, gen(marchandises_simplification_num)
 bysort marchandises_simplification_num: drop if _N<=10
 encode quantity_unit, gen(quantity_unit_num)
 bysort quantity_unit_num: drop if _N<=10
 gen marchandises_et_quantités = marchandises_simplification + quantity_unit
 encode marchandises_et_quantités, gen(marchandises_et_quantités_num)
 bysort marchandises_et_quantités_num: drop if _N<=10
 drop if year>1787 & year<1788
 drop if year==1805.75
 regress lnPrix i.marchandises_et_quantités_num i.year if exportsimports=="Imports"
 predict lnPrix_predImp if e(sample)
 gen résiduImp = lnPrix_predImp - lnPrix
 
 regress lnPrix i.marchandises_et_quantités_num i.year if exportsimports=="Exports"
 predict lnPrix_predExp if e(sample)
 gen résiduExp = lnPrix_predExp - lnPrix

 drop if abs(résiduImp)<1.5 & exportsimports=="Imports"
 drop if abs(résiduImp)>2 & exportsimports=="Imports" 
 drop if abs(résiduExp)<1.5 & exportsimports=="Exports"
 drop if abs(résiduExp)>2 & exportsimports=="Exports"
 drop if résiduExp==. & résiduImp==.
 
 gen ln_prix_pred = lnPrix_predImp if exportsimports=="Imports"
 replace ln_prix_pred = lnPrix_predExp if exportsimports=="Exports"
 gen prix_predit = exp(ln_prix_pred)
 
 drop if doubleaccounts==1
 drop if doubleaccounts==2
 drop if doubleaccounts==3
 
 keep numrodeligne sourcepath exportsimports year sheet marchandises pays ///
      résiduImp résiduExp quantit prix_unitaire quantity_unit prix_predit
 
 sort sourcepath numrodeligne
 export delimited using "/Users/Matthias/Données Stata/probleme_prix.csv", replace
 save "/Users/Matthias/Données Stata/probleme_prix.dta", replace
 
 * En utilisant les unités métriques
 
 clear all
 set maxvar 32767
 set matsize 11000
 use "/Users/Matthias/Données Stata/bdd courante.dta", clear
 drop if u_conv=="."
 drop if q_conv==0
 drop if q_conv==.
 drop if prix_unitaire==.
 drop if prix_unitaire==0
 gen prix_conv=prix_unitaire/q_conv
 gen lnPrix=ln(prix_conv)
 encode marchandises_simplification, gen(marchandises_simplification_num)
 bysort marchandises_simplification_num: drop if _N<=10
 gen marchandises_et_unités = marchandises_simplification + u_conv
 encode marchandises_et_unités, gen(marchandises_et_unités_num)
 bysort marchandises_et_unités_num: drop if _N<=10
 drop if year>1787 & year<1788
 drop if year==1805.75
 regress lnPrix i.marchandises_et_unités_num i.year if exportsimports=="Imports"
 predict lnPrix_predImp if e(sample)
 gen résiduImp = lnPrix_predImp - lnPrix
 
 regress lnPrix i.marchandises_et_unités_num i.year if exportsimports=="Exports"
 predict lnPrix_predExp if e(sample)
 gen résiduExp = lnPrix_predExp - lnPrix

 drop if abs(résiduImp)<2 & exportsimports=="Imports"
 drop if abs(résiduExp)<2 & exportsimports=="Exports"
 drop if résiduExp==. & résiduImp==.
 
 gen ln_prix_pred = lnPrix_predImp if exportsimports=="Imports"
 replace ln_prix_pred = lnPrix_predExp if exportsimports=="Exports"
 gen prix_conv_pred = exp(ln_prix_pred)
 gen prix_pred = prix_conv_pred*q_conv
 
 drop if doubleaccounts==1
 drop if doubleaccounts==2
 drop if doubleaccounts==3
 
 keep numrodeligne sourcepath sourcetype direction exportsimports year sheet marchandises pays ///
	  résiduImp résiduExp prix_unitaire quantity_unit u_conv q_conv prix_conv_pred prix_pred
 
 sort sourcepath numrodeligne
 export delimited using "/Users/Matthias/Données Stata/probleme_prix2.csv", replace
 save "/Users/Matthias/Données Stata/probleme_prix2.dta", replace
 
 
 use "/Users/Matthias/Données Stata/probleme_prix2.dta", clear
 drop if abs(résiduImp)<2.5 & exportsimports=="Imports"
 drop if abs(résiduExp)<2.5 & exportsimports=="Exports"
 keep if sourcetype=="Local"
 keep if direction=="Bordeaux"
 sort exportsimports year numrodeligne
 export delimited using "/Users/Matthias/Données Stata/probleme_prix3.csv", replace
 
 list prix_unitaire quantity_unit if strmatch(marchandises_norm_ortho,"**")

