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
 bysort grouping_classification exportsimports year simplification_classification: egen somme_directions=sum(value)
 collapse (sum) value, by(year simplification_classification grouping_classification exportsimports somme_directions)
 gen lnValue=ln(value)
 encode simplification_classification, gen(simplification_classification_num)
 bysort simplification_classification_num: drop if _N<=10
 encode grouping_classification, gen(grouping_classification_num)
 drop if year>1787 & year<1788
 drop if year==1805.75
 regress lnValue i.simplification_classification_num i.year i.grouping_classification_num if exportsimports=="Imports"
 predict lnValue_predImp if e(sample)
 gen résiduImp = lnValue_predImp - lnValue
 * histogram résiduImp
 * count if abs(résiduImp)>8
 
 regress lnValue i.simplification_classification_num i.year i.grouping_classification_num if exportsimports=="Exports"
 predict lnValue_predExp if e(sample)
 gen résiduExp = lnValue_predExp - lnValue
 * histogram résiduExp
 * count if abs(résiduExp)>8
 
 merge 1:m year simplification_classification grouping_classification exportsimports using ///
 "/Users/Matthias/Données Stata/bdd courante.dta"
 drop if abs(résiduImp)<=8 & résiduExp==.
 drop if abs(résiduExp)<=8 & résiduImp==.
 drop if résiduExp==. & résiduImp==.
 
 keep numrodeligne sourcepath exportsimports year sheet marchandises pays ///
 résiduImp résiduExp
 
 export delimited using "/Users/Matthias/Données Stata/probleme_résidu.csv", replace
