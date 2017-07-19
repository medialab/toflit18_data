


***********************************************************************************************************************************

* CALCUL INDICES CHAINES


* REPRISE DE LA NOUVELLE BASE

capture program drop Indice_chaine_v1
program  Indice_chaine_v1 
args direction X_ou_I year_debut year_fin


if "`c(username)'"=="maellestricot"  use "/Users/maellestricot/Documents/STATA MAC/bdd courante reduite2.dta", clear
if "`c(username)'"=="guillaumedaudin" use "~/Documents/Recherche/TOFLIT18/Indices de prix - travail Maëlle Stricot/bdd courante reduite2.dta", clear


if "`direction'" !="France" keep if direction=="`direction'" 
keep if exportsimports=="`X_ou_I'"
drop if year<`year_debut'
drop if year>`year_fin'

* CADUC On garde une observation par marchandise, année, direction et exports ou imports
*bysort year marchandises_simplification exportsimports direction u_conv: keep if _n==1
*sort year marchandises_simplification


*On calcul des indices de prix / inflation par marchandise

gen IPC=.
bys panvar_num: replace IPC=100*prix_pondere_annuel[_n]/prix_pondere_annuel[1]
gen inflation=.
replace inflation=100*prix_pondere_annuel/L.prix_pondere_annuel
sort marchandises_simplification year

* NOUVEAU PROGRAMME DE CALCULS D'INDICES (6 marchandises dans l'exemple)

*local direction La Rochelle
*local X_ou_I Imports 
*local year_debut 1760


* Garder les marchandises qui sont présentes chaque année, et supprimer celles qui n'apparaissent pas chaque année
bys panvar_num : egen nbr_annees=count(prix_pondere_annuel) 
egen nbr_annees_max=max(nbr_annees) 
bys panvan_num : drop if nbr_annees < nbr_annees_max
sort year panvar_num 

capture tabulate panvar_num
local panvar_num=r(r)

gen p0=.
gen q0=.


**Je pense que dans tout cela, il faut utiliser quantité métrique plutôt que quantité échangée
* Sinon l'unité du prix n'est pas la même que l'unité de la quantité !!

foreach lag of num 1(1)100 {

	replace p0=L`lag'.prix_pondere_annuel if p0==.
	replace q0=L`lag'.quantites_metric if q0==.
	
}

*sort marchandises_simplification year

gen pnq0=.
replace pnq0=prix_pondere_annuel*q0

gen p0qn=.
replace p0qn=p0*quantites_metric

gen p0q0=.
replace p0q0=p0*q0

gen pnqn=.
replace pnqn=value


* Calcul sommes
sort year marchandises_simplification 
by year : egen sommepnq0=total(pnq0)

by year : egen sommep0qn=total(p0qn)

by year : egen sommepnqn=total(pnqn)

by year : egen sommep0q0=total(p0q0)

* Calcul indices de prix 
by year : gen laspeyresP=sommepnq0/sommep0q0

by year : gen paascheP=sommepnqn/sommep0qn

by year : gen fisherP=sqrt(laspeyresP*paascheP) 

* Calcul indices de volume
by year : gen laspeyresQ=sommep0qn/sommep0q0

by year : gen paascheQ=sommepnqn/sommepnq0

by year : gen fisherQ=sqrt(laspeyresQ*paascheQ) 

* Calcul indice de valeur
by year : gen valeur=sommepnqn/sommep0q0


* On garde une ligne par année pour avoir un indice par année et faire les indices chaînés
bys year: keep if _n==1
sort year marchandises_simplification

* replace laspeyresP=1 if year==1760
* replace paascheP=1 if year==1760
* replace fisherP=1 if year==1760

* replace laspeyresQ=1 if year==1760
* replace paascheQ=1 if year==1760
* replace fisherQ=1 if year==1760

* Calcul indices chaînés de prix 

gen loglaspeyresP=log(laspeyresP) 
sort year 
gen sum_loglaspeyresP=sum(loglaspeyresP) 
gen indice_laspeyresP_chaine=exp(sum_loglaspeyresP) 

gen logpaascheP=log(paascheP) 
sort year 
gen sum_logpaascheP=sum(logpaascheP) 
gen indice_paascheP_chaine=exp(sum_logpaascheP) 

gen logfisherP=log(fisherP) 
sort year 
gen sum_logfisherP=sum(logfisherP) 
gen indice_fisherP_chaine=exp(sum_logfisherP) 

drop loglaspeyresP
drop logpaascheP
drop logfisherP

drop sum_loglaspeyresP
drop sum_logpaascheP
drop sum_logfisherP

* Calcul indices chaînés de volume 

gen loglaspeyresQ=log(laspeyresQ) 
sort year 
gen sum_loglaspeyresQ=sum(loglaspeyresQ) 
gen indice_laspeyresQ_chaine=exp(sum_loglaspeyresQ) 

gen logpaascheQ=log(paascheQ) 
sort year 
gen sum_logpaascheQ=sum(logpaascheQ) 
gen indice_paascheQ_chaine=exp(sum_logpaascheQ) 

gen logfisherQ=log(fisherQ) 
sort year 
gen sum_logfisherQ=sum(logfisherQ) 
gen indice_fisherQ_chaine=exp(sum_logfisherQ) 

drop loglaspeyresQ
drop logpaascheQ
drop logfisherQ

drop sum_loglaspeyresQ
drop sum_logpaascheQ
drop sum_logfisherQ

* Calcul indice chaine de valeur
gen logvaleur=log(valeur)
sort year
gen sum_logvaleur=sum(logvaleur)
gen indice_valeur_chaine=exp(sum_logvaleur) 

drop logvaleur
drop sum_logvaleur

* Graphique

twoway connected indice_fisherP_chaine year, lpattern(l) xtitle() ytitle() yaxis(2) ///
 || connected indice_fisherQ_chaine year, lpattern(_) ///
 || connected indice_valeur_chaine year, lpattern(_) ///
 , title("`direction'--`X_ou_I' sur la période `year_debut'-`year_fin' (`nbr_de_marchandises')")	
 
 end
 
 Indice_chaine_v1 "La Rochelle" Imports 1716 1780
 Indice_chaine_v1 France Imports 1754


*****************************************************************************************

* CALCUL PART MARCHANDISES DANS LE COMMERCE

use "/Users/maellestricot/Documents/STATA MAC/bdd courante reduite2.dta", clear

* On garde une observation par marchandise, année, direction et exports ou imports
bysort year marchandises_simplification exportsimports direction u_conv: keep if _n==1
sort year marchandises_simplification

keep if direction=="Marseille"

* Calculer la valeur annuelle totale échangée par année par marchandise (déjà fait dans la base) 
* sort year marchandises_simplification
* by year marchandises_simplification exportsimports, sort: egen valeur_totale_par_marchandise=total(value)

* Calculer la valeur annuelle totale échangée pour toutes les marchandises

by year exportsimports, sort: egen valeur_annuelle_totale=total(value)

* Calculer le ratio 

bys year marchandises_simplification:gen part_marchandise_dans_commerce=valeur_totale_par_marchandise/valeur_annuelle_totale

encode marchandises_simplification, gen(marchandises_simplification_num) 






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
keep if exportsimports=="Imports"
drop if year<1730

* Garder les marchandises qui sont présentes chaque année, et supprimer celles qui n'apparaissent pas chaque année
bys marchandises_simplification direction exportsimports u_conv: egen nbr_annees=count(prix_pondere_annuel) 
egen nbr_annees_max=max(nbr_annees) 
bys marchandises_simplification direction exportsimports u_conv : drop if nbr_annees < nbr_annees_max
sort year marchandises_simplification 

tsset panvar_num year

* Générer prix de base et quantité de base
sort marchandises_simplification year 
by marchandises_simplification : gen prix1754=prix_pondere_annuel[1]
by marchandises_simplification : gen quantite1754=quantitities_metric[1]

gen pnq0=.
replace pnq0=prix_pondere_annuel*quantite1754

gen p0qn=.
replace p0qn=prix1754*quantitities_metric

gen p0q0=.
replace p0q0=prix1754*quantite1754

gen pnqn=.
replace pnqn=prix_pondere_annuel*quantitities_metric if year!=1754

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

* REPRISE DE LA NOUVELLE BASE
use "/Users/maellestricot/Documents/STATA MAC/bdd courante reduite.dta", clear

keep if year==1754 | year==1774
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

sort year marchandises_simplification

gen p1q0=.
replace p1q0=prix_unitaire_converti*L10.quantitities_metric

gen  p0q1=.
replace p0q1=quantitities_metric*L10.prix_unitaire_converti

gen p1q1=.
replace p1q1=prix_unitaire_converti*quantitities_metric if year==1764
* replace p1q1=pq

gen p0q0=.
replace p0q0=L10.prix_unitaire_converti*L10.quantitities_metric
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




