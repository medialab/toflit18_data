* Ne pas oublier de mettre la base de donn�es utilis�e 

use "/Users/maellestricot/Documents/STATA MAC/bdd courante.dta", clear

* S�lectionner les variables que l'on veut garder (keep)

keep year direction exportsimports quantit prix_unitaire marchandises_simplification quantites_metric quantity_unit_ajustees quantity_unit_ortho u_conv q_conv
sort marchandises_simplification year
order marchandises_simplification year prix_unitaire quantit quantity_unit_ajustees u_conv q_conv direction exportsimports

* On supprime les marchandises qui n'ont pas de prix ou qui apparaissent moins de 1000 fois dans la base

 drop if prix_unitaire==.
 drop if prix_unitaire==0
 drop if marchandises_simplification==""
 encode marchandises_simplification, gen(marchandises_simplification_num)
 bysort marchandises_simplification_num: drop if _N<=1000 
 sort marchandises_simplification year
	
* On convertit les prix dans leur unit� conventionnelle
	
generate prix_unitaire_converti=prix_unitaire/q_conv 
drop if prix_unitaire_converti==.

	
* Calcul de la moyenne des prix par ann�e en pond�rant en fonction des quantit�s �chang�es

by year direction exportsimports u_conv marchandises_simplification, sort: egen quantit�_�chang�e=total(quantites_metric)
generate prix_unitaire_pond�r�=(quantites_metric/quantit�_�chang�e)*prix_unitaire_converti
by year direction exportsimports u_conv marchandises_simplification, sort: egen prix_pond�r�_annuel=total(prix_unitaire_pond�r�)

* On sauvegarde la base de donn�e d�sormais r�duite
 
save "/Users/maellestricot/Documents/STATA MAC/bdd courante reduite.dta", replace

* Pour avoir la liste des marchandises dont N > 1000

bysort marchandises_simplification: keep if _n==1
list marchandises_simplifications




***********************************************************************************************************************************
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

* Graphique repr�sentant l'�volution de l'indice de prix ainsi que l'inflation
twoway (line IPC year) (line inflation year), ytitle(test) xtitle(year)

