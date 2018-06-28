
* On sauvegarde la base de donnée désormais réduite

use "/Users/maellestricot/Documents/STATA MAC/bdd courante.dta", clear

* On créé une variable "valeur"

gen valeur=0 

if value==. replace valeur=quantit*prix_unitaire

if prix_unitaire==. | quantit==. replace valeur=value

codebook valeur 

* Supprimer les valeur manquantes

drop if valeur==. 

* Calculer la valeur annuelle totale échangée par année par marchandise

sort year simplification_classification
by year simplification_classification exportsimports, sort: egen valeur_annuelle_par_marchandise=total(valeur)

* Calculer la valeur annuelle totale échangée pour toutes les marchandises

by year exportsimports, sort: egen valeur_annuelle_totale=total(valeur)

* Calculer le ratio 

gen part_marchandise_dans_commerce=valeur_annuelle_par_marchandise/valeur_annuelle_totale

save "/Users/maellestricot/Documents/STATA MAC/bdd part du commerce.dta", replace

**********************************************************************************************************

use "/Users/maellestricot/Documents/STATA MAC/bdd part du commerce.dta", clear

keep if simplification_classification=="cacao" 

keep if exportsimports=="Imports" 

**********************************************************************************************************

* Composition des parts du commerce pour une année donnée (ne fonctionne pas)

keep if year==1800
if part_marchandise_dans_commerce<0.01 replace simplification_classification="Autres"
by simplification_classification, sort: egen valeur_marchandises_autres=total(valeur)
if simplification_classification=="Autres" replace part_marchandises_dans_commerce=valeur_marchandises_autres/valeur_annuelle_totale







