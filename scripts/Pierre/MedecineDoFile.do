* 1/ Création bdd médicale

cd "C:\Users\pierr\Documents\Toflit"

	import delimited "toflit18_data_GIT\base\bdd_product_medicinales.csv",  encoding(UTF-8) clear varname(1) stringcols(_all)   

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
	sort simplification_classification
	drop sitc_classification obsolete nbr_obs
	save "Données Stata/bdd_product_medicinales.dta", replace
	
	
* 2/ On merge avec bdd centrale
use "Données Stata/bdd courante.dta", clear
sort simplification_classification
merge m:1 simplification_classification using "Données Stata/bdd_product_medicinales.dta"
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
	keep if(export_import=="Imports"|export_import=="Importations")
	keep if(medicinales_classification=="narrow medical product")
	*drop if(source_type=="Divers"|source_type=="1792-both semester"|source_type=="1792-first semestre"|source_type=="National partenaires manquants")
	drop if(year==1787&source_type=="Résumé")
	drop if(year==1788&source_type=="Résumé")
	sort year
	collapse (sum) value_as_reported, by(year customs_region source_type)
	rename value_as_reported ImpTotal_Med
	sort year customs_region
	save "Données Stata/ImpTotal_Med.dta", replace

	
	use "Données Stata/bdd courante with medecine.dta", clear
	keep if(export_import=="Exports"|export_import=="Exportations")
	keep if(medicinales_classification=="narrow medical product")
	*drop if(source_type=="Divers"|source_type=="1792-both semester"|source_type=="1792-first semestre"|source_type=="National partenaires manquants")
	drop if(year==1787&source_type=="Résumé")
	drop if(year==1788&source_type=="Résumé")
	sort year
	collapse (sum) value_as_reported, by(year customs_region source_type)
	rename value_as_reported ExpTotal_Med
	sort year customs_region
	save "Données Stata/ExpTotal_Med.dta", replace

	use "Données Stata/ImpTotal_Med.dta", clear
	merge m:m year customs_region using "Données Stata/ExpTotal_Med.dta"
	drop _merge

	encode customs_region, gen(customs_region_enc)
	
	gen ln_ImpTotal_Med=ln(ImpTotal_Med)
	gen ln_ExpTotal_Med=ln(ExpTotal_Med)

	save "Données Stata/bdd_Import_Export.dta", replace

			use "Données Stata/bdd_Import_Export.dta", clear
			set more off
			regress ln_ImpTotal_Med i.year i.customs_region_enc
			predict predicted_lnImpTotal_Med
			reg predicted_lnImpTotal_Med year i.customs_region_enc
			
			
			
			/*margins, dydx(year) post
			estimates save mymodel, replace
			estimates use mymodel
			matrix coeff_year = r(b)
			ereturn post coeff_year 
			matrix coeff_stdyear = r(c)
			ereturn post coeff_stdyear
			ereturn display

			parmest, saving("Données Stata/Excel/ImpTotal_Med.dta", replace)
			use "Données Stata/Excel/ImpTotal_Med.dta", clear

			
			*** RE, à voir dans la formule de regress --> rechercher
			*** predict pour prédire le commerce français.
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
			*/
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

	
	