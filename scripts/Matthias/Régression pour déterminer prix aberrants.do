 * Sans utiliser les unités métriques
 
 clear all
 set maxvar 32767
 set matsize 11000
 use "/Users/Matthias/Données Stata/bdd courante.dta", clear
 drop if prix_unitaire==.
 drop if prix_unitaire==0
 gen lnPrix=ln(prix_unitaire)
 encode marchandises_simplification, gen(marchandises_simplification_num)
 bysort marchandises_simplification_num: drop if _N<=10
 encode pays_grouping, gen(pays_grouping_num)
 drop if year>1787 & year<1788
 drop if year==1805.75
 regress lnPrix i.marchandises_simplification_num i.year i.pays_grouping_num if exportsimports=="Imports"
 predict lnPrix_predImp if e(sample)
 gen résiduImp = lnPrix_predImp - lnPrix
 
 regress lnPrix i.marchandises_simplification_num i.year i.pays_grouping_num if exportsimports=="Exports"
 predict lnPrix_predExp if e(sample)
 gen résiduExp = lnPrix_predExp - lnPrix

 drop if abs(résiduImp)<10 & exportsimports=="Imports"
 drop if abs(résiduExp)<10 & exportsimports=="Exports"
 drop if résiduExp==. & résiduImp==.
 
 keep numrodeligne sourcepath exportsimports year sheet marchandises pays ///
 résiduImp résiduExp quantit prix_unitaire 
 
 export delimited using "/Users/Matthias/Données Stata/probleme_prix.csv", replace
 
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
 encode pays_grouping, gen(pays_grouping_num)
 drop if year>1787 & year<1788
 drop if year==1805.75
 regress lnPrix i.marchandises_simplification_num i.year i.pays_grouping_num if exportsimports=="Imports"
 predict lnPrix_predImp if e(sample)
 gen résiduImp = lnPrix_predImp - lnPrix
 
 regress lnPrix i.marchandises_simplification_num i.year i.pays_grouping_num if exportsimports=="Exports"
 predict lnPrix_predExp if e(sample)
 gen résiduExp = lnPrix_predExp - lnPrix

 drop if abs(résiduImp)<10 & exportsimports=="Imports"
 drop if abs(résiduExp)<10 & exportsimports=="Exports"
 drop if résiduExp==. & résiduImp==.
 
 keep numrodeligne sourcepath exportsimports year sheet marchandises pays ///
 résiduImp résiduExp prix_unitaire quantity_unit u_conv q_conv prix_conv
 
 export delimited using "/Users/Matthias/Données Stata/probleme_prix2.csv", replace
