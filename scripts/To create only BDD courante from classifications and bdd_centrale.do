*capture ssc install missings

 *version 15.1

 
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

*foreach file in "$dir/Données Stata/Belgique/RG_base.dta" "$dir/Données Stata/Belgique/RG_1774.dta" ///
			"$dir/Données Stata/Sound/BDD_SUND_FR.dta" "$dir/Données Stata/Marchandises Navigocorpus/Navigo.dta" {
	
*	use "`file'", clear
*	foreach variable of var * {
*		capture	replace `variable'  =usubinstr(`variable',"  "," ",.)
*		capture	replace `variable'  =usubinstr(`variable',"  "," ",.)
*		capture	replace `variable'  =usubinstr(`variable',"  "," ",.)
*		capture	replace `variable'  =usubinstr(`variable',"…","...",.)
*		capture replace `variable'  =usubinstr(`variable',"u","œ",.) 
*		capture replace `variable'  =usubinstr(`variable'," "," ",.)/*Pour espace insécable*/
*		capture replace `variable'  =usubinstr(`variable',"’","'",.)
*		capture	replace `variable'  =ustrtrim(`variable')
*	}
*	replace product = ustrupper(usubstr(product,1,1),"fr")+usubstr(product,2,.)
*	save "`file'", replace
*}




use "Données Stata/classification_quantityunit_simplification.dta", clear
replace conv_orthographic_to_simplificat  =usubinstr(conv_orthographic_to_simplificat,",",".",.)
destring conv_orthographic_to_simplificat source_bdc, replace
save "Données Stata/classification_quantityunit_simplification.dta", replace

use "Données Stata/classification_quantityunit_metric1.dta", clear
destring conv_simplification_to_metric, replace
save "Données Stata/classification_quantityunit_metric1.dta", replace

use "Données Stata/classification_quantityunit_metric2.dta", clear
replace conv_simplification_to_metric  =usubinstr(conv_simplification_to_metric,",",".",.)
destring conv_simplification_to_metric, replace
save "Données Stata/classification_quantityunit_metric2.dta", replace


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



capture drop v24




save "Données Stata/bdd_centrale.dta", replace
export delimited "$dir/toflit18_data_GIT/base/bdd_centrale.csv", replace
zipfile "$dir/toflit18_data_GIT/base/bdd_centrale.csv", saving("$dir/toflit18_data_GIT/base/bdd_centrale.csv.zip", replace)

*/



****************************BDD courante

use "Données Stata/bdd_centrale.dta", clear


merge m:1 tax_department using "Données Stata/bdd_tax_departments.dta"
drop if _merge==2
rename tax_department tax_department_origin
rename tax_department_simpl tax_department
drop _merge nbr_occurence

merge m:1 origin using "Données Stata/bdd_origin.dta"
drop if _merge==2
rename origin origin_origin
rename origin_norm_ortho origin
drop _merge nbr_occurence


rename source source_doc
rename partner source
merge m:1 source using "Données Stata/classification_partner_orthographic.dta"
rename source partner
rename source_doc source
drop if _merge==2
drop note-_merge

merge m:1 orthographic using "Données Stata/classification_partner_simplification.dta"
drop if _merge==2


drop note-_merge

foreach class_name in grouping obrien ///
			sourcename wars africa {

	merge m:1 simplification using "Données Stata/classification_partner_`class_name'.dta"
	drop if _merge==2
	drop note-_merge
	rename `class_name' partner_`class_name'
}
rename simplification partner_simplification
rename orthographi partner_orthographic

******

rename source source_doc
rename product source
merge m:1 source using "Données Stata/classification_product_orthographic.dta"
rename source product
rename source_doc source
drop if _merge==2
drop note-_merge


merge m:1 orthographic using "Données Stata/classification_product_simplification"
drop if _merge==2
drop nbr_occure* _merge
rename orthographic  product_orthographic

foreach class_name in sitc edentreaty ///
				canada medicinales hamburg ///
				grains  coton ulrich ///
				coffee porcelaine ///
				v_glass_beads revolutionempire beaver ///
				type_textile luxe_dans_type luxe_dans_SITC {

	merge m:1 simplification using "Données Stata/classification_product_`class_name'.dta"
	drop if _merge==2
	drop nbr_occure* _merge
	capture drop obsolete
	rename `class_name' product_`class_name'
	if "`class_name'"=="revolutionempire" capture drop sitc sitc_FR
	
}
rename simplification product_simplification





rename product_sitc sitc
foreach class_name in sitc_FR sitc_EN sitc_simplEN {
	merge m:1 sitc using "Données Stata/classification_product_`class_name'.dta"
	drop if _merge==2
	drop _merge
	rename `class_name' product_`class_name'
}
rename sitc product_sitc

foreach class_name in RE_aggregate threesectors threesectorsM {
	rename product_revolutionempire revolutionempire
	merge m:1 revolutionempire using "Données Stata/classification_product_`class_name'.dta"
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

keep export_import partner_grouping tax_department product_simplification product_revolutionempire quantity_unit_simplification
bys export_import partner_grouping tax_department product_simplification product_revolutionempire quantity_unit_simplification: keep if _n==1
rename quantity_unit_simplification simplification
merge 1:1 export_import partner_grouping tax_department product_simplification product_revolutionempire simplification ///
	using "$dir/Données Stata/classification_quantityunit_metric2.dta"
drop if _merge==2
	
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
 replace  unit_price_metric=value_per_unit /conv_orthographic_to_simplificat * conv_simplification_to_metric


 *save "$dir/Données Stata/bdd courante.dta", replace
 
 /*
 *************Pour les best guess (anciens)
 gen NationalBestGuess=0
 replace NationalBestGuess=1 if (source_type=="National toutes tax_departments tous partenaires" & year==1750) /*
		*/ | (source_type=="Objet Général" & year >=1754 & year <=1782) /*
		*/ | (source_type=="Résumé")
		
 gen LocalBestGuess=0
 replace LocalBestGuess=1 if (source_type=="Local" & year!=1750) /*
		*/ | (source_type=="National toutes tax_departments tous partenaires" & year==1750)
		
save "$dir/Données Stata/bdd courante", replace
 */
 *******************************************************************
 *use "$dir/Données Stata/bdd courante.dta", replace
 
 /*
 ***Pour valeurs absurdes -- C’est maintenant dans les sources
 do "$dir/toflit18_data_GIT/scripts/To flag values & quantities in error.do"
 */
 *save "$dir/Données Stata/bdd courante.dta", replace
 
 drop if absurd_value=="absurd" | absurd_quantity=="absurd"
 
 ************For best guesses
*use "$dir/Données Stata/bdd courante.dta", replace

capture drop best_guess_national_prodxpart
gen best_guess_national_prodxpart = 0
**Sources qui donnent la répartition du commerce français en valeur par produit et par partenaire
**Ancien nom : national_product_best_guess
**Nouveau nom : best_guess_national_prodxpart
replace best_guess_national_prodxpart = 1 if (source_type=="Objet Général" & year<=1786) | ///
		(source_type=="Résumé") | source_type=="National toutes directions tous partenaires" 
egen year_CN = max(best_guess_national_prodxpart), by(year)
replace best_guess_national_prodxpart=1 if year_CN == 1 & source_type=="Compagnie des Indes" & tax_department=="France par la Compagnie des Indes"
drop year_CN

capture drop best_guess_national_partner
gen best_guess_national_partner = 0
**Sources qui donnent la répartition du commerce français en valeur par partenaire
**Ancien nom national_geography_best_guess
**Nouveau nom  best_guess_national_partner	
replace best_guess_national_partner = 1 if source_type=="Tableau Général" | source_type=="Résumé" 

capture drop best_guess_department_prodxpart
**Sources qui permettent d’analyser l’ensemble du commerce par produit et partenaire en valeur de chaque département de Ferme concerné
**Ancien nom local_product_best_guess
**Nouveau nom best_guess_department_prodxpart
gen best_guess_department_prodxpart=0
replace best_guess_department_prodxpart= 1 if (source_type=="Local" & year !=1750) | ///
		(source_type== "National toutes directions tous partenaires" & year == 1750)
replace best_guess_department_prodxpart= 0 if tax_department=="Rouen" & export_import=="Imports" & ///
		(year==1737| (year>= 1739 & year<=1749) | year==1754 | (year>=1756 & year <=1762))

capture drop best_guess_national_department
**Sources qui permettent de comparer le commerce des départements de fermes entre eux en valeur, même si ce n’est peut-être pas pour l’ensemble des partenaires ni des produits
**Ancien nom local_geography_best_guess
**Nouveau nom best_guess_national_department
gen best_guess_national_department=0
replace best_guess_national_department = 1 if source_type=="National toutes directions sans produits" | ///
		(source_type== "National toutes directions tous partenaires")
replace best_guess_national_department = 1 if source_type=="National toutes directions partenaires manquants"
egen year_CN = max(best_guess_national_department), by(year)
replace best_guess_national_department=1 if year_CN == 1 & source_type=="Local"
drop year_CN

*save "$dir/Données Stata/bdd courante", replace
***************************************************Pour les computed value_per_unit & value
*use "$dir/Données Stata/bdd courante.dta", clear

generate byte computed_value = 0
label var computed_value "Was the value computed expost based on unit price and quantities ? 0 no 1 yes"
replace computed_value=1 if (value==0 | value==.) & value_per_unit!=0 & value_per_unit!=. & quantity!=0 & quantity!=.
replace value = quantity*value_per_unit if computed_value==1

gen byte computed_value_per_unit = 0
label var computed_value_per_unit "Was the value_per_unit computed expost based on and quantities and value ? 0 no 1 yes"
replace computed_value_per_unit = 1 if (value_per_unit==0 | value_per_unit==.) & value!=0 & value!=. ///
				& quantity!=0 & quantity!=. & (value_part_of_bundle ==. | value_part_of_bundle==0)
replace value_per_unit = value/quantity  if computed_value_per_unit ==1




*save "$dir/Données Stata/bdd courante", replace
 ********************************************************************
*use "$dir/Données Stata/bdd courante.dta", clear

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



