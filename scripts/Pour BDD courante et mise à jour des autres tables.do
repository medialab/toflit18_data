

version 14.2

**pour mettre les bases dans stata + mettre à jour les .csv
** version 2 : pour travailler avec la nouvelle organisation

global dir "~/Documents/Recherche/Commerce International Français XVIIIe.xls/Balance du commerce/Retranscriptions_Commerce_France"

cd "$dir"
capture log using "`c(current_time)' `c(current_date)'"


foreach file in classification_country_orthographic_normalization classification_country_simplification classification_country_grouping /*
*/               bdd_marchandises_normalisees_orthographique bdd_marchandises_simplifiees /*
*/				 Units_N1 Units_N2 Units_N3  bdd_classification_edentreaty bdd_classification_NorthAmerica /*
*/				 bdd_classification_medicinales bdd_classification_hamburg bdd_grains /*
*/ 				 bdd_marchandises_sitc  bdd_directions {

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


/*

foreach file in travail_sitcrev3 sitc18_simpl {

	import delimited "toflit18_data_GIT/traitements_marchandises/SITC/`file'.csv",  encoding(UTF-8) clear varname(1) stringcols(_all)   

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
		
import delimited "toflit18_data_GIT/traitements_marchandises/SITC/Définitions sitc18_rev3.csv",  encoding(UTF-8) clear varname(1) stringcols(_all)   

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
	save "Données Stata/Définitions sitc18_rev3.dta", replace
	
	
	
	
	
	
	

 *(juste parce que c'est trop long)


import delimited "toflit18_data_GIT/base/bdd_centrale.csv",  encoding(UTF-8) clear varname(1) stringcols(_all)  
foreach variable of var marchandises pays quantity_unit {
	replace `variable'  =usubinstr(`variable',"  "," ",.)
	replace `variable'  =usubinstr(`variable',"  "," ",.)
	replace `variable'  =usubinstr(`variable',"  "," ",.)
	replace `variable'  =usubinstr(`variable',"…","...",.)
	replace `variable'  =usubinstr(`variable',"u","œ",.)
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
	replace `variable'  =usubinstr(`variable',"u","œ",.)
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

***********directions
use "bdd_centrale.dta", clear
merge m:1 direction using "bdd_directions.dta"
rename direction direction_origine
rename direction_simpl direction







***********Unit values
use "bdd_centrale.dta", clear
merge m:1 quantity_unit using "Units_N1.dta"
drop numrodeligne-total leurvaleursubtotal_1-remarkspourlesdroits
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


use "bdd_marchandises_normalisees_orthographique.dta", replace
bys marchandises : drop if _n!=1

save "bdd_marchandises_normalisees_orthographique.dta", replace

use "bdd_centrale.dta", clear
merge m:1 marchandises using "bdd_marchandises_normalisees_orthographique.dta"

drop _merge

keep marchandises marchandises_norm_ortho mériteplusdetravail

bys marchandises : keep if _n==1


save "bdd_marchandises_normalisees_orthographique.dta", replace
generate sortkey = ustrsortkey(marchandises, "fr")
sort sortkey
drop sortkey
export delimited bdd_marchandises_normalisees_orthographique.csv, replace

**
use "bdd_marchandises_simplifiees.dta", replace
bys marchandises_norm_orth : drop if _n!=1
save "bdd_marchandises_simplifiees.dta", replace

use "bdd_marchandises_normalisees_orthographique.dta", clear
merge m:1 marchandises_norm_ortho using "bdd_marchandises_simplifiees.dta"

keep marchandises_norm_ortho marchandises_simplification _merge
drop if _merge==2

drop _merge
bys marchandises_norm_ortho : keep if _n==1


save "bdd_marchandises_simplifiees.dta", replace
generate sortkey = ustrsortkey(marchandises_norm_ortho, "fr")
sort sortkey
drop sortkey
export delimited bdd_marchandises_simplifiees.csv, replace
**

foreach file_on_simp in bdd_marchandises_sitc bdd_classification_edentreaty bdd_classification_NorthAmerica bdd_classification_medicinales bdd_classification_hamburg {

	use "`file_on_simp'.dta", clear
	bys marchandises_simplification : drop if _n!=1
	save "`file_on_simp'.dta", replace

	use "bdd_marchandises_simplifiees.dta", clear
	merge m:1 marchandises_simplification using "`file_on_simp'.dta"


	drop marchandises_norm_ortho 

	*drop if _merge==2
	capture gen obsolete=""
	replace obsolete = "oui" if _merge==2
	replace obsolete = "non" if _merge!=2
	drop _merge
	capture bys marchandises_simplification : keep if _n==1

	
	capture generate sortkey = ustrsortkey(marchandises_simplification, "fr")
	sort sortkey
	drop sortkey
	

	save "`file_on_simp'.dta", replace
	export delimited `file_on_simp'.csv, replace

}


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

merge m:1 marchandises using "bdd_marchandises_normalisees_orthographique.dta"
drop if _merge==2
drop mériteplusdetravail-_merge


merge m:1 marchandises_norm_ortho using "bdd_marchandises_simplifiees.dta"
drop if _merge==2
drop _merge

merge m:1 marchandises_simplification using "bdd_marchandises_sitc.dta"
drop if _merge==2
drop _merge

merge m:1 sitc18_rev3 using "bdd_marchandises_sitc_FR.dta"
drop if _merge==2
drop _merge

merge m:1 sitc18_rev3 using "bdd_marchandises_sitc_EN.dta"
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




save "bdd courante", replace
export delimited "bdd courante.csv", replace




***********************************************************************************************************************************
*keep if quantity_unit!=""
use "bdd courante.dta", clear 

merge m:1 quantity_unit using "$dir/Units N1.dta"
* 5 _merge==2 -> viennent de Hambourg
drop if _merge==2
drop _merge 

end

generate quantites_metric = q_conv * quantit


order sourcetype year exportsimports direction marchandises_simplification pays_simplification value quantit quantity_unit quantites_metric u_conv

sort year sourcetype exportsimports direction marchandises_simplification pays_simplification

save "bdd courante", replace
export delimited "bdd courante.csv", replace




/*

merge m:1 quantity_unit marchandises_normalisees using "$dir/Units N2_v1.dta"
drop if _merge==2
drop _merge
* 3 _merge==2 -> combinaisons nouvelles marchandises_normalisees-quantity_unit viennent de Hambourg (tonneaux de beurre et d'huile de baleine, quartiers d'eau de vie)
merge m:1 quantity_unit marchandises_normalisees exportsimports pays_corriges using "$dir/Units N3_v1.dta"
drop _merge
replace quantity_unit_ajustees = N2_quantity_unit_ajustees  if N2_quantity_unit_ajustees!=""
replace quantity_unit_ajustees = N3_quantity_unit_ajustees if N3_quantity_unit_ajustees!=""
replace u_conv=N2_u_conv if N2_u_conv!=""
replace u_conv=N3_u_conv if N3_u_conv!=""
replace q_conv=N2_q_conv if N2_q_conv!=.
replace q_conv=N3_q_conv if N3_q_conv!=.
replace Remarque_unit=N2_Remarque_unit if N2_Remarque_unit!=""
replace Remarque_unit =N3_Remarque_unit if N3_Remarque_unit!=""
drop N2_u_conv N3_u_conv N2_q_conv N3_q_conv N2_Remarque_unit N3_Remarque_unit
*** à la fin il y a 64 635 observations -> les 64 633 de départ + les 3 issues des combinaisons nouvelles marchandises_normalisees-quantity_unit venant de Hambourg
*********************************

*/




save "$dir/bdd courante", replace


/*
********
use "$dir/bdd courante", replace 

keep if year=="1750"
keep if direction=="Bordeaux"
keep if exportsimports=="Imports"
keep source sourcetype year exportsimports direction marchandises pays value quantit quantity_unit prix_unitaire probleme remarks quantit_unit pays_corriges marchandises_normalisees value_calcul prix_calcul
sort marchandises pays


export delimited using "/Users/guillaumedaudin/Documents/Recherche/Commerce International Français XVIIIe.xls/Balance du commerce/Retranscriptions_Commerce_France/Pour comparaison Bordeaux 1750.csv", replace



