

 version 15.1

 
**pour mettre les bases dans stata + mettre à jour les .csv
** version 2 : pour travailler avec la nouvelle organisation

global dir "~/Documents/Recherche/Commerce International Français XVIIIe.xls/Balance du commerce/Retranscriptions_Commerce_France"

if "`c(username)'"=="Matthias" global dir "/Users/Matthias/"

if "`c(username)'"=="Tirindelli" global dir "/Users/Tirindelli/Google Drive/ETE/Thesis"

if "`c(username)'"=="federico.donofrio" global dir "C:\Users\federico.donofrio\Documents\GitHub"

if "`c(username)'"=="pierr" global dir "/Users/pierr/Documents/Toflit/"

cd "$dir"



foreach file in classification_country_orthographic classification_country_simplification classification_country_grouping /*
*/				 classification_country_obrien classification_country_wars /*
*/				 classification_country_sourcename classification_country_africa /*
*/               classification_product_orthographic classification_product_simplification /*
*/				 /*Units_N1 Units_N2 Units_N3*/  classification_product_edentreaty classification_product_canada /*
*/				 classification_product_medicinales classification_product_hamburg classification_product_grains /*
*/ 				 classification_product_sitc  classification_product_coffee classification_product_porcelaine /*
*/				 bdd_directions classification_product_sitc_FR classification_product_sitc_EN /*
*/				 classification_product_sitc_simplEN /* 
*/ 				 Units_Normalisation_Orthographique Units_Normalisation_Metrique1 Units_Normalisation_Metrique2 /*
*/				 bdd_origine classification_product_coton	classification_product_ulrich /*
*/ 				 classification_product_v_glass_beads classification_product_beaver/*
*/				 classification_product_RE_aggregate classification_product_revolutionempire {

	import delimited "$dir/toflit18_data_GIT/base/`file'.csv",  encoding(UTF-8) /// 
			clear varname(1) stringcols(_all) case(preserve) 

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
use "Données Stata/Units_N1.dta", clear
destring q_conv, replace
save "Données Stata/Units_N1.dta", replace
*/

use "Données Stata/Units_Normalisation_Metrique1.dta", clear
destring q_conv, replace
save "Données Stata/Units_Normalisation_Metrique1.dta", replace

use "Données Stata/Units_Normalisation_Metrique2.dta", clear
destring q_conv, replace
save "Données Stata/Units_Normalisation_Metrique2.dta", replace

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
	
	
/*	
import delimited "$dir/toflit18_data_GIT/traitements_marchandises/SITC/Définitions sitc_classification.csv",  encoding(UTF-8) clear varname(1) stringcols(_all)   

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


import delimited "toflit18_data_GIT/base/bdd_centrale.csv",  encoding(UTF-8) clear varname(1) stringcols(_all)  
foreach variable of var marchandises pays quantity_unit {
	replace `variable'  =usubinstr(`variable',"  "," ",.)
	replace `variable'  =usubinstr(`variable',"  "," ",.)
	replace `variable'  =usubinstr(`variable',"  "," ",.)
	replace `variable'  =usubinstr(`variable',"…","...",.)
	replace `variable'  =usubinstr(`variable',"u","œ",.)
	replace `variable'  =usubinstr(`variable'," "," ",.)/*Pour espace insécable*/
	replace `variable'  =usubinstr(`variable',"’","'",.)
	replace `variable'  =ustrtrim(`variable')
}

foreach variable of var quantit value prix_unitaire probleme { 
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


destring total leurvaleursubtotal_1 leurvaleursubtotal_2 leurvaleursubtotal_3  doubleaccounts, replace
destring quantit prix_unitaire value, replace

drop if source==""
drop if value==0 & quantit==. & prix_unitaire==. /*Dans tous les cas regardés le 31 mai 2016, ce sont des "vrais" 0*/
drop if (value==0|value==.) & (quantit==.|quantit==0) & (prix_unitaire==.|prix_unitaire==0) /*idem*/
replace value=. if (value==0 & quantit!=. & quantit!=0)

**Je mets des majuscules à toutes les "marchandises" de la source
replace marchandises = upper(substr(marchandises,1,1))+substr(marchandises,2,.)


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
export delimited "$dir/toflit18_data_GIT/base/Units_Normalisation_Orthographique.csv", replace

use "Units_Normalisation_Orthographique.dta", clear
merge m:1 quantity_unit_ortho using "Units_Normalisation_Metrique1.dta"
keep quantity_unit_ortho quantity_unit_ajustees u_conv q_conv remarque_unit incertitude_unit ///
source_hambourg missing needs_more_details source_bdc _merge

foreach variable of var quantity_unit_ortho quantity_unit_ajustees  {
	capture drop nbr_bdc_`variable'
	generate nbr_bdc_`variable'=0
	label variable nbr_bdc_`variable' "Nbr de flux avec ce `variable' dans la source française"
	bys `variable' : replace nbr_bdc_`variable'=_N if (_merge==3 | _merge==1)
}

drop _merge

egen source_bdc_new = max(source_bdc), by(quantity_unit_ortho)
drop source_bdc
rename source_bdc_new source_bdc
order quantity_unit_ortho source_bdc nbr_bdc_quantity_unit_ortho quantity_unit_ajustees nbr_bdc_quantity_unit_ajustees ///
	u_conv q_conv incertitude_unit source_hambourg missing needs_more_details  remarque_unit

bys quantity_unit_ortho : keep if _n==1
save "Units_Normalisation_Metrique1.dta", replace
generate sortkey = ustrsortkey(quantity_unit_ortho, "fr")
sort sortkey
drop sortkey
export delimited "$dir/toflit18_data_GIT/base/Units_Normalisation_Metrique1.csv", replace

/*See below for "Units_Normalisation_Metrique2.dta"*/


/*
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
export delimited "$dir/toflit18_data_GIT/base/Units_N1.csv", replace
*/

******* Direction et origine
use "bdd_centrale.dta", clear
merge m:1 direction using "bdd_directions.dta"
keep direction direction_simpl
bys direction : gen nbr_occurence=_N
bys direction : keep if _n==1
save "bdd_directions.dta", replace
generate sortkey = ustrsortkey(direction, "fr")
sort sortkey
drop sortkey
export delimited "$dir/toflit18_data_GIT/base/bdd_directions.csv", replace


use "bdd_centrale.dta", clear
merge m:1 origine using "bdd_origine.dta"
keep origine origine_norm_ortho
bys origine : gen nbr_occurence=_N
bys origine : keep if _n==1
save "bdd_origine.dta", replace
generate sortkey = ustrsortkey(origine, "fr")
sort sortkey
drop sortkey
export delimited "$dir/toflit18_data_GIT/base/bdd_origine.csv", replace





****Pays*************
use "bdd_centrale.dta", clear
rename source source_doc
rename pays source
merge m:1 source using "classification_country_orthographic.dta"
drop numrodeligne-marchandises value-remarkspourlesdroits

capture drop nbr_occurences_source
capture drop nbr_occurences_ortho

drop _merge
bys source : gen nbr_occurences_source=_N
bys orthographic : gen nbr_occurences_ortho=_N 
bys source : keep if _n==1
keep source orthographic note nbr_occurences_source nbr_occurences_ortho
order source s nbr_occurences_source orthographic nbr_occurences_ortho note
save "classification_country_orthographic.dta", replace
generate sortkey = ustrsortkey(source, "fr")
sort sortkey
drop sortkey
export delimited "$dir/toflit18_data_GIT/base/classification_country_orthographic.csv", replace




**
use "classification_country_orthographic.dta", clear
drop note
merge m:1 orthographic using "classification_country_simplification.dta"
drop if _merge==2
drop _merge

capture drop nbr_occurences_simpl

bys simplification : egen nbr_occurences_simpl=total(nbr_occurences_source) 

bys orthographic : keep if _n==1
keep orthographic simplification nbr_occurences_ortho nbr_occurences_simpl note

save "classification_country_simplification.dta", replace
generate sortkey = ustrsortkey(orthographic, "fr")
sort sortkey
drop sortkey
export delimited "$dir/toflit18_data_GIT/base/classification_country_simplification.csv", replace

**

use "classification_country_simplification.dta", clear
drop note
merge m:1 simplification using "classification_country_grouping.dta"

drop if _merge==2
drop _merge

capture drop nbr_occurences_grouping
bys grouping : egen nbr_occurences_grouping=total(nbr_occurences_ortho)

bys simplification : keep if _n==1
keep simplification grouping nbr_occurences_simpl nbr_occurences_grouping note
save "classification_country_grouping.dta", replace
generate sortkey = ustrsortkey(simplification, "fr")
sort sortkey
drop sortkey
export delimited "$dir/toflit18_data_GIT/base/classification_country_grouping.csv", replace

** 
use "classification_country_simplification.dta", clear
drop note
merge m:1 simplification using "classification_country_obrien.dta"

drop if _merge==2
drop _merge

capture drop nbr_occurences_obrien
bys obrien : egen nbr_occurences_obrien=total(nbr_occurences_ortho)

bys simplification : keep if _n==1
keep simplification obrien nbr_occurences_simpl nbr_occurences_obrien note
save "classification_country_obrien.dta", replace
generate sortkey = ustrsortkey(simplification, "fr")
sort sortkey
drop sortkey
export delimited "$dir/toflit18_data_GIT/base/classification_country_obrien.csv", replace


** 
use "classification_country_simplification.dta", clear
drop note
merge m:1 simplification using "classification_country_wars.dta"

drop if _merge==2
drop _merge

capture drop nbr_occurences_wars
bys wars : egen nbr_occurences_wars=total(nbr_occurences_ortho)

bys simplification : keep if _n==1
keep simplification wars nbr_occurences_simpl nbr_occurences_wars note
save "classification_country_wars.dta", replace
generate sortkey = ustrsortkey(simplification, "fr")
sort sortkey
drop sortkey
export delimited "$dir/toflit18_data_GIT/base/classification_country_wars.csv", replace

** 
use "classification_country_simplification.dta", clear
drop note
merge m:1 simplification using "classification_country_sourcename.dta"

drop if _merge==2
drop _merge

capture drop nbr_occurences_sourcename
bys sourcename : egen nbr_occurences_sourcename=total(nbr_occurences_ortho)

bys simplification : keep if _n==1
keep simplification sourcename nbr_occurences_simpl nbr_occurences_sourcename note
save "classification_country_sourcename.dta", replace
generate sortkey = ustrsortkey(simplification, "fr")
sort sortkey
drop sortkey
export delimited "$dir/toflit18_data_GIT/base/classification_country_sourcename.csv", replace

*******************************

use "classification_country_simplification.dta", clear
drop note
merge m:1 simplification using "classification_country_africa.dta"

drop if _merge==2
drop _merge

capture drop nbr_occurences_africa
bys africa : egen nbr_occurences_africa=total(nbr_occurences_ortho)

bys simplification : keep if _n==1
keep simplification africa nbr_occurences_simpl nbr_occurences_africa note
save "classification_country_africa.dta", replace
generate sortkey = ustrsortkey(simplification, "fr")
sort sortkey
drop sortkey
export delimited "$dir/toflit18_data_GIT/base/classification_country_africa.csv", replace




*************Marchandises


use "classification_product_orthographic.dta", replace

bys source : drop if _n!=1

save "classification_product_orthographic.dta", replace

use "bdd_centrale.dta", clear
rename source source_doc
rename marchandises source
merge m:1 source using "classification_product_orthographic.dta"
capture drop nbr_occurences_source
capture drop nbr_occurences_ortho
bys source : gen nbr_occurences_source=_N
bys orthographic : gen nbr_occurences_ortho=_N


drop _merge

keep source orthographic note nbr_occurences_source  nbr_occurences_ortho
order source nbr_occurences_source orthographic nbr_occurences_ortho

bys source : keep if _n==1
save "classification_product_orthographic.dta", replace
generate sortkey = ustrsortkey(source, "fr")
sort sortkey
drop sortkey
export delimited "$dir/toflit18_data_GIT/base/classification_product_orthographic.csv", replace

**
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
generate sortkey = ustrsortkey(orthographic, "fr")
sort sortkey
drop sortkey
export delimited "$dir/toflit18_data_GIT/base/classification_product_simplification.csv", replace
**

foreach file_on_simp in sitc edentreaty canada medicinales hamburg /*
		*/ grains  coton ulrich coffee porcelaine v_glass_beads revolutionempire beaver {

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

	
	capture generate sortkey = ustrsortkey(simplification, "fr")
	sort sortkey
	drop sortkey
	

	save "classification_product_`file_on_simp'.dta", replace
	export delimited "$dir/toflit18_data_GIT/base/classification_product_`file_on_simp'.csv", replace

}


***********************************************************************************************************************************



****************************BDD courante

use "bdd_centrale.dta", clear


merge m:1 direction using "bdd_directions.dta"
rename direction direction_origine
rename direction_simpl direction
drop _merge nbr_occurence

merge m:1 origine using "bdd_origine.dta"
rename origine origine_origine
rename origine_norm_ortho origine
drop _merge nbr_occurence


rename source source_doc
rename pays source
merge m:1 source using "classification_country_orthographic.dta"
rename source pays
rename source_doc source
drop if _merge==2
drop note-_merge

merge m:1 orthographic using "classification_country_simplification.dta"
drop if _merge==2


drop note-_merge

foreach class_name in grouping obrien ///
			sourcename wars africa {

	merge m:1 simplification using "classification_country_`class_name'.dta"
	drop if _merge==2
	drop note-_merge
	rename `class_name' country_`class_name'
}
rename simplification country_simplification
rename orthographi country_orthographic

******

rename source source_doc
rename marchandises source
merge m:1 source using "classification_product_orthographic.dta"
rename source product
rename source_doc source
drop if _merge==2
drop note-_merge

merge m:1 orthographic using "classification_product_simplification"
drop if _merge==2
drop nbr_occure* _merge

foreach class_name in sitc edentreaty ///
				canada medicinales hamburg ///
				grains  coton ulrich ///
				coffee porcelaine ///
				v_glass_beads revolutionempire beaver {

	merge m:1 simplification using "classification_product_`class_name'.dta"
	drop if _merge==2
	drop nbr_occure* _merge
	rename `class_name' product_`class_name'
}
rename simplification product_simplification
rename orthographi product_orthographic



foreach class_name in sitc_FR sitc_EN sitc_simplEN {

	capture drop product_`class_name'
	capture drop sitc
	rename product_sitc sitc
	merge m:1 sitc using "classification_product_`class_name'.dta"
	rename sitc product_sitc
	drop if _merge==2
	drop _merge
	rename `class_name' product_`class_name'
}


capture drop product_RE_aggregate
rename product_revolutionempire revolutionempire
merge m:1 revolutionempire using "classification_product_RE_aggregate.dta"
rename revolutionempire product_revolutionempire
drop if _merge==2
drop _merge
rename RE_aggregate product_RE_aggregate

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




 merge m:1 quantity_unit using "$dir/Données Stata/Units_Normalisation_Orthographique.dta"
 replace quantity_unit_ortho="unité manquante" if quantity_unit==""
 drop if _merge==2
 drop _merge source_bdc nbr_bdc_quantity_unit nbr_bdc_quantity_unit_ortho
 
 merge m:1 quantity_unit_ortho using "$dir/Données Stata/Units_Normalisation_Metrique1.dta"
 replace quantity_unit_ajustees="unité manquante" if quantity_unit_ortho=="unité manquante"
 replace u_conv="unité manquante" if quantity_unit_ortho=="unité manquante"
 drop if _merge==2
 drop _merge source_bdc nbr_bdc_quantity_unit_ortho nbr_bdc_quantity_unit_ajustees source_hambourg missing
 codebook q_conv
 
 save "$dir/Données Stata/bdd courante_temp.dta", replace
 keep if needs_more_details=="1"
 keep exportsimports country_grouping direction product_simplification quantity_unit_ortho
 bys exportsimports country_grouping direction product_simplification quantity_unit_ortho: keep if _n==1
 merge 1:1 exportsimports country_grouping direction product_simplification quantity_unit_ortho ///
	using "$dir/Données Stata/Units_Normalisation_Metrique2.dta"

 drop _merge
 sort quantity_unit_ortho product_simplification exportsimports direction country_grouping
 save "$dir/Données Stata/Units_Normalisation_Metrique2.dta", replace
 export delimited "$dir/toflit18_data_GIT/base/Units_Normalisation_Metrique2.csv", replace
 
 use "$dir/Données Stata/bdd courante_temp.dta", clear
 erase "$dir/Données Stata/bdd courante_temp.dta"
 
 merge m:1 exportsimports country_grouping direction product_simplification quantity_unit_ortho ///
	using "$dir/Données Stata/Units_Normalisation_Metrique2.dta", update
 
 drop if _merge==2
 drop  remarque_unit-_merge
 codebook q_conv
 
 generate quantities_metric = q_conv * quantit
 generate unit_price_metric=value/quantities_metric
 
 save "$dir/Données Stata/bdd courante", replace

 
 *******************************************************************
 do "$dir/toflit18_data_GIT/scripts/To flag values & quantities in error.do"
 
 
 ********************************************************************

 missings dropobs, force
 missings dropvars, force
 

export delimited "$dir/toflit18_data_GIT/base/bdd courante_avec_out.csv", replace
*export delimited "$dir/toflit18_data_GIT/base/$dir/toflit18_data_GIT/base/bdd courante.csv", replace
*Il est trop gros pour être envoyé dans le GIT
preserve
drop if sourcetype=="Out"
export delimited "$dir/toflit18_data_GIT/base/bdd courante.csv", replace
restore

sort sourcetype direction year exportsimports numrodeligne 
order numrodeligne sourcetype year direction pays country_orthographic exportsimports ///
		product product_orthographic value quantit quantity_unit quantity_unit_ortho prix_unitaire

save "$dir/Données Stata/bdd courante_avec_out.dta", replace
drop if sourcetype=="Out"
save "$dir/Données Stata/bdd courante.dta", replace


/*
********
use "$dir/bdd courante", replace 

keep if year=="1750"
keep if direction=="Bordeaux"
keep if exportsimports=="Imports"
keep source sourcetype year exportsimports direction marchandises pays value quantit quantity_unit prix_unitaire probleme remarks quantit_unit pays_corriges marchandises_normalisees value_calcul prix_calcul
sort marchandises pays


export delimited using "/Users/guillaumedaudin/Documents/Recherche/Commerce International Français XVIIIe.xls/Balance du commerce/Retranscriptions_Commerce_France/Pour comparaison Bordeaux 1750.csv", replace
*/

*****************************Pour marchandises_sourcees.csv



use "$dir/Données Stata/classification_product_orthographic.dta", replace
rename source marchandises
keep marchandises
merge 1:m marchandises using "$dir/Données Stata/Belgique/RG_base.dta"
generate sourceBEL=0
generate sourceBEL_nbr1=0
bys marchandises : replace sourceBEL_nbr1=_N if _merge==3
bys marchandises : keep if _n==1
replace sourceBEL=1 if _merge==3
keep marchandises sourceBEL sourceBEL_nbr1

merge 1:m marchandises using "$dir/Données Stata/Belgique/RG_1774.dta"
generate sourceBEL_nbr2=0
bys marchandises : replace sourceBEL_nbr2=_N if _merge==3
bys marchandises : keep if _n==1
replace sourceBEL=1 if _merge==3
generate sourceBEL_nbr=sourceBEL_nbr1+sourceBEL_nbr2
keep marchandises sourceBEL  sourceBEL_nbr

merge 1:m marchandises using "$dir/Données Stata/bdd_centrale.dta"
generate sourceFR=0
generate sourceFR_nbr=0
bys marchandises : replace sourceFR_nbr=_N if _merge==3
bys marchandises : keep if _n==1

replace sourceFR=1 if _merge==3
keep marchandises sourceBEL sourceFR sourceBEL_nbr sourceFR_nbr

merge 1:m marchandises using "$dir/Données Stata/Sound/BDD_SUND_FR.dta"
generate sourceSUND=0
generate sourceSUND_nbr=0
bys marchandises : replace sourceSUND_nbr=_N if _merge==3
bys marchandises : keep if _n==1
replace sourceSUND=1 if _merge==3
keep marchandises sourceBEL sourceFR sourceSUND sourceBEL_nbr sourceFR_nbr sourceSUND_nbr

merge 1:m marchandises using "$dir/Données Stata/Marchandises Navigocorpus/Navigo.dta"
bys marchandises : keep if _n==1
generate sourceNAVIGO=0
generate sourceNAVIGO_nbr=nbr_occurences_navigo_marseille_ + nbr_occurences_navigo_g5
replace sourceNAVIGO=1 if _merge==3
keep marchandises sourceBEL sourceFR sourceSUND sourceBEL_nbr sourceFR_nbr sourceSUND_nbr sourceNAVIGO sourceNAVIGO_nbr

sort marchandises
gen nbr_source=sourceBEL+sourceFR+sourceSUND+sourceNAVIGO

drop if nbr_source==0

save "$dir/Données Stata/marchandises_sourcees", replace
export delimited "$dir/toflit18_data_GIT/base/marchandises_sourcees.csv", replace



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

drop imprimatur obsolete

sort simplification


save "$dir/Données Stata/marchandises_pour_nouvelle_classification.dta", replace
export delimited "$dir/toflit18_data_GIT/base/marchandises_pour_nouvelle_classification.csv", replace



*****Pour travail de Stephen Jackson sur la classification impériale
/*
use "$dir/Données Stata/bdd courante", clear
keep if sourcetype=="Résumé"
collapse (count) value, by(year product_simplification product_sitc_FR product_revolutionempire)
rename value observations_total
collapse (count) year (sum) observations_total , by( product_simplification product_sitc_FR product_revolutionempire)
rename year années_observées

save blif.dta, replace

use "$dir/Données Stata/bdd courante", clear
keep if sourcetype=="Résumé"
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

*/

insheet using "$dir/toflit18_data_GIT/base/classification_product_revolutionempire.csv", clear
keep simplification	nbr_occurences_simpl revolutionempire nbr_occurences_revolutionempire
merge 1:1 simplification using "$dir/Données Stata/classification_product_sitc.dta"
drop imprimatur obsolete nbr_occurences_sitc
drop _merge
merge m:1 sitc using "$dir/Données Stata/classification_product_sitc_FR.dta"
sort simplification
drop _merge
export delimited "$dir/toflit18_data_GIT/base/classification_product_revolutionempire.csv", replace


