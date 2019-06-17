****Pour classification luxe / bas de gamme
**Pour colloque 2019

global dir "~/Documents/Recherche/Commerce International Français XVIIIe.xls/Balance du commerce/Retranscriptions_Commerce_France"

use "$dir/Données Stata/bdd courante.dta", clear
keep if u_conv=="kg" | u_conv=="pièces" | u_conv=="cm"
keep if product_sitc=="6d" | product_sitc=="6e" | product_sitc=="6f" | product_sitc=="6g" | product_sitc=="6h"
generate unit_price_metric=value/quantites_metric
drop if unit_price_metric==.
collapse (mean) mean_price=unit_price_metric (median)  median_price=unit_price_metric (sd) sd_price=unit_price_metric (count) value, by(product_simplification product_sitc_FR u_conv)
gsort product_simplification - value
rename value nbobs
gen variete=""
gen position_variete=""
gen type=""
gen position_type=""
gsort product_sitc_FR u_conv - nbobs product_simplification

export delimited "$dir/toflit18_data_GIT/base/classification_autre_luxe.csv", replace



