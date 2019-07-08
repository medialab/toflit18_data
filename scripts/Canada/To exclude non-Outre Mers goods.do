
****To get Data for the African Commodity Trade Database

use "/Users/guillaumedaudin/Documents/Recherche/Commerce International Français XVIIIe.xls/Balance du commerce/Retranscriptions_Commerce_France/Données Stata/bdd courante.dta", clear

format value %-15.2fc
format quantities_metric %-15.2fc

keep if country_africa =="Africa"


export delimited using "/Users/guillaumedaudin/Documents/Recherche/Commerce International Français XVIIIe.xls/Balance du commerce/Retranscriptions_Commerce_France/Données Stata/TOFLIT18 for African Commodity Trade Database.csv", replace


