
clear all
set more off
*set trace on

**pour mettre les bases dans stata + mettre à jour les .csv
** version 2 : pour travailler avec la nouvelle organisation
** version 3 : permet d'utiliser les fichiers Units_N2 et Units_N3 avec les nouvelles classifications product
** ATTENTION script propre au travail sur l'Angleteerre ici

if "`c(username)'"=="Corentin" global dir "/Users/Corentin/Desktop/script/" 
cd "$dir"
*capture log using "`c(current_time)' `c(current_date)'"

*log using "Version2.txt", text replace

foreach file in classification_country_orthographic_normalization classification_country_simplification classification_country_grouping /*
*/               bdd_revised_product_normalisees_orthographique bdd_revised_product_simplifiees bdd_classification_edentreaty bdd_product_normalisees /*
*/				 Units_N1 Units_N2 Units_N3 {

	import delimited "toflit18_data/base/`file'.csv",  encoding(UTF-8) clear varname(1) stringcols(_all)   

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




foreach file in travail_sitcrev3 sitc18_simpl {

	import delimited "toflit18_data/traitements_product/SITC/`file'.csv",  encoding(UTF-8) clear varname(1) stringcols(_all)   

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
		
		
import delimited "toflit18_data/traitements_product/SITC/Définitions sitc_classification.csv",  encoding(UTF-8) clear varname(1) stringcols(_all)   

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
	save "Données Stata/Définitions sitc_classification.dta", replace
	
	
	
	
	
	
	

 *(juste parce que c'est trop long)


import delimited "toflit18_data/base/bdd_centrale.csv",  encoding(UTF-8) clear varname(1) stringcols(_all)  
foreach variable of var product partner quantity_unit {
	replace `variable'  =usubinstr(`variable',"  "," ",.)
	replace `variable'  =usubinstr(`variable',"  "," ",.)
	replace `variable'  =usubinstr(`variable',"  "," ",.)
	replace `variable'  =usubinstr(`variable',"…","...",.)
	replace `variable'  =usubinstr(`variable'," "," ",.)/*Pour espace insécable*/
	replace `variable' =usubinstr(`variable',"’","'",.)
	replace `variable'  =ustrtrim(`variable')
}

foreach variable of var quantity value value_unit { 
	replace `variable'  =usubinstr(`variable',"  "," ",.)
	replace `variable'  =usubinstr(`variable',"  "," ",.)
	replace `variable'  =usubinstr(`variable',"  "," ",.)
	replace `variable'  =usubinstr(`variable',",",".",.)
	replace `variable'  =usubinstr(`variable'," ","",.)
	replace `variable'  =usubinstr(`variable'," ","",.)
	replace `variable' =usubinstr(`variable',"’","'",.)
	capture replace `variable'  =usubinstr(`variable'," "," ",.)/*Pour espace insécable*/
	replace `variable'  =usubinstr(`variable',char(202),"",.)
	*edit  if missing(real(`variable')) & `variable' != ""
	display "---------Pas trop !-----------------"
	replace `variable' ="" if missing(real(`variable')) & `variable' != ""
}


destring line_number  total value_sub_total_1 value_sub_total_2 value_sub_total_3  value_part_of_bundle, replace
destring quantity value_unit value, replace

drop if source==""
drop if value==0 & quantit==. & value_unit==. /*Dans tous les cas regardés le 31 mai 2016, ce sont des "vrais" 0*/
drop if (value==0|value==.) & (quantit==.|quantit==0) & (value_unit==.|value_unit==0) /*idem*/
replace value=. if (value==0 & quantit!=. & quantit!=0)


**** Ce bout de code traite des 0 dans value et unit_price. Remplace des "0" par des valeurs manquantes.
***Puis calcule en les flaguant les values et les unit_price quand c'est possible.
/*
generate byte computed_value = 0
label var computed_value "Was the value computed expost based on unit price and quantities ? 0 no 1 yes"
replace computed_value=1 if (value==0 | value==.) & value_unit!=0 & value_unit!=. & quantit!=0 & quantit!=.
replace value = quantit*value_unit if computed_value==1

gen byte computed_up = 0
label var computed_up "Was the unit price computed expost based on and quantities and value ? 0 no 1 yes"
replace computed_up=1 if (value_unit==0 | value_unit==.) & value!=0 & value!=. & quantit!=0 & quantit!=.
replace value_unit = value/quantity  if computed_up==1
*/
save "Données Stata/bdd_centrale.dta", replace
export delimited "Données Stata/bdd_centrale.csv", replace




********* Procédure pour les nouveaux fichiers ************
******ATTENTION !!!! POUR GARDER LE LIEN AVEC GIT, IL FAUT ALLER DANS LIBRE OFFICE ET REFAIRE LE TRI !
*******************************

cd "$dir/Données Stata"

*******************  Unit values
use "bdd_centrale.dta", clear

merge m:1 quantity_unit using "Units_N1.dta"
drop line_number-total value_sub_total_1-remarkspourlesdroits
drop computed_value computed_up

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



*************Marchandises


use "bdd_revised_product_normalisees_orthographique.dta", replace
bys product : drop if _n!=1

save "bdd_revised_product_normalisees_orthographique.dta", replace

use "bdd_centrale.dta", clear
merge m:1 product using "bdd_revised_product_normalisees_orthographique.dta"

drop _merge

keep product orthographic_normalization_classification mériteplusdetravail

bys product : keep if _n==1


save "bdd_revised_product_normalisees_orthographique.dta", replace
generate sortkey = ustrsortkey(product, "fr")
sort sortkey
drop sortkey
export delimited bdd_revised_product_normalisees_orthographique.csv, replace

**
use "bdd_revised_product_simplifiees.dta", replace
bys product_norm_orth : drop if _n!=1
save "bdd_revised_product_simplifiees.dta", replace

use "bdd_revised_product_normalisees_orthographique.dta", clear
merge m:1 orthographic_normalization_classification using "bdd_revised_product_simplifiees.dta"

keep orthographic_normalization_classification simplification_classification _merge
drop if _merge==2

drop _merge
bys orthographic_normalization_classification : keep if _n==1


save "bdd_revised_product_simplifiees.dta", replace
generate sortkey = ustrsortkey(orthographic_normalization_classification, "fr")
sort sortkey
drop sortkey
export delimited bdd_revised_product_simplifiees.csv, replace

**

use "travail_sitcrev3.dta", clear
bys simplification_classification : drop if _n!=1
save "travail_sitcrev3.dta", replace

use "bdd_revised_product_simplifiees.dta", clear
merge m:1 simplification_classification using "travail_sitcrev3.dta"


drop orthographic_normalization_classification 

*drop if _merge==2
replace obsolete = "oui" if _merge==2
replace obsolete = "non" if _merge!=2
drop _merge
bys simplification_classification : keep if _n==1


save "travail_sitcrev3.dta", replace
generate sortkey = ustrsortkey(simplification_classification, "fr")
sort sortkey
drop sortkey
export delimited travail_sitcrev3.csv, replace


***********************************************************************************************************************************


****************************BDD courante

use "bdd_centrale.dta", clear

merge m:1 partner using "classification_country_orthographic_normalization.dta"
drop if _merge==2
drop note-_merge

merge m:1 orthographic_normalization_classification using "classification_country_simplification.dta"
drop if _merge==2


drop note-_merge

merge m:1 simplification_classification using "classification_country_grouping.dta"
drop if _merge==2
drop note-_merge


******

merge m:1 product using "bdd_revised_product_normalisees_orthographique.dta"
drop if _merge==2
drop mériteplusdetravail-_merge

merge m:1 orthographic_normalization_classification using "bdd_revised_product_simplifiees.dta"
drop if _merge==2
drop _merge

merge m:1 simplification_classification using "bdd_classification_edentreaty.dta"
drop if _merge==2
drop _merge

merge m:1 simplification_classification using "travail_sitcrev3.dta"
drop if _merge==2
drop _merge

local j 5
generate yearbis=year
foreach i of num 1797(1)1805 {
	replace yearbis = "`i'" if year =="An `j'"
	local j =`j'+1
}

replace yearbis="1806" if yearbis== "An 14 & 1806"
generate yearnum=real(yearbis)
drop yearbis
* findit labutil
labmask yearnum, values(year)
drop year
rename yearnum year

keep if year > 1769 & year < 1791 /////////////////////////////RAJOUT///////////////////

save "bdd courante", replace
export delimited "bdd courante.csv", replace

*** Pour angleterre Eden


***********************************************************************************************************************************
*keep if quantity_unit!=""

use "bdd courante.dta", clear 

*keep if grouping_classification == "Angleterre"
keep if year > 1769 & year < 1791
*drop if edentreaty_classification == ""

merge m:1 quantity_unit using "Units_N1.dta"
* 5 _merge==2 -> viennent de Hambourg
drop if _merge==2
drop _merge 

**
destring q_conv, replace

save "bdd courante", replace
export delimited "bdd courante.csv", replace

**

use "bdd_product_normalisees.dta", clear
	
	sort product_normalisees

save "bdd_product_normalisees.dta", replace

*********************** MAJ UNITS

*** MAJ fichiers N2 

use "Units_N2.dta", clear

	sort product_normalisees
	joinby product_normalisees using "bdd_product_normalisees.dta", unmatched(master)  
	drop _merge
	drop product_prix	dutchtranslation	englishproduct	unit	alternativenames	/* 
*/	source_rg_1774	source_rgbase	source_france	source_sound	source_hambourg	v14	v15	/*
*/  remarques	nbr_lignes_fr	nbr_lignes_hambourg	blok	product_normalisees_inter

*

	merge m:1 product using "bdd_revised_product_normalisees_orthographique.dta"
	drop if _merge==2
	drop _merge

*
	
	merge m:1 orthographic_normalization_classification using "bdd_revised_product_simplifiees.dta"
	drop if _merge==2
	drop _merge	
	
*


drop if simplification_classification==""

drop product_normalisees
drop product
drop orthographic_normalization_classification

bys quantity_unit simplification_classification : keep if _n==1

rename quantity_unit quantity_unit_orthographe

save "Units_N2_revised.dta", replace


*** MAJ fichiers N3

use "Units_N3.dta", clear

	rename partner_regroupes grouping_classification

	sort product_normalisees
	joinby product_normalisees using "bdd_product_normalisees.dta", unmatched(master)  
	drop _merge	
	drop product_prix	dutchtranslation	englishproduct	unit	alternativenames	/* 
*/	source_rg_1774	source_rgbase	source_france	source_sound	source_hambourg	v14	v15	/*
*/  remarques	nbr_lignes_fr	nbr_lignes_hambourg	blok	product_normalisees_inter

*

	merge m:1 product using "/Users/Corentin/Desktop/script/Données Stata/bdd_revised_product_normalisees_orthographique.dta"
	drop if _merge==2
	drop _merge

*

	merge m:1 orthographic_normalization_classification using "bdd_revised_product_simplifiees.dta"
	drop if _merge==2
	drop _merge	

*

drop product_normalisees
drop product
drop orthographic_normalization_classification

bys quantity_unit simplification_classification export_import grouping_classification : keep if _n==1

rename quantity_unit quantity_unit_orthographe

save "Units_N3_revised.dta", replace


********************* MERGE UNITS
use "bdd courante.dta", clear 

merge m:1 quantity_unit_orthographe simplification_classification using "Units_N2_revised.dta"
drop if _merge==2
drop _merge
* 3 _merge==2 -> combinaisons nouvelles product_normalisees-quantity_unit viennent de Hambourg (tonneaux de beurre et d'huile de baleine, quartiers d'eau de vie)

su q_conv 

merge m:1 quantity_unit_orthographe simplification_classification export_import grouping_classification using "Units_N3_revised.dta"
drop if _merge==2
drop _merge
replace quantity_unit_ajustees = n2_quantity_unit_ajustees  if n2_quantity_unit_ajustees!=""
replace quantity_unit_ajustees = n3_quantity_unit_ajustees if n3_quantity_unit_ajustees!=""
replace u_conv=n2_u_conv if n2_u_conv!=""
replace u_conv=n3_u_conv if n3_u_conv!=""

destring n2_q_conv, replace
destring n3_q_conv, replace


replace q_conv=n2_q_conv if n2_q_conv!=.
replace q_conv=n3_q_conv if n3_q_conv!=.
replace remarque_unit=n2_remarque_unit if n2_remarque_unit!=""
replace remarque_unit =n3_remarque_unit if n3_remarque_unit!=""
drop n2_u_conv n3_u_conv n2_q_conv n3_q_conv n2_remarque_unit n3_remarque_unit
*** à la fin il y a 64 635 observations -> les 64 633 de départ + les 3 issues des combinaisons nouvelles product_normalisees-quantity_unit venant de Hambourg
*************************** ******
su q_conv 
*


*keep if grouping_classification == "Angleterre"
*keep if year > 1769 & year < 1791
*drop if edentreaty_classification == ""

generate quantites_metric = q_conv * quantit

save "bdd courante", replace
export delimited "bdd courante.csv", replace

*drop if quantity == .
*drop if quantity_unit == ""
su quantites_metric

*save "/Users/Corentin/Desktop/script/Base_Eden_Mesure.dta", replace
save "/Users/Corentin/Desktop/script/Base_Eden_Mesure_Totale.dta", replace

*log close
/*
********************* Units

use "bdd_centrale.dta", clear

merge m:1 quantity_unit using "Units_N2_revised.dta"
drop line_number-total value_sub_total_1-remarkspourlesdroits
drop computed_value computed_up

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
*save "Units_N2.dta", replace
generate sortkey = ustrsortkey(quantity_unit, "fr")
sort sortkey
drop sortkey
export delimited "Units_N2_revised.csv", replace

***

use "bdd_centrale.dta", clear

merge m:1 quantity_unit using "Units_N3_revised.dta"
drop line_number-total value_sub_total_1-remarkspourlesdroits
drop computed_value computed_up

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
*save "Units_N3.dta", replace
generate sortkey = ustrsortkey(quantity_unit, "fr")
sort sortkey
drop sortkey
export delimited "Units_N3_revised.csv", replace


