****Pour exploiter classification luxe / bas de gamme
**Pour colloque 2019

global dir "~/Documents/Recherche/Commerce International Français XVIIIe.xls/Balance du commerce/Retranscriptions_Commerce_France"

*****D'abord, je fais de la classification de luxe une triple classification "comme les autres"


use "$dir/Données Stata/classification_autre_luxe.dta", clear
gen test=.
bys product_simplification  (type): replace test= type[1]== type[_N]
codebook test
br if test==0 
assert test==1

keep product_simplification type
rename type type_textile
bys product_simplification : keep if _n==1

save "$dir/Données Stata/classification_product_type_textile.dta"
export delimited "$dir/toflit18_data_GIT/base/classification_product_type_textile.csv", replace
***

use "$dir/Données Stata/classification_autre_luxe.dta", clear
gen test=.
bys product_simplification  (position_type): replace test= position_type[1]== position_type[_N]
codebook test
gsort + product_sitc_FR + product_simplification
br if test==0
assert test==1

bys product_simplification : keep if _n==1

rename position_type luxe_dans_type

keep product_simplification luxe_dans_type
save "$dir/Données Stata/classification_product_luxe_dans_type.dta"
export delimited "$dir/toflit18_data_GIT/base/classification_product_luxe_dans_type.csv", replace
***


use "$dir/Données Stata/classification_autre_luxe.dta", clear
gen test=.
bys product_simplification  (PositiondansSITC): replace test= PositiondansSITC[1]== PositiondansSITC[_N]
codebook test
br if test==0
assert test==1

bys product_simplification : keep if _n==1

rename PositiondansSITC luxe_dans_SITC

keep product_simplification luxe_dans_SITC
save "$dir/Données Stata/classification_product_luxe_dans_SITC.dta"
export delimited "$dir/toflit18_data_GIT/base/classification_product_luxe_dans_SITC.csv", replace

**************************************
*
**************************************

merge 1:m  product_simplification using "$dir/Données Stata/bdd courante.dta"


import delimited "$dir/toflit18_data_GIT/base/classification_autre_luxe.csv",  encoding(UTF-8) /// 
			clear varname(1) stringcols(_all) case(preserve)
sort product_simplification product_sitc_FR u_conv
			
save "$dir/Données Stata/classification_autre_luxe.dta", replace

use "$dir/Données Stata/bdd courante.dta", clear
merge 
keep if u_conv=="kg" | u_conv=="pièces" | u_conv=="cm"
keep if product_sitc=="6d" | product_sitc=="6e" | product_sitc=="6f" | product_sitc=="6g" | product_sitc=="6h" | product_sitc=="6i"
*generate unit_price_metric=value/quantites_metric
drop if unit_price_metric==.
collapse (mean) mean_price=unit_price_metric (median)  median_price=unit_price_metric (sd) sd_price=unit_price_metric (count) value, by(product_simplification product_sitc_FR u_conv)
gsort product_simplification - value
rename value nbobs

gen PositiondansSITC=""
gen type=""
gen position_type=""

sort product_simplification product_sitc_FR u_conv


merge 1:1 product_simplification product_sitc_FR u_conv using "$dir/Données Stata/classification_autre_luxe.dta", update force
drop obsolete
gen obsolete="non"
replace obsolete ="oui" if _merge==2
drop _merge

gsort product_sitc_FR u_conv - nbobs product_simplification

drop if obsolete=="oui"
drop if nbobs<=9

gsort + product_sitc_FR + u_conv - nbobs



export delimited "$dir/toflit18_data_GIT/base/classification_autre_luxe.csv", replace
