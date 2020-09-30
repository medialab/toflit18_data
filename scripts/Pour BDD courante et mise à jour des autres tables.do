ssc install missings

 version 15.1

 
**pour mettre les bases dans stata + mettre à jour les .csv
** version 2 : pour travailler avec la nouvelle organisation

global dir "~/Documents/Recherche/Commerce International Français XVIIIe.xls/Balance du commerce/Retranscriptions_Commerce_France"

if "`c(username)'"=="Matthias" global dir "/Users/Matthias/"

if "`c(username)'"=="Tirindelli" global dir "/Users/Tirindelli/Google Drive/ETE/Thesis"

if "`c(username)'"=="federico.donofrio" global dir "C:\Users\federico.donofrio\Documents\GitHub"

if "`c(username)'"=="pierr" global dir "/Users/pierr/Documents/Toflit/"

if "`c(username)'"=="loiccharles" global dir "/Users/loiccharles/Documents/"

cd "$dir"



foreach file in classification_partner_orthographic classification_partner_simplification classification_partner_grouping /*
*/				 classification_partner_obrien classification_partner_wars /*
*/				 classification_partner_sourcename classification_partner_africa /*
*/               classification_product_orthographic classification_product_simplification /*
*/				 /*Units_N1 Units_N2 Units_N3*/  classification_product_edentreaty classification_product_canada /*
*/				 classification_product_medicinales classification_product_hamburg classification_product_grains /*
*/ 				 classification_product_sitc  classification_product_coffee classification_product_porcelaine /*
*/				 bdd_tax_departments classification_product_sitc_FR classification_product_sitc_EN /*
*/				 classification_product_sitc_simplEN /* 
*/ 				 classification_quantityunit_orthographic classification_quantityunit_simplification /*
*/				 classification_quantityunit_metric1 classification_quantityunit_metric2 /*
*/				 bdd_origin classification_product_coton	classification_product_ulrich /*
*/ 				 classification_product_v_glass_beads classification_product_beaver/*
*/				 classification_product_RE_aggregate classification_product_revolutionempire /*
*/				 classification_product_type_textile  classification_product_luxe_dans_type /*
*/				 classification_product_luxe_dans_SITC	classification_product_threesectors /*
*/				 classification_product_threesectorsM	{

	import delimited "$dir/toflit18_data_GIT/base/`file'.csv",  encoding(UTF-8) /// 
			clear varname(1) stringcols(_all) case(preserve) 

	foreach variable of var * {
		capture	replace `variable'  =usubinstr(`variable',"  "," ",.)
		capture	replace `variable'  =usubinstr(`variable',"  "," ",.)
		capture	replace `variable'  =usubinstr(`variable',"  "," ",.)
		capture	replace `variable'  =usubinstr(`variable',"…","...",.)
		capture replace `variable'  =usubinstr(`variable',"u","œ",.) 
		capture replace `variable'  =usubinstr(`variable'," "," ",.)/*Pour espace insécable*/
		capture replace `variable'  =usubinstr(`variable',"’","'",.)
		capture	replace `variable'  =ustrtrim(`variable')
	}

	capture destring nbr*, replace float
	capture drop nbr_bdc* source_bdc
	save "Données Stata/`file'.dta", replace
 
}

foreach file in "$dir/Données Stata/Belgique/RG_base.dta" "$dir/Données Stata/Belgique/RG_1774.dta" ///
			"$dir/Données Stata/Sound/BDD_SUND_FR.dta" "$dir/Données Stata/Marchandises Navigocorpus/Navigo.dta" {
	
	use "`file'", clear
	foreach variable of var * {
		capture	replace `variable'  =usubinstr(`variable',"  "," ",.)
		capture	replace `variable'  =usubinstr(`variable',"  "," ",.)
		capture	replace `variable'  =usubinstr(`variable',"  "," ",.)
		capture	replace `variable'  =usubinstr(`variable',"…","...",.)
		capture replace `variable'  =usubinstr(`variable',"u","œ",.) 
		capture replace `variable'  =usubinstr(`variable'," "," ",.)/*Pour espace insécable*/
		capture replace `variable'  =usubinstr(`variable',"’","'",.)
		capture	replace `variable'  =ustrtrim(`variable')
	}
	replace product = ustrupper(usubstr(product,1,1),"fr")+usubstr(product,2,.)
	save "`file'", replace
}


/* 
use "Données Stata/Units_N1.dta", clear
destring q_conv, replace
save "Données Stata/Units_N1.dta", replace
*/

use "Données Stata/classification_quantityunit_simplification.dta", clear
destring conv_orthographic_to_simplificat source_bdc, replace
save "Données Stata/classification_quantityunit_simplification.dta", replace

use "Données Stata/classification_quantityunit_metric1.dta", clear
destring conv_simplification_to_metric, replace
save "Données Stata/classification_quantityunit_metric1.dta", replace

use "Données Stata/classification_quantityunit_metric2.dta", clear
destring conv_simplification_to_metric, replace
save "Données Stata/classification_quantityunit_metric2.dta", replace

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
	
	
/*	
import delimited "$dir/toflit18_data_GIT/traitements_product/SITC/Définitions sitc_classification.csv",  encoding(UTF-8) clear varname(1) stringcols(_all)   

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
*/
	
	
	
	
	
	

 *(juste parce que c'est trop long)


import delimited "$dir/toflit18_data_GIT/base/bdd_centrale.csv",  encoding(UTF-8) clear varname(1) stringcols(_all)  
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


zipfile "$dir/toflit18_data_GIT/base/bdd_centrale.csv", saving("$dir/toflit18_data_GIT/base/bdd_centrale.csv.zip", replace)

foreach variable of var quantity value value_per_unit value_minus_unit_val_x_qty { 
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


destring value_total value_sub_total_1 value_sub_total_2 value_sub_total_3  value_part_of_bundle, replace
destring quantity value_per_unit value, replace

drop if source==""
drop if value==0 & quantity==. & value_per_unit ==. /*Dans tous les cas regardés le 31 mai 2016, ce sont des "vrais" 0*/
drop if (value==0|value==.) & (quantity ==.|quantity ==0) & (value_per_unit ==.|value_per_unit ==0) /*idem*/
replace value=. if (value==0 & quantity !=. & quantity !=0)

**Je mets des majuscules à toutes les "product" de la source
replace product = upper(substr(product,1,1))+substr(product,2,.)


** RQ : l'unification des values, etc. est faite dans le scrip d'agrégation
* Création de value_as_reported, value = unit_price*quantit...

capture drop v24




save "Données Stata/bdd_centrale.dta", replace
export delimited "$dir/toflit18_data_GIT/base/bdd_centrale.csv", replace

*/


********* Procédure pour les nouveaux fichiers ************
*******************************

cd "$dir/Données Stata"




***********Unit values

use "bdd_centrale.dta", clear
rename source source_doc
rename quantity_unit source
merge m:1 source using "classification_quantityunit_orthographic.dta"
keep source orthographic _merge 


capture drop source_bdc
generate source_bdc=0
label variable source_bdc "1 si présent dans la source française, 0 sinon"
replace source_bdc=1 if _merge==3 | _merge==1
replace source_bdc=0 if _merge==2


capture drop nbr_occurences_source
generate nbr_occurences_source=0
bys source : replace nbr_occurences_source = _N if (_merge==3 | _merge==1)
bys source : replace nbr_occurences_source = 0 if _merge==2
label variable nbr_occurences_source "Nbr de flux avec la quantité source dans la source française"

bys source : keep if _n==1
**Pour éviter que certaines lignes dans le même orthographic aient des nombres entiers et des zéros (suivant si le "source" est dans la bdc ou pas)
bys orthographic : egen nbr_occurences_orthographic = total(nbr_occurences_source)

label variable nbr_occurences_orthographic "Nbr de flux avec la quantité orthographic dans la source française"



drop _merge

generate sortkey = ustrsortkeyex(source,  "fr",-1,2,-1,-1,-1,0,-1)
sort sortkey
drop sortkey
save "classification_quantityunit_orthographic.dta", replace
export delimited "$dir/toflit18_data_GIT/base/classification_quantityunit_orthographic.csv", replace



******
use "classification_quantityunit_orthographic.dta", clear
keep orthographic nbr_occurences_orthographic source_bdc
bys orthographic : egen blif=max(source_bdc)
replace source_bdc=blif
drop blif
bys orthographic : keep if _n==1
merge 1:1 orthographic using "classification_quantityunit_simplification.dta"
keep orthographic nbr_occurences_orthographic simplification conv_orthographic_to_simplificat remarque_unit ///
					source_bdc _merge


capture drop nbr_bdc_simplification
bys simplification : egen nbr_occurences_simplification=total(nbr_occurences_orthographic)
label variable nbr_occurences_simplification "Nbr de flux avec la quantité simplification dans la source française"

drop _merge

egen source_bdc_new = max(source_bdc), by(simplification)
drop source_bdc
rename source_bdc_new source_bdc
order orthographic source_bdc nbr_occurences_orthographic simplification nbr_occurences_simplification ///
	conv_orthographic_to_simplificat remarque_unit
	
	
generate sortkey = ustrsortkeyex(orthographic, "fr",-1,2,-1,-1,-1,0,-1)
sort sortkey
drop sortkey
save "classification_quantityunit_simplification.dta", replace
export delimited "$dir/toflit18_data_GIT/base/classification_quantityunit_simplification.csv", replace


******
use "classification_quantityunit_simplification.dta", clear
keep simplification nbr_occurences_simplification source_bdc
bys simplification : keep if _n==1
merge 1:1 simplification using "classification_quantityunit_metric1.dta"
keep simplification nbr_occurences_simplification metric conv_simplification_to_metric /// 
				incertitude_unit source_hambourg	missing	needs_more_details remarque_unit


foreach variable of var metric  {
	capture drop nbr_bdc_`variable'
	bys `variable' : egen nbr_occurences_`variable'=total(nbr_occurences_simplification)
	label variable nbr_occurences_`variable' "Nbr de flux avec la quantité `variable' dans la source française"
}


capture drop _merge

order simplification  nbr_occurences_simplification metric  ///
	conv_simplification_to_metric incertitude_unit source_hambourg	missing	needs_more_details remarque_unit

	
	
generate sortkey = ustrsortkeyex(simplification,  "fr",-1,2,-1,-1,-1,0,-1)
sort sortkey
drop sortkey
save "classification_quantityunit_metric1.dta", replace
export delimited "$dir/toflit18_data_GIT/base/classification_quantityunit_metric1.csv", replace

/*See below for "classification_quantityunit_metric2.dta"*/


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
export delimited "$dir/toflit18_data_GIT/base/Units_N1.csv", replace
*/

******* Direction et origin
use "bdd_centrale.dta", clear
merge m:1 tax_department using "bdd_tax_departments.dta"
keep tax_department tax_department_simpl
bys tax_department : gen nbr_occurence=_N
bys tax_department : keep if _n==1
save "bdd_tax_departments.dta", replace
generate sortkey = ustrsortkeyex(tax_department,  "fr",-1,2,-1,-1,-1,0,-1)
sort sortkey
drop sortkey
export delimited "$dir/toflit18_data_GIT/base/bdd_tax_departments.csv", replace


use "bdd_centrale.dta", clear
merge m:1 origin using "bdd_origin.dta"
keep origin origin_norm_ortho
bys origin : gen nbr_occurence=_N
bys origin : keep if _n==1
save "bdd_origin.dta", replace
generate sortkey = ustrsortkeyex(origin,  "fr",-1,2,-1,-1,-1,0,-1)
sort sortkey
drop sortkey
export delimited "$dir/toflit18_data_GIT/base/bdd_origin.csv", replace





****Pays*************
use "bdd_centrale.dta", clear
rename source source_doc
rename partner source
merge m:1 source using "classification_partner_orthographic.dta"
keep source orthographic note

bys source : gen nbr_occurences_source=_N
bys orthographic : gen nbr_occurences_ortho=_N 
bys source : keep if _n==1
keep source orthographic note nbr_occurences_source nbr_occurences_ortho
order source s nbr_occurences_source orthographic nbr_occurences_ortho note
save "classification_partner_orthographic.dta", replace
generate sortkey = ustrsortkeyex(source,  "fr",-1,2,-1,-1,-1,0,-1)
sort sortkey
drop sortkey
export delimited "$dir/toflit18_data_GIT/base/classification_partner_orthographic.csv", replace




**
use "classification_partner_orthographic.dta", clear
drop note
merge m:1 orthographic using "classification_partner_simplification.dta"
drop if _merge==2
drop _merge

capture drop nbr_occurences_simpl

bys simplification : egen nbr_occurences_simpl=total(nbr_occurences_source) 

bys orthographic : keep if _n==1
keep orthographic simplification nbr_occurences_ortho nbr_occurences_simpl note

save "classification_partner_simplification.dta", replace
generate sortkey = ustrsortkeyex(orthographic, "fr",-1,2,-1,-1,-1,0,-1)
sort sortkey
drop sortkey
export delimited "$dir/toflit18_data_GIT/base/classification_partner_simplification.csv", replace

**

use "classification_partner_simplification.dta", clear
drop note
merge m:1 simplification using "classification_partner_grouping.dta"

drop if _merge==2
drop _merge

capture drop nbr_occurences_grouping
bys grouping : egen nbr_occurences_grouping=total(nbr_occurences_ortho)

bys simplification : keep if _n==1
keep simplification grouping nbr_occurences_simpl nbr_occurences_grouping note
save "classification_partner_grouping.dta", replace
generate sortkey = ustrsortkeyex(simplification,  "fr",-1,2,-1,-1,-1,0,-1)
sort sortkey
drop sortkey
export delimited "$dir/toflit18_data_GIT/base/classification_partner_grouping.csv", replace

** 
use "classification_partner_simplification.dta", clear
drop note
merge m:1 simplification using "classification_partner_obrien.dta"

drop if _merge==2
drop _merge

capture drop nbr_occurences_obrien
bys obrien : egen nbr_occurences_obrien=total(nbr_occurences_ortho)

bys simplification : keep if _n==1
keep simplification obrien nbr_occurences_simpl nbr_occurences_obrien note
save "classification_partner_obrien.dta", replace
generate sortkey = ustrsortkeyex(simplification,  "fr",-1,2,-1,-1,-1,0,-1)
sort sortkey
drop sortkey
export delimited "$dir/toflit18_data_GIT/base/classification_partner_obrien.csv", replace


** 
use "classification_partner_simplification.dta", clear
drop note
merge m:1 simplification using "classification_partner_wars.dta"

drop if _merge==2
drop _merge

capture drop nbr_occurences_wars
bys wars : egen nbr_occurences_wars=total(nbr_occurences_ortho)

bys simplification : keep if _n==1
keep simplification wars nbr_occurences_simpl nbr_occurences_wars note
save "classification_partner_wars.dta", replace
generate sortkey = ustrsortkeyex(simplification,  "fr",-1,2,-1,-1,-1,0,-1)
sort sortkey
drop sortkey
export delimited "$dir/toflit18_data_GIT/base/classification_partner_wars.csv", replace

** 
use "classification_partner_simplification.dta", clear
drop note
merge m:1 simplification using "classification_partner_sourcename.dta"

drop if _merge==2
drop _merge

capture drop nbr_occurences_sourcename
bys sourcename : egen nbr_occurences_sourcename=total(nbr_occurences_ortho)

bys simplification : keep if _n==1
keep simplification sourcename nbr_occurences_simpl nbr_occurences_sourcename note
save "classification_partner_sourcename.dta", replace
generate sortkey = ustrsortkeyex(simplification,  "fr",-1,2,-1,-1,-1,0,-1)
sort sortkey
drop sortkey
export delimited "$dir/toflit18_data_GIT/base/classification_partner_sourcename.csv", replace

*******************************

use "classification_partner_simplification.dta", clear
drop note
merge m:1 simplification using "classification_partner_africa.dta"

drop if _merge==2
drop _merge

capture drop nbr_occurences_africa
bys africa : egen nbr_occurences_africa=total(nbr_occurences_ortho)

bys simplification : keep if _n==1
keep simplification africa nbr_occurences_simpl nbr_occurences_africa note
save "classification_partner_africa.dta", replace
generate sortkey = ustrsortkeyex(simplification,  "fr",-1,2,-1,-1,-1,0,-1)
sort sortkey
drop sortkey
export delimited "$dir/toflit18_data_GIT/base/classification_partner_africa.csv", replace




*************Marchandises
/*
****************Orthographique de la base française
use "classification_product_orthographic.dta", replace

bys source : drop if _n!=1

save "classification_product_orthographic.dta", replace

use "bdd_centrale.dta", clear
rename source source_doc
rename product source
merge m:1 source using "classification_product_orthographic.dta"
capture drop nbr_occurences_source
capture drop nbr_occurences_ortho
bys source : gen nbr_occurences_source=_N
if _merge==2 replace nbr_occurences_source=0
bys orthographic : gen nbr_occurences_ortho=_N

drop _merge

keep source orthographic note nbr_occurences_source  nbr_occurences_ortho 
order source nbr_occurences_source orthographic nbr_occurences_ortho 

bys source : keep if _n==1
save "classification_product_orthographic.dta", replace
generate sortkey =  ustrsortkeyex(source, "fr",-1,2,-1,-1,-1,0,-1)
sort sortkey
drop sortkey
export delimited "$dir/toflit18_data_GIT/base/classification_product_orthographic.csv", replace
*/
*******************Sourcé
*****************************Pour product_sourcees.csv (et product orthographic)


use "$dir/Données Stata/Marchandises Navigocorpus/Navigo.dta", clear
collapse (sum) nbr_occurences_navigo_marseille_ nbr_occurences_navigo_g5, by(product)
save "$dir/Données Stata/Marchandises Navigocorpus/Navigo.dta", replace



use "$dir/Données Stata/classification_product_orthographic.dta", replace
rename source product
keep product orthographic note

merge 1:m product using "$dir/Données Stata/bdd_centrale.dta"
generate sourceFR=0
generate sourceFR_nbr=0
bys product : replace sourceFR_nbr=_N
replace sourceFR_nbr=0 if _merge==1
bys product : keep if _n==1
replace sourceFR=1 if _merge!=1
keep product orthographic sourceFR sourceFR_nbr note



merge 1:m product using "$dir/Données Stata/Belgique/RG_base.dta"
generate sourceBEL=0
generate sourceBEL_nbr1=0
bys product : replace sourceBEL_nbr1=_N
replace sourceBEL_nbr1=0 if _merge==1
bys product : keep if _n==1
replace sourceBEL=1 if _merge!=1
keep product  orthographic sourceFR sourceFR_nbr sourceBEL sourceBEL_nbr1 note

merge 1:m product using "$dir/Données Stata/Belgique/RG_1774.dta"
generate sourceBEL_nbr2=0
bys product : replace sourceBEL_nbr2=_N
replace sourceBEL_nbr2=0 if _merge==1
bys product : keep if _n==1
replace sourceBEL=1 if _merge!=1
generate sourceBEL_nbr=sourceBEL_nbr1+sourceBEL_nbr2
keep product orthographic sourceFR sourceFR_nbr sourceBEL  sourceBEL_nbr note

merge 1:m product using "$dir/Données Stata/Sound/BDD_SUND_FR.dta"
generate sourceSUND=0
generate sourceSUND_nbr=0
bys product : replace sourceSUND_nbr=_N
replace sourceSUND_nbr=0 if _merge==1
bys product : keep if _n==1
replace sourceSUND=1 if _merge!=1
keep product orthographic sourceBEL sourceFR sourceSUND sourceBEL_nbr sourceFR_nbr sourceSUND_nbr note

merge 1:m product using "$dir/Données Stata/Marchandises Navigocorpus/Navigo.dta"
drop if product=="(empty)" & _merge !=2
sort product
bys product : keep if _n==1
generate sourceNAVIGO=0
generate sourceNAVIGO_nbr=nbr_occurences_navigo_marseille_ + nbr_occurences_navigo_g5
replace sourceNAVIGO=1 if _merge!=1

keep product orthographic sourceBEL sourceFR sourceSUND sourceBEL_nbr sourceFR_nbr sourceSUND_nbr sourceNAVIGO sourceNAVIGO_nbr note

foreach i of varlist sourceBEL sourceFR sourceSUND sourceBEL_nbr sourceFR_nbr sourceSUND_nbr sourceNAVIGO sourceNAVIGO_nbr {
	replace    `i'=0 if `i'==.
}


sort product
gen nbr_source=sourceBEL+sourceFR+sourceSUND+sourceNAVIGO
gen nbr_occurence_ttesources = sourceBEL_nbr + sourceSUND_nbr + sourceNAVIGO_nbr + sourceFR_nbr


generate sortkey =  ustrsortkeyex(product, "fr",-1,2,-1,-1,-1,0,-1)
sort sortkey
drop sortkey
save "$dir/Données Stata/product_sourcees.dta", replace
export delimited "$dir/toflit18_data_GIT/base/product_sourcees.csv", replace

****************************Orthographique y compris toutes les bases
/*
use "$dir/Données Stata/classification_product_orthographic.dta", clear
rename source product
merge 1:1 product using "$dir/Données Stata/product_sourcees.dta"
*/

capture drop obsolete
generate obsolete = "non"
if nbr_source == 0 replace obsolete="oui"
rename product source
rename sourceFR_nbr nb_occurence_BdCFR
capture drop nbr_occurences_source
rename nbr_occurence_ttesources nbr_occurences_source
capture drop nbr_occurences_ortho

bys orthographic : egen nbr_occurences_ortho=total(nbr_occurences_source)
keep source	nbr_occurences_source orthographic nbr_occurences_ortho nb_occurence_BdCFR obsolete note
order source nb_occurence_BdCFR nbr_occurences_source
replace obsolete = "oui" if nbr_occurences_source==0
drop if obsolete=="oui" & orthographic==""
sort source
generate sortkey =  ustrsortkeyex(source, "fr",-1,2,-1,-1,-1,0,-1)
sort sortkey
drop sortkey
save "$dir/Données Stata/classification_product_orthographic.dta", replace
export delimited "$dir/toflit18_data_GIT/base/classification_product_orthographic.csv", replace




***************************************Simplification
use "classification_product_simplification.dta", replace
bys orthographic : drop if _n!=1
save "classification_product_simplification.dta", replace

use "classification_product_orthographic.dta", clear
merge m:1 orthographic using "classification_product_simplification.dta"

capture drop nbr_occurences_simpl
bys simplification : egen nbr_occurences_simpl=total(nbr_occurences_source)

keep orthographic simplification nbr_occurences_ortho nbr_occurences_simpl _merge
drop if _merge==2

drop _merge
bys orthographic : keep if _n==1


save "classification_product_simplification.dta", replace
generate sortkey = ustrsortkeyex(orthographic, "fr",-1,2,-1,-1,-1,0,-1)
sort sortkey
drop sortkey
export delimited "$dir/toflit18_data_GIT/base/classification_product_simplification.csv", replace
**

foreach file_on_simp in sitc edentreaty canada medicinales hamburg /*
		*/ grains  coton ulrich coffee porcelaine v_glass_beads revolutionempire beaver /*
		*/ type_textile luxe_dans_type luxe_dans_SITC {

	use "classification_product_`file_on_simp'.dta", clear
	bys simplification : drop if _n!=1
	save "classification_product_`file_on_simp'.dta", replace

	use "classification_product_simplification.dta", clear
	merge m:1 simplification using "classification_product_`file_on_simp'.dta", force
	

	capture drop nbr_occurences_`file_on_simp'
	bys `file_on_simp' : egen nbr_occurences_`file_on_simp'=total(nbr_occurences_ortho)


	drop orthographic nbr_occurences_ortho

	*drop if _merge==2
	capture gen obsolete=""
	replace obsolete = "oui" if _merge==2
	replace obsolete = "non" if _merge!=2
	drop _merge
	capture bys simplification : keep if _n==1

	
	capture generate sortkey = ustrsortkeyex(simplification,  "fr",-1,2,-1,-1,-1,0,-1)
	sort sortkey
	drop sortkey
	

	save "classification_product_`file_on_simp'.dta", replace
	export delimited "$dir/toflit18_data_GIT/base/classification_product_`file_on_simp'.csv", replace

}

foreach file_on_RE in RE_aggregate threesectors threesectorsM {
	use "classification_product_`file_on_RE'.dta", clear
	bys revolutionempire : drop if _n!=1
	save  "classification_product_`file_on_RE'.dta", replace

	use "classification_product_revolutionempire.dta", clear
	merge m:1 revolutionempire using "classification_product_`file_on_RE'.dta", force
	capture bys revolutionempire : keep if _n==1
	capture drop nbr_occurences_`file_on_RE'
	bys `file_on_RE' : egen nbr_occurences_`file_on_RE'=total(nbr_occurences_revolutionempire)
	drop nbr_occurences_simpl
	capture gen obsolete=""
	replace obsolete = "oui" if _merge==2
	replace obsolete = "non" if _merge!=2
	drop _merge
	drop simplification
	
	capture generate sortkey = ustrsortkeyex(revolutionempire,  "fr",-1,2,-1,-1,-1,0,-1)
	sort sortkey
	drop sortkey	
	
	save "classification_product_`file_on_RE'.dta", replace
	export delimited "$dir/toflit18_data_GIT/base/classification_product_`file_on_RE'.csv", replace

}


***********************************************************************************************************************************



****************************BDD courante

use "bdd_centrale.dta", clear


merge m:1 tax_department using "bdd_tax_departments.dta"
drop if _merge==2
rename tax_department tax_department_origin
rename tax_department_simpl tax_department
drop _merge nbr_occurence

merge m:1 origin using "bdd_origin.dta"
drop if _merge==2
rename origin origin_origin
rename origin_norm_ortho origin
drop _merge nbr_occurence


rename source source_doc
rename partner source
merge m:1 source using "classification_partner_orthographic.dta"
rename source partner
rename source_doc source
drop if _merge==2
drop note-_merge

merge m:1 orthographic using "classification_partner_simplification.dta"
drop if _merge==2


drop note-_merge

foreach class_name in grouping obrien ///
			sourcename wars africa {

	merge m:1 simplification using "classification_partner_`class_name'.dta"
	drop if _merge==2
	drop note-_merge
	rename `class_name' partner_`class_name'
}
rename simplification partner_simplification
rename orthographi partner_orthographic

******

rename source source_doc
rename product source
merge m:1 source using "classification_product_orthographic.dta"
rename source product
rename source_doc source
drop if _merge==2
drop note-_merge


merge m:1 orthographic using "classification_product_simplification"
drop if _merge==2
drop nbr_occure* _merge
rename orthographic  product_orthographic

foreach class_name in sitc edentreaty ///
				canada medicinales hamburg ///
				grains  coton ulrich ///
				coffee porcelaine ///
				v_glass_beads revolutionempire beaver ///
				type_textile luxe_dans_type luxe_dans_SITC {

	merge m:1 simplification using "classification_product_`class_name'.dta"
	drop if _merge==2
	drop nbr_occure* _merge
	capture drop obsolete
	rename `class_name' product_`class_name'
	if "`class_name'"=="revolutionempire" capture drop sitc sitc_FR
	
}
rename simplification product_simplification





rename product_sitc sitc
foreach class_name in sitc_FR sitc_EN sitc_simplEN {
	merge m:1 sitc using "classification_product_`class_name'.dta"
	drop if _merge==2
	drop _merge
	rename `class_name' product_`class_name'
}
rename sitc product_sitc

foreach class_name in RE_aggregate threesectors threesectorsM {
	rename product_revolutionempire revolutionempire
	merge m:1 revolutionempire using "classification_product_`class_name'.dta"
	rename revolutionempire product_revolutionempire
	drop if _merge==2
	drop _merge
	rename `class_name' product_`class_name'
}

local j 5
generate yearbis=year
foreach i of num 1797(1)1805 {
	replace yearbis = "`i'" if year =="An `j'"
	local j =`j'+1
}

replace yearbis="1805.75" if yearbis== "An 14 & 1806"
replace yearbis="1787.20" if yearbis== "10 mars-31 décembre 1787"
replace yearbis="1714" if strmatch(yearbis,"*1714")==1

generate yearnum=real(yearbis)
drop yearbis
* findit labutil
*labmask yearnum, values(year)
rename year yearstr
rename yearnum year

******************************************************************************************************
* Pour les quantités



rename source source_or
rename quantity_unit source
merge m:1 source using "$dir/Données Stata/classification_quantityunit_orthographic.dta"
rename source quantity_unit
rename source_or source
 
replace orthographic="unité manquante" if orthographic==""
drop if _merge==2
drop _merge source_bdc	nbr_occurences_source	nbr_occurences_orthographic
 
merge m:1 orthographic using "$dir/Données Stata/classification_quantityunit_simplification.dta"
rename orthographic quantity_unit_orthographic
replace simplification="unité manquante" if quantity_unit_orthographic=="unité manquante"
 
 
drop _merge source_bdc	nbr_occurences_orthographic nbr_occurences_simplification remarque_unit

merge m:1 simplification using "$dir/Données Stata/classification_quantityunit_metric1.dta"
rename simplification quantity_unit_simplification

 
replace metric="unité manquante" if quantity_unit_simplification=="unité manquante"
drop if _merge==2
drop _merge  incertitude_unit nbr_occurences_simplification nbr_occurences_metric /*
		*/ source_hambourg	missing	remarque_unit
rename metric quantity_unit_metric
*gen quantities_metric=quantity *conv_orthographic_to_simplificat*conv_simplification_to_metric
 
 
save "$dir/Données Stata/bdd courante_temp.dta", replace
keep if needs_more_details=="1"

keep export_import partner_grouping tax_department product_simplification product_revolutionempire quantity_unit_simplification
bys export_import partner_grouping tax_department product_simplification product_revolutionempire quantity_unit_simplification: keep if _n==1
rename quantity_unit_simplification simplification
merge 1:1 export_import partner_grouping tax_department product_simplification product_revolutionempire simplification ///
	using "$dir/Données Stata/classification_quantityunit_metric2.dta"
	
 drop _merge
 sort simplification product_simplification product_revolutionempire export_import tax_department partner_grouping
 order simplification product_simplification product_revolutionempire export_import tax_department partner_grouping
 save "$dir/Données Stata/classification_quantityunit_metric2.dta", replace
 export delimited "$dir/toflit18_data_GIT/base/classification_quantityunit_metric2.csv", replace
 
 use "$dir/Données Stata/bdd courante_temp.dta", clear
 erase "$dir/Données Stata/bdd courante_temp.dta"
 
 rename quantity_unit_simplification simplification 
 
 merge m:1 export_import partner_grouping tax_department product_simplification product_revolutionempire simplification ///
	using "$dir/Données Stata/classification_quantityunit_metric2.dta", update
 
 drop if _merge==2
 drop  remarks_unit-_merge
 codebook conv_simplification_to_metric
 
 generate quantities_metric = quantity * conv_orthographic_to_simplificat * conv_simplification_to_metric
 generate unit_price_metric=value/quantities_metric
 replace  unit_price_metric=value_per_unit /conv_orthographic_to_simplificat * conv_simplification_to_metric if unit_price_metric==. 

 save "$dir/Données Stata/bdd courante_temp.dta", replace
 
 *************Pour les best guess
 gen NationalBestGuess=0
 replace NationalBestGuess=1 if (source_type=="National toutes tax_departments tous partenaires" & year==1750) /*
		*/ | (source_type=="Objet Général" & year >=1754 & year <=1782) /*
		*/ | (source_type=="Résumé")
		
 gen LocalBestGuess=0
 replace LocalBestGuess=1 if (source_type=="Local" & year!=1750) /*
		*/ | (source_type=="National toutes tax_departments tous partenaires" & year==1750)
		
save "$dir/Données Stata/bdd courante", replace
 
 *******************************************************************
 do "$dir/toflit18_data_GIT/scripts/To flag values & quantities in error.do"
 
 
 ************For best guesses
capture drop national_product_best_guess
gen national_product_best_guess = 0		
replace national_product_best_guess = 1 if (source_type=="Objet Général" & year<=1786) | ///
		(source_type=="Résumé") | source_type=="National toutes directions tous partenaires" 
egen year_CN = max(national_product_best_guess), by(year)
replace national_product_best_guess=1 if year_CN == 1 & source_type=="Compagnie des Indes" & tax_department=="France par la Compagnie des Indes"
drop year_CN

capture drop national_geography_best_guess
gen national_geography_best_guess = 0
replace national_geography_best_guess = 1 if source_type=="Tableau Général" | source_type=="Résumé"

capture drop local_product_best_guess
gen local_product_best_guess=0
replace local_product_best_guess= 1 if (source_type=="Local" & year !=1750) | (source_type== "National toutes directions tous partenaires" & year == 1750)

capture drop local_geography_best_guess
gen local_geography_best_guess=0
replace local_geography_best_guess = 1 if source_type=="National toutes directions sans produits" | ///
		(source_type== "National toutes directions tous partenaires" & year == 1750)
egen year_CN = max(local_geography_best_guess), by(year)
replace local_geography_best_guess=1 if year_CN == 1 & source_type=="Local"
drop year_CN
 ********************************************************************
use "$dir/Données Stata/bdd courante.dta", clear

 missings dropobs, force
 missings dropvars, force
 
sort source_type tax_department year export_import line_number 
order line_number source_type year tax_department partner partner_orthographic export_import ///
		product product_orthographic value quantity quantity_unit quantity_unit_ortho value_per_unit
 
 
export delimited "$dir/toflit18_data_GIT/base/bdd courante_avec_out.csv", replace
*export delimited "$dir/toflit18_data_GIT/base/$dir/toflit18_data_GIT/base/bdd courante.csv", replace
*Il est trop gros pour être envoyé dans le GIT
save "$dir/Données Stata/bdd courante_avec_out.dta", replace




drop if source_type=="Out"
export delimited "$dir/toflit18_data_GIT/base/bdd courante.csv", replace
zipfile "$dir/toflit18_data_GIT/base/bdd courante.csv", /*
		*/ saving("$dir/toflit18_data_GIT/base/bdd courante.csv.zip", replace)
drop if source_type=="Out"
save "$dir/Données Stata/bdd courante.dta", replace


/*
********
use "$dir/bdd courante", replace 

keep if year=="1750"
keep if tax_department=="Bordeaux"
keep if export_import=="Imports"
keep source source_type year export_import tax_department product partner value quantity quantity_unit value_per_unit value_minus_unit_val_x_qty remarks quantit_unit partner_corriges product_normalisees value_calcul prix_calcul
sort product partner


export delimited using "/Users/guillaumedaudin/Documents/Recherche/Commerce International Français XVIIIe.xls/Balance du commerce/Retranscriptions_Commerce_France/Pour comparaison Bordeaux 1750.csv", replace
*/



***Pour commencer une nouvelle classification



use "$dir/Données Stata/classification_product_simplification.dta", replace


 bys simplification	: keep if _n==1
keep simplification

merge m:1 simplification using "$dir/Données Stata/classification_product_sitc.dta"
drop if _merge==2
drop _merge


merge m:1 sitc using "$dir/Données Stata/classification_product_sitc_FR.dta"
drop if _merge==2
drop _merge

merge m:1 sitc using "$dir/Données Stata/classification_product_sitc_EN.dta"
drop if _merge==2
drop _merge

merge m:1 simplification using "$dir/Données Stata/classification_product_revolutionempire.dta"
drop if _merge==2
drop _merge

merge m:1 revolutionempire using "$dir/Données Stata/classification_product_RE_aggregate.dta"
drop if _merge==2
drop _merge


drop imprimatur obsolete nbr_occurences_revolutionempire nbr_occurences_sitc

sort simplification


save "$dir/Données Stata/product_pour_nouvelle_classification.dta", replace
export delimited "$dir/toflit18_data_GIT/base/product_pour_nouvelle_classification.csv", replace



*****Pour travail de Stephen Jackson sur la classification impériale
/*
use "$dir/Données Stata/bdd courante", clear
keep if source_type=="Résumé"
collapse (count) value, by(year product_simplification product_sitc_FR product_revolutionempire)
rename value observations_total
collapse (count) year (sum) observations_total , by( product_simplification product_sitc_FR product_revolutionempire)
rename year années_observées

save blif.dta, replace

use "$dir/Données Stata/bdd courante", clear
keep if source_type=="Résumé"
collapse (count) value, by(year product_revolutionempire)
rename value observations_total_bis
collapse (count) year (sum) observations_total , by( product_revolutionempire)
rename year années_observées_bis

merge 1:m product_revolutionempire using "blif.dta"
drop _merge
order product_simplification product_sitc_FR observations_total années_observées product_revolutionempire
rename product_* *
sort simplification
export delimited "$dir/toflit18_data_GIT/base/classification_product_revolutionempire.csv", replace
erase blif.dta



insheet using "$dir/toflit18_data_GIT/base/classification_product_revolutionempire.csv", clear
keep simplification	nbr_occurences_simpl revolutionempire nbr_occurences_revolutionempire
merge 1:1 simplification using "$dir/Données Stata/classification_product_sitc.dta"
drop imprimatur obsolete nbr_occurences_sitc
drop _merge
merge m:1 sitc using "$dir/Données Stata/classification_product_sitc_FR.dta"
sort simplification
drop _merge
export delimited "$dir/toflit18_data_GIT/base/classification_product_revolutionempire.csv", replace

*/





****Pour classification luxe / bas de gamme
/***Pour colloque 2019 (Renvoyé dans un .do différent)

global dir "~/Documents/Recherche/Commerce International Français XVIIIe.xls/Balance du commerce/Retranscriptions_Commerce_France"


import delimited "$dir/toflit18_data_GIT/base/classification_autre_luxe.csv",  encoding(UTF-8) /// 
			clear varname(1) stringcols(_all) case(preserve)
sort product_simplification product_sitc_FR u_conv
			
save "$dir/Données Stata/classification_autre_luxe.dta", replace

use "$dir/Données Stata/bdd courante.dta", clear
keep if u_conv=="kg" | u_conv=="pièces" | u_conv=="cm"
keep if product_sitc=="6d" | product_sitc=="6e" | product_sitc=="6f" | product_sitc=="6g" | product_sitc=="6h" | product_sitc=="6i"
*generate unit_price_metric=value/quantites_metric
drop if unit_price_metric==.
collapse (mean) mean_price=unit_price_metric (median)  median_price=unit_price_metric (sd) sd_price=unit_price_metric (count) value, by(product_simplification product_sitc_FR u_conv)
gsort product_simplification - value
rename value nbobs

gen positiondansSITC=""
gen type=""
gen position_type=""

sort product_simplification product_sitc_FR u_conv


merge 1:1 product_simplification product_sitc_FR u_conv using "$dir/Données Stata/classification_autre_luxe.dta", update force
drop obsolete
gen obsolete="non"
replace obsolete ="oui" if _merge==2
drop _merge

gsort product_sitc_FR u_conv - nbobs product_simplification

export delimited "$dir/toflit18_data_GIT/base/classification_autre_luxe.csv", replace



