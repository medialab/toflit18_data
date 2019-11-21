* CREATION D'UNE BASE REDUITE (NE PAS RELANCER (SAUF EN CAS DE PROBLEME AVEC BDD COURANTE REDUITE))

* Ne pas oublier de mettre la base de données utilisée 
* Dans cette base, on considère que les produits de même dénomination sont les mêmes quelques soient leurs provenance / origine
use "C:\Users\gdonnat\Documents\TOFLIT18\bdd_courante.dta", clear 

*if "`c(username)'"=="guillaumedaudin" ///
*        use "~/Documents/Recherche/Commerce International Français XVIIIe.xls/Balance du commerce/Retranscriptions_Commerce_France/Données Stata/bdd courante.dta", clear

* Sélectionner les variables que l'on veut garder (keep)

keep year direction exportsimports quantit prix_unitaire product_simplification value quantities_metric quantity_unit_ajustees quantity_unit_ortho u_conv q_conv
sort product_simplification year
order product_simplification year prix_unitaire quantit quantity_unit_ajustees u_conv q_conv value direction exportsimports
label var quantities_metric "Quantités en kg (q_conv)" 

* On supprime les marchandises qui n'ont pas de prix 


 drop if prix_unitaire==.
 drop if prix_unitaire==0
 drop if product_simplification=="" | product_simplification=="???"
 drop if value==.
 
 
 * Essai : ou qui apparaissent moins de 1000 fois dans la base /
 * ou bien on supprime les marchandises dont la valeur totale échangée sur la période est inférieure à 100 000
 * encode product_simplification, gen(product_simplification_num)
 * bysort product_simplification_num: drop if _N<=1000 
 * sort product_simplification year
	

* Calculer la valeur totale échangée par marchandise sur la période

by product_simplification direction exportsimports u_conv, sort: egen valeur_totale_par_marchandise=total(value)	
label var valeur_totale_par_marchandise "Somme variable valeur par march_simpli, dir, expimp, u_conv" 	
drop if valeur_totale_par_marchandise<=100000
sort product_simplification year
	

* On convertit les prix dans leur unité conventionnelle
	
generate prix_unitaire_converti=prix_unitaire/q_conv 
drop if prix_unitaire_converti==.
label var prix_unitaire_converti "Prix unitaire par marchandise en unité métrique p_conv" 

* Calcul de la moyenne des prix par année en pondérant en fonction des quantités échangées pour un produit.unitée métrique

*drop if quantities_metric==.
*by year direction exportsimports u_conv product_simplification, sort: egen quantite_echangee=total(quantities_metric)
*label var quantite_echangee "Quantités métric par dir expimp u_conv march_simpli"

*generate prix_unitaire_pondere=(quantites_metric/quantite_echangee)*prix_unitaire_converti
*label var prix_unitaire_pondere "Prix de chaque observation en u métrique en % de la quantit échangée totale" 


*collapse (sum) value quantities_metric,by(year direction exportsimports u_conv product_simplification)

* by year direction exportsimports u_conv product_simplification, sort: egen prix_pondere_annuel=total(prix_unitaire_pondere)


gen prix_pondere_annuel = value/quantities_metric
label var prix_pondere_annuel "Prix moyen d'une mrchd pour une année, march, dir, expimp, u_conv"
sort product_simplification year

*drop prix_unitaire_pondere

* Encode panvar (sinon prend trop de temps) 
gen panvar = product_simplification + exportsimports + direction + u_conv
encode panvar, gen(panvar_num)
drop if year>1787 & year<1788
*tsset panvar_num year

* On sauvegarde la base de donnée désormais réduite (A REMPLACER SI ON PREND FINALEMENT LES MARCHANDISES DONT VALEUR > 100 000)
 
*if "`c(username)'"=="maellestricot" save   "/Users/maellestricot/Documents/STATA MAC/bdd courante reduite2.dta", replace
*if "`c(username)'"=="guillaumedaudin" save "~/Documents/Recherche/TOFLIT18/Indices de prix - travail Maëlle Stricot/bdd courante reduite2.dta", replace



save "C:\Users\gdonnat\Documents\TOFLIT18\bdd_courante_reduite2.dta", replace 