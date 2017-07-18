* TERMES DE L'ECHANGE AVEC PROGRAMME 2



* IMPORTS 

capture program drop Termes_echange_v1
program  Termes_echange_v1
args direction X_ou_I

use "/Users/maellestricot/Documents/STATA MAC/bdd courante reduite2.dta", clear

* On garde une observation par marchandise, année, direction et exports ou imports
bysort year marchandises_simplification exportsimports direction u_conv: keep if _n==1
sort year marchandises_simplification

* Choix d'un port 
* keep if direction=="La Rochelle"
* keep if exportsimports=="Imports"
if "`direction'" !="France" keep if direction=="`direction'" 
keep if exportsimports=="`X_ou_I'"

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

* Graphique
twoway (line indice_fisherP_chaine year)

save "/Users/maellestricot/Documents/STATA MAC/bdd Direction Imports.dta", replace 


 end
 
 Termes_echange_v1 "La Rochelle" Imports

*****************************************************************************************************

* EXPORTS 

capture program drop Termes_echange_v2
program  Termes_echange_v2
args direction X_ou_I

use "/Users/maellestricot/Documents/STATA MAC/bdd courante reduite2.dta", clear

* On garde une observation par marchandise, année, direction et exports ou imports
bysort year marchandises_simplification exportsimports direction u_conv: keep if _n==1
sort year marchandises_simplification

* Choix d'un port 
* keep if direction=="La Rochelle"
* keep if exportsimports=="Exports"
if "`direction'" !="France" keep if direction=="`direction'" 
keep if exportsimports=="`X_ou_I'"

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

* Graphique
twoway (line indice_fisherP_chaine year)


save "/Users/maellestricot/Documents/STATA MAC/bdd Direction Exports.dta", replace 


 end
 
 Termes_echange_v2 "La Rochelle" Exports

************************************************************************************************************

* COMBINAISON IMPORTS / EXPORTS 


use "/Users/maellestricot/Documents/STATA MAC/bdd Direction Imports.dta", clear
sort year 
rename indice_fisherP_chaine indice_prix_imports
save "/Users/maellestricot/Documents/STATA MAC/bdd Direction Imports.dta", replace
clear

use "/Users/maellestricot/Documents/STATA MAC/bdd Direction Exports.dta", clear
sort year 
rename indice_fisherP_chaine indice_prix_exports
save "/Users/maellestricot/Documents/STATA MAC/bdd Direction Exports.dta", replace

merge 1:1 year using "/Users/maellestricot/Documents/STATA MAC/bdd Direction Imports.dta"
save "/Users/maellestricot/Documents/STATA MAC/bdd Direction merge.dta", replace 

bys year: gen termes_echange=indice_prix_exports/indice_prix_imports

twoway line termes_echange year, yscale(range (0 2)), title(" Evolution des termes de l'échange à La Rochelle")





