* CREATION D'UNE BASE REDUITE (NE PAS RELANCER (SAUF EN CAS DE PROBLEME AVEC BDD COURANTE REDUITE))

* Ne pas oublier de mettre la base de données utilisée 
* Dans cette base, on considère que les produits de même dénomination sont les mêmes quelques soient leurs provenance / origin

capture use "/Users/maellestricot/Documents/STATA MAC/bdd courante2.dta", clear

if "`c(username)'"=="guillaumedaudin" ///
        use "~/Documents/Recherche/Commerce International Français XVIIIe.xls/Balance du commerce/Retranscriptions_Commerce_France/Données Stata/bdd courante.dta", clear

* Sélectionner les variables que l'on veut garder (keep)

keep year customs_region export_import quantity value_unit simplification_classification value quantites_metric quantity_unit_ajustees quantity_unit_ortho u_conv q_conv
sort simplification_classification year
order simplification_classification year value_unit quantity quantity_unit_ajustees u_conv q_conv value customs_region export_import
label var quantites_metric "Quantités en kg (q_conv)" 

* On supprime les product qui n'ont pas de prix 


 drop if value_unit==.
 drop if value_unit==0
 drop if simplification_classification=="" | simplification_classification=="???"
 drop if value==.
 
 
 * Essai : ou qui apparaissent moins de 1000 fois dans la base /
 * ou bien on supprime les product dont la valeur totale échangée sur la période est inférieure à 100 000
 * encode simplification_classification, gen(simplification_classification_num)
 * bysort simplification_classification_num: drop if _N<=1000 
 * sort simplification_classification year
	

* Calculer la valeur totale échangée par marchandise sur la période

*by simplification_classification customs_region export_import u_conv, sort: egen valeur_totale_par_marchandise=total(value)	
*label var valeur_totale_par_marchandise "Somme variable valeur par march_simpli, dir, expimp, u_conv" 	
*drop if valeur_totale_par_marchandise<=100000
*sort simplification_classification year
	

* On convertit les prix dans leur unité conventionnelle
	
generate value_unit_converti=value_unit/q_conv 
drop if value_unit_converti==.
label var value_unit_converti "Prix unitaire par marchandise en unité métrique p_conv" 

* Calcul de la moyenne des prix par année en pondérant en fonction des quantités échangées pour un produit.unitée métrique

*drop if quantites_metric==.
*by year customs_region export_import u_conv simplification_classification, sort: egen quantite_echangee=total(quantites_metric)
*label var quantite_echangee "Quantités métric par dir expimp u_conv march_simpli"

*generate value_unit_pondere=(quantites_metric/quantite_echangee)*value_unit_converti
*label var value_unit_pondere "Prix de chaque observation en u métrique en % de la quantity échangée totale" 


collapse (sum) value quantites_metric,by(year customs_region export_import u_conv simplification_classification)

* by year customs_region export_import u_conv simplification_classification, sort: egen prix_pondere_annuel=total(value_unit_pondere)


gen prix_pondere_annuel = value/quantites_metric
label var prix_pondere_annuel "Prix moyen d'une mrchd pour une année, march, dir, expimp, u_conv"
sort simplification_classification year

*drop value_unit_pondere

* Encode panvar (sinon prend trop de temps) 
gen panvar = simplification_classification + export_import + customs_region + u_conv
encode panvar, gen(panvar_num)
drop if year>1787 & year<1788
tsset panvar_num year

* On sauvegarde la base de donnée désormais réduite (A REMPLACER SI ON PREND FINALEMENT LES MARCHANDISES DONT VALEUR > 100 000)
 
if "`c(username)'"=="maellestricot" save   "/Users/maellestricot/Documents/STATA MAC/bdd courante reduite2.dta", replace
if "`c(username)'"=="guillaumedaudin" save "~/Documents/Recherche/TOFLIT18/Indices de prix - travail Maëlle Stricot/bdd courante reduite2.dta", replace


