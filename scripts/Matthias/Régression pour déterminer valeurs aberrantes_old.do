 clear all
 set maxvar 32767
 set matsize 11000
 use "/Users/Matthias/Données Stata/bdd courante.dta", clear
 drop if source_type=="1792-both semester"
 drop if source_type=="1792-first semester" 
 drop if source_type=="Colonies"
 drop if source_type=="Divers"
 drop if source_type=="Divers - in"
 drop if source_type=="Local"
 drop if source_type=="Tableau Général"
 bysort grouping_classification export_import year simplification_classification: egen somme_tax_departments=sum(value)
 collapse (sum) value, by(year simplification_classification grouping_classification export_import somme_tax_departments)
 gen lnValue=ln(value)
 encode simplification_classification, gen(simplification_classification_num)
 bysort simplification_classification_num: drop if _N<=10
 encode grouping_classification, gen(grouping_classification_num)
 drop if year>1787 & year<1788
 drop if year==1805.75
 regress lnValue i.simplification_classification_num i.year i.grouping_classification_num if export_import=="Imports"
 predict lnValue_predImp if e(sample)
 gen résiduImp = lnValue_predImp - lnValue
 * histogram résiduImp
 * count if abs(résiduImp)>8
 
 regress lnValue i.simplification_classification_num i.year i.grouping_classification_num if export_import=="Exports"
 predict lnValue_predExp if e(sample)
 gen résiduExp = lnValue_predExp - lnValue
 * histogram résiduExp
 * count if abs(résiduExp)>8
 
 merge 1:m year simplification_classification grouping_classification export_import using ///
 "/Users/Matthias/Données Stata/bdd courante.dta"
 drop if abs(résiduImp)<=8 & résiduExp==.
 drop if abs(résiduExp)<=8 & résiduImp==.
 drop if résiduExp==. & résiduImp==.
 
 keep line_number filepath export_import year sheet product partner ///
 résiduImp résiduExp
 
 export delimited using "/Users/Matthias/Données Stata/probleme_résidu.csv", replace
