* CREATION D'UNE BASE REDUITE (NE PAS RELANCER (SAUF EN CAS DE PROBLEME AVEC BDD COURANTE REDUITE))

* Ne pas oublier de mettre la base de données utilisée 

use "/Users/maellestricot/Documents/STATA MAC/bdd courante.dta", clear

* Sélectionner les variables que l'on veut garder (keep)

keep year direction exportsimports quantit prix_unitaire marchandises_simplification value quantites_metric quantity_unit_ajustees quantity_unit_ortho u_conv q_conv
sort marchandises_simplification year
order marchandises_simplification year prix_unitaire quantit quantity_unit_ajustees u_conv q_conv value direction exportsimports

* On supprime les marchandises qui n'ont pas de prix ou qui apparaissent moins de 1000 fois dans la base /
* ou bien on supprime les marchandises dont la valeur totale échangée sur la période est inférieure à 100 000

 drop if prix_unitaire==.
 drop if prix_unitaire==0
 drop if marchandises_simplification==""
 
 * encode marchandises_simplification, gen(marchandises_simplification_num)
 * bysort marchandises_simplification_num: drop if _N<=1000 
 * sort marchandises_simplification year
	
* On créé une variable "valeur"

gen valeur=0 

if value==. replace valeur=quantit*prix_unitaire

if prix_unitaire==. | quantit==. replace valeur=value

codebook valeur 

* Supprimer les valeur manquantes

drop if valeur==. 
drop if valeur==0

* Calculer la valeur totale échangée par marchandise sur la période

by marchandises_simplification direction exportsimports, sort: egen valeur_totale_par_marchandise=total(valeur)		
drop if valeur_totale_par_marchandise<=100000
sort marchandises_simplification year
	
* On convertit les prix dans leur unité conventionnelle
	
generate prix_unitaire_converti=prix_unitaire/q_conv 
drop if prix_unitaire_converti==.

* Calcul de la moyenne des prix par année en pondérant en fonction des quantités échangées

drop if quantites_metric==.
by year direction exportsimports u_conv marchandises_simplification, sort: egen quantite_echangee=total(quantites_metric)
generate prix_unitaire_pondere=(quantites_metric/quantite_echangee)*prix_unitaire_converti
by year direction exportsimports u_conv marchandises_simplification, sort: egen prix_pondere_annuel=total(prix_unitaire_pondere)
sort marchandises_simplification year

* On sauvegarde la base de donnée désormais réduite (A REMPLACER SI ON PREND FINALEMENT LES MARCHANDISES DONT VALEUR > 100 000)
 
save "/Users/maellestricot/Documents/STATA MAC/bdd courante reduite.dta", replace




***********************************************************************************************************************************	


* REPRISE DE LA NOUVELLE BASE
use "/Users/maellestricot/Documents/STATA MAC/bdd courante reduite.dta", clear

* On garde une observation par marchandise, année, direction et exports ou imports
bysort year marchandises_simplification exportsimports direction: keep if _n==1

gen inflation=.
sort marchandises_simplification exportsimports direction year
bys marchandises_simplification exportsimports direction: replace inflation=100*prix_pondere_annuel[_n]/prix_pondere_annuel[_n-1]

gen IPC=.
bys marchandises_simplification exportsimports direction: replace IPC=100*prix_pondere_annuel[_n]/prix_pondere_annuel[1]
gen panvar = marchandises_simplification + exportsimports + direction
encode panvar, gen(panvar_num)
drop if year>1787 & year<1788
tsset panvar_num year
replace inflation=100*prix_pondere_annuel/L.prix_pondere_annuel

* NOUVEAU PROGRAMME DE CALCULS D'INDICES (6 marchandises dans l'exemple)

keep if direction=="Marseille"
keep if exportsimports=="Imports"
drop if year<1754

* Garder les marchandises qui sont présentes chaque année, et supprimer celles qui n'apparaissent pas chaque année
bys marchandises_simplification direction exportsimports : egen nbr_annees=count(prix_unitaire_converti) 
egen nbr_annees_max=max(nbr_annees) 
bys marchandises_simplification direction exportsimports : drop if nbr_annees < nbr_annees_max
sort year marchandises_simplification 

tsset panvar_num year

* Générer prix de base et quantité de base
sort marchandises_simplification year 
by marchandises_simplification : gen prix1754=prix_unitaire_converti[1]
by marchandises_simplification : gen quantite1754=quantite_echangee[1]

gen pnq0=.
replace pnq0=prix_unitaire_converti*quantite1754

gen p0qn=.
replace p0qn=prix1754*quantite_echangee

gen p0q0=.
replace p0q0=prix1754*quantite1754

gen pnqn=.
replace pnqn=prix_unitaire_converti*quantite_echangee if year!=1754

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

* CALCUL INDICES POUR DEUX ANNES SEULEMENT

keep if year==1754 | year==1764
keep if direction=="La Rochelle"
keep if exportsimports=="Imports"

* trouver une commande pour garder les marchandises qui apparaissent les deux années, et supprimer les marchandises qui ne sont présentes qu'une seule année
* encode marchandises_simplification, gen(marchandises_simplification_num)
* bysort marchandises_simplification_num: drop if _N<2

bys marchandises_simplification direction exportsimports : egen nbr_annees=count(prix_unitaire_converti) 
egen nbr_annees_max=max(nbr_annees) 
bys marchandises_simplification direction exportsimports : drop if nbr_annees < nbr_annees_max
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
