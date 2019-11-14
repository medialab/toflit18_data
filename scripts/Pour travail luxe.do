****Pour exploiter classification luxe / bas de gamme
**Pour colloque 2019

global dir "~/Documents/Recherche/Commerce International Français XVIIIe.xls/Balance du commerce/Retranscriptions_Commerce_France"

*****D'abord, je fais de la classification de luxe une triple classification "comme les autres"


use "$dir/Données Stata/classification_autre_luxe.dta", clear
gen test=.
bys product_simplification  (type): replace test= type[1]== type[_N]
codebook test
br if test==0 
*assert test==1

keep product_simplification type
rename type type_textile
bys product_simplification : keep if _n==1

save "$dir/Données Stata/classification_product_type_textile.dta", replace
export delimited "$dir/toflit18_data_GIT/base/classification_product_type_textile.csv", replace
***

use "$dir/Données Stata/classification_autre_luxe.dta", clear
gen test=.
bys product_simplification  (position_type): replace test= position_type[1]== position_type[_N]
codebook test
gsort + product_sitc_FR + product_simplification
br if test==0
*assert test==1

bys product_simplification : keep if _n==1

rename position_type luxe_dans_type

keep product_simplification luxe_dans_type
save "$dir/Données Stata/classification_product_luxe_dans_type.dta", replace
export delimited "$dir/toflit18_data_GIT/base/classification_product_luxe_dans_type.csv", replace
***


use "$dir/Données Stata/classification_autre_luxe.dta", clear
gen test=.
bys product_simplification  (PositiondansSITC): replace test= PositiondansSITC[1]== PositiondansSITC[_N]
codebook test
br if test==0
*assert test==1

bys product_simplification : keep if _n==1

rename PositiondansSITC luxe_dans_SITC

keep product_simplification luxe_dans_SITC
save "$dir/Données Stata/classification_product_luxe_dans_SITC.dta", replace
export delimited "$dir/toflit18_data_GIT/base/classification_product_luxe_dans_SITC.csv", replace

**************************************
*
**************************************
*** et maintenant des stats des
use "$dir/Données Stata/bdd courante.dta", clear
merge m:1 product_simplification using "$dir/Données Stata/classification_product_type_textile.dta"
drop _merge
merge m:1 product_simplification using "$dir/Données Stata/classification_product_luxe_dans_type.dta"
drop _merge
merge m:1 product_simplification using "$dir/Données Stata/classification_product_luxe_dans_SITC.dta"
gen echantillon_luxe =0
replace echantillon_luxe=1 if _merge==3 & type_textile !="filés"
drop _merge

preserve
collapse (sum) value, by(echantillon_luxe year)
egen comm_tot = sum(value), by(year)
gen share_echantillon_luxe = value/comm_tot if echantillon_luxe==1
graph twoway (line share_echantillon_luxe year), name(share_echantillon_luxe)
restore

keep if echantillon_luxe==1
collapse (sum) value, by(luxe_dans_type exportsimports year)
keep if exportsimports=="Exports"
egen comm_tot = sum(value), by(year)
gen share_luxe = value/


graph twoway (line share_luxe year, if luxe_dans_type=="haut de gamme") /*
	*/ (line share_luxe year, if luxe_dans_type=="moyen de gamme") /*
	*/ (line share_luxe year, if luxe_dans_type=="bas de gamme")



