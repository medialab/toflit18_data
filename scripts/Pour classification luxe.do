****Pour classification luxe / bas de gamme
**Pour colloque 2019

global dir "~/Documents/Recherche/Commerce International Français XVIIIe.xls/Balance du commerce/Retranscriptions_Commerce_France"


import delimited "$dir/toflit18_data_GIT/base/classification_autre_luxe.csv",  encoding(UTF-8) /// 
			clear varname(1) stringcols(_all) case(preserve)
sort product_simplification product_sitc_FR u_conv
capture drop len
gen len=length(product_simplification)
summ len
local max=r(max)
recast str`max' product_simplification, force
drop len
			
save "$dir/Données Stata/classification_autre_luxe.dta", replace

use "$dir/Données Stata/bdd courante.dta", clear
keep if (u_conv=="kg" | u_conv=="pièces" | u_conv=="cm") | sourcetype=="Résumé"
keep if product_sitc=="6d" | product_sitc=="6e" | product_sitc=="6f" | product_sitc=="6g" | product_sitc=="6h" | product_sitc=="6i"
*generate unit_price_metric=value/quantites_metric
drop if unit_price_metric==. & sourcetype!="Résumé"
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

*drop if obsolete=="oui"
drop if nbobs<=9

gsort + product_sitc_FR + u_conv - nbobs + product_simplification

order product_simplification product_sitc_FR u_conv mean_price median_price sd_price nbobs type position_type PositiondansSITC obsolete


***Pour enlever les "unités manquantes" que nous avons déjà par ailleurs
capture drop garder_um
bys product_simplification : gen garder_um=_N
drop if u_conv=="unité manquante" & garder_um!=1
drop garder_um


gsort + type + product_sitc_FR + u_conv - median_price
export delimited "$dir/toflit18_data_GIT/base/classification_autre_luxe.csv", replace
save "$dir/Données Stata/classification_autre_luxe.dta", replace



**********Puis test et création des classifications "sandards"

*****D'abord, je fais de la classification de luxe une triple classification "comme les autres"


use "$dir/Données Stata/classification_autre_luxe.dta", clear
gen test=.
bys product_simplification  (type): replace test= type[1]== type[_N]
replace test=0 if type==""
codebook test
*br if test==0 
assert test==1


rename type type_textile
bys product_simplification : keep if _n==1
rename product_simplification simplification

keep simplification type_textile

save "$dir/Données Stata/classification_product_type_textile.dta", replace
export delimited "$dir/toflit18_data_GIT/base/classification_product_type_textile.csv", replace
***

use "$dir/Données Stata/classification_autre_luxe.dta", clear
gen test=.
bys product_simplification  (position_type): replace test= position_type[1]== position_type[_N]
replace test=0 if position_type==""
codebook test
gsort + product_sitc_FR + product_simplification
replace test=1 if type=="filés"
*br if test==0
assert test==1

bys product_simplification : keep if _n==1

rename position_type luxe_dans_type
rename product_simplification simplification

keep simplification luxe_dans_type
save "$dir/Données Stata/classification_product_luxe_dans_type.dta", replace
export delimited "$dir/toflit18_data_GIT/base/classification_product_luxe_dans_type.csv", replace
***


use "$dir/Données Stata/classification_autre_luxe.dta", clear
gen test=.
bys product_simplification  (PositiondansSITC): replace test= PositiondansSITC[1]== PositiondansSITC[_N]
replace test=0 if PositiondansSITC==""
replace test=1 if type=="filés"
codebook test
*br if test==0
assert test==1
bys product_simplification : keep if _n==1

rename PositiondansSITC luxe_dans_SITC
rename product_simplification simplification

keep simplification luxe_dans_SITC
save "$dir/Données Stata/classification_product_luxe_dans_SITC.dta", replace
export delimited "$dir/toflit18_data_GIT/base/classification_product_luxe_dans_SITC.csv", replace




