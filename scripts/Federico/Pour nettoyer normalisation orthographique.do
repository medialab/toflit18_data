

version 14

**pour mettre les bases dans stata + mettre à jour les .csv
** version 2 : pour travailler avec la nouvelle organisation

global dir "/Users/guillaumedaudin/Documents/Recherche/Commerce International Français XVIIIe.xls/Balance du commerce/Retranscriptions_Commerce_France"
cd "$dir"



foreach file in Hambourg/BDD_Hambourg_21_juillet_2014 Sound/BDD_SUND_FR Belgique/RG_1774 Belgique/RG_base  {

	import delimited "toflit18_data_GIT/foreign_sources/`file'.csv",  encoding(UTF-8) clear varname(1) stringcols(_all)   

	foreach variable of var * {
		capture	replace `variable'  =usubinstr(`variable',"  "," ",.)
		capture	replace `variable'  =usubinstr(`variable',"  "," ",.)
		capture	replace `variable'  =usubinstr(`variable',"  "," ",.)
		capture	replace `variable'  =usubinstr(`variable',"…","...",.)
		capture replace `variable'  =usubinstr(`variable'," "," ",.)/*Pour espace insécable*/
		replace `variable' =usubinstr(`variable',"’","'",.)
		capture	replace `variable'  =ustrtrim(`variable')
	}

	capture destring nbr*, replace float
	capture drop nbr_bdc* source_bdc
	save "Données Stata/`file'.dta", replace
 
}





cd "$dir/Données Stata"


*************Marchandises


use "bdd_revised_marchandises_normalisees_orthographique.dta", replace
bys marchandises : drop if _n!=1
generate keep=0

foreach file in bdd_centrale Hambourg/BDD_Hambourg_21_juillet_2014 Sound/BDD_SUND_FR Belgique/RG_1774 Belgique/RG_base  {
	merge 1:m marchandises using "`file'.dta"
	replace keep = 1 if _merge==3
	drop _merge
	bys marchandises : drop if _n!=1
	keep keep marchandises orthographic_normalization_classification mériteplusdetravail
}

drop if keep==0
drop keep

save "bdd_revised_marchandises_normalisees_orthographique.dta", replace



cd "$dir"
export delimited "toflit18_data_GIT/base/bdd_revised_marchandises_normalisees_orthographique.csv", replace
