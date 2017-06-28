* Ne pas oublier de mettre la base de données utilisée 

use "/Users/maellestricot/Documents/STATA MAC/bdd courante.dta", clear

* Sélectionner les variables que l'on veut garder (keep)

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
	
* On convertit les prix dans leur unité conventionnelle
	
generate prix_unitaire_converti=prix_unitaire/q_conv 
drop if prix_unitaire_converti==.

	
* Calcul de la moyenne des prix par année en pondérant en fonction des quantités échangées

by year direction exportsimports u_conv marchandises_simplification, sort: egen quantité_échangée=total(quantites_metric)
generate prix_unitaire_pondéré=(quantites_metric/quantité_échangée)*prix_unitaire_converti
by year direction exportsimports u_conv marchandises_simplification, sort: egen prix_pondéré_annuel=total(prix_unitaire_pondéré)

* On sauvegarde la base de donnée désormais réduite
 
save "/Users/maellestricot/Documents/STATA MAC/bdd courante reduite.dta", replace

* On garde une observation par marchandise, année, direction et exports ou imports

bysort year marchandises_simplification exportsimports direction: keep if _n==1

gen inflation=.
sort marchandises_simplification exportsimports direction year
bys marchandises_simplification exportsimports direction: replace inflation=100*prix_pondéré_annuel[_n]/prix_pondéré_annuel[_n-1]

gen IPC=.
bys marchandises_simplification exportsimports direction: replace IPC=100*prix_pondéré_annuel[_n]/prix_pondéré_annuel[1]
gen panvar = marchandises_simplification + exportsimports + direction
encode panvar, gen(panvar_num)
* Il faudrait supprimer les années non pleines (par exemple 1787.2 le remplacer en 1787)
tsset panvar_num year
replace inflation=100*prix_pondéré_annuel/L.prix_pondéré_annuel

* Graphique

twoway (line IPC year if direction=="Bordeaux" & marchandises_simplification =="acier" & exportsimports=="Exports")





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
gen IPC=100*prix_pondéré_annuel[_n]/prix_pondéré_annuel[1]
bysort year: keep if _n==1

* Inflation
gen inflation=100*prix_pondéré_annuel[_n]/prix_pondéré_annuel[_n-1]

* Graphique représentant l'évolution de l'indice de prix ainsi que l'inflation
twoway (line IPC year) (line inflation year), ytitle(test) xtitle(year)

