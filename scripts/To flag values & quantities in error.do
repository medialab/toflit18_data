
use "~/Documents/Recherche/Commerce International Français XVIIIe.xls/Balance du commerce/Retranscriptions_Commerce_France/Données Stata/bdd courante.dta", clear

capture gen absurd_value=0
capture gen absurd_quantity=0


*egen prop = pc(value), by(sourcetype year direction exportsimports) prop

****D'après Torsten, email juin 2018

replace absurd_value=1 if direction=="Bordeaux" & year==1766 & exportsimports=="Exports" ////
			& (partners_simpl_classification =="Nord" | partners_simpl_classification =="Italie" | partners_simpl_classification =="Hollande") ///
			& (goods_simpl_classification == "sucre blanc")
			
replace absurd_quantity=1 if direction=="Bordeaux" & year==1766 & exportsimports=="Exports" ////
			& (partners_simpl_classification =="Nord" | partners_simpl_classification =="Italie" | partners_simpl_classification =="Hollande") ///
			& (goods_simpl_classification == "sucre blanc")

replace absurd_quantity=1 if direction=="Bordeaux" & year==1766 & exportsimports=="Exports" ////
			& (partners_simpl_classification =="Hollande") ///
			& (goods_simpl_classification == "sucre brut")	
			
replace absurd_value=1 if direction=="Bordeaux" & year==1766 & exportsimports=="Exports" ////
			& (partners_simpl_classification =="Hollande") ///
			& (goods_simpl_classification == "sucre brut")	
			
***Nous l'avons remarqué il y a longtemps...

replace absurd_value=1 if direction=="Bordeaux" & year==1771 & exportsimports=="Imports" ////
			& (partners_simpl_classification =="Îles françaises de l'Amérique") ///
			& (goods_simpl_classification == "café")
			
replace absurd_quantity=1 if direction=="Bordeaux" & year==1771 & exportsimports=="Imports" ////
			& (partners_simpl_classification =="Îles françaises de l'Amérique") ///
			& (goods_simpl_classification == "café")
			

replace absurd_value=1 if direction=="Bordeaux" & year==1768 & exportsimports=="Imports" ////
			& (partners_simpl_classification =="Îles françaises de l'Amérique") ///
			& (goods_simpl_classification == "sucre blanc")
			
replace absurd_quantity=1 if direction=="Bordeaux" & year==1768 & exportsimports=="Imports" ////
			& (partners_simpl_classification =="Îles françaises de l'Amérique") ///
			& (goods_simpl_classification == "sucre blanc")
			
			
*save "~/Documents/Recherche/Commerce International Français XVIIIe.xls/Balance du commerce/Retranscriptions_Commerce_France/Données Stata/bdd courante.dta", replace
*export delimited  "~/Documents/Recherche/Commerce International Français XVIIIe.xls/Balance du commerce/Retranscriptions_Commerce_France/Données Stata/bdd courante.csv", replace



/*Pour autres recherches
egen prop = pc(value), by(sourcetype year direction exportsimports) prop
list  if prop >=.5 & prop!=. & direction=="Bordeaux"
*/
