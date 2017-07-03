* NE PAS RELANCER (SAUF EN CAS DE PROBLEME AVEC BDD COURANTE REDUITE)

* Ne pas oublier de mettre la base de donn�es utilis�e 

use "/Users/maellestricot/Documents/STATA MAC/bdd courante.dta", clear

* S�lectionner les variables que l'on veut garder (keep)

keep year direction exportsimports quantit prix_unitaire marchandises_simplification value quantites_metric quantity_unit_ajustees quantity_unit_ortho u_conv q_conv
sort marchandises_simplification year
order marchandises_simplification year prix_unitaire quantit quantity_unit_ajustees u_conv q_conv value direction exportsimports

* On supprime les marchandises qui n'ont pas de prix ou qui apparaissent moins de 1000 fois dans la base /
* ou bien on supprime les marchandises dont la valeur totale �chang�e sur la p�riode est inf�rieure � 100 000

 drop if prix_unitaire==.
 drop if prix_unitaire==0
 drop if marchandises_simplification==""
 
 * encode marchandises_simplification, gen(marchandises_simplification_num)
 * bysort marchandises_simplification_num: drop if _N<=1000 
 * sort marchandises_simplification year
	
* On cr�� une variable "valeur"

gen valeur=0 

if value==. replace valeur=quantit*prix_unitaire

if prix_unitaire==. | quantit==. replace valeur=value

codebook valeur 

* Supprimer les valeur manquantes

drop if valeur==. 
drop if valeur==0

* Calculer la valeur totale �chang�e par marchandise sur la p�riode

by marchandises_simplification direction exportsimports, sort: egen valeur_totale_par_marchandise=total(valeur)		
drop if valeur_totale_par_marchandise<=100000
sort marchandises_simplification year
	
* On convertit les prix dans leur unit� conventionnelle
	
generate prix_unitaire_converti=prix_unitaire/q_conv 
drop if prix_unitaire_converti==.

* Calcul de la moyenne des prix par ann�e en pond�rant en fonction des quantit�s �chang�es

drop if quantites_metric==.
by year direction exportsimports u_conv marchandises_simplification, sort: egen quantit�_�chang�e=total(quantites_metric)
generate prix_unitaire_pond�r�=(quantites_metric/quantit�_�chang�e)*prix_unitaire_converti
by year direction exportsimports u_conv marchandises_simplification, sort: egen prix_pond�r�_annuel=total(prix_unitaire_pond�r�)
sort marchandises_simplification year

* On sauvegarde la base de donn�e d�sormais r�duite (A REMPLACER SI ON PREND FINALEMENT LES MARCHANDISES DONT VALEUR > 100 000)
 
save "/Users/maellestricot/Documents/STATA MAC/bdd courante reduite.dta", replace

******************************************************************************************************************************
* DEBUT

use "/Users/maellestricot/Documents/STATA MAC/bdd courante reduite.dta", clear

* On garde une observation par marchandise, ann�e, direction et exports ou imports

bysort year marchandises_simplification exportsimports direction: keep if _n==1

gen inflation=.
sort marchandises_simplification exportsimports direction year
bys marchandises_simplification exportsimports direction: replace inflation=100*prix_pond�r�_annuel[_n]/prix_pond�r�_annuel[_n-1]

gen IPC=.
bys marchandises_simplification exportsimports direction: replace IPC=100*prix_pond�r�_annuel[_n]/prix_pond�r�_annuel[1]
gen panvar = marchandises_simplification + exportsimports + direction
encode panvar, gen(panvar_num)
drop if year>1787 & year<1788
tsset panvar_num year
replace inflation=100*prix_pond�r�_annuel/L.prix_pond�r�_annuel

* Graphique juste IPC

twoway (line IPC year if direction=="Bordeaux" & marchandises_simplification =="acier" & exportsimports=="Exports")

* Graphique avec inflation

twoway (line IPC year if direction=="Bordeaux" & marchandises_simplification =="acier" & exportsimports=="Exports") (line inflation year if direction=="Bordeaux" & marchandises_simplification =="acier" & exportsimports=="Exports")



* En cas de valeur aberrante, supprimer la ligne posant probl�me, exemple : 

 drop if marchandises_simplification=="acier" & year==1724 & direction=="Bordeaux" & exportsimports=="Imports"



**********************************************************************************************************************************
* CALCUL INDICES

* Calcul des produits prix*quantit� (je ne suis pas certaine des prix et quantit� que je dois prendre) 

gen p0q0=.
bys marchandises_simplification exportsimports direction: replace p0q0=prix_unitaire_pond�r�[1]*quantit�_�chang�e[1] 

gen pnqn=.
bys marchandises_simplification exportsimports direction: replace pnqn=prix_unitaire_pond�r�[_n]*quantit�_�chang�e[_n] 
 
gen p0qn=.
bys marchandises_simplification exportsimports direction: replace p0qn=prix_unitaire_pond�r�[1]*quantit�_�chang�e[_n] 
 
gen pnq0=.
bys marchandises_simplification exportsimports direction: replace pnq0=prix_unitaire_pond�r�[_n]*quantit�_�chang�e[1] 

* Calcul indices de Laspeyres, Paasche et Fisher

gen laspeyres=. 
bys marchandises_simplification exportsimports direction: replace laspeyres=sum(pnq0)/sum(p0q0)

gen paasche=.
bys marchandises_simplification exportsimports direction: replace paasche=sum(pnqn)/sum(p0qn)

gen fisher=.
bys marchandises_simplification exportsimports direction: replace fisher=sqrt(laspeyres*paasche) 

* Ordonner 

tsset panvar_num year

* Comparaisons graphiques, exemple : 

	twoway (line laspeyres year if direction=="La Rochelle" & marchandises_simplification =="sel" & exportsimports=="Exports")
	twoway (line paasche year if direction=="La Rochelle" & marchandises_simplification =="sel" & exportsimports=="Exports")
	twoway (line fisher year if direction=="La Rochelle" & marchandises_simplification =="sel" & exportsimports=="Exports")


* Pour �tudier seulement les indices des exportations ou importations 

keep if exportsimports=="Exports" 
	
	
***********************************************************************************************************************************
* TEST POUR DEUX ANNES SEULEMENT

keep if year==1754 | year==1764
keep if direction=="La Rochelle"
keep if exportsimports=="Imports"

sort year marchandises_simplification 
* trouver une commande pour garder les marchandises qui apparaissent les deux ann�es, et supprimer les marchandises qui ne sont pr�sentes qu'une seule ann�e

gen p0=. 
replace p0=prix_unitaire_pond�r� if year==1754

gen p1=.
replace p1=prix_unitaire_pond�r� if year==1764

gen q0=.
replace q0=quantit�_�chang�e if year==1754

gen q1=.
replace q1=quantit�_�chang�e if year==1764
	
drop year 
	
gen laspeyres=. 
replace laspeyres=sum(p1*q0)/sum(p0*q0)

	
	

***********************************************************************************************************************************
* METHODE PRECEDENTE (A CONSERVER SI PROBLEME) 

use "/Users/maellestricot/Documents/STATA MAC/bdd courante reduite.dta", clear

* Choisir une marchandise
keep if marchandises_simplification=="nom de la marchandise"
sort year 

* Choisir une direction
encode direction, gen(direction_num)
bysort direction_num: drop if _N<=100
codebook direction
keep if direction=="nom de la direction" 

* Choisir exports ou imports
encode exportsimports, gen(exportsimports_num)
bysort exportsimports_num: drop if _N<=50
codebook exportsimports
* Si besoin
keep if exportsimports=="Exports ou Imports"

* Indice de prix 
gen IPC=100*prix_pond�r�_annuel[_n]/prix_pond�r�_annuel[1]
bysort year: keep if _n==1

* Inflation
gen inflation=100*prix_pond�r�_annuel[_n]/prix_pond�r�_annuel[_n-1]

* Graphique représentant l'évolution de l'indice de prix ainsi que l'inflation
twoway (line IPC year) (line inflation year), ytitle(test) xtitle(year)

