
global dir "~/Documents/Recherche/Commerce International Français XVIIIe.xls/Balance du commerce/Retranscriptions_Commerce_France"



use "$dir/Données Stata/Marchandises Navigocorpus/Navigo.dta", clear
collapse (sum) nbr_occurences_navigo_marseille_ nbr_occurences_navigo_g5, by(marchandises)
save "$dir/Données Stata/Marchandises Navigocorpus/Navigo.dta", replace



use "$dir/Données Stata/classification_product_orthographic.dta", replace
rename source marchandises
keep marchandises orthographic note

merge 1:m marchandises using "$dir/Données Stata/bdd_centrale.dta"
generate sourceFR=0
generate sourceFR_nbr=0
bys marchandises : replace sourceFR_nbr=_N
replace sourceFR_nbr=0 if _merge==1
bys marchandises : keep if _n==1
replace sourceFR=1 if _merge!=1
keep marchandises orthographic sourceFR sourceFR_nbr note



merge 1:m marchandises using "$dir/Données Stata/Belgique/RG_base.dta"
generate sourceBEL=0
generate sourceBEL_nbr1=0
bys marchandises : replace sourceBEL_nbr1=_N
replace sourceBEL_nbr1=0 if _merge==1
bys marchandises : keep if _n==1
replace sourceBEL=1 if _merge!=1
keep marchandises  orthographic sourceFR sourceFR_nbr sourceBEL sourceBEL_nbr1 note

merge 1:m marchandises using "$dir/Données Stata/Belgique/RG_1774.dta"
generate sourceBEL_nbr2=0
bys marchandises : replace sourceBEL_nbr2=_N
replace sourceBEL_nbr2=0 if _merge==1
bys marchandises : keep if _n==1
replace sourceBEL=1 if _merge!=1
generate sourceBEL_nbr=sourceBEL_nbr1+sourceBEL_nbr2
keep marchandises orthographic sourceFR sourceFR_nbr sourceBEL  sourceBEL_nbr note

merge 1:m marchandises using "$dir/Données Stata/Sound/BDD_SUND_FR.dta"
generate sourceSUND=0
generate sourceSUND_nbr=0
bys marchandises : replace sourceSUND_nbr=_N
replace sourceSUND_nbr=0 if _merge==1
bys marchandises : keep if _n==1
replace sourceSUND=1 if _merge!=1
keep marchandises orthographic sourceBEL sourceFR sourceSUND sourceBEL_nbr sourceFR_nbr sourceSUND_nbr note

merge 1:m marchandises using "$dir/Données Stata/Marchandises Navigocorpus/Navigo.dta"
drop if marchandises=="(empty)" & _merge !=2
sort marchandises
bys marchandises : keep if _n==1
generate sourceNAVIGO=0
generate sourceNAVIGO_nbr=nbr_occurences_navigo_marseille_ + nbr_occurences_navigo_g5
replace sourceNAVIGO=1 if _merge!=1

keep marchandises orthographic sourceBEL sourceFR sourceSUND sourceBEL_nbr sourceFR_nbr sourceSUND_nbr sourceNAVIGO sourceNAVIGO_nbr note

foreach i of varlist sourceBEL sourceFR sourceSUND sourceBEL_nbr sourceFR_nbr sourceSUND_nbr sourceNAVIGO sourceNAVIGO_nbr {
	replace    `i'=0 if `i'==.
}


sort marchandises
gen nbr_source=sourceBEL+sourceFR+sourceSUND+sourceNAVIGO
gen nbr_occurence_ttesources = sourceBEL_nbr + sourceSUND_nbr + sourceNAVIGO_nbr + sourceFR_nbr


generate sortkey =  ustrsortkeyex(marchandises, "fr",-1,2,-1,-1,-1,0,-1)
sort sortkey
drop sortkey
save "$dir/Données Stata/marchandises_sourcees.dta", replace
export delimited "$dir/toflit18_data_GIT/base/marchandises_sourcees.csv", replace

****************************Orthographique y compris toutes les bases
/*
use "$dir/Données Stata/classification_product_orthographic.dta", clear
rename source marchandises
merge 1:1 marchandises using "$dir/Données Stata/marchandises_sourcees.dta"
*/

capture drop obsolete
generate obsolete = "non"
if nbr_source == 0 replace obsolete="oui"
rename marchandises source
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

