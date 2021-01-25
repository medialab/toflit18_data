
**Ne marche pas bien. Les classifications sont trop étroite (le sucre vers le Nord n'existe qu'à partir de 1785 et les faibles flux de la révolution et de l'empire flaguent
**les hauts flus de 1788
**Il faut mieux choisir les sources
**Et ne pas partir de goods_simpl_classification (ou alors mettre barre pour éliminer les noms simplifiés plus haute qu'à 10



 
 global dir "~/Documents/Recherche/Commerce International Français XVIIIe.xls/Balance du commerce/Retranscriptions_Commerce_France"
 global dirgit "~/Documents/Recherche/Commerce International Français XVIIIe.xls/Balance du commerce/Retranscriptions_Commerce_France/toflit18_data_GIT"
 

 clear all
 set maxvar 32767
 set matsize 11000
 
 
 capture program drop pour_determ_valeurs_aberrantes
 program pour_determ_valeurs_aberrantes
 args plancher
 
 use "$dir/Données Stata/bdd courante.dta", clear
 drop if source_type=="1792-both semester"
 drop if source_type=="1792-first semester" 
 drop if source_type=="Colonies"
 drop if source_type=="Divers"
 drop if source_type=="Divers - in"
 drop if source_type=="Local"
 drop if source_type=="Tableau Général"
 collapse (sum) value,by(grouping_classification export_import year goods_simpl_classification)
 rename value somme_value
 
 gen ln_somme_value	=ln(somme_value)
 encode goods_simpl_classification, gen(goods_simpl_classification_num)
 bysort goods_simpl_classification_num: drop if _N<=10
 encode grouping_classification, gen(grouping_classification_num)
 drop if year>1787 & year<1788
 drop if year==1805.75
 
 *keep if grouping_classification=="Nord" & goods_simpl_classification=="sucre"
 *tab year
 
 regress ln_somme_value i.goods_simpl_classification_num i.year i.grouping_classification_num if export_import=="Imports"
 predict ln_somme_value_predImp if e(sample)
 gen résiduImp = ln_somme_value_predImp - ln_somme_value
 * histogram résiduImp
 * drop if résiduImp==.
 * count if abs(résiduImp)>8
 gen somme_value_predImp=exp(ln_somme_value_predImp)
 
 regress ln_somme_value i.goods_simpl_classification_num i.year i.grouping_classification_num if export_import=="Exports"
 predict ln_somme_value_predExp if e(sample)
 gen résiduExp = ln_somme_value_predExp - ln_somme_value
 * histogram résiduExp
 * drop if résiduExp==.
 * count if abs(résiduExp)>8
 gen somme_value_predExp=exp(ln_somme_value_predExp)
 
*blif
 
 gen résidu=résiduExp
 replace résidu=résiduImp if export_import=="Imports"
 
 gen résidu_élevé = 1 if résidu<`plancher'
 
					
merge 1:m year goods_simpl_classification export_import  grouping_classification ///
					using "$dir/Données Stata/bdd courante.dta"
 

 keep if résidu_élevé==1
drop if résiduImp>=`plancher' & export_import=="Imports"
drop if résiduExp>=`plancher' & export_import=="Exports"
drop if résiduExp==. & résiduImp==.
 
 
sort year export_import goods_simpl_classification grouping_classification
 
 
 
keep year export_import goods_simpl_classification grouping_classification ///
			value somme_value  somme_value_predExp somme_value_predImp ///
			customs_region ///
			line_number filepath sheet product partner ///

order year export_import goods_simpl_classification grouping_classification ///
			value somme_value  somme_value_predExp somme_value_predImp ///
			customs_region ///
			line_number filepath sheet product partner ///
		
 
save "$dir/Travail sur les points aberrants/probleme_valeurs.dta", replace
 export delimited using "$dir/Travail sur les points aberrants/probleme_valeurs.csv", replace
 
 end
 
 pour_determ_valeurs_aberrantes -7
 
 * Essayer en ne gardant que les résidus négatifs <-5 par exemple
 
 
