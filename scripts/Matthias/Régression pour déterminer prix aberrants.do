 * Sans utiliser les unités métriques
 
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
	drop if prix_unitaire==.
	drop if prix_unitaire==0
	keep if u_conv==""
	drop if quantit==.
	drop if quantity_unit==""
	gen prix_obs=prix_unitaire
	gen lnPrix=ln(prix_obs)
}

if "`def_unit'"=="u_conv" {
	drop if u_conv=="."
	drop if q_conv==0
	drop if q_conv==.
	drop if prix_unitaire==.
	drop if prix_unitaire==0
	gen prix_obs=prix_unitaire/q_conv
	gen lnPrix=ln(prix_obs)
}

 
 
 
 encode goods_simpl_classification, gen(goods_simpl_classification_num)
 bysort goods_simpl_classification_num: drop if _N<=10
 encode `def_unit', gen(`def_unit'_num)
 bysort `def_unit'_num: drop if _N<=10
 gen marchandises_et_quantités = goods_simpl_classification + `def_unit'
 encode marchandises_et_quantités, gen(marchandises_et_quantités_num)
 bysort marchandises_et_quantités_num: drop if _N<=10
 drop if year>1787 & year<1788
 drop if year==1805.75
 regress lnPrix i.marchandises_et_quantités_num i.year if exportsimports=="Imports"
 predict lnPrix_predImp if e(sample)
 gen résiduImp = lnPrix_predImp - lnPrix
 
 regress lnPrix i.marchandises_et_quantités_num i.year if exportsimports=="Exports"
 predict lnPrix_predExp if e(sample)
 gen résiduExp = lnPrix_predExp - lnPrix
 
 gen nbr_de_comparaisons=.
 by marchandises_et_quantités_num : replace nbr_de_comparaisons=_N

 drop if abs(résiduImp)<`plancher' & exportsimports=="Imports"
 drop if abs(résiduImp)>`plafond' & exportsimports=="Imports" 
 drop if abs(résiduExp)<`plancher' & exportsimports=="Exports"
 drop if abs(résiduExp)>`plafond' & exportsimports=="Exports"
 drop if résiduExp==. & résiduImp==.
 
 gen ln_prix_pred = lnPrix_predImp if exportsimports=="Imports"
 replace ln_prix_pred = lnPrix_predExp if exportsimports=="Exports"
 gen prix_predit = exp(ln_prix_pred)
 
 drop if doubleaccounts==1
 drop if doubleaccounts==2
 drop if doubleaccounts==3
 
 keep numrodeligne sourcepath exportsimports year sheet marchandises goods_simpl_classification pays ///
      résiduImp résiduExp quantit `def_unit' quantity_unit prix_obs prix_predit nbr_de_comparaisons
 
 sort sourcepath numrodeligne
 export delimited using "$dir/Travail sur les points aberrants/probleme_prix_`def_unit'_`plancher'_`plafond'.csv", replace
 save "$dir/Travail sur les points aberrants/probleme_prix_`def_unit'_`plancher'_`plafond'.dta", replace
 
 
 end
 
 
 
 pour_determ_prix_aberrants quantity_unit 5 .
 pour_determ_prix_aberrants u_conv 5 .
 
 
 
 
 
 
 
 
 
 
 
 
 /*
 * En utilisant les unités métriques
 
 clear all
 set maxvar 32767
 set matsize 11000
 use "$dir/Données Stata/bdd courante.dta", clear
 drop if u_conv=="."
 drop if q_conv==0
 drop if q_conv==.
 drop if prix_unitaire==.
 drop if prix_unitaire==0
 gen prix_conv=prix_unitaire/q_conv
 gen lnPrix=ln(prix_conv)
 encode goods_simpl_classification, gen(goods_simpl_classification_num)
 bysort goods_simpl_classification_num: drop if _N<=10
 gen marchandises_et_unités = goods_simpl_classification + u_conv
 encode marchandises_et_unités, gen(marchandises_et_unités_num)
 bysort marchandises_et_unités_num: drop if _N<=10
 drop if year>1787 & year<1788
 drop if year==1805.75
 regress lnPrix i.marchandises_et_unités_num i.year if exportsimports=="Imports"
 predict lnPrix_predImp if e(sample)
 gen résiduImp = lnPrix_predImp - lnPrix
 
 regress lnPrix i.marchandises_et_unités_num i.year if exportsimports=="Exports"
 predict lnPrix_predExp if e(sample)
 gen résiduExp = lnPrix_predExp - lnPrix

 drop if abs(résiduImp)<2 & exportsimports=="Imports"
 drop if abs(résiduExp)<2 & exportsimports=="Exports"
 drop if résiduExp==. & résiduImp==.
 
 gen ln_prix_pred = lnPrix_predImp if exportsimports=="Imports"
 replace ln_prix_pred = lnPrix_predExp if exportsimports=="Exports"
 gen prix_conv_pred = exp(ln_prix_pred)
 gen prix_pred = prix_conv_pred*q_conv
 
 drop if doubleaccounts==1
 drop if doubleaccounts==2
 drop if doubleaccounts==3
 
 keep numrodeligne sourcepath sourcetype direction exportsimports year sheet marchandises pays ///
	  résiduImp résiduExp prix_unitaire quantity_unit u_conv q_conv prix_conv_pred prix_pred
 
 sort sourcepath numrodeligne
 export delimited using "$dir/Travail sur les points aberrants/probleme_prix2.csv", replace
 save "$dir/Travail sur les points aberrants/probleme_prix2.dta", replace
 
 
 use "$dir/Travail sur les points aberrants/probleme_prix2.dta", clear
 drop if abs(résiduImp)<2.5 & exportsimports=="Imports"
 drop if abs(résiduExp)<2.5 & exportsimports=="Exports"
 keep if sourcetype=="Local"
 keep if direction=="Bordeaux"
 sort exportsimports year numrodeligne
 export delimited using "$dir/Travail sur les points aberrants/probleme_prix3.csv", replace
 
 list prix_unitaire quantity_unit if strmatch(marchandises,"**")

