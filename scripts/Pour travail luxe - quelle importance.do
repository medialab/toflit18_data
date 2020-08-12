****Pour exploiter classification luxe / bas de gamme
**Pour colloque 2019

global dir "~/Documents/Recherche/Commerce International Français XVIIIe.xls/Balance du commerce/Retranscriptions_Commerce_France"


capture erase  "~/Dropbox/Partage GD-LC/2019 Colloque Haut de gamme Bercy/Pour_echantillon_luxe.dta"
**************************************
*
**************************************
*** et maintenant des stats des

capture program drop quelle_importance
program quelle_importance
args geographie export_import
** Ex : quelle_importance France Exports quelle_importance Bordeaux Imports

use "$dir/Données Stata/bdd courante.dta", clear

keep if export_import=="`export_import'"

if "`geographie'"=="France" {
	keep if NationalBestGuess==1
}

if "`geographie'" !="France" {
	keep if LocalBestGuess==1 & strmatch(tax_department,"*`geographie'*")==1
}



gen textile = 0
replace textile=1 if product_sitc=="6d" | product_sitc=="6e" | product_sitc=="6f" | product_sitc=="6g" | /*
					 */ product_sitc=="6h" | product_sitc=="6i"

gen luxe =0
replace luxe=1 if  product_type_textile =="passementerie" | product_type_textile =="tissés" 



collapse (sum) value, by(luxe textile year)
egen comm_tot = sum(value), by(year)

gen share_ = value/comm_tot
gen group = ""
replace group ="textile" if textile==1
replace group ="luxe" if luxe==1
drop if group==""
drop luxe textile value
reshape wide share_, i(year) j(group) string
replace share_textile=share_textile+share_luxe


graph twoway (connected share_textile year) (connected share_luxe year), /*
	*/ name(`geographie'_`export_import', replace) /*
	*/ title (`geographie'_`export_import') /*
	*/ ytitle("Part dans les flux totaux")
	
graph export "~/Dropbox/Partage GD-LC/2019 Colloque Haut de gamme Bercy/`geographie'_`export_import'.pdf", replace

gen keep_for_luxe=0
replace keep_for_luxe=1 if share_textile>=0.025 & share_luxe>=0.8*share_textile
gen geographie="`geographie'" 
gen export_import="`export_import'"


capture append using  "~/Dropbox/Partage GD-LC/2019 Colloque Haut de gamme Bercy/Pour_echantillon_luxe.dta"
save  "~/Dropbox/Partage GD-LC/2019 Colloque Haut de gamme Bercy/Pour_echantillon_luxe.dta", replace





end
/*


keep if echantillon_luxe==1
collapse (sum) value, by(product_luxe_dans_type export_import year)
egen comm_tot = sum(value), by(year export_import)
gen share = value/comm_tot
replace product_luxe_dans_type="haut" if product_luxe_dans_type=="haut de gamme"
replace product_luxe_dans_type="bas" if product_luxe_dans_type=="bas de gamme"
replace product_luxe_dans_type="moyen" if product_luxe_dans_type=="moyen de gamme"
gen blif = export_import+ "_" +product_luxe_dans_type
drop value comm_tot export_import product_luxe_dans_type
reshape wide share,i(year) j(blif)



graph twoway (line share_luxe year, if luxe_dans_type=="haut de gamme") /*
	*/ (line share_luxe year, if luxe_dans_type=="moyen de gamme") /*
	*/ (line share_luxe year, if luxe_dans_type=="bas de gamme")

*/

quelle_importance France Imports
quelle_importance France Exports

quelle_importance Nantes Imports
quelle_importance Nantes Exports

quelle_importance Rouen Imports
quelle_importance Rouen Exports

quelle_importance Rennes Imports
quelle_importance Rennes Exports


quelle_importance Bordeaux Imports
quelle_importance Bordeaux Exports

quelle_importance Marseille Imports
quelle_importance Marseille Exports

quelle_importance Bayonne Imports
quelle_importance Bayonne Exports


quelle_importance Rochelle Imports
quelle_importance Rochelle Exports


