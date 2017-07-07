* CREATION D'UNE BASE REDUITE (NE PAS RELANCER (SAUF EN CAS DE PROBLEME AVEC BDD COURANTE REDUITE))

* Ne pas oublier de mettre la base de données utilisée 

use "/Users/maellestricot/Documents/STATA MAC/bdd courante.dta", clear

* Sélectionner les variables que l'on veut garder (keep)

keep year direction exportsimports quantit prix_unitaire marchandises_simplification value quantites_metric quantity_unit_ajustees quantity_unit_ortho u_conv q_conv
sort marchandises_simplification year
order marchandises_simplification year prix_unitaire quantit quantity_unit_ajustees u_conv q_conv value direction exportsimports
label var quantites_metric "Quantités en kg (q_conv)" 

* On supprime les marchandises qui n'ont pas de prix ou qui apparaissent moins de 1000 fois dans la base /
* ou bien on supprime les marchandises dont la valeur totale échangée sur la période est inférieure à 100 000

 drop if prix_unitaire==.
 drop if prix_unitaire==0
 drop if marchandises_simplification=="" | marchandises_simplification=="???"
 drop if value==.
 
 * encode marchandises_simplification, gen(marchandises_simplification_num)
 * bysort marchandises_simplification_num: drop if _N<=1000 
 * sort marchandises_simplification year
	

* Calculer la valeur totale échangée par marchandise sur la période

by marchandises_simplification direction exportsimports, sort: egen valeur_totale_par_marchandise=total(value)	
label var valeur_totale_par_marchandise "Somme variable valeur par march_simpli, dir, expimp" 	
*drop if valeur_totale_par_marchandise<=100000
sort marchandises_simplification year
	
* On convertit les prix dans leur unité conventionnelle
	
generate prix_unitaire_converti=prix_unitaire/q_conv 
drop if prix_unitaire_converti==.
label var prix_unitaire_converti "Prix unitaire par marchandise en unité métrique p_conv" 

* Calcul de la moyenne des prix par année en pondérant en fonction des quantités échangées pour un produit.unitée métrique

drop if quantites_metric==.
by year direction exportsimports u_conv marchandises_simplification, sort: egen quantite_echangee=total(quantites_metric)
label var quantite_echangee "Quantités métric par dir expimp u_conv march_simpli"

generate prix_unitaire_pondere=(quantites_metric/quantite_echangee)*prix_unitaire_converti
label var prix_unitaire_pondere "Prix de chaque observation en u métrique en % de la quantit échangée totale" 

by year direction exportsimports u_conv marchandises_simplification, sort: egen prix_pondere_annuel=total(prix_unitaire_pondere)
label var prix_pondere_annuel "Prix moyen d'une mrchd pour une année, march, dir, expimp, u_conv"
sort marchandises_simplification year

drop prix_unitaire_pondere

* Encode panvar (sinon prend trop de temps) 
gen panvar = marchandises_simplification + exportsimports + direction + u_conv
encode panvar, gen(panvar_num)
drop if year>1787 & year<1788

* On sauvegarde la base de donnée désormais réduite (A REMPLACER SI ON PREND FINALEMENT LES MARCHANDISES DONT VALEUR > 100 000)
 
save "/Users/maellestricot/Documents/STATA MAC/bdd courante reduite.dta", replace




***********************************************************************************************************************************

* CALCUL INDICES CHAINES


* REPRISE DE LA NOUVELLE BASE
use "/Users/maellestricot/Documents/STATA MAC/bdd courante reduite.dta", clear

* On garde une observation par marchandise, année, direction et exports ou imports
bysort year marchandises_simplification exportsimports direction u_conv: keep if _n==1
sort year marchandises_simplification

gen IPC=.
bys marchandises_simplification exportsimports direction u_conv: replace IPC=100*prix_pondere_annuel[_n]/prix_pondere_annuel[1]
tsset panvar_num year
gen inflation=.
replace inflation=100*prix_pondere_annuel/L.prix_pondere_annuel
sort marchandises_simplification year

* NOUVEAU PROGRAMME DE CALCULS D'INDICES (6 marchandises dans l'exemple)

keep if direction=="Marseille"
keep if exportsimports=="Imports"
drop if year<1754

* Garder les marchandises qui sont présentes chaque année, et supprimer celles qui n'apparaissent pas chaque année
bys marchandises_simplification direction exportsimports u_conv: egen nbr_annees=count(prix_pondere_annuel) 
egen nbr_annees_max=max(nbr_annees) 
bys marchandises_simplification direction exportsimports u_conv : drop if nbr_annees < nbr_annees_max
sort year marchandises_simplification 

tsset panvar_num year

gen p0=.
gen q0=.

foreach lag of num 1(1)100 {

	replace p0=L`lag'.prix_pondere_annuel if p0==.
	replace q0=L`lag'.quantite_echangee if q0==.
	
}

*sort marchandises_simplification year


gen pnq0=.
replace pnq0=prix_pondere_annuel*q0

gen p0qn=.
replace p0qn=p0*quantite_echangee

gen p0q0=.
replace p0q0=p0*q0

gen pnqn=.
replace pnqn=prix_pondere_annuel*quantite_echangee


* Calcul sommes
sort year marchandises_simplification 
by year : egen sommepnq0=total(pnq0)

by year : egen sommep0qn=total(p0qn)

by year : egen sommepnqn=total(pnqn)

by year : egen sommep0q0=total(p0q0)

* Calcul indices 
by year : gen laspeyres=sommepnq0/sommep0q0

by year : gen paasche=sommepnqn/sommep0qn

by year : gen fisher=sqrt(laspeyres*paasche) 

* On garde une ligne par année pour avoir un indice par année et faire les indices chaînés
bys year: keep if _n==1
sort year marchandises_simplification

replace laspeyres=1 if year==1754
replace paasche=1 if year==1754
replace fisher=1 if year==1754

* Calcul indices chaînés 

gen loglaspeyres=log(laspeyres) 
sort year 
gen sum_loglaspeyres=sum(loglaspeyres) 
gen indice_laspeyres_chaine=exp(sum_loglaspeyres) 

gen logpaasche=log(paasche) 
sort year 
gen sum_logpaasche=sum(logpaasche) 
gen indice_paasche_chaine=exp(sum_logpaasche) 

gen logfisher=log(fisher) 
sort year 
gen sum_logfisher=sum(logfisher) 
gen indice_fisher_chaine=exp(sum_logfisher) 

drop loglaspeyres
drop logpaasche
drop logfisher

drop sum_loglaspeyres
drop sum_logpaasche
drop sum_logfisher


twoway connected indice_laspeyres_chaine year, lpattern(l) xtitle() ytitle() ///
 || connected indice_paasche_chaine year, lpattern(_) ///
 || connected indice_fisher_chaine year, lpattern(_)


***********************************************************************************************************************************


* CALCUL INDICES PAR RAPPORT A L'ANNEE 1754

* REPRISE DE LA NOUVELLE BASE
use "/Users/maellestricot/Documents/STATA MAC/bdd courante reduite.dta", clear

* On garde une observation par marchandise, année, direction et exports ou imports
bysort year marchandises_simplification exportsimports direction u_conv: keep if _n==1
sort year marchandises_simplification

gen IPC=.
bys marchandises_simplification exportsimports direction u_conv: replace IPC=100*prix_pondere_annuel[_n]/prix_pondere_annuel[1]
tsset panvar_num year
gen inflation=.
replace inflation=100*prix_pondere_annuel/L.prix_pondere_annuel
sort marchandises_simplification year

* NOUVEAU PROGRAMME DE CALCULS D'INDICES (6 marchandises dans l'exemple)

keep if direction=="Marseille"
keep if exportsimports=="Imports "
drop if year<1754

* Garder les marchandises qui sont présentes chaque année, et supprimer celles qui n'apparaissent pas chaque année
bys marchandises_simplification direction exportsimports u_conv: egen nbr_annees=count(prix_pondere_annuel) 
egen nbr_annees_max=max(nbr_annees) 
bys marchandises_simplification direction exportsimports u_conv : drop if nbr_annees < nbr_annees_max
sort year marchandises_simplification 

tsset panvar_num year

* Générer prix de base et quantité de base
sort marchandises_simplification year 
by marchandises_simplification : gen prix1754=prix_pondere_annuel[1]
by marchandises_simplification : gen quantite1754=quantite_echangee[1]

gen pnq0=.
replace pnq0=prix_pondere_annuel*quantite1754

gen p0qn=.
replace p0qn=prix1754*quantite_echangee

gen p0q0=.
replace p0q0=prix1754*quantite1754

gen pnqn=.
replace pnqn=prix_pondere_annuel*quantite_echangee if year!=1754

* Calcul sommes
sort year marchandises_simplification 
by year : egen sommepnq0=total(pnq0)

by year : egen sommep0qn=total(p0qn)

by year : egen sommepnqn=total(pnqn)

by year : egen sommep0q0=total(p0q0)

* Calcul indices 
by year : gen laspeyres=sommepnq0/sommep0q0

by year : gen paasche=sommepnqn/sommep0qn

by year : gen fisher=sqrt(laspeyres*paasche) 


***********************************************************************************************************************************

* CALCUL INDICES POUR DEUX ANNEES SEULEMENT

keep if year==1754 | year==1764
keep if direction=="La Rochelle"
keep if exportsimports=="Imports"

* trouver une commande pour garder les marchandises qui apparaissent les deux années, et supprimer les marchandises qui ne sont présentes qu'une seule année
* encode marchandises_simplification, gen(marchandises_simplification_num)
* bysort marchandises_simplification_num: drop if _N<2

bys marchandises_simplification direction exportsimports u_conv: egen nbr_annees=count(prix_pondere_annuel) 
egen nbr_annees_max=max(nbr_annees) 
bys marchandises_simplification direction exportsimports u_conv : drop if nbr_annees < nbr_annees_max
sort year marchandises_simplification 

tsset panvar_num year

gen p1q0=.
replace p1q0=prix_unitaire_converti*L10.quantite_echangee

gen  p0q1=.
replace p0q1=quantite_echangee*L10.prix_unitaire_converti

gen p1q1=.
replace p1q1=prix_unitaire_converti*quantite_echangee if year==1764
* replace p1q1=pq

gen p0q0=.
replace p0q0=L10.prix_unitaire_converti*L10.quantite_echangee
* replace p0q0=L10.pq

egen sommep1q0=total(p1q0)

egen sommep0q1=total(p0q1)

egen sommep1q1=total(p1q1)

egen sommep0q0=total(p0q0)

* ou faire
* egen sommep1q1=total(p1q1)
* engen sommep0q0=total(L10.p1q1)

gen laspeyres=.
replace laspeyres=sommep1q0/sommep0q0

gen paasche=.
replace paasche=sommep1q1/sommep0q1

gen fisher=.
replace fisher=sqrt(laspeyres*paasche) 

* Pour conserver l'indice seulement à la ligne de l'année étudiée 

replace laspeyres=1 if year==1754

replace paasche=1 if year==1754

replace fisher=1 if year==1754




