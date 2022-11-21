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

generate sortkey = ustrsortkeyex(source,  "fr",-1,1,-1,-1,-1,0,-1)
sort sortkey
drop sortkey
save "classification_quantityunit_orthographic.dta", replace
export delimited "$dir_git/base/classification_quantityunit_orthographic.csv", replace



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
	
	
generate sortkey = ustrsortkeyex(orthographic, "fr",-1,1,-1,-1,-1,0,-1)
sort sortkey
drop sortkey
save "classification_quantityunit_simplification.dta", replace
export delimited "$dir_git/base/classification_quantityunit_simplification.csv", replace


******
use "classification_quantityunit_simplification.dta", clear
keep simplification nbr_occurences_simplification source_bdc
bys simplification : keep if _n==1
merge 1:1 simplification using "classification_quantityunit_metric1.dta"

replace nbr_occurences_simplification= 0 if _merge==2

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

	
	
generate sortkey = ustrsortkeyex(simplification,  "fr",-1,1,-1,-1,-1,0,-1)
sort sortkey
drop sortkey
save "classification_quantityunit_metric1.dta", replace
export delimited "$dir_git/base/classification_quantityunit_metric1.csv", replace

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
export delimited "$dir_git/base/Units_N1.csv", replace
*/

******* Direction et origin
use "bdd_centrale.dta", clear
merge m:1 customs_region using "bdd_customs_regions.dta"
keep customs_region customs_region_simpl customs_region_grouping /* 
	*/ customs_region_province customs_region_hinterland remarks_customs_region
bys customs_region : gen nbr_occurence=_N
bys customs_region_simpl : gen nbr_occurence_simpl=_N
bys customs_region_grouping : gen nbr_occurence_grouping=_N
bys customs_region_province : gen nbr_occurence_customs_province=_N
bys customs_region : keep if _n==1
order customs_region customs_region_simpl nbr_occurence  nbr_occurence_simpl customs_region_grouping /*
		*/ nbr_occurence_grouping customs_region_province customs_region_hinterland remarks
****Le deux premières colonnes doivent être customs_region customs_region_simpl pour que le datascape marche
save "bdd_customs_regions.dta", replace
generate sortkey = ustrsortkeyex(customs_region,  "fr",-1,1,-1,-1,-1,0,-1)
sort sortkey
drop sortkey
export delimited "$dir_git/base/bdd_customs_regions.csv", replace


use "bdd_centrale.dta", clear
merge m:1 customs_office using "bdd_customs_offices.dta"
keep customs_office customs_office_grouping
bys customs_office : gen nbr_occurence=_N
bys customs_office_grouping : gen nbr_occurence_grouping=_N
bys customs_office : keep if _n==1
order customs_office nbr_occurence customs_office_grouping /*
		*/ nbr_occurence_grouping
save "bdd_customs_offices.dta", replace
generate sortkey = ustrsortkeyex(customs_office,  "fr",-1,1,-1,-1,-1,0,-1)
sort sortkey
drop sortkey
export delimited "$dir_git/base/bdd_customs_offices.csv", replace




use "bdd_centrale.dta", clear
merge m:1 origin using "bdd_origin.dta"
keep origin origin_norm_ortho  origin_province remarks_origin
bys origin : gen nbr_occurence=_N
bys origin_norm_ortho : gen nbr_occurence_norm_ortho=_N
bys origin_province : gen nbr_occurence_province=_N
bys origin : keep if _n==1

order origin nbr_occurence origin_norm_ortho nbr_occurence_norm_ortho origin_province /*
	*/ nbr_occurence_province remarks

save "bdd_origin.dta", replace
generate sortkey = ustrsortkeyex(origin,  "fr",-1,1,-1,-1,-1,0,-1)
sort sortkey
drop sortkey
export delimited "$dir_git/base/bdd_origin.csv", replace





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
generate sortkey = ustrsortkeyex(source,  "fr",-1,1,-1,-1,-1,0,-1)
sort sortkey
drop sortkey
export delimited "$dir_git/base/classification_partner_orthographic.csv", replace




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
generate sortkey = ustrsortkeyex(orthographic, "fr",-1,1,-1,-1,-1,0,-1)
sort sortkey
drop sortkey
export delimited "$dir_git/base/classification_partner_simplification.csv", replace

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
generate sortkey = ustrsortkeyex(simplification,  "fr",-1,1,-1,-1,-1,0,-1)
sort sortkey
drop sortkey
export delimited "$dir_git/base/classification_partner_grouping.csv", replace

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
generate sortkey = ustrsortkeyex(simplification,  "fr",-1,1,-1,-1,-1,0,-1)
sort sortkey
drop sortkey
export delimited "$dir_git/base/classification_partner_obrien.csv", replace


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
generate sortkey = ustrsortkeyex(simplification,  "fr",-1,1,-1,-1,-1,0,-1)
sort sortkey
drop sortkey
export delimited "$dir_git/base/classification_partner_wars.csv", replace

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
generate sortkey = ustrsortkeyex(simplification,  "fr",-1,1,-1,-1,-1,0,-1)
sort sortkey
drop sortkey
export delimited "$dir_git/base/classification_partner_sourcename.csv", replace

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
generate sortkey = ustrsortkeyex(simplification,  "fr",-1,1,-1,-1,-1,0,-1)
sort sortkey
drop sortkey
export delimited "$dir_git/base/classification_partner_africa.csv", replace




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
generate sortkey =  ustrsortkeyex(source, "fr",-1,1,-1,-1,-1,0,-1)
sort sortkey
drop sortkey
export delimited "$dir_git/base/classification_product_orthographic.csv", replace
*/
*******************Sourcé
*****************************Pour product_sourcees.csv (et product orthographic)
**Pour updater les classifications

use "$dir_git/traitements_marchandises/Marchandises Navigocorpus/Navigo.dta", clear
collapse (sum) nbr_occurences_navigo_marseille_ nbr_occurences_navigo_g5 nbr_occurrences_datasprint, by(product)
save "$dir_git/traitements_marchandises/Marchandises Navigocorpus/Navigo.dta", replace




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




merge 1:m product using "$dir_git/traitements_marchandises/Marchandises Navigocorpus/Navigo.dta"
drop if product=="(empty)" & _merge !=2
sort product
bys product : keep if _n==1
generate sourceNAVIGO=0
generate sourceNAVIGO_nbr=nbr_occurences_navigo_marseille_ + nbr_occurences_navigo_g5+ nbr_occurrences_datasprint
replace sourceNAVIGO=1 if _merge!=1



keep product orthographic sourceBEL sourceFR sourceSUND sourceBEL_nbr sourceFR_nbr sourceSUND_nbr sourceNAVIGO sourceNAVIGO_nbr note

foreach i of varlist sourceBEL sourceFR sourceSUND sourceBEL_nbr sourceFR_nbr sourceSUND_nbr sourceNAVIGO sourceNAVIGO_nbr {
	replace    `i'=0 if `i'==.
}


sort product
gen nbr_source=sourceBEL+sourceFR+sourceSUND+sourceNAVIGO
gen nbr_occurence_ttesources = sourceBEL_nbr + sourceSUND_nbr + sourceNAVIGO_nbr + sourceFR_nbr


generate sortkey =  ustrsortkeyex(product, "fr",-1,1,-1,-1,-1,0,-1)
sort sortkey
drop sortkey
save "$dir/Données Stata/product_sourcees.dta", replace
export delimited "$dir_git/base/product_sourcees.csv", replace



****************************Orthographique
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
generate sortkey =  ustrsortkeyex(source, "fr",-1,1,-1,-1,-1,0,-1)
sort sortkey
drop sortkey
save "$dir/Données Stata/classification_product_orthographic.dta", replace
export delimited "$dir_git/base/classification_product_orthographic.csv", replace




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
generate sortkey = ustrsortkeyex(orthographic, "fr",-1,1,-1,-1,-1,0,-1)
sort sortkey
drop sortkey
export delimited "$dir_git/base/classification_product_simplification.csv", replace
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

	
	capture generate sortkey = ustrsortkeyex(simplification,  "fr",-1,1,-1,-1,-1,0,-1)
	sort sortkey
	drop sortkey
	

	save "classification_product_`file_on_simp'.dta", replace
	export delimited "$dir_git/base/classification_product_`file_on_simp'.csv", replace

}

foreach file_on_RE in RE_aggregate threesectors threesectorsM reexportations {
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
	
	capture generate sortkey = ustrsortkeyex(revolutionempire,  "fr",-1,1,-1,-1,-1,0,-1)
	sort sortkey
	drop sortkey	
	
	save "classification_product_`file_on_RE'.dta", replace
	export delimited "$dir_git/base/classification_product_`file_on_RE'.csv", replace

}
