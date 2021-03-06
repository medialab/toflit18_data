


global dir "~/Documents/Recherche/Commerce International Français XVIIIe.xls/Balance du commerce/Retranscriptions_Commerce_France"

if "`c(username)'"=="Matthias" global dir "/Users/Matthias/"

if "`c(username)'"=="Tirindelli" global dir "/Users/Tirindelli/Google Drive/ETE/Thesis"

if "`c(username)'"=="federico.donofrio" global dir "C:\Users\federico.donofrio\Documents\GitHub"

if "`c(username)'"=="pierr" global dir "/Users/pierr/Documents/Toflit/"

if "`c(username)'"=="loiccharles" global dir "/Users/loiccharles/Documents/"



*****À remettre pour les tests
*use "$dir/Données Stata/bdd courante.dta", clear


capture drop absurd_value
capture drop absurd_quantity

gen absurd_value=0
gen absurd_quantity=0


*egen prop = pc(value), by(source_type year customs_region export_import) prop

/*Corrigé par Loïc 30 octobre 2020

replace absurd_value=1 if customs_region=="Bordeaux" & year==1770 & export_import=="Imports" ///
		& (partner_simplification=="Nord" | partner_simplification=="Hollande" ) ///
		& (product_simplification=="froment")
**Ces chiffres sont beaucoup trop importants

*/


****D'après Torsten, email juin 2018 --- Mis dans la source

replace absurd_value=1 if customs_region=="Bordeaux" & year==1766 & export_import=="Exports" ////
			& (partner_simplification =="Nord" | partner_simplification =="Italie" | partner_simplification =="Hollande") ///
			& (product_simplification == "sucre blanc")
			
replace absurd_quantity=1 if customs_region=="Bordeaux" & year==1766 & export_import=="Exports" ////
			& (partner_simplification =="Nord" | partner_simplification =="Italie" | partner_simplification =="Hollande") ///
			& (product_simplification == "sucre blanc")

replace absurd_quantity=1 if customs_region=="Bordeaux" & year==1766 & export_import=="Exports" ////
			& (partner_simplification =="Hollande") ///
			& (product_simplification == "sucre brut")	
			
replace absurd_value=1 if customs_region=="Bordeaux" & year==1766 & export_import=="Exports" ////
			& (partner_simplification =="Hollande") ///
			& (product_simplification == "sucre brut")	
			
***Nous l'avons remarqué il y a longtemps...

replace absurd_value=1 if customs_region=="Bordeaux" & year==1771 & export_import=="Imports" ////
			& (partner_simplification =="Îles françaises de l'Amérique") ///
			& (product_hamburg == "Café")
			
replace absurd_quantity=1 if customs_region=="Bordeaux" & year==1771 & export_import=="Imports" ////
			& (partner_simplification =="Îles françaises de l'Amérique") ///
			& (product_hamburg == "Café")


replace absurd_value=1 if customs_region=="" & year==1771 & export_import=="Imports" ////
			& (partner_simplification =="Îles") ///
			& (product_hamburg == "Café")
			
replace absurd_quantity=1 if customs_region=="" & year==1771 & export_import=="Imports" ////
			& (partner_simplification =="Îles") ///
			& (product_hamburg == "Café")
		
			

replace absurd_value=1 if customs_region=="Bordeaux" & year==1768 & export_import=="Imports" ////
			& (partner_simplification =="Îles françaises de l'Amérique") ///
			& (product_simplification == "sucre blanc")
			
replace absurd_quantity=1 if customs_region=="Bordeaux" & year==1768 & export_import=="Imports" ////
			& (partner_simplification =="Îles françaises de l'Amérique") ///
			& (product_simplification == "sucre blanc")
			
******* Fèves et Légumes : 1773 La Rochelle Exports vers la Guinée. Erreur reprise dans l'Objet Général pour les légumes. Nous avons corrigé un problème de zéros
/*
replace absurd_quantity=1 if customs_region=="La Rochelle" & year==1773 & export_import=="Exports" ////
			& (partner_simplification =="Guinée") ///
			& (product_simplification == "fèves")
*/			
*save "~/Documents/Recherche/Commerce International Français XVIIIe.xls/Balance du commerce/Retranscriptions_Commerce_France/Données Stata/bdd courante.dta", replace
*export delimited  "~/Documents/Recherche/Commerce International Français XVIIIe.xls/Balance du commerce/Retranscriptions_Commerce_France/Données Stata/bdd courante.csv", replace



/*Pour autres recherches
egen prop = pc(value), by(source_type year customs_region export_import) prop
list  if prop >=.5 & prop!=. & customs_region=="Bordeaux"
*/


*À remettre pour les tests
*save "$dir/Données Stata/bdd courante.dta", replace
