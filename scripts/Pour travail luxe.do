****Pour exploiter classification luxe / bas de gamme
**Pour colloque 2019

global dir "~/Documents/Recherche/Commerce International Français XVIIIe.xls/Balance du commerce/Retranscriptions_Commerce_France"



**************************************
*
**************************************
*** et maintenant des stats des
use "$dir/Données Stata/bdd courante.dta", clear

gen echantillon_luxe =0
replace echantillon_luxe=1 if  product_type_textile =="passementerie" | product_type_textile =="tissés" 

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



