* 1/ Création bdd médicale

cd "C:\Users\pierr\Documents\Toflit"

	import delimited "toflit18_data_GIT\base\bdd_marchandises_medicinales.csv",  encoding(UTF-8) clear varname(1) stringcols(_all)   

	foreach variable of var * {
		capture	replace `variable'  =usubinstr(`variable',"  "," ",.)
		capture	replace `variable'  =usubinstr(`variable',"  "," ",.)
		capture	replace `variable'  =usubinstr(`variable',"  "," ",.)
		capture	replace `variable'  =usubinstr(`variable',"…","...",.)
		capture replace `variable'  =usubinstr(`variable',"u","œ",.) 
		capture replace `variable'  =usubinstr(`variable'," "," ",.)/*Pour espace insécable*/
		replace `variable' =usubinstr(`variable',"’","'",.)
		capture	replace `variable'  =ustrtrim(`variable')
	}

	capture destring nbr*, replace float
	capture drop nbr_bdc* source_bdc
	sort marchandises_simplification
	drop sitc18_rev3 obsolete nbr_obs
	save "Données Stata/bdd_marchandises_medicinales.dta", replace
	
	
* 2/ On merge avec bdd centrale
use "Données Stata/bdd courante.dta", clear
sort marchandises_simplification
merge m:1 marchandises_simplification using "Données Stata/bdd_marchandises_medicinales.dta"
drop if _merge==2
drop _merge
replace value_as_reported = subinstr(value_as_reported, ",", ".",.) 
replace value_as_reported = subinstr(value_as_reported, " ", "",.) 
destring value_as_reported, replace
replace year=1787 if(year>1787&year<1788)
replace year=1805 if(year==1805.75)
save "Données Stata/bdd courante with medecine", replace

**** On peut commencer l'analyse

use "Données Stata/bdd courante with medecine.dta", clear

*************** GRAPHIQUE TOTAL IMPORT EXPORT EN VALEUR

	set more off
	keep if(exportsimports=="Imports"|exportsimports=="Importations")
	keep if(medical_classification=="narrow medical product")
	*drop if(sourcetype=="Divers"|sourcetype=="1792-both semester"|sourcetype=="1792-first semestre"|sourcetype=="National partenaires manquants")
	drop if(year==1787&sourcetype=="Résumé")
	drop if(year==1788&sourcetype=="Résumé")
	sort year
	collapse (sum) value_as_reported, by(year direction sourcetype)
	rename value_as_reported ImpTotal_Med
	sort year direction
	save "Données Stata/ImpTotal_Med.dta", replace

	
	use "Données Stata/bdd courante with medecine.dta", clear
	keep if(exportsimports=="Exports"|exportsimports=="Exportations")
	keep if(medical_classification=="narrow medical product")
	*drop if(sourcetype=="Divers"|sourcetype=="1792-both semester"|sourcetype=="1792-first semestre"|sourcetype=="National partenaires manquants")
	drop if(year==1787&sourcetype=="Résumé")
	drop if(year==1788&sourcetype=="Résumé")
	sort year
	collapse (sum) value_as_reported, by(year direction sourcetype)
	rename value_as_reported ExpTotal_Med
	sort year direction
	save "Données Stata/ExpTotal_Med.dta", replace

	use "Données Stata/ImpTotal_Med.dta", clear
	merge m:m year direction using "Données Stata/ExpTotal_Med.dta"
	drop _merge

	encode direction, gen(direction_enc)
	
	gen ln_ImpTotal_Med=ln(ImpTotal_Med)
	gen ln_ExpTotal_Med=ln(ExpTotal_Med)

	save "Données Stata/bdd_Import_Export.dta", replace

			use "Données Stata/bdd_Import_Export.dta", clear
			set more off
			regress ln_ImpTotal_Med i.year i.direction_enc
			outreg2 using Import.xls, replace ctitle(Import)
			outreg2 using EF.doc, replace ctitle(Import)
			parmest, saving("Données Stata/Excel/ImpTotal_Med.dta", replace)
			use "Données Stata/Excel/ImpTotal_Med.dta", clear
			keep parm estimate stderr
			rename estimate Import
			rename stderr stderrImport
			save "Données Stata/Excel/ImpTotal_Med.dta", replace
			export excel using "Données Stata/Excel/annee.xls", firstrow(variables) replace

			*supprimer dans le excel
			
import excel "Données Stata/Excel/annee.xls", sheet("Sheet1") firstrow clear
sort year
destring Import, replace
destring Stderr_Import, replace

reg Import year
outreg2 using Import.doc, replace ctitle(Import) addtext(Year FE, YES)

gen Import_moins=Import-Stderr_Import
gen Import_plus=Import+Stderr_Import

tsset year
twoway   (rarea Import_plus Import_moins year, color(gs7) fcolor(gs7)) (tsline Import, lcolor(gold)) (lfit Import year),/*
*/ xtitle("Years") ytitle("Regression Coefficients") title("Imported value") subtitle("1719-1839") scheme(s1color) /*
*/ legend(label(1 "Standard deviation") label(2 "Imported value per capita"))
graph export Import_value_4.emf , replace


*)

	
	