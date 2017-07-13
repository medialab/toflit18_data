
* REPRISE DE LA NOUVELLE BASE

capture program drop Indice_chaine_v2
program  Indice_chaine_v2
args direction X_ou_I year_debut

use "/Users/maellestricot/Documents/STATA MAC/bdd courante reduite2.dta", clear

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

*local direction La Rochelle
*local X_ou_I Imports 
*local year_debut 1760

if "`direction'" !="France" keep if direction=="`direction'" 
keep if exportsimports=="`X_ou_I'"
drop if year<`year_debut'

* keep if direction=="Marseille"
* keep if exportsimports=="Imports"
* drop if year<1760

* Garder les marchandises qui sont présentes chaque année, et supprimer celles qui n'apparaissent pas chaque année
* bys marchandises_simplification direction exportsimports u_conv: egen nbr_annees=count(prix_pondere_annuel) 
* egen nbr_annees_max=max(nbr_annees) 
* bys marchandises_simplification direction exportsimports u_conv : drop if nbr_annees < nbr_annees_max
* sort year marchandises_simplification 

* capture tabulate marchandises_simplification
* local nbr_de_marchandises=r(r)

* Calcul des p0 et q0 en prenant en compte les marchandises présentes d'une année sur l'autre
generate presence_annee=0
gen somme_annee=.
gen p0=.
gen q0=.

foreach lag of num 1(1)80 {

tsset panvar_num year
replace presence_annee=1 if L`lag'.panvar_num==panvar_num
bys year: egen blink=total(presence_annee)
replace somme_annee=blink if somme_annee==. | somme_annee==0
drop blink 
* donne le nb de marchandises présentes d'une année sur l'autre

if somme_annee!=0 by (year)
tsset panvar_num year

	replace p0=L`lag'.prix_pondere_annuel if p0==.
	replace q0=L`lag'.quantite_echangee if q0==.
	
}

* gen p0=.
* gen q0=.

* generate presence_annee1=0
* tsset panvar_num year
* replace presence_annee1=1 if L1.panvar_num==panvar_num
* bys year: egen somme_annee1=total(presence_annee1) 

* if somme_annee1!=0 by (year)
* tsset panvar_num year
	* replace p0=L1.prix_pondere_annuel if p0==.
	* replace q0=L1.quantite_echangee if q0==.

* if somme_annee1==0 by (year)
* gen presence_annee2=0
* tsset panvar_num year
* replace presence_annee2=1 if L2.panvar_num==panvar_num 
* bys year: egen somme_annee2=total(presence_annee2)

* if somme_annee2!=0 by (year)
* tsset panvar_num year
	* replace p0=L2.prix_pondere_annuel if p0==.
	* replace q0=L2.quantite_echangee if q0==.
	
* if somme_annee2==0 by (year)
* gen presence_annee3=0
* tsset panvar_num year
* replace presence_annee3=1 if L3.panvar_num==panvar_num
* bys year: egen somme_annee3=total(presence_annee3)

* if somme_annee3!=0 by (year)
* tsset panvar_num year
	* replace p0=L3.prix_pondere_annuel if p0==.
	* replace q0=L3.quantite_echangee if q0==.



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
 , title("`direction'--`X_ou_I' à partir de `year_debut' (`nbr_de_marchandises')") name(graphindices, replace)

twoway bar somme_annee year, fcolor(gs15) xtitle() ytitle() title(Nombre de produits par année) name(graphmarchandises, replace)
* || bar somme_annee year scale (0.2) ///

graph combine graphindices graphmarchandises, cols(1)

 end
 
 Indice_chaine_v2 "Marseille" Imports 1760
 Indice_chaine_v2 France Imports 1754
