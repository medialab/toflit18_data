

 version 14.0

 
**pour mettre les bases dans stata + mettre à jour les .csv
** version 2 : pour travailler avec la nouvelle organisation

global dir "~/Documents/Recherche/Commerce International Français XVIIIe.xls/Balance du commerce/Retranscriptions_Commerce_France"

if "`c(username)'"=="Matthias" global dir "/Users/Matthias/"

if "`c(username)'"=="Tirindelli" global dir "/Users/Tirindelli/Google Drive/ETE/Thesis"

if "`c(username)'"=="federico.donofrio" global dir "C:\Users\federico.donofrio\Documents\GitHub"

cd "$dir"



foreach file in classification_country_orthographic_normalization classification_country_simplification classification_country_grouping /*
*/				 classification_country_obrien /*
*/               orthographic_normalization_classification bdd_product_simplification /*
*/				 /*Units_N1 Units_N2 Units_N3*/  bdd_product_edentreaty bdd_product_NorthAmerica /*
*/				 bdd_product_medicinales bdd_product_hamburg bdd_product_grains /*
*/ 				 bdd_product_sitc  bdd_tax_departments bdd_product_sitc_FR bdd_product_sitc_EN /* 
*/ 				 Units_Normalisation_Orthographique Units_Normalisation_Metrique1 Units_Normalisation_Metrique2 /*
*/				 bdd_origin	{

	import delimited "toflit18_data_GIT/base/`file'.csv",  encoding(UTF-8) clear varname(1) stringcols(_all)   

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
	save "Données Stata/`file'.dta", replace
 
}

use "Données Stata/Units_N1.dta", clear
destring q_conv, replace
save "Données Stata/Units_N1.dta", replace

use "Données Stata/Units_Normalisation_Metrique1.dta", clear
destring q_conv, replace
save "Données Stata/Units_Normalisation_Metrique1.dta", replace

use "Données Stata/Units_Normalisation_Metrique2.dta", clear
destring q_conv, replace
save "Données Stata/Units_Normalisation_Metrique2.dta", replace

/*

foreach file in travail_sitcrev3 sitc18_simpl {

	import delimited "toflit18_data_GIT/traitements_product/SITC/`file'.csv",  encoding(UTF-8) clear varname(1) stringcols(_all)   

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
		save "Données Stata/`file'.dta", replace
}
*/		
		
import delimited "toflit18_data_GIT/traitements_product/SITC/Définitions sitc_classification.csv",  encoding(UTF-8) clear varname(1) stringcols(_all)   

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
	save "Données Stata/Définitions sitc_classification.dta", replace
	
	
	
	
	
	
	

 *(juste parce que c'est trop long)


import delimited "toflit18_data_GIT/base/bdd_centrale.csv",  encoding(UTF-8) clear varname(1) stringcols(_all)  
foreach variable of var product partner quantity_unit {
	replace `variable'  =usubinstr(`variable',"  "," ",.)
	replace `variable'  =usubinstr(`variable',"  "," ",.)
	replace `variable'  =usubinstr(`variable',"  "," ",.)
	replace `variable'  =usubinstr(`variable',"…","...",.)
	replace `variable'  =usubinstr(`variable',"u","œ",.)
	replace `variable'  =usubinstr(`variable'," "," ",.)/*Pour espace insécable*/
	replace `variable'  =usubinstr(`variable',"’","'",.)
	replace `variable'  =ustrtrim(`variable')
}

foreach variable of var quantity value value_unit probleme { 
	replace `variable'  =usubinstr(`variable',"  "," ",.)
	replace `variable'  =usubinstr(`variable',"  "," ",.)
	replace `variable'  =usubinstr(`variable',"  "," ",.)
	replace `variable'  =usubinstr(`variable',",",".",.)
	replace `variable'  =usubinstr(`variable'," ","",.)
	replace `variable'  =usubinstr(`variable'," ","",.)
	replace `variable'  =usubinstr(`variable',"’","'",.)
	replace `variable'  =usubinstr(`variable',"u","œ",.)
	capture replace `variable'  =usubinstr(`variable'," "," ",.)/*Pour espace insécable*/
	replace `variable'  =usubinstr(`variable',char(202),"",.)
	*edit  if missing(real(`variable')) & `variable' != ""
	display "---------Pas trop !-----------------"
	replace `variable' ="" if missing(real(`variable')) & `variable' != ""
}


destring total value_sub_total_1 value_sub_total_2 value_sub_total_3  value_part_of_bundle, replace
destring quantity value_unit value, replace

drop if source==""
drop if value==0 & quantit==. & value_unit==. /*Dans tous les cas regardés le 31 mai 2016, ce sont des "vrais" 0*/
drop if (value==0|value==.) & (quantit==.|quantit==0) & (value_unit==.|value_unit==0) /*idem*/
replace value=. if (value==0 & quantit!=. & quantit!=0)



** RQ : l'unification des values, etc. est faite dans le scrip d'agrégation
* Création de value_as_reported, value = unit_price*quantit...

capture drop v24
save "Données Stata/bdd_centrale.dta", replace
export delimited "Données Stata/bdd_centrale.csv", replace

*/


********* Procédure pour les nouveaux fichiers ************
******ATTENTION !!!! POUR GARDER LE LIEN AVEC GIT, IL FAUT ALLER DANS LIBRE OFFICE ET REFAIRE LE TRI !
*******************************

cd "$dir/Données Stata"




***********Unit values

use "bdd_centrale.dta", clear
merge m:1 quantity_unit using "Units_Normalisation_Orthographique.dta"
keep quantity_unit quantity_unit_ortho _merge 


capture drop source_bdc
generate source_bdc=0
label variable source_bdc "1 si présent dans la source française, 0 sinon"
replace source_bdc=1 if _merge==3 | _merge==1
replace source_bdc=0 if _merge==2


foreach variable of var quantity_unit quantity_unit_ortho  {
	capture drop nbr_bdc_`variable'
	generate nbr_bdc_`variable'=0
	label variable nbr_bdc_`variable' "Nbr de flux avec ce `variable' dans la source française"
	bys `variable' : replace nbr_bdc_`variable'=_N if (_merge==3 | _merge==1)
}

drop _merge
bys quantity_unit : keep if _n==1
save "Units_Normalisation_Orthographique.dta", replace
generate sortkey = ustrsortkey(quantity_unit, "fr")
sort sortkey
drop sortkey
export delimited "Units_Normalisation_Orthographique.csv", replace

use "Units_Normalisation_Orthographique.dta", clear
merge m:1 quantity_unit_ortho using "Units_Normalisation_Metrique1.dta"
keep quantity_unit_ortho quantity_unit_ajustees u_conv q_conv remarque_unit incertitude_unit ///
source_hambourg missing need_product source_bdc _merge 
foreach variable of var quantity_unit_ortho quantity_unit_ajustees  {
	capture drop nbr_bdc_`variable'
	generate nbr_bdc_`variable'=0
	label variable nbr_bdc_`variable' "Nbr de flux avec ce `variable' dans la source française"
	bys `variable' : replace nbr_bdc_`variable'=_N if (_merge==3 | _merge==1)
}

drop _merge
bys quantity_unit_ortho : keep if _n==1
save "Units_Normalisation_Metrique1.dta", replace
generate sortkey = ustrsortkey(quantity_unit_ortho, "fr")
sort sortkey
drop sortkey
export delimited "Units_Normalisation_Metrique1.csv", replace


/*
use "bdd_centrale.dta", clear
merge m:1 quantity_unit using "Units_N1.dta"
drop line_number-total value_sub_total_1-remarkspourlesdroits
drop computed_value
drop value_as_reported	replace_computed_up
* drop computed_up

capture drop source_bdc
generate source_bdc=0
label variable source_bdc "1 si présent dans la source française, 0 sinon"
replace source_bdc=1 if _merge==3 | _merge==1
replace source_bdc=0 if _merge==2


foreach variable of var quantity_unit quantity_unit_ajustees  {
	capture drop nbr_bdc_`variable'
	generate nbr_bdc_`variable'=0
	label variable nbr_bdc_`variable' "Nbr de flux avec ce `variable' dans la source française"
	bys `variable' : replace nbr_bdc_`variable'=_N if (_merge==3 | _merge==1)
}

drop _merge
bys quantity_unit : keep if _n==1
save "Units_N1.dta", replace
generate sortkey = ustrsortkey(quantity_unit, "fr")
sort sortkey
drop sortkey
export delimited "Units_N1.csv", replace
*/

******* Direction et origin
use "bdd_centrale.dta", clear
merge m:1 tax_department using "bdd_tax_departments.dta"
keep tax_department tax_department_simpl
bys tax_department : gen nbr_occurence=_N
bys tax_department : keep if _n==1
save "bdd_tax_departments.dta", replace
generate sortkey = ustrsortkey(tax_department, "fr")
sort sortkey
drop sortkey
export delimited bdd_tax_departments.csv, replace


use "bdd_centrale.dta", clear
merge m:1 origin using "bdd_origin.dta"
keep origin origin_norm_ortho
bys origin : gen nbr_occurence=_N
bys origin : keep if _n==1
save "bdd_origin.dta", replace
generate sortkey = ustrsortkey(origin, "fr")
sort sortkey
drop sortkey
export delimited bdd_origin.csv, replace





****Pays*************
use "bdd_centrale.dta", clear
merge m:1 partner using "classification_country_orthographic_normalization.dta"
drop line_number-product value-remarkspourlesdroits

drop _merge
bys partner : keep if _n==1
keep partner orthographic_normalization_classification note
save "classification_country_orthographic_normalization.dta", replace
generate sortkey = ustrsortkey(partner, "fr")
sort sortkey
drop sortkey
export delimited classification_country_orthographic_normalization.csv, replace




**
use "classification_country_orthographic_normalization.dta", clear
drop note
merge m:1 orthographic_normalization_classification using "classification_country_simplification.dta"
drop if _merge==2



drop _merge

bys orthographic_normalization_classification : keep if _n==1
keep orthographic_normalization_classification simplification_classification note
save "classification_country_simplification.dta", replace
generate sortkey = ustrsortkey(orthographic_normalization_classification, "fr")
sort sortkey
drop sortkey
export delimited classification_country_simplification.csv, replace

**

use "classification_country_simplification.dta", clear
drop note
merge m:1 simplification_classification using "classification_country_grouping.dta"

drop if _merge==2
drop _merge

bys simplification_classification : keep if _n==1
keep simplification_classification grouping_classification note
save "classification_country_grouping.dta", replace
generate sortkey = ustrsortkey(simplification_classification, "fr")
sort sortkey
drop sortkey
export delimited classification_country_grouping.csv, replace

** 
use "classification_country_simplification.dta", clear
drop note
merge m:1 simplification_classification using "classification_country_obrien.dta"

drop if _merge==2
drop _merge

bys simplification_classification : keep if _n==1
keep simplification_classification obrien_classification note
save "classification_country_obrien.dta", replace
generate sortkey = ustrsortkey(simplification_classification, "fr")
sort sortkey
drop sortkey
export delimited classification_country_obrien.csv, replace


*************Marchandises


use "bdd_product_orthographic_normalization.dta", replace
bys product : drop if _n!=1

save "bdd_product_orthographic_normalization.dta", replace

use "bdd_centrale.dta", clear
merge m:1 product using "bdd_product_orthographic_normalization.dta"

drop _merge

keep product orthographic_normalization_classification mériteplusdetravail

bys product : keep if _n==1


save "bdd_product_orthographic_normalization.dta", replace
generate sortkey = ustrsortkey(product, "fr")
sort sortkey
drop sortkey
export delimited orthographic_normalization_classification.csv, replace

**
use "bdd_product_simplification.dta", replace
bys product_norm_orth : drop if _n!=1
save "bdd_product_simplification.dta", replace

use "bdd_product_orthographic_normalization.dta", clear
merge m:1 orthographic_normalization_classification using "bdd_product_simplification.dta"

keep orthographic_normalization_classification simplification_classification _merge
drop if _merge==2

drop _merge
bys orthographic_normalization_classification : keep if _n==1


save "bdd_product_simplification.dta", replace
generate sortkey = ustrsortkey(orthographic_normalization_classification, "fr")
sort sortkey
drop sortkey
export delimited bdd_product_simplification.csv, replace
**

foreach file_on_simp in bdd_product_sitc bdd_product_edentreaty bdd_product_NorthAmerica bdd_product_medicinales bdd_product_hamburg /*
		*/ bdd_product_grains {

	use "`file_on_simp'.dta", clear
	bys simplification_classification : drop if _n!=1
	save "`file_on_simp'.dta", replace

	use "bdd_product_simplification.dta", clear
	merge m:1 simplification_classification using "`file_on_simp'.dta"


	drop orthographic_normalization_classification 

	*drop if _merge==2
	capture gen obsolete=""
	replace obsolete = "oui" if _merge==2
	replace obsolete = "non" if _merge!=2
	drop _merge
	capture bys simplification_classification : keep if _n==1

	
	capture generate sortkey = ustrsortkey(simplification_classification, "fr")
	sort sortkey
	drop sortkey
	

	save "`file_on_simp'.dta", replace
	export delimited `file_on_simp'.csv, replace

}


***********************************************************************************************************************************



****************************BDD courante

use "bdd_centrale.dta", clear


merge m:1 tax_department using "bdd_tax_departments.dta"
rename tax_department tax_department_origin
rename tax_department_simpl tax_department
drop _merge nbr_occurence

merge m:1 origin using "bdd_origin.dta"
rename origin origin_origin
rename origin_norm_ortho origin
drop _merge nbr_occurence



merge m:1 partner using "classification_country_orthographic_normalization.dta"
drop if _merge==2
drop note-_merge

merge m:1 orthographic_normalization_classification using "classification_country_simplification.dta"
drop if _merge==2


drop note-_merge

merge m:1 simplification_classification using "classification_country_grouping.dta"
drop if _merge==2
drop note-_merge



merge m:1 simplification_classification using "classification_country_obrien.dta"
drop if _merge==2
drop note-_merge


******

merge m:1 product using "bdd_product_orthographic_normalization.dta"
drop if _merge==2
drop mériteplusdetravail-_merge


merge m:1 orthographic_normalization_classification using "bdd_product_simplification.dta"
drop if _merge==2
drop _merge

merge m:1 simplification_classification using "bdd_product_sitc.dta"
drop if _merge==2
drop _merge


merge m:1 simplification_classification using "bdd_product_grains.dta"
drop if _merge==2
drop _merge

merge m:1 sitc_classification using "bdd_product_sitc_FR.dta"
drop if _merge==2
drop _merge

merge m:1 sitc_classification using "bdd_product_sitc_EN.dta"
drop if _merge==2
drop _merge

merge m:1 simplification_classification using "bdd_product_hamburg"
drop if _merge==2
drop _merge

merge m:1 simplification_classification using "bdd_product_medicinales"
drop if _merge==2
drop _merge


local j 5
generate yearbis=year
foreach i of num 1797(1)1805 {
	replace yearbis = "`i'" if year =="An `j'"
	local j =`j'+1
}

replace yearbis="1805.75" if yearbis== "An 14 & 1806"
replace yearbis="1787.20" if yearbis== "10 mars-31 décembre 1787"

generate yearnum=real(yearbis)
drop yearbis
* findit labutil
*labmask yearnum, values(year)
rename year yearstr
rename yearnum year

******************************************************************************************************
* Pour les quantités




 merge m:1 quantity_unit using "$dir/Données Stata/Units_Normalisation_Orthographique.dta"
 replace quantity_unit_ortho="unité manquante" if quantity_unit==""
 drop _merge source_bdc nbr_bdc_quantity_unit nbr_bdc_quantity_unit_ortho
 
 merge m:1 quantity_unit_ortho using "$dir/Données Stata/Units_Normalisation_Metrique1.dta"
 replace quantity_unit_ajustees="unité manquante" if quantity_unit_ortho=="unité manquante"
 replace u_conv="unité manquante" if quantity_unit_ortho=="unité manquante"
 drop _merge source_bdc nbr_bdc_quantity_unit_ortho nbr_bdc_quantity_unit_ajustees source_hambourg missing need_product
 codebook q_conv
 
 merge m:1 export_import grouping_classification tax_department simplification_classification quantity_unit_ortho ///
		using "$dir/Données Stata/Units_Normalisation_Metrique2.dta", update
 drop  remarque_unit-_merge
 codebook q_conv
 
 generate quantites_metric = q_conv * quantit

 
 *******************************************************************


export delimited "$dir/Données Stata/bdd courante.csv", replace
*export delimited "$dir/toflit18_data_GIT/base/bdd courante.csv", replace
*Il est trop gros pour être envoyé dans le GIT

sort source_type tax_department year export_import line_number 
order line_number source_type year tax_department partner orthographic_normalization_classification export_import product orthographic_normalization_classification value quantity quantity_unit quantity_unit_ortho value_unit
drop if year==.

save "$dir/Données Stata/bdd courante", replace


/*
********
use "$dir/bdd courante", replace 

keep if year=="1750"
keep if tax_department=="Bordeaux"
keep if export_import=="Imports"
keep source source_type year export_import tax_department product partner value quantity quantity_unit value_unit probleme remarks quantit_unit partner_corriges product_normalisees value_calcul prix_calcul
sort product partner


export delimited using "/Users/guillaumedaudin/Documents/Recherche/Commerce International Français XVIIIe.xls/Balance du commerce/Retranscriptions_Commerce_France/Pour comparaison Bordeaux 1750.csv", replace
*/

*****************************Pour product_sourcees.csv


capture 
{
use "$dir/Données Stata/bdd_product_orthographic_normalization.dta", replace
keep product
merge 1:m product using "$dir/Données Stata/Belgique/RG_base.dta"
generate sourceBEL=0
generate sourceBEL_nbr1=0
bys product : replace sourceBEL_nbr1=_N if _merge==3
bys product : keep if _n==1
replace sourceBEL=1 if _merge==3
keep product sourceBEL sourceBEL_nbr1

merge 1:m product using "$dir/Données Stata/Belgique/RG_1774.dta"
generate sourceBEL_nbr2=0
bys product : replace sourceBEL_nbr2=_N if _merge==3
bys product : keep if _n==1
replace sourceBEL=1 if _merge==3
generate sourceBEL_nbr=sourceBEL_nbr1+sourceBEL_nbr2
keep product sourceBEL  sourceBEL_nbr

merge 1:m product using "$dir/Données Stata/bdd_centrale.dta"
generate sourceFR=0
generate sourceFR_nbr=0
bys product : replace sourceFR_nbr=_N if _merge==3
bys product : keep if _n==1

replace sourceFR=1 if _merge==3
keep product sourceBEL sourceFR sourceBEL_nbr sourceFR_nbr

merge 1:m product using "$dir/Données Stata/Sound/BDD_SUND_FR.dta"
generate sourceSUND=0
generate sourceSUND_nbr=0
bys product : replace sourceSUND_nbr=_N if _merge==3
bys product : keep if _n==1
replace sourceSUND=1 if _merge==3
keep product sourceBEL sourceFR sourceSUND sourceBEL_nbr sourceFR_nbr sourceSUND_nbr

sort product
gen nbr_source=sourceBEL+sourceFR+sourceSUND

drop if nbr_source==0

save "$dir/Données Stata/product_sourcees", replace
export delimited "$dir/Données Stata/product_sourcees.csv", replace
}







