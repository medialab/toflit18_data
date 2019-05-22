
use "~/Documents/Recherche/Commerce International Français XVIIIe.xls/Balance du commerce/Retranscriptions_Commerce_France/Données Stata/bdd courante.dta", clear


capture drop absurd_value
capture drop absurd_quantity

gen absurd_value=0
gen absurd_quantity=0


*egen prop = pc(value), by(sourcetype year direction exportsimports) prop

****D'après Torsten, email juin 2018

replace absurd_value=1 if direction=="Bordeaux" & year==1766 & exportsimports=="Exports" ////
			& (country_simplification =="Nord" | country_simplification =="Italie" | country_simplification =="Hollande") ///
			& (product_simplification == "sucre blanc")
			
replace absurd_quantity=1 if direction=="Bordeaux" & year==1766 & exportsimports=="Exports" ////
			& (country_simplification =="Nord" | country_simplification =="Italie" | country_simplification =="Hollande") ///
			& (product_simplification == "sucre blanc")

replace absurd_quantity=1 if direction=="Bordeaux" & year==1766 & exportsimports=="Exports" ////
			& (country_simplification =="Hollande") ///
			& (product_simplification == "sucre brut")	
			
replace absurd_value=1 if direction=="Bordeaux" & year==1766 & exportsimports=="Exports" ////
			& (country_simplification =="Hollande") ///
			& (product_simplification == "sucre brut")	
			
***Nous l'avons remarqué il y a longtemps...

replace absurd_value=1 if direction=="Bordeaux" & year==1771 & exportsimports=="Imports" ////
			& (country_simplification =="Îles françaises de l'Amérique") ///
			& (product_hamburg == "Café")
			
replace absurd_quantity=1 if direction=="Bordeaux" & year==1771 & exportsimports=="Imports" ////
			& (country_simplification =="Îles françaises de l'Amérique") ///
			& (product_hamburg == "Café")


replace absurd_value=1 if direction=="" & year==1771 & exportsimports=="Imports" ////
			& (country_simplification =="Îles") ///
			& (product_hamburg == "Café")
			
replace absurd_quantity=1 if direction=="" & year==1771 & exportsimports=="Imports" ////
			& (country_simplification =="Îles") ///
			& (product_hamburg == "Café")
		
			

replace absurd_value=1 if direction=="Bordeaux" & year==1768 & exportsimports=="Imports" ////
			& (country_simplification =="Îles françaises de l'Amérique") ///
			& (product_simplification == "sucre blanc")
			
replace absurd_quantity=1 if direction=="Bordeaux" & year==1768 & exportsimports=="Imports" ////
			& (country_simplification =="Îles françaises de l'Amérique") ///
			& (product_simplification == "sucre blanc")
			
			
*save "~/Documents/Recherche/Commerce International Français XVIIIe.xls/Balance du commerce/Retranscriptions_Commerce_France/Données Stata/bdd courante.dta", replace
*export delimited  "~/Documents/Recherche/Commerce International Français XVIIIe.xls/Balance du commerce/Retranscriptions_Commerce_France/Données Stata/bdd courante.csv", replace



/*Pour autres recherches
egen prop = pc(value), by(sourcetype year direction exportsimports) prop
list  if prop >=.5 & prop!=. & direction=="Bordeaux"
*/
