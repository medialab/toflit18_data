* NE PAS RELANCER (SAUF EN CAS DE PROBLEME AVEC BDD COURANTE REDUITE)

* Ne pas oublier de mettre la base de données utilisée 

use "/Users/maellestricot/Documents/STATA MAC/bdd courante.dta", clear

* Sélectionner les variables que l'on veut garder (keep)

keep year customs_region export_import quantity value_unit simplification_classification value quantites_metric quantity_unit_ajustees quantity_unit_ortho u_conv q_conv
sort simplification_classification year
order simplification_classification year value_unit quantity quantity_unit_ajustees u_conv q_conv value customs_region export_import

* On supprime les product qui n'ont pas de prix ou qui apparaissent moins de 1000 fois dans la base /
* ou bien on supprime les product dont la valeur totale échangée sur la période est inférieure à 100 000

 drop if value_unit==.
 drop if value_unit==0
 drop if simplification_classification==""
 
 * encode simplification_classification, gen(simplification_classification_num)
 * bysort simplification_classification_num: drop if _N<=1000 
 * sort simplification_classification year
	
* On créé une variable "valeur"

gen valeur=0 

if value==. replace valeur=quantit*value_unit

if value_unit==. | quantit==. replace valeur=value

codebook valeur 

* Supprimer les valeur manquantes

drop if valeur==. 
drop if valeur==0

* Calculer la valeur totale échangée par marchandise sur la période

by simplification_classification customs_region export_import, sort: egen valeur_totale_par_marchandise=total(valeur)		
drop if valeur_totale_par_marchandise<=100000
sort simplification_classification year
	
* On convertit les prix dans leur unité conventionnelle
	
generate value_unit_converti=value_unit/q_conv 
drop if value_unit_converti==.

* Calcul de la moyenne des prix par année en pondérant en fonction des quantités échangées

drop if quantites_metric==.
by year customs_region export_import u_conv simplification_classification, sort: egen quantite_echangee=total(quantites_metric)
generate value_unit_pondere=(quantites_metric/quantite_echangee)*value_unit_converti
by year customs_region export_import u_conv simplification_classification, sort: egen prix_pondere_annuel=total(value_unit_pondere)
sort simplification_classification year

* On sauvegarde la base de donnée désormais réduite (A REMPLACER SI ON PREND FINALEMENT LES MARCHANDISES DONT VALEUR > 100 000)
 
save "/Users/maellestricot/Documents/STATA MAC/bdd courante reduite.dta", replace

******************************************************************************************************************************
* DEBUT

use "/Users/maellestricot/Documents/STATA MAC/bdd courante reduite.dta", clear

* On garde une observation par marchandise, année, customs_region et exports ou imports

bysort year simplification_classification export_import customs_region: keep if _n==1

gen inflation=.
sort simplification_classification export_import customs_region year
bys simplification_classification export_import customs_region: replace inflation=100*prix_pondere_annuel[_n]/prix_pondere_annuel[_n-1]

gen IPC=.
bys simplification_classification export_import customs_region: replace IPC=100*prix_pondere_annuel[_n]/prix_pondere_annuel[1]
gen panvar = simplification_classification + export_import + customs_region
encode panvar, gen(panvar_num)
drop if year>1787 & year<1788
tsset panvar_num year
replace inflation=100*prix_pondere_annuel/L.prix_pondere_annuel

* Graphique juste IPC
twoway (line IPC year if customs_region=="Bordeaux" & simplification_classification =="acier" & export_import=="Exports")

* Graphique avec inflation
twoway (line IPC year if customs_region=="Bordeaux" & simplification_classification =="acier" & export_import=="Exports") (line inflation year if customs_region=="Bordeaux" & simplification_classification =="acier" & export_import=="Exports")


* En cas de valeur aberrante, supprimer la ligne posant problème, exemple : 
 drop if simplification_classification=="acier" & year==1724 & customs_region=="Bordeaux" & export_import=="Imports"


***********************************************************************************************************************************

* CALCUL INDICES POUR DEUX ANNES SEULEMENT

keep if year==1754 | year==1764
keep if customs_region=="La Rochelle"
keep if export_import=="Imports"

* trouver une commande pour garder les product qui apparaissent les deux années, et supprimer les product qui ne sont présentes qu'une seule année
* encode simplification_classification, gen(simplification_classification_num)
* bysort simplification_classification_num: drop if _N<2

bys simplification_classification customs_region export_import : egen nbr_annees=count(value_unit_converti) 
egen nbr_annees_max=max(nbr_annees) 
bys simplification_classification customs_region export_import : drop if nbr_annees < nbr_annees_max
sort year simplification_classification 

tsset panvar_num year

gen p1q0=.
replace p1q0=value_unit_converti*L10.quantite_echangee

gen  p0q1=.
replace p0q1=quantite_echangee*L10.value_unit_converti

gen p1q1=.
replace p1q1=value_unit_converti*quantite_echangee if year==1764
* replace p1q1=pq

gen p0q0=.
replace p0q0=L10.value_unit_converti*L10.quantite_echangee
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



***********************************************************************************************************************************	

* CALCUL INDICES 

* REPRISE DU PROGRAMME PRECEDENT
use "/Users/maellestricot/Documents/STATA MAC/bdd courante reduite.dta", clear

* On garde une observation par marchandise, année, customs_region et exports ou imports
bysort year simplification_classification export_import customs_region: keep if _n==1

gen inflation=.
sort simplification_classification export_import customs_region year
bys simplification_classification export_import customs_region: replace inflation=100*prix_pondere_annuel[_n]/prix_pondere_annuel[_n-1]

gen IPC=.
bys simplification_classification export_import customs_region: replace IPC=100*prix_pondere_annuel[_n]/prix_pondere_annuel[1]
gen panvar = simplification_classification + export_import + customs_region
encode panvar, gen(panvar_num)
drop if year>1787 & year<1788
tsset panvar_num year
replace inflation=100*prix_pondere_annuel/L.prix_pondere_annuel

* NOUVEAU PROGRAMME DE CALCULS D'INDICES (6 product dans l'exemple)

keep if customs_region=="Marseille"
keep if export_import=="Imports"
drop if year<1754

bys simplification_classification customs_region export_import : egen nbr_annees=count(value_unit_converti) 
egen nbr_annees_max=max(nbr_annees) 
bys simplification_classification customs_region export_import : drop if nbr_annees < nbr_annees_max
sort year simplification_classification 

tsset panvar_num year

sort simplification_classification year 
by simplification_classification : gen prix1754=value_unit_converti[1]
by simplification_classification : gen quantite1754=quantite_echangee[1]

gen pnq0=.
replace pnq0=value_unit_converti*quantite1754

gen p0qn=.
replace p0qn=prix1754*quantite_echangee

gen p0q0=.
replace p0q0=prix1754*quantite1754

gen pnqn=.
replace pnqn=value_unit_converti*quantite_echangee if year!=1754

sort year simplification_classification 
by year : egen sommepnq0=total(pnq0)

by year : egen sommep0qn=total(p0qn)

by year : egen sommepnqn=total(pnqn)

by year : egen sommep0q0=total(p0q0)


by year : gen laspeyres=sommepnq0/sommep0q0

by year : gen paasche=sommepnqn/sommep0qn

by year : gen fisher=sqrt(laspeyres*paasche) 



















	
***********************************************************************************************************************************	
* CALCUL INDICES (FAUX !!!!)

* Calcul des produits prix*quantité (je ne suis pas certaine des prix et quantité que je dois prendre) 

gen p0q0=.
bys simplification_classification export_import customs_region: replace p0q0=value_unit_pondere[1]*quantite_echangee[1] 

gen pnqn=.
bys simplification_classification export_import customs_region: replace pnqn=value_unit_pondere[_n]*quantite_echangee[_n] 
 
gen p0qn=.
bys simplification_classification export_import customs_region: replace p0qn=value_unit_pondere[1]*quantite_echangee[_n] 
 
gen pnq0=.
bys simplification_classification export_import customs_region: replace pnq0=value_unit_pondere[_n]*quantite_echangee[1] 

* Calcul indices de Laspeyres, Paasche et Fisher

gen laspeyres=. 
bys simplification_classification export_import customs_region: replace laspeyres=sum(pnq0)/sum(p0q0)

gen paasche=.
bys simplification_classification export_import customs_region: replace paasche=sum(pnqn)/sum(p0qn)

gen fisher=.
bys simplification_classification export_import customs_region: replace fisher=sqrt(laspeyres*paasche) 

* Ordonner 

tsset panvar_num year

* Comparaisons graphiques, exemple : 

	twoway (line laspeyres year if customs_region=="La Rochelle" & simplification_classification =="sel" & export_import=="Exports")
	twoway (line paasche year if customs_region=="La Rochelle" & simplification_classification =="sel" & export_import=="Exports")
	twoway (line fisher year if customs_region=="La Rochelle" & simplification_classification =="sel" & export_import=="Exports")


* Pour étudier seulement les indices des exportations ou importations 
keep if export_import=="Exports" 
	


***********************************************************************************************************************************
* METHODE PRECEDENTE (A CONSERVER SI PROBLEME) 

use "/Users/maellestricot/Documents/STATA MAC/bdd courante reduite.dta", clear

* Choisir une marchandise
keep if simplification_classification=="nom de la marchandise"
sort year 

* Choisir une customs_region
encode customs_region, gen(customs_region_num)
bysort customs_region_num: drop if _N<=100
codebook customs_region
keep if customs_region=="nom de la customs_region" 

* Choisir exports ou imports
encode export_import, gen(export_import_num)
bysort export_import_num: drop if _N<=50
codebook export_import
* Si besoin
keep if export_import=="Exports ou Imports"

* Indice de prix 
gen IPC=100*prix_pondere_annuel[_n]/prix_pondere_annuel[1]
bysort year: keep if _n==1

* Inflation
gen inflation=100*prix_pondere_annuel[_n]/prix_pondere_annuel[_n-1]

* Graphique repr√©sentant l'√©volution de l'indice de prix ainsi que l'inflation
twoway (line IPC year) (line inflation year), ytitle(test) xtitle(year)

