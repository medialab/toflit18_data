 clear all
 set maxvar 32767
 set matsize 11000
 use "/Users/Matthias/Données Stata/bdd courante.dta", clear
 drop if sourcetype=="1792-both semester"
 drop if sourcetype=="1792-first semester" 
 drop if sourcetype=="Colonies"
 drop if sourcetype=="Divers"
 drop if sourcetype=="Divers - in"
 drop if sourcetype=="Local"
 drop if sourcetype=="Tableau Général"
 bysort pays_grouping exportsimports year marchandises_simplification: egen somme_directions=sum(value)
 collapse (sum) value, by(year marchandises_simplification pays_grouping exportsimports somme_directions)
 gen lnValue=ln(value)
 encode marchandises_simplification, gen(marchandises_simplification_num)
 bysort marchandises_simplification_num: drop if _N<=10
 encode pays_grouping, gen(pays_grouping_num)
 drop if year>1787 & year<1788
 drop if year==1805.75
 regress lnValue i.marchandises_simplification_num i.year i.pays_grouping_num if exportsimports=="Imports"
 predict lnValue_predImp
 gen résiduImp = lnValue_predImp - lnValue
 histogram résiduImp
 drop if résiduImp==.
 count if abs(résiduImp)>8
 
 regress lnValue i.marchandises_simplification_num i.year i.pays_grouping_num if exportsimports=="Exports"
 predict lnValue_predExp
 gen résiduExp = lnValue_predExp - lnValue
 histogram résiduExp
 drop if résiduExp==.
 count if abs(résiduExp)>8
 
 gen résidu=résiduExp
 replace résidu=résiduImp if exportsimports=="Imports"
 
 gen résidu_élevé = 1 if abs(résidu)>8
 
 merge 1:m year marchandises_simplification pays_grouping exportsimports using ///
 "/Users/Matthias/Données Stata/bdd courante.dta"
 keep if résidu_élevé==1
 
 drop résiduImp résiduExp résidu
 
 export delimited using "/Users/Matthias/Données Stata/probleme_résidu.csv", replace
