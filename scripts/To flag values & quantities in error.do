
use "~/Documents/Recherche/Commerce International Français XVIIIe.xls/Balance du commerce/Retranscriptions_Commerce_France/Données Stata/bdd courante.dta", clear


capture drop absurd_value
capture drop absurd_quantity

gen absurd_value=0
gen absurd_quantity=0


*egen prop = pc(value), by(source_type year tax_department export_import) prop

****D'après Torsten, email juin 2018

replace absurd_value=1 if tax_department=="Bordeaux" & year==1766 & export_import=="Exports" ////
			& (country_simplification =="Nord" | country_simplification =="Italie" | country_simplification =="Hollande") ///
			& (product_simplification == "sucre blanc")
			
replace absurd_quantity=1 if tax_department=="Bordeaux" & year==1766 & export_import=="Exports" ////
			& (country_simplification =="Nord" | country_simplification =="Italie" | country_simplification =="Hollande") ///
			& (product_simplification == "sucre blanc")

replace absurd_quantity=1 if tax_department=="Bordeaux" & year==1766 & export_import=="Exports" ////
			& (country_simplification =="Hollande") ///
			& (product_simplification == "sucre brut")	
			
replace absurd_value=1 if tax_department=="Bordeaux" & year==1766 & export_import=="Exports" ////
			& (country_simplification =="Hollande") ///
			& (product_simplification == "sucre brut")	
			
***Nous l'avons remarqué il y a longtemps...

replace absurd_value=1 if tax_department=="Bordeaux" & year==1771 & export_import=="Imports" ////
			& (country_simplification =="Îles françaises de l'Amérique") ///
			& (product_hamburg == "Café")
			
replace absurd_quantity=1 if tax_department=="Bordeaux" & year==1771 & export_import=="Imports" ////
			& (country_simplification =="Îles françaises de l'Amérique") ///
			& (product_hamburg == "Café")


replace absurd_value=1 if tax_department=="" & year==1771 & export_import=="Imports" ////
			& (country_simplification =="Îles") ///
			& (product_hamburg == "Café")
			
replace absurd_quantity=1 if tax_department=="" & year==1771 & export_import=="Imports" ////
			& (country_simplification =="Îles") ///
			& (product_hamburg == "Café")
		
			

replace absurd_value=1 if tax_department=="Bordeaux" & year==1768 & export_import=="Imports" ////
			& (country_simplification =="Îles françaises de l'Amérique") ///
			& (product_simplification == "sucre blanc")
			
replace absurd_quantity=1 if tax_department=="Bordeaux" & year==1768 & export_import=="Imports" ////
			& (country_simplification =="Îles françaises de l'Amérique") ///
			& (product_simplification == "sucre blanc")
			
******* Fèves et Légumes : 1773 La Rochelle Exports vers la Guinée. Erreur reprise dans l'Objet Général pour les légumes. Nous avons corrigé un problème de zéros
/*
replace absurd_quantity=1 if tax_department=="La Rochelle" & year==1773 & export_import=="Exports" ////
			& (country_simplification =="Guinée") ///
			& (product_simplification == "fèves")
*/			
*save "~/Documents/Recherche/Commerce International Français XVIIIe.xls/Balance du commerce/Retranscriptions_Commerce_France/Données Stata/bdd courante.dta", replace
*export delimited  "~/Documents/Recherche/Commerce International Français XVIIIe.xls/Balance du commerce/Retranscriptions_Commerce_France/Données Stata/bdd courante.csv", replace



/*Pour autres recherches
egen prop = pc(value), by(source_type year tax_department export_import) prop
list  if prop >=.5 & prop!=. & tax_department=="Bordeaux"
*/

save "~/Documents/Recherche/Commerce International Français XVIIIe.xls/Balance du commerce/Retranscriptions_Commerce_France/Données Stata/bdd courante.dta", replace
