* TERMES DE L'ECHANGE AVEC PROGRAMME 2



* IMPORTS 

capture program drop Termes_echange_v1
program  Termes_echange_v1
args customs_region X_ou_I

use "C:\Users\gdonnat\Documents\TOFLIT18\bdd_courante_reduite.dta", clear

* On garde une observation par marchandise, année, customs_region et exports ou imports
bysort year product_simplification export_import customs_region u_conv: keep if _n==1
sort year product_simplification

* Choix d'un port 
* keep if customs_region=="La Rochelle"
* keep if export_import=="Imports"
if "`customs_region'" !="France" keep if customs_region=="`customs_region'" 
keep if export_import=="`X_ou_I'"

* Calcul des p0 et q0 en prenant en compte les product présentes d'une année sur l'autre
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
* donne le nb de product présentes d'une année sur l'autre

if somme_annee!=0 by (year)
tsset panvar_num year

	replace p0=L`lag'.prix_pondere_annuel if p0==.
	replace q0=L`lag'.quantities_metric if q0==.
	
}

*sort simplification_classification year

gen pnq0=.
replace pnq0=prix_pondere_annuel*q0

gen p0qn=.
replace p0qn=p0*quantities_metric

gen p0q0=.
replace p0q0=p0*q0

gen pnqn=.
replace pnqn=prix_pondere_annuel*quantities_metric


* Calcul sommes
sort year product_simplification 
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
sort year product_simplification

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
* twoway (line indice_fisherP_chaine year)

save "C:\Users\gdonnat\Documents\TOFLIT18\bdd_Direction_Imports.dta", replace 


 end
 
 Termes_echange_v1 "Bayonne" Imports

*****************************************************************************************************

* EXPORTS 

capture program drop Termes_echange_v2
program  Termes_echange_v2
args customs_region X_ou_I

use "C:\Users\gdonnat\Documents\TOFLIT18\bdd_courante_reduite.dta", clear

* On garde une observation par marchandise, année, customs_region et exports ou imports
bysort year product_simplification export_import customs_region u_conv: keep if _n==1
sort year product_simplification

* Choix d'un port 
* keep if customs_region=="La Rochelle"
* keep if export_import=="Exports"
if "`customs_region'" !="France" keep if customs_region=="`customs_region'" 
keep if export_import=="`X_ou_I'"

* Calcul des p0 et q0 en prenant en compte les product présentes d'une année sur l'autre
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
* donne le nb de product présentes d'une année sur l'autre

if somme_annee!=0 by (year)
tsset panvar_num year

	replace p0=L`lag'.prix_pondere_annuel if p0==.
	replace q0=L`lag'.quantities_metric if q0==.
	
}

*sort simplification_classification year

gen pnq0=.
replace pnq0=prix_pondere_annuel*q0

gen p0qn=.
replace p0qn=p0*quantities_metric

gen p0q0=.
replace p0q0=p0*q0

gen pnqn=.
replace pnqn=prix_pondere_annuel*quantities_metric


* Calcul sommes
sort year product_simplification
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
sort year product_simplification

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
* twoway (line indice_fisherP_chaine year)


save "C:\Users\gdonnat\Documents\TOFLIT18\bdd_Direction_Exports.dta", replace 


 end
 
 Termes_echange_v2 "Bayonne" Exports

************************************************************************************************************

* COMBINAISON IMPORTS / EXPORTS 


use "C:\Users\gdonnat\Documents\TOFLIT18\bdd_Direction_Imports.dta", clear
sort year 
rename indice_fisherP_chaine indice_prix_imports
save "C:\Users\gdonnat\Documents\TOFLIT18\bdd_Direction_Imports.dta", replace
clear

use "C:\Users\gdonnat\Documents\TOFLIT18\bdd_Direction_Exports.dta", clear
sort year 
rename indice_fisherP_chaine indice_prix_exports
save "C:\Users\gdonnat\Documents\TOFLIT18\bdd_Direction_Exports.dta", replace

merge 1:1 year using "C:\Users\gdonnat\Documents\TOFLIT18\bdd_Direction_Imports.dta"
save "C:\Users\gdonnat\Documents\TOFLIT18\bdd_Direction_merge.dta", replace 

bys year: gen termes_echange=indice_prix_exports/indice_prix_imports

twoway line termes_echange year, title("Evolution des termes de l'échange à Bayonne (1)")

