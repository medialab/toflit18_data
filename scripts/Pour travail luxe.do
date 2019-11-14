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
collapse (sum) value, by(echantillon_luxe year exportsimports)
egen comm_tot = sum(value), by(year exportsimports)
gen share_echantillon_luxe = value/comm_tot if echantillon_luxe==1
drop if share_echantillon_luxe==.
drop echantillon_luxe value comm_tot
reshape wide share_echantillon_luxe,i(year) j(exportsimports) string


graph twoway (line share_echantillon_luxeExports year) (line share_echantillon_luxeImports year), name(share_echantillon_luxe, replace)
restore

keep if echantillon_luxe==1
collapse (sum) value, by(product_luxe_dans_type exportsimports year)
egen comm_tot = sum(value), by(year exportsimports)
gen share = value/comm_tot
replace product_luxe_dans_type="haut" if product_luxe_dans_type=="haut de gamme"
replace product_luxe_dans_type="bas" if product_luxe_dans_type=="bas de gamme"
replace product_luxe_dans_type="moyen" if product_luxe_dans_type=="moyen de gamme"
gen blif = exportsimports+ "_" +product_luxe_dans_type
drop value comm_tot exportsimports product_luxe_dans_type
reshape wide share,i(year) j(blif)



graph twoway (line share_luxe year, if luxe_dans_type=="haut de gamme") /*
	*/ (line share_luxe year, if luxe_dans_type=="moyen de gamme") /*
	*/ (line share_luxe year, if luxe_dans_type=="bas de gamme")



