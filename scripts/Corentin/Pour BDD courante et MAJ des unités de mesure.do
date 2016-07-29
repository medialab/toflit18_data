
clear all
set more off
*set trace on

**pour mettre les bases dans stata + mettre à jour les .csv
** version 2 : pour travailler avec la nouvelle organisation
** version 3 : permet d'utiliser les fichiers Units_N2 et Units_N3 avec les nouvelles classifications marchandises
** ATTENTION script propre au travail sur l'Angleteerre ici

if "`c(username)'"=="Corentin" global dir "/Users/Corentin/Desktop/script/" 
cd "$dir"
*capture log using "`c(current_time)' `c(current_date)'"

*log using "Version2.txt", text replace

foreach file in classification_country_orthographic_normalization classification_country_simplification classification_country_grouping /*
*/               bdd_revised_marchandises_normalisees_orthographique bdd_revised_marchandises_simplifiees bdd_classification_edentreaty bdd_marchandises_normalisees /*
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

	import delimited "toflit18_data/traitements_marchandises/SITC/`file'.csv",  encoding(UTF-8) clear varname(1) stringcols(_all)   

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
		
		
import delimited "toflit18_data/traitements_marchandises/SITC/Définitions sitc18_rev3.csv",  encoding(UTF-8) clear varname(1) stringcols(_all)   

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
	save "Données Stata/Définitions sitc18_rev3.dta", replace
	
	
	
	
	
	
	

 *(juste parce que c'est trop long)


import delimited "toflit18_data/base/bdd_centrale.csv",  encoding(UTF-8) clear varname(1) stringcols(_all)  
foreach variable of var marchandises pays quantity_unit {
	replace `variable'  =usubinstr(`variable',"  "," ",.)
	replace `variable'  =usubinstr(`variable',"  "," ",.)
	replace `variable'  =usubinstr(`variable',"  "," ",.)
	replace `variable'  =usubinstr(`variable',"…","...",.)
	replace `variable'  =usubinstr(`variable'," "," ",.)/*Pour espace insécable*/
	replace `variable' =usubinstr(`variable',"’","'",.)
	replace `variable'  =ustrtrim(`variable')
}

foreach variable of var quantit value prix_unitaire { 
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


destring numrodeligne  total leurvaleursubtotal_1 leurvaleursubtotal_2 leurvaleursubtotal_3  doubleaccounts, replace
destring quantit prix_unitaire value, replace

drop if source==""
drop if value==0 & quantit==. & prix_unitaire==. /*Dans tous les cas regardés le 31 mai 2016, ce sont des "vrais" 0*/
drop if (value==0|value==.) & (quantit==.|quantit==0) & (prix_unitaire==.|prix_unitaire==0) /*idem*/
replace value=. if (value==0 & quantit!=. & quantit!=0)


**** Ce bout de code traite des 0 dans value et unit_price. Remplace des "0" par des valeurs manquantes.
***Puis calcule en les flaguant les values et les unit_price quand c'est possible.
/*
generate byte computed_value = 0
label var computed_value "Was the value computed expost based on unit price and quantities ? 0 no 1 yes"
replace computed_value=1 if (value==0 | value==.) & prix_unitaire!=0 & prix_unitaire!=. & quantit!=0 & quantit!=.
replace value = quantit*prix_unitaire if computed_value==1

gen byte computed_up = 0
label var computed_up "Was the unit price computed expost based on and quantities and value ? 0 no 1 yes"
replace computed_up=1 if (prix_unitaire==0 | prix_unitaire==.) & value!=0 & value!=. & quantit!=0 & quantit!=.
replace prix_unitaire = value/quantit  if computed_up==1
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
drop numrodeligne-total leurvaleursubtotal_1-remarkspourlesdroits
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
merge m:1 pays using "classification_country_orthographic_normalization.dta"
drop numrodeligne-marchandises value-remarkspourlesdroits


drop _merge
bys pays : keep if _n==1
keep pays pays_norm_ortho note
save "classification_country_orthographic_normalization.dta", replace
generate sortkey = ustrsortkey(pays, "fr")
sort sortkey
drop sortkey
export delimited classification_country_orthographic_normalization.csv, replace




**
use "classification_country_orthographic_normalization.dta", clear
drop note
merge m:1 pays_norm_ortho using "classification_country_simplification.dta"
drop if _merge==2



drop _merge

bys pays_norm_ortho : keep if _n==1
keep pays_norm_ortho pays_simplification note
save "classification_country_simplification.dta", replace
generate sortkey = ustrsortkey(pays_norm_ortho, "fr")
sort sortkey
drop sortkey
export delimited classification_country_simplification.csv, replace

**

use "classification_country_simplification.dta", clear
drop note
merge m:1 pays_simplification using "classification_country_grouping.dta"

drop if _merge==2
drop _merge

bys pays_simplification : keep if _n==1
keep pays_simplification pays_grouping note
save "classification_country_grouping.dta", replace
generate sortkey = ustrsortkey(pays_simplification, "fr")
sort sortkey
drop sortkey
export delimited classification_country_grouping.csv, replace



*************Marchandises


use "bdd_revised_marchandises_normalisees_orthographique.dta", replace
bys marchandises : drop if _n!=1

save "bdd_revised_marchandises_normalisees_orthographique.dta", replace

use "bdd_centrale.dta", clear
merge m:1 marchandises using "bdd_revised_marchandises_normalisees_orthographique.dta"

drop _merge

keep marchandises marchandises_norm_ortho mériteplusdetravail

bys marchandises : keep if _n==1


save "bdd_revised_marchandises_normalisees_orthographique.dta", replace
generate sortkey = ustrsortkey(marchandises, "fr")
sort sortkey
drop sortkey
export delimited bdd_revised_marchandises_normalisees_orthographique.csv, replace

**
use "bdd_revised_marchandises_simplifiees.dta", replace
bys marchandises_norm_orth : drop if _n!=1
save "bdd_revised_marchandises_simplifiees.dta", replace

use "bdd_revised_marchandises_normalisees_orthographique.dta", clear
merge m:1 marchandises_norm_ortho using "bdd_revised_marchandises_simplifiees.dta"

keep marchandises_norm_ortho marchandises_simplification _merge
drop if _merge==2

drop _merge
bys marchandises_norm_ortho : keep if _n==1


save "bdd_revised_marchandises_simplifiees.dta", replace
generate sortkey = ustrsortkey(marchandises_norm_ortho, "fr")
sort sortkey
drop sortkey
export delimited bdd_revised_marchandises_simplifiees.csv, replace

**

use "travail_sitcrev3.dta", clear
bys marchandises_simplification : drop if _n!=1
save "travail_sitcrev3.dta", replace

use "bdd_revised_marchandises_simplifiees.dta", clear
merge m:1 marchandises_simplification using "travail_sitcrev3.dta"


drop marchandises_norm_ortho 

*drop if _merge==2
replace obsolete = "oui" if _merge==2
replace obsolete = "non" if _merge!=2
drop _merge
bys marchandises_simplification : keep if _n==1


save "travail_sitcrev3.dta", replace
generate sortkey = ustrsortkey(marchandises_simplification, "fr")
sort sortkey
drop sortkey
export delimited travail_sitcrev3.csv, replace


***********************************************************************************************************************************


****************************BDD courante

use "bdd_centrale.dta", clear

merge m:1 pays using "classification_country_orthographic_normalization.dta"
drop if _merge==2
drop note-_merge

merge m:1 pays_norm_ortho using "classification_country_simplification.dta"
drop if _merge==2


drop note-_merge

merge m:1 pays_simplification using "classification_country_grouping.dta"
drop if _merge==2
drop note-_merge


******

merge m:1 marchandises using "bdd_revised_marchandises_normalisees_orthographique.dta"
drop if _merge==2
drop mériteplusdetravail-_merge

merge m:1 marchandises_norm_ortho using "bdd_revised_marchandises_simplifiees.dta"
drop if _merge==2
drop _merge

merge m:1 marchandises_simplification using "bdd_classification_edentreaty.dta"
drop if _merge==2
drop _merge

merge m:1 marchandises_simplification using "travail_sitcrev3.dta"
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

*keep if pays_grouping == "Angleterre"
keep if year > 1769 & year < 1791
*drop if eden_classification == ""

merge m:1 quantity_unit using "Units_N1.dta"
* 5 _merge==2 -> viennent de Hambourg
drop if _merge==2
drop _merge 

**
destring q_conv, replace

save "bdd courante", replace
export delimited "bdd courante.csv", replace

**

use "bdd_marchandises_normalisees.dta", clear
	
	sort marchandises_normalisees

save "bdd_marchandises_normalisees.dta", replace

*********************** MAJ UNITS

*** MAJ fichiers N2 

use "Units_N2.dta", clear

	sort marchandises_normalisees
	joinby marchandises_normalisees using "bdd_marchandises_normalisees.dta", unmatched(master)  
	drop _merge
	drop product_prix	dutchtranslation	englishproduct	unit	alternativenames	/* 
*/	source_rg_1774	source_rgbase	source_france	source_sound	source_hambourg	v14	v15	/*
*/  remarques	nbr_lignes_fr	nbr_lignes_hambourg	blok	marchandises_normalisees_inter

*

	merge m:1 marchandises using "bdd_revised_marchandises_normalisees_orthographique.dta"
	drop if _merge==2
	drop _merge

*
	
	merge m:1 marchandises_norm_ortho using "bdd_revised_marchandises_simplifiees.dta"
	drop if _merge==2
	drop _merge	
	
*


drop if marchandises_simplification==""

drop marchandises_normalisees
drop marchandises
drop marchandises_norm_ortho

bys quantity_unit marchandises_simplification : keep if _n==1

rename quantity_unit quantity_unit_orthographe

save "Units_N2_revised.dta", replace


*** MAJ fichiers N3

use "Units_N3.dta", clear

	rename pays_regroupes pays_grouping

	sort marchandises_normalisees
	joinby marchandises_normalisees using "bdd_marchandises_normalisees.dta", unmatched(master)  
	drop _merge	
	drop product_prix	dutchtranslation	englishproduct	unit	alternativenames	/* 
*/	source_rg_1774	source_rgbase	source_france	source_sound	source_hambourg	v14	v15	/*
*/  remarques	nbr_lignes_fr	nbr_lignes_hambourg	blok	marchandises_normalisees_inter

*

	merge m:1 marchandises using "/Users/Corentin/Desktop/script/Données Stata/bdd_revised_marchandises_normalisees_orthographique.dta"
	drop if _merge==2
	drop _merge

*

	merge m:1 marchandises_norm_ortho using "bdd_revised_marchandises_simplifiees.dta"
	drop if _merge==2
	drop _merge	

*

drop marchandises_normalisees
drop marchandises
drop marchandises_norm_ortho

bys quantity_unit marchandises_simplification exportsimports pays_grouping : keep if _n==1

rename quantity_unit quantity_unit_orthographe

save "Units_N3_revised.dta", replace


********************* MERGE UNITS
use "bdd courante.dta", clear 

merge m:1 quantity_unit_orthographe marchandises_simplification using "Units_N2_revised.dta"
drop if _merge==2
drop _merge
* 3 _merge==2 -> combinaisons nouvelles marchandises_normalisees-quantity_unit viennent de Hambourg (tonneaux de beurre et d'huile de baleine, quartiers d'eau de vie)

su q_conv 

merge m:1 quantity_unit_orthographe marchandises_simplification exportsimports pays_grouping using "Units_N3_revised.dta"
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
*** à la fin il y a 64 635 observations -> les 64 633 de départ + les 3 issues des combinaisons nouvelles marchandises_normalisees-quantity_unit venant de Hambourg
*************************** ******
su q_conv 
*


*keep if pays_grouping == "Angleterre"
*keep if year > 1769 & year < 1791
*drop if eden_classification == ""

generate quantites_metric = q_conv * quantit

save "bdd courante", replace
export delimited "bdd courante.csv", replace

*drop if quantit == .
*drop if quantity_unit == ""
su quantites_metric

*save "/Users/Corentin/Desktop/script/Base_Eden_Mesure.dta", replace
save "/Users/Corentin/Desktop/script/Base_Eden_Mesure_Totale.dta", replace

*log close
/*
********************* Units

use "bdd_centrale.dta", clear

merge m:1 quantity_unit using "Units_N2_revised.dta"
drop numrodeligne-total leurvaleursubtotal_1-remarkspourlesdroits
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
drop numrodeligne-total leurvaleursubtotal_1-remarkspourlesdroits
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


