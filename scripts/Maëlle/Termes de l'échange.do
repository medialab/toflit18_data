* TERMES DE L'ECHANGE

use "/Users/maellestricot/Documents/STATA MAC/bdd courante reduite2.dta", clear

* On garde une observation par marchandise, année, direction et exports ou imports
bysort year marchandises_simplification exportsimports direction u_conv: keep if _n==1
sort year marchandises_simplification


* Calcul des p0 et q0 en prenant en compte les marchandises présentes d'une année sur l'autre
generate presence_annee=0
bys year: egen somme_annee=total(presence_annee) 
gen p0=.
gen q0=.

tsset panvar_num year

foreach lag of num 1(1)70 {

replace presence_annee=1 if L`lag'.panvar_num==panvar_num
* donne le nb de marchandises présentes d'une année sur l'autre
if somme_annee!=0 by (year)

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

* Calcul indices de prix 
by year : gen laspeyresP=sommepnq0/sommep0q0

by year : gen paascheP=sommepnqn/sommep0qn

by year : gen fisherP=sqrt(laspeyresP*paascheP) 



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

save "/Users/maellestricot/Documents/STATA MAC/bdd courante indices.dta", replace 


* Calcul termes de l'échange

use "/Users/maellestricot/Documents/STATA MAC/bdd courante indices.dta", replace 


keep if direction=="La Rochelle"

tsset panvar_num year

gen Pe=.
gen Pi=.

foreach lag of num 1(1)1 {

	replace Pe=L`lag'.indice_fisherP_chaine if exportsimports=="Exports"
	replace Pi=L`lag'.indice_fisherP_chaine if exportsimports=="Imports"
	
}

gen Pe=indice_fisherP_chaine if exportsimports=="Exports"
gen Pi=indice_fisherP_chaine if exportsimports=="Imports"
bys year: gen termes_echange=(Pe/Pi)*100




