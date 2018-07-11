
use "~/Documents/Recherche/Commerce International Français XVIIIe.xls/Balance du commerce/Retranscriptions_Commerce_France/Données Stata/bdd courante.dta", clear

capture gen value_in_error=0
capture gen quantity_in_error=0


*egen prop = pc(value), by(sourcetype year direction exportsimports) prop

****D'après Torsten, email juin 2018

replace value_in_error=1 if direction=="Bordeaux" & year==1766 & exportsimports=="Exports" ////
			& (partners_simpl_classification =="Nord" | partners_simpl_classification =="Italie" | partners_simpl_classification =="Hollande") ///
			& (goods_simpl_classification == "sucre blanc")
			
replace quantity_in_error=1 if direction=="Bordeaux" & year==1766 & exportsimports=="Exports" ////
			& (partners_simpl_classification =="Nord" | partners_simpl_classification =="Italie" | partners_simpl_classification =="Hollande") ///
			& (goods_simpl_classification == "sucre blanc")

replace quantity_in_error=1 if direction=="Bordeaux" & year==1766 & exportsimports=="Exports" ////
			& (partners_simpl_classification =="Hollande") ///
			& (goods_simpl_classification == "sucre brut")	
			
replace value_in_error=1 if direction=="Bordeaux" & year==1766 & exportsimports=="Exports" ////
			& (partners_simpl_classification =="Hollande") ///
			& (goods_simpl_classification == "sucre brut")	


			
			
			
			
use "~/Documents/Recherche/Commerce International Français XVIIIe.xls/Balance du commerce/Retranscriptions_Commerce_France/Données Stata/bdd courante.dta", replace
export delimited use "~/Documents/Recherche/Commerce International Français XVIIIe.xls/Balance du commerce/Retranscriptions_Commerce_France/Données Stata/bdd courante.csv", replace
