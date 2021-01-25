* CREATION D'UNE BASE REDUITE (NE PAS RELANCER (SAUF EN CAS DE PROBLEME AVEC BDD COURANTE REDUITE))

* Ne pas oublier de mettre la base de données utilisée 
* Dans cette base, on considère que les produits de même dénomination sont les mêmes quelques soient leurs provenance / origin
use "C:\Users\gdonnat\Documents\TOFLIT18\bdd_courante.dta", clear 

*if "`c(username)'"=="guillaumedaudin" ///
*        use "~/Documents/Recherche/Commerce International Français XVIIIe.xls/Balance du commerce/Retranscriptions_Commerce_France/Données Stata/bdd courante.dta", clear

* Sélectionner les variables que l'on veut garder (keep)

keep year customs_region export_import quantity value_unit product_simplification value quantities_metric quantity_unit_ajustees quantity_unit_ortho u_conv q_conv
sort product_simplification year
order product_simplification year value_unit quantity quantity_unit_ajustees u_conv q_conv value customs_region export_import
label var quantities_metric "Quantités en kg (q_conv)" 

* On supprime les product qui n'ont pas de prix 


 drop if value_unit==.
 drop if value_unit==0
 drop if product_simplification=="" | product_simplification=="???"
 drop if value==.
 
 
 * Essai : ou qui apparaissent moins de 1000 fois dans la base /
 * ou bien on supprime les product dont la valeur totale échangée sur la période est inférieure à 100 000
 * encode product_simplification, gen(product_simplification_num)
 * bysort product_simplification_num: drop if _N<=1000 
 * sort product_simplification year
	

* Calculer la valeur totale échangée par marchandise sur la période

by product_simplification customs_region export_import u_conv, sort: egen valeur_totale_par_marchandise=total(value)	
label var valeur_totale_par_marchandise "Somme variable valeur par march_simpli, dir, expimp, u_conv" 	
drop if valeur_totale_par_marchandise<=100000
sort product_simplification year
	

* On convertit les prix dans leur unité conventionnelle
	
generate value_unit_converti=value_unit/q_conv 
drop if value_unit_converti==.
label var value_unit_converti "Prix unitaire par marchandise en unité métrique p_conv" 

* Calcul de la moyenne des prix par année en pondérant en fonction des quantités échangées pour un produit.unitée métrique

*drop if quantities_metric==.
*by year customs_region export_import u_conv product_simplification, sort: egen quantite_echangee=total(quantities_metric)
*label var quantite_echangee "Quantités métric par dir expimp u_conv march_simpli"

*generate value_unit_pondere=(quantites_metric/quantite_echangee)*value_unit_converti
*label var value_unit_pondere "Prix de chaque observation en u métrique en % de la quantity échangée totale" 


collapse (sum) value quantities_metric,by(year customs_region export_import u_conv product_simplification)

* by year customs_region export_import u_conv product_simplification, sort: egen prix_pondere_annuel=total(value_unit_pondere)


gen prix_pondere_annuel = value/quantities_metric
label var prix_pondere_annuel "Prix moyen d'une mrchd pour une année, march, dir, expimp, u_conv"
sort product_simplification year

*drop value_unit_pondere

* Encode panvar (sinon prend trop de temps) 
gen panvar = product_simplification + export_import + customs_region + u_conv
encode panvar, gen(panvar_num)
drop if year>1787 & year<1788
tsset panvar_num year

* On sauvegarde la base de donnée désormais réduite (A REMPLACER SI ON PREND FINALEMENT LES MARCHANDISES DONT VALEUR > 100 000)
 
*if "`c(username)'"=="maellestricot" save   "/Users/maellestricot/Documents/STATA MAC/bdd courante reduite2.dta", replace
*if "`c(username)'"=="guillaumedaudin" save "~/Documents/Recherche/TOFLIT18/Indices de prix - travail Maëlle Stricot/bdd courante reduite2.dta", replace



save "C:\Users\gdonnat\Documents\TOFLIT18\bdd_courante_reduite.dta", replace 