
****In simplification, excluding goods that cannot come at all from Canada thanks to their origin

use "~/Documents/Recherche/Commerce International Français XVIIIe.xls/Balance du commerce/Retranscriptions_Commerce_France/Données Stata/bdd courante.dta", clear

format value %-15.2fc
format quantities_metric %-15.2fc

**Ici je ne prends que parmi les partenaires présents avant 1765
drop surement_pas_canada
gen surement_pas_canada=1

tab partner_simplification if year <=1763

replace surement_pas_canada=0 if export_import == "Imports"  &  ( ///
		partner_simplification == "Îles françaises de l'Amérique" | ///
		partner_simplification == "Îles françaises" | ///
		partner_simplification == "Îles de l'Amérique" | ///
		partner_simplification == "Îles" | ///
		partner_simplification == "Louisiane" | ///
		partner_simplification == "Barbarie dans l'Océan et Îles françaises d'Amérique" | ///
		partner_simplification == "Canada")
		
collapse (min) surement_pas_canada, by(product_simplification)

rename product_simplification simplification
merge 1:1 simplification using "~/Documents/Recherche/Commerce International Français XVIIIe.xls/Balance du commerce/Retranscriptions_Commerce_France/Données Stata/classification_product_canada.dta", force

replace canada = "Pas importé en France depuis l'Amérique avant 1763" if _merge==2
drop _merge
replace canada = "Pas importé en France depuis l'Amérique avant 1763" if surement_pas_canada==1
replace canada = "Importé depuis l’Amérique avant 1763" if (canada == "Pas importé en France depuis l'Amérique avant 1763" | canada=="") & surement_pas_canada==0


sort simplification

export delimited using "~/Répertoires GIT/toflit18_data_GIT/base/classification_product_canada.csv", replace
save "~/Documents/Recherche/Commerce International Français XVIIIe.xls/Balance du commerce/Retranscriptions_Commerce_France/Données Stata/classification_product_canada.dta", replace

*************************** Traitement de la pêche

use "~/Documents/Recherche/Commerce International Français XVIIIe.xls/Balance du commerce/Retranscriptions_Commerce_France/Données Stata/classification_product_canada.dta",clear
merge 1:1 simplification using  "~/Documents/Recherche/Commerce International Français XVIIIe.xls/Balance du commerce/Retranscriptions_Commerce_France/Données Stata/classification_product_revolutionempire.dta", keep (3)
gen peche=0
replace peche=1 if revolutionempire=="Pêche et fruits de mer"
replace peche=1 if revolutionempire=="Huile de poisson"
 
replace canada = "Pêche d’Amérique avant 1763" if peche==1 & canada!="Pas importé en France depuis l'Amérique avant 1763"
replace canada = "Autres pêches" if peche==1 & canada=="Pas importé en France depuis l'Amérique avant 1763"


sort simplification

export delimited using "~/Répertoires GIT/toflit18_data_GIT/base/classification_product_canada.csv", replace
save "~/Documents/Recherche/Commerce International Français XVIIIe.xls/Balance du commerce/Retranscriptions_Commerce_France/Données Stata/classification_product_canada.dta", replace
