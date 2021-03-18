cd "/Users/guillaumedaudin/Documents/Recherche/Commerce International Français XVIIIe.xls/Balance du commerce/Retranscriptions_Commerce_France/Données Stata"



use "Marchandises Navigocorpus/Navigo.dta", clear
rename  product source
merge 1:1 source using "classification_product_orthographic.dta"
drop if _merge==2
drop _merge

merge m:1 orthographic using "classification_product_simplification"
drop if _merge==2
drop nbr_occure* _merge
rename orthographic  product_orthographic

foreach class_name in sitc edentreaty ///
				canada medicinales hamburg ///
				grains  coton ulrich ///
				coffee porcelaine ///
				v_glass_beads revolutionempire beaver ///
				type_textile luxe_dans_type luxe_dans_SITC {

	merge m:1 simplification using "classification_product_`class_name'.dta"
	drop if _merge==2
	drop nbr_occure* _merge
	capture drop obsolete
	rename `class_name' product_`class_name'
	if "`class_name'"=="revolutionempire" capture drop sitc sitc_FR
	
}
rename simplification product_simplification



rename product_sitc sitc
foreach class_name in sitc_FR sitc_EN sitc_simplEN {
	merge m:1 sitc using "classification_product_`class_name'.dta"
	drop if _merge==2
	drop _merge
	rename `class_name' product_`class_name'
}
rename sitc product_sitc

foreach class_name in RE_aggregate threesectors threesectorsM {
	rename product_revolutionempire revolutionempire
	merge m:1 revolutionempire using "classification_product_`class_name'.dta"
	rename revolutionempire product_revolutionempire
	drop nbr_occure*
	drop if _merge==2
	drop _merge
	rename `class_name' product_`class_name'
}


drop peche details_provenance nbr_obs imprimatur note nbr_occurrences* nb_occurence* surement_pas* obsolete

rename source product

merge 1:1 product using "Marchandises Navigocorpus/Navigo.dta"
drop _merge
rename product source

export delimited using "/Users/guillaumedaudin/Répertoires Git/toflit18_data_GIT/traitements_marchandises/Marchandises Navigocorpus/Produits_Navigo_plat.csv", replace
