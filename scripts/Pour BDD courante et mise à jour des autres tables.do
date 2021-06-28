capture ssc install missings

 version 15.1

 
**pour mettre les bases dans stata + mettre à jour les .csv
** version 2 : pour travailler avec la nouvelle organisation

global dir "~/Documents/Recherche/Commerce International Français XVIIIe.xls/Balance du commerce/Retranscriptions_Commerce_France"
global dir_git "~/Répertoires Git/toflit18_data_GIT"

if "`c(username)'"=="Matthias" global dir "/Users/Matthias/"

if "`c(username)'"=="Tirindelli"{
	global dir "/Users/Tirindelli/Desktop/toflit18"
	global dir_git "/Volumes/GoogleDrive/My Drive/Hamburg"
}
if "`c(username)'"=="federico.donofrio" global dir "C:\Users\federico.donofrio\Documents\GitHub"

if "`c(username)'"=="pierr" global dir "/Users/pierr/Documents/Toflit/"

if "`c(username)'"=="loiccharles" global dir "/Users/loiccharles/Documents/"

cd "$dir"

*I restrict some stuff to my setting -- GD



foreach file in classification_partner_orthographic classification_partner_simplification classification_partner_grouping /*
*/				 classification_partner_obrien classification_partner_wars /*
*/				 classification_partner_sourcename classification_partner_africa /*
*/               classification_product_orthographic classification_product_simplification /*
*/				 /*Units_N1 Units_N2 Units_N3*/  classification_product_edentreaty classification_product_canada /*
*/				 classification_product_medicinales classification_product_hamburg classification_product_grains /*
*/ 				 classification_product_sitc  classification_product_coffee classification_product_porcelaine /*
*/				 bdd_customs_regions classification_product_sitc_FR classification_product_sitc_EN /*
*/				 classification_product_sitc_simplEN /* 
*/ 				 classification_quantityunit_orthographic classification_quantityunit_simplification /*
*/				 classification_quantityunit_metric1 classification_quantityunit_metric2 /*
*/				 bdd_origin classification_product_coton	classification_product_ulrich /*
*/ 				 classification_product_v_glass_beads classification_product_beaver/*
*/				 classification_product_RE_aggregate classification_product_revolutionempire /*
*/				 classification_product_type_textile  classification_product_luxe_dans_type /*
*/				 classification_product_luxe_dans_SITC	classification_product_threesectors /*
*/				 classification_product_threesectorsM	classification_product_reexportations {

	import delimited "$dir_git/base/`file'.csv",  encoding(UTF-8) /// 
			clear varname(1) stringcols(_all) case(preserve) asdouble

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

	capture destring nbr*, replace 
	capture drop nbr_bdc* source_bdc
	save "Données Stata/`file'.dta", replace
 
}


if "`c(username)'"=="guillaumedaudin" | "`c(username)'"=="Tirindelli" {

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
}

/* 
use "Données Stata/Units_N1.dta", clear
destring q_conv, replace
save "Données Stata/Units_N1.dta", replace
*/

use "Données Stata/classification_quantityunit_simplification.dta", clear
replace conv_orthographic_to_simplificat  =usubinstr(conv_orthographic_to_simplificat,",",".",.)
destring conv_orthographic_to_simplificat source_bdc, replace
replace conv_orthographic_to_simplificat=round(conv_orthographic_to_simplificat,0.0001)
save "Données Stata/classification_quantityunit_simplification.dta", replace

use "Données Stata/classification_quantityunit_metric1.dta", clear
replace conv_simplification_to_metric  =usubinstr(conv_simplification_to_metric,",",".",.)
destring conv_simplification_to_metric, replace 
replace conv_simplification_to_metric=round(conv_simplification_to_metric,0.0001)
save "Données Stata/classification_quantityunit_metric1.dta", replace

use "Données Stata/classification_quantityunit_metric2.dta", clear
replace conv_simplification_to_metric  =usubinstr(conv_simplification_to_metric,",",".",.)
destring conv_simplification_to_metric, replace 
replace conv_simplification_to_metric=round(conv_simplification_to_metric,0.0001)
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

		capture destring nbr*, replace 
		capture drop nbr_bdc* source_bdc
		save "Données Stata/`file'.dta", replace
}
*/		
	
	
/*	
import delimited "$dir_git/traitements_product/SITC/Définitions sitc_classification.csv",  encoding(UTF-8) clear varname(1) stringcols(_all)   

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

	capture destring nbr*, replace 
	capture drop nbr_bdc* source_bdc
	save "Données Stata/Définitions sitc_classification.dta", replace
*/
	
	
	
	
	
	

 *(juste parce que c'est trop long)


import delimited "$dir_git/base/bdd_centrale.csv",  encoding(UTF-8) clear varname(1) stringcols(_all) asdouble
foreach variable of var product partner quantity_unit  {
	replace `variable'  =usubinstr(`variable',"  "," ",.)
	replace `variable'  =usubinstr(`variable',"  "," ",.)
	replace `variable'  =usubinstr(`variable',"  "," ",.)
	replace `variable'  =usubinstr(`variable',"…","...",.)
	replace `variable'  =usubinstr(`variable',"u","œ",.)
	replace `variable'  =usubinstr(`variable'," "," ",.)/*Pour espace insécable*/
	replace `variable'  =usubinstr(`variable',"’","'",.)
	replace `variable'  =ustrtrim(`variable')
}


foreach variable of var quantity value value_per_unit value_minus_unit_val_x_qty value_total line_number { 
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
replace value_per_unit=round(value_per_unit,0.00001)
destring line_number, replace 
destring value_minus_unit_val_x_qty, replace 
replace value_minus_unit_val_x_qty=round(value_minus_unit_val_x_qty,0.00001)

drop if source==""
drop if value==0 & quantity==. & value_per_unit ==. /*Dans tous les cas regardés le 31 mai 2016, ce sont des "vrais" 0*/
drop if (value==0|value==.) & (quantity ==.|quantity ==0) & (value_per_unit ==.|value_per_unit ==0) /*idem*/
replace value=. if (value==0 & quantity !=. & quantity !=0)
replace quantity=. if quantity==0


**Je mets des majuscules à toutes les "product" de la source
replace product = upper(substr(product,1,1))+substr(product,2,.)



capture drop v24




save "Données Stata/bdd_centrale.dta", replace
export delimited "$dir_git/base/bdd_centrale.csv", replace
cd "$dir_git/base"
zipfile "bdd_centrale.csv", saving("bdd_centrale.csv.zip", replace)

*/
blif

**********************Metter à jour les classifications
if "`c(username)'"=="guillaumedaudin" do "$dir_git/scripts/Pour mise à jour des classifications"
if "`c(username)'"=="Tirindelli" do "$dir_git/scripts/Pour mise à jour des classifications"

***********************************************************************************************************************************



****************************BDD courante

use "bdd_centrale.dta", clear


merge m:1 customs_region using "bdd_customs_regions.dta"
drop if _merge==2
rename customs_region customs_region_source
rename customs_region_simpl customs_region
drop _merge nbr_occurence nbr_occurence_simpl nbr_occurence_grouping remarks_customs_region

merge m:1 origin using "bdd_origin.dta"
drop if _merge==2
rename origin origin_source
rename origin_norm_ortho origin
drop _merge nbr_occurence nbr_occurence_norm_ortho nbr_occurence_province remarks_origin


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

foreach class_name in RE_aggregate threesectors threesectorsM reexportations {
	rename product_revolutionempire revolutionempire
	merge m:1 revolutionempire using "classification_product_`class_name'.dta"
	rename revolutionempire product_revolutionempire
	drop nbr_occure*
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
drop if _merge==2
 
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

keep export_import partner_grouping customs_region product_simplification product_revolutionempire quantity_unit_simplification
bys export_import partner_grouping customs_region product_simplification product_revolutionempire quantity_unit_simplification: keep if _n==1
rename quantity_unit_simplification simplification
merge 1:1 export_import partner_grouping customs_region product_simplification product_revolutionempire simplification ///
	using "$dir/Données Stata/classification_quantityunit_metric2.dta"
drop if _merge==2
	
 drop _merge
 gen pour_tri = simplification+product_revolutionempire+product_simplification+export_import+customs_region+partner_grouping
 generate sortkey = ustrsortkeyex(pour_tri,  "fr",-1,1,-1,-1,-1,0,-1)
 sort sortkey
 drop sortkey pour_tri
 order simplification product_simplification product_revolutionempire export_import customs_region partner_grouping
 save "$dir/Données Stata/classification_quantityunit_metric2.dta", replace
 export delimited "$dir_git/base/classification_quantityunit_metric2.csv", replace
 
 use "$dir/Données Stata/bdd courante_temp.dta", clear
 erase "$dir/Données Stata/bdd courante_temp.dta"
 
 rename quantity_unit_simplification simplification 
 
 merge m:1 export_import partner_grouping customs_region product_simplification product_revolutionempire simplification ///
	using "$dir/Données Stata/classification_quantityunit_metric2.dta", update
	
replace quantity_unit_metric = metric if quantity_unit_metric==""
drop metric
 
drop if _merge==2
drop  remarks_unit-_merge
codebook conv_simplification_to_metric
 
generate quantities_metric = quantity * conv_orthographic_to_simplificat * conv_simplification_to_metric
generate unit_price_metric=value/quantities_metric
replace  unit_price_metric=value_per_unit /(conv_orthographic_to_simplificat * conv_simplification_to_metric)

rename  simplification  quantity_unit_simplification

 *save "$dir/Données Stata/bdd courante.dta", replace
 
 /*
 *************Pour les best guess (anciens)
 gen NationalBestGuess=0
 replace NationalBestGuess=1 if (source_type=="National toutes customs_regions tous partenaires" & year==1750) /*
		*/ | (source_type=="Objet Général" & year >=1754 & year <=1782) /*
		*/ | (source_type=="Résumé")
		
 gen LocalBestGuess=0
 replace LocalBestGuess=1 if (source_type=="Local" & year!=1750) /*
		*/ | (source_type=="National toutes customs_regions tous partenaires" & year==1750)
		
save "$dir/Données Stata/bdd courante", replace
 */
 *******************************************************************
 *use "$dir/Données Stata/bdd courante.dta", replace
 
 /*
 ***Pour valeurs absurdes -- C’est maintenant dans les sources
 do "$dir_git/scripts/To flag values & quantities in error.do"
 */
 *save "$dir/Données Stata/bdd courante.dta", replace
 
 
 ************For best guesses
*use "$dir/Données Stata/bdd courante.dta", replace

capture drop best_guess_national_prodxpart
gen best_guess_national_prodxpart = 0
**Sources qui donnent la répartition du commerce français en valeur par produit et par partenaire
**Ancien nom : national_product_best_guess
**Nouveau nom : best_guess_national_prodxpart
**1782 ne comprend pas le commerce inter-continental
replace best_guess_national_prodxpart = 1 if (source_type=="Objet Général" & year<=1780  & year>=1754) | ///
		(source_type=="Résumé") | source_type=="National toutes directions tous partenaires" 
egen year_CN = max(best_guess_national_prodxpart), by(year)
replace best_guess_national_prodxpart=1 if year_CN == 1 & source_type=="Compagnie des Indes" & customs_region=="France par la Compagnie des Indes"
drop year_CN

capture drop best_guess_national_partner
gen best_guess_national_partner = 0
**Sources qui donnent la répartition du commerce français en valeur par partenaire
**Ancien nom national_geography_best_guess
**Nouveau nom  best_guess_national_partner	
replace best_guess_national_partner = 1 if source_type=="Tableau Général" | source_type=="Résumé"

capture drop best_guess_national_product
gen best_guess_national_product = 0
**Sources qui donnent la répartition du commerce français en valeur par product
**Ancien nom national_geography_best_guess
**Nouveau nom  best_guess_national_partner	
replace best_guess_national_product = 1 if best_guess_national_prodxpart == 1 | (source_type=="Tableau des quantités" & (year==1822|year==1823))


capture drop best_guess_region_prodxpart
**Sources qui permettent d’analyser l’ensemble du commerce par produit et partenaire en valeur de chaque département de Ferme concerné
**Ancien nom local_product_best_guess
**Nouveau nom best_guess_region_prodxpart
gen best_guess_region_prodxpart=0
replace best_guess_region_prodxpart= 1 if (source_type=="Local" & year !=1750) | ///
		(source_type== "National toutes directions tous partenaires" & year == 1750)
replace best_guess_region_prodxpart= 1 if source_type=="National toutes directions partenaires manquants" & year ==1789
replace best_guess_region_prodxpart= 1 if source_type=="National toutes directions partenaires manquants" & year ==1787 /*
					*/ & customs_region=="Marseille" 
replace best_guess_region_prodxpart= 0 if customs_region=="Rouen" & export_import=="Imports" & ///
		(year==1737| (year>= 1739 & year<=1749) | year==1754 | (year>=1756 & year <=1762))
replace best_guess_region_prodxpart= 0 if customs_region=="Colonies Françaises de l'Amérique" & source_type=="local"

capture drop best_guess_national_region
**Sources qui permettent de comparer le commerce des départements de fermes entre eux en valeur, même si ce n’est peut-être pas pour l’ensemble des partenaires ni des produits
**Ancien nom local_geography_best_guess
**Nouveau nom best_guess_national_region
gen best_guess_national_region=0
replace best_guess_national_region = 1 if source_type=="National toutes directions sans produits" | ///
		(source_type== "National toutes directions tous partenaires")
replace best_guess_national_region = 1 if source_type=="National toutes directions partenaires manquants"
egen year_CN = max(best_guess_national_region), by(year)
replace best_guess_national_region=1 if year_CN == 1 & source_type=="Local"
drop year_CN

*save "$dir/Données Stata/bdd courante", replace
***************************************************Pour les computed value_per_unit & value
*use "$dir/Données Stata/bdd courante.dta", clear

generate byte computed_value = 0
**On donne la priorité aux valeurs calculées quand c’est possible : il y a beacoup d’erreurs de calcul dans les sources
label var computed_value "Was the value computed expost based on unit price and quantities ? 0 no 1 yes"
generate value_as_reported = value
replace computed_value=1 if (value==0 | value==.) & value_per_unit!=0 & value_per_unit!=. & quantity!=0 & quantity!=.
replace value = quantity*value_per_unit if computed_value==1
replace value = quantity*value_per_unit if quantity*value_per_unit !=.
replace computed_value=1 if value != value_as_reported


gen byte computed_value_per_unit = 0
label var computed_value_per_unit "Was the value_per_unit computed expost based on and quantities and value ? 0 no 1 yes"
replace computed_value_per_unit = 1 if (value_per_unit==0 | value_per_unit==.) & value!=0 & value!=. ///
				& quantity!=0 & quantity!=. & (value_part_of_bundle ==. | value_part_of_bundle==0)
replace value_per_unit = value/quantity  if computed_value_per_unit ==1

gen byte computed_quantity = 0
label var computed_quantity "Was the quantity computed expost based on and quantities and value ? 0 no 1 yes"
replace computed_quantity = 1 if (quantity==. | quantity==0) & value_per_unit!=0 & value_per_unit !=. ///
				& value_per_unit!=0 & value_per_unit!=. & (value_part_of_bundle ==. | value_part_of_bundle==0)
replace quantity = value/value_per_unit  if computed_quantity ==1



destring value_minus_unit_val_x_qty, replace 
rename value_minus_unit_val_x_qty value_minus_un_source
gen value_minus_unit_val_x_qty = value_as_reported-(value_per_unit*quantity)






*save "$dir/Données Stata/bdd courante", replace
 ********************************************************************
*use "$dir/Données Stata/bdd courante.dta", clear

 missings dropobs, force
 missings dropvars, force
 
sort source_type customs_region year export_import line_number 
order line_number source_type year customs_region partner partner_orthographic export_import ///
		product product_orthographic value quantity quantity_unit quantity_unit_ortho value_per_unit

 
export delimited "$dir_git/base/bdd courante_avec_out.csv", replace
*export delimited "$dir_git/base/$dir_git/base/bdd courante.csv", replace
*Il est trop gros pour être envoyé dans le GIT
save "$dir/Données Stata/bdd courante_avec_out.dta", replace




drop if source_type=="Out"
drop if absurd_observation=="absurd"
export delimited "$dir_git/base/bdd courante.csv", replace

cd "$dir_git/base/"
zipfile "bdd courante.csv", saving("bdd courante.csv.zip", replace)
save "$dir/Données Stata/bdd courante.dta", replace



/*
********
use "$dir/bdd courante", replace 

keep if year=="1750"
keep if customs_region=="Bordeaux"
keep if export_import=="Imports"
keep source source_type year export_import customs_region product partner value quantity quantity_unit value_per_unit value_minus_unit_val_x_qty remarks quantit_unit partner_corriges product_normalisees value_calcul prix_calcul
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
export delimited "$dir_git/base/product_pour_nouvelle_classification.csv", replace



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
export delimited "$dir_git/base/classification_product_revolutionempire.csv", replace
erase blif.dta



insheet using "$dir_git/base/classification_product_revolutionempire.csv", clear
keep simplification	nbr_occurences_simpl revolutionempire nbr_occurences_revolutionempire
merge 1:1 simplification using "$dir/Données Stata/classification_product_sitc.dta"
drop imprimatur obsolete nbr_occurences_sitc
drop _merge
merge m:1 sitc using "$dir/Données Stata/classification_product_sitc_FR.dta"
sort simplification
drop _merge
export delimited "$dir_git/base/classification_product_revolutionempire.csv", replace

*/





****Pour classification luxe / bas de gamme
/***Pour colloque 2019 (Renvoyé dans un .do différent)

global dir "~/Documents/Recherche/Commerce International Français XVIIIe.xls/Balance du commerce/Retranscriptions_Commerce_France"


import delimited "$dir_git/base/classification_autre_luxe.csv",  encoding(UTF-8) /// 
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

export delimited "$dir_git/base/classification_autre_luxe.csv", replace



