
capture program drop Indice_v3
program  Indice_v3
args direction X_ou_I year_debut


clear all
set maxvar 32000
set matsize 11000

use "/Users/maellestricot/Documents/STATA MAC/bdd courante reduite2.dta", clear

if "`direction'" !="France" keep if direction=="`direction'" 
keep if exportsimports=="`X_ou_I'"
drop if year<`year_debut'

* keep if direction=="La Rochelle"
* tsset panvar_num year 
gen lnPrix=ln(prix_unitaire_converti)
* encode simplification_classification, gen(simplification_classification_num)
generate part_valeur=value/valeur_totale_par_marchandise
bys panvar_num : drop if _N==1
gen part_valeur_integer=round(part_valeur*10000)
regress lnPrix i.year i.panvar_num [fweight=part_valeur_integer]

* Enregistrer les effets fixes temps

su year, meanonly    
local nbr_year=r(max)
quietly levelsof year, local (liste_year) clean
display "`liste_year'"
global liste_year  `liste_year'
display "$liste_year"


* matrice des coefficients estimés

capture matrix X= e(b)
capture matrix V=e(V)

capture generate effet_fixe=.
capture generate ecart_type=.

* Calcul indice de valeur 

by year, sort: egen valeur_totale_annuelle=total(value) 
gen indice_valeur=.
gen v0=valeur_totale_annuelle[1]
replace indice_valeur=valeur_totale_annuelle/v0

* keep year effet_fixe ecart_type 
 bys year : keep if _n==1

local n 1
*list
*matrix list X


foreach i of num $liste_year {
replace effet_fixe= X[1,`n'] in `n'
replace ecart_type=V[`n',`n'] in `n'
local  n=`n'+1
}


* on lui dit d'aller chercher à la valeur du n (c'est pour ca qu'il faut mettre entre guillemets)


* Effet fixe 

gen exp_effet_fixe=exp(effet_fixe)
gen borne_inf=exp(effet_fixe-1.96*ecart_type)
gen borne_sup=exp(effet_fixe+1.96*ecart_type)

twoway line exp_effet_fixe year, yaxis(2) ///
	|| line indice_valeur year, yaxis(1) ///
, title(" Evolution des indices de prix et de valeur à `direction'--`X_ou_I'")

end

 Indice_v3 "Marseille" Exports 1716
 Indice_v3 France Imports 1754
