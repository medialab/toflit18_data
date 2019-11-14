****Pour classification luxe / bas de gamme
**Pour colloque 2019

global dir "~/Documents/Recherche/Commerce International Français XVIIIe.xls/Balance du commerce/Retranscriptions_Commerce_France"


import delimited "$dir/toflit18_data_GIT/base/classification_autre_luxe.csv",  encoding(UTF-8) /// 
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



