

global dir "~/Documents/Recherche/Commerce International Français XVIIIe.xls/Balance du commerce/Retranscriptions_Commerce_France"


***Evolution de chaque gamme
capture program drop evolution_gamme
program evolution_gamme
args geographie exportsimports reference
** reference peut être product_luxe_dans_type product_luxe_dans_type product_sitc_FR

use "$dir/Données Stata/bdd courante.dta", clear

keep if exportsimports=="`exportsimports'"

if "`geographie'"=="France" {
	keep if NationalBestGuess==1
}

if "`geographie'" !="France" {
	keep if LocalBestGuess==1 & strmatch(direction,"*`geographie'*")==1
}


gen textile = 0
replace textile=1 if product_sitc=="6d" | product_sitc=="6e" | product_sitc=="6f" | product_sitc=="6g" | /*
					 */ product_sitc=="6h" | product_sitc=="6i"

gen classifie_luxe =0
replace classifie_luxe=1 if  product_type_textile =="passementerie" | product_type_textile =="tissés" 



keep if textile==1 & classifie_luxe==1


collapse (sum) value, by(`reference')







