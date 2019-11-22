global dir "~/Documents/Recherche/Commerce International Français XVIIIe.xls/Balance du commerce/Retranscriptions_Commerce_France"

use "$dir/Données Stata/bdd courante.dta", clear

gen textile = 0
replace textile=1 if product_sitc=="6d" | product_sitc=="6e" | product_sitc=="6f" | product_sitc=="6g" | /*
					 */ product_sitc=="6h" | product_sitc=="6i"

gen classifie_luxe =0
replace classifie_luxe=1 if  product_type_textile =="passementerie" | product_type_textile =="tissés" 

keep if textile==1 & classifie_luxe==1

tab product_luxe_dans_SITC product_sitc

replace product_sitc="Pur lin" if product_sitc=="6d"
replace product_sitc="Laine" if product_sitc=="6e"
replace product_sitc="Soie" if product_sitc=="6f"
replace product_sitc="Pur coton" if product_sitc=="6g"
replace product_sitc="Mixte vég" if product_sitc=="6h"
replace product_sitc="Autres" if product_sitc=="6i"

replace product_luxe_dans_SITC="Haut de gamme" if product_luxe_dans_SITC=="haut de gamme"
replace product_luxe_dans_SITC="Milieu de gamme" if product_luxe_dans_SITC=="milieu de gamme"

label var product_sitc "SITC18"
label var product_luxe_dans_SITC "Gamme dans SITC18"
label var value "Valeur en milliers"
replace value=value/1000
format value %9.0fc

tab product_luxe_dans_SITC product_sitc [aweight=value], row column  nofreq colsort

label var product_luxe_dans_type "Gamme dans type"

replace product_luxe_dans_type="Haut de gamme" if product_luxe_dans_type=="haut de gamme"
replace product_luxe_dans_type="Milieu de gamme" if product_luxe_dans_type=="milieu de gamme"

tab product_luxe_dans_type product_sitc [aweight=value], row column  nofreq colsort

rename product_luxe_dans_type luxe_dans_typetype
rename product_luxe_dans_SITC luxe_dans_SITC
rename product_type_textile type
rename product_sitc SITC18



collapse (sum) value, by(product_simplification luxe_dans_type luxe_dans_SITC SITC18 type)
gsort - value
list if luxe_dans_type=="Haut de gamme" in 1/15
list if luxe_dans_type=="Haut de gamme" & SITC18!="Soie" in 1/100
list if luxe_dans_type=="Milieu de gamme" in 1/15
list if luxe_dans_type=="bas de gamme" in 1/15

*collapse (sum) value,by(product_type_textile product_sitc product_luxe_dans_type product_luxe_dans_SITC)

