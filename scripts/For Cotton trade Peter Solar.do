
****To get cotton imports and exports for Peter Solar

use "/Users/guillaumedaudin/Documents/Recherche/Commerce International Français XVIIIe.xls/Balance du commerce/Retranscriptions_Commerce_France/Données Stata/bdd courante.dta", clear
keep if year == 1787 | year==1788 | year==1789 


drop if sourcetype=="Résumé" & (year == 1788 | year == 1787)
drop if sourcetype=="Local"
drop if sourcetype=="National toutes directions partenaires manquants"
drop if sourcetype=="National toutes directions tous partenaires"

format value %-15.2fc
format quantites_metric %-15.2fc

drop if raw_cotton_classification=="not raw cotton"
drop if raw_cotton_classification==""

sort year exportsimports

export excel using "/Users/guillaumedaudin/Documents/Recherche/Commerce International Français XVIIIe.xls/Balance du commerce/Retranscriptions_Commerce_France/Données Stata/Cotton trade for Peter Solar_long.xls", firstrow(variables) replace

preserve
collapse (sum) quantites_metric value, by (u_conv raw_cotton_classification exportsimports year)

sort year exportsimports
export excel using "/Users/guillaumedaudin/Documents/Recherche/Commerce International Français XVIIIe.xls/Balance du commerce/Retranscriptions_Commerce_France/Données Stata/Cotton trade for Peter Solar.xls", firstrow(variables) replace
