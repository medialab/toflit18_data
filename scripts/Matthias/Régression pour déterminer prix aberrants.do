
 
 global dir "~/Documents/Recherche/Commerce International Français XVIIIe.xls/Balance du commerce/Retranscriptions_Commerce_France"
 global dirgit "~/Documents/Recherche/Commerce International Français XVIIIe.xls/Balance du commerce/Retranscriptions_Commerce_France/toflit18_data_GIT"
 
 clear all
 set maxvar 32767
 set matsize 11000
 
 
 capture program drop pour_determ_prix_aberrants
 program pour_determ_prix_aberrants
 args def_unit plancher plafond
 *eg pour_determ_prix_aberrants quantity_unit 5 .
 
 use "$dir/Données Stata/bdd courante.dta", clear
 
 if "`def_unit'"=="quantity_unit" {
	drop if value_unit==.
	drop if value_unit==0
	keep if u_conv==""
	drop if quantit==.
	drop if quantity_unit==""
	gen prix_obs=value_unit
	gen lnPrix=ln(prix_obs)
}

if "`def_unit'"=="u_conv" {
	drop if u_conv=="."
	drop if q_conv==0
	drop if q_conv==.
	drop if value_unit==.
	drop if value_unit==0
	gen prix_obs=value_unit/q_conv
	gen lnPrix=ln(prix_obs)
}

 
 
 
 encode goods_simpl_classification, gen(goods_simpl_classification_num)
 bysort goods_simpl_classification_num: drop if _N<=10
 encode `def_unit', gen(`def_unit'_num)
 bysort `def_unit'_num: drop if _N<=10
 gen product_et_quantités = goods_simpl_classification + `def_unit'
 encode product_et_quantités, gen(product_et_quantités_num)
 bysort product_et_quantités_num: drop if _N<=10
 drop if year>1787 & year<1788
 drop if year==1805.75
 regress lnPrix i.product_et_quantités_num i.year if export_import=="Imports"
 predict lnPrix_predImp if e(sample)
 gen résiduImp = lnPrix_predImp - lnPrix
 
 regress lnPrix i.product_et_quantités_num i.year if export_import=="Exports"
 predict lnPrix_predExp if e(sample)
 gen résiduExp = lnPrix_predExp - lnPrix
 
 gen nbr_de_comparaisons=.
 by product_et_quantités_num : replace nbr_de_comparaisons=_N

 
 gen ln_prix_pred = lnPrix_predImp if export_import=="Imports"
 replace ln_prix_pred = lnPrix_predExp if export_import=="Exports"
 gen prix_predit = exp(ln_prix_pred)
 
 
 
 drop if abs(résiduImp)<`plancher' & export_import=="Imports"
 drop if abs(résiduImp)>`plafond' & export_import=="Imports" 
 drop if abs(résiduExp)<`plancher' & export_import=="Exports"
 drop if abs(résiduExp)>`plafond' & export_import=="Exports"
 drop if résiduExp==. & résiduImp==.
 
 
 
 drop if value_part_of_bundle==1
 drop if value_part_of_bundle==2
 drop if value_part_of_bundle==3
 
 keep line_number filepath export_import year sheet product goods_simpl_classification partner ///
      résiduImp résiduExp quantity `def_unit' quantity_unit prix_obs prix_predit nbr_de_comparaisons
 
 sort filepath line_number
 export delimited using "$dir/Travail sur les points aberrants/probleme_prix_`def_unit'_`plancher'_`plafond'.csv", replace
 save "$dir/Travail sur les points aberrants/probleme_prix_`def_unit'_`plancher'_`plafond'.dta", replace
 
 
 end
 
 
 
 
 pour_determ_prix_aberrants u_conv 5 .
 pour_determ_prix_aberrants quantity_unit 3 .
 
 **Les problèmes trouvés avec u_conv sont souvent dûs à des erreurs de conversion
 **Les problèmes avec quantity_unit sont très clairement des soucis de retranscription
