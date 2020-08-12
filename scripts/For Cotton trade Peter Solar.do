
****To get cotton imports and exports for Peter Solar

use "/Users/guillaumedaudin/Documents/Recherche/Commerce International Français XVIIIe.xls/Balance du commerce/Retranscriptions_Commerce_France/Données Stata/bdd courante.dta", clear
keep if year == 1787 | year==1788 | year==1789 


*drop if source_type=="Résumé" & (year == 1788 | year == 1787)
drop if source_type=="Local"
drop if source_type=="National toutes tax_departments partenaires manquants"
drop if source_type=="National toutes tax_departments tous partenaires"

format value %-15.2fc
format quantites_metric %-15.2fc

drop if coton_classification=="not raw cotton"
drop if coton_classification==""

sort year export_import

export excel using "/Users/guillaumedaudin/Documents/Recherche/Commerce International Français XVIIIe.xls/Balance du commerce/Retranscriptions_Commerce_France/Données Stata/Cotton trade for Peter Solar_long.xls", firstrow(variables) replace


collapse (sum) quantites_metric value, by (u_conv coton_classification export_import year source_type)

sort year export_import
export excel using "/Users/guillaumedaudin/Documents/Recherche/Commerce International Français XVIIIe.xls/Balance du commerce/Retranscriptions_Commerce_France/Données Stata/Cotton trade for Peter Solar.xls", firstrow(variables) replace

