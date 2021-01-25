if "`c(username)'" =="federico.donofrio" {
	*import delimited "C:\Users\federico.donofrio\Documents\TOFLIT desktop\Données Stata\bdd courante.csv", varnames(1) encoding(UTF-8) 
	**GD20200710 Déjà, cela c’est assez suspect. Il faut exploiter le .zip qui est intégré dans le git, plutôt ? Tu peux unzipper depuis stata
	*avec la commande unzipfile
	*save "C:\Users\federico.donofrio\Documents\GitHub\Données Stata\bdd courante.dta", replace
	global dir "C:\Users\federico.donofrio\Documents\GitHub\"
	
}

if "`c(username)'" =="guillaumedaudin" {
	global dir "~/Documents/Recherche/Commerce International Français XVIIIe.xls/Balance du commerce/Retranscriptions_Commerce_France"
}


clear
cd `"$dir"'
capture log using "`c(current_time)' `c(current_date)'"
*À faire pour récupérer les données
unzipfile "toflit18_data_GIT\base/bdd courante.csv.zip", replace
insheet using "toflit18_data_GIT\base/bdd courante.csv", clear
save "Données Stata/bdd courante.dta", replace
*/


use "Données Stata/bdd courante.dta", clear


codebook product_grains


*** dummy importexport
gen importexport=0
replace importexport=1 if (export_import=="Export" | export_import=="Exports"| export_import=="Sortie")



*** deal with missing values and generate value ** Devrait être fait dand la base 
/*
generate value=value
replace value=prix_unitaire*quantit if value==. & prix_unitaire!=.
drop if value==.
drop if value==0
*/



***garder quand on a le commerce national complet ou les flux locaux complets
****Je garde 1789 (pour du local) car il ne manque que le commerce avec les Indes.
keep if best_guess_national_prodxpart==1 | best_guess_region_prodxpart==1 | (year==1789 & source_type=="National toutes directions partenaires manquants")
drop if customs_region =="Colonies Françaises de l'Amérique"




*create national and local
gen natlocal=customs_region

**Pour traiter 1750, qui a à la fois du local et du national. Du coup, on le met 2 fois
save temp.dta, replace
keep if year==1750
replace natlocal="National"
append using temp.dta
erase temp.dta

replace natlocal="National" if best_guess_national_prodxpart==1 & year !=1750
drop if natlocal=="[vide]"



*** isolate grains (Rq : il faut faire le fillin avant !)
drop if product_grains=="Pas grain (0)"
drop if product_grains=="."
encode product_grains, generate(grains_num)label(grains)

*********************************************Fin de la préparation des données
*create geography

encode natlocal, generate(geography) label(natlocal)

drop if year==.
drop if geography==.
drop if geography!=5
drop geography


***only wheat
keep if grains_num==2
***convert measures
gen unifiedmeasure=quantity 
*a boisseau de bordeaux according to dictionnaire Leopold =2 setiers de Paris, that is approx 120 livres, but if the grain is good then 124.
replace unifiedmeasure=quantity*124 if quantity_unit_orthographic=="boisseau"
*a 1 quartier de blaye corresponds according to brutails to 1.25 boisseaux de Bordeaux, that is about 152 livres (1 boisseau de bordeaux ==122 livres)
replace unifiedmeasure=quantity*152 if quantity_unit_orthographic=="quartiers mesure de blaye"
* Leopold claims 1 last=38 boisseaux de bordeaux
replace unifiedmeasure=quantity*38*124 if quantity_unit_orthographic=="last"
*based on : the universal cambist, the quintal in bordeaux is actually 101 lpdm
replace unifiedmeasure=quantity*101 if quantity_unit_orthographic=="quintal"
***based on universal cambist sack of wheat from holland should be about 127 lpdm, but 120 seems more accurate, i.e. == boisseaux
replace unifiedmeasure=quantity*120 if quantity_unit_orthographic=="sacs" & partner_orthographic=="Hollande"
*** theoretically a sack from England should be equal to 4 bushels (James Sheppard, the British corn merchant's and farmer's manual), that is 259 livres de pdm, but this does not make any sense for us.
replace unifiedmeasure=quantity*259 if quantity_unit_orthographic=="sacs" & partner_orthographic=="Angleterre"
***not very significant, retrieved from price ratio with boisseau (1 pots at 2,7=0,45 boisseaux at 6 livres t)
replace unifiedmeasure=quantity*55.8 if quantity_unit_orthographic=="pots"
**despite the similarity with the measure "quarter", it seems that quartier is similar to quartier mesure de blaye and therefore 1,25 boisseaux
replace unifiedmeasure=quantity*152 if quantity_unit_orthographic=="quartiers"
replace unifiedmeasure=quantity*240 if quantity_unit_orthographic=="setiers"
*according to Savary: 1 tonneau==20 boisseaux, 2880 livres
replace unifiedmeasure=quantity*2880 if quantity_unit_orthographic=="tonneaux"
** selon le Dictionnaire universel de commerce, banque, manufactures, douanes, 1805, la fanègue pèse autour des 150 livres pdm but it is too little, still better than the usual estimation at 95
replace unifiedmeasure=quantity*150 if quantity_unit_orthographic=="fanègues"

***LOWER LIMIT convert measures without hypothesis that boisseaux==120 livres, which is very low.
gen unifiedmeasure2=quantity
replace unifiedmeasure2=quantity*120 if quantity_unit_orthographic=="boisseau"

replace unifiedmeasure2=quantity*150 if quantity_unit_orthographic=="quartiers mesure de blaye"
* Leopold claims 1 last=38 boisseaux de bordeaux
replace unifiedmeasure2=quantity*38*120 if quantity_unit_orthographic=="last"
*based on : the universal cambist, the quintal in bordeaux is actually 101 lpdm
replace unifiedmeasure2=quantity*100 if quantity_unit_orthographic=="quintal"
***based on universal cambist sack of wheat from holland should be about 127 lpdm, but 120 seems more accurate, i.e. == boisseaux
replace unifiedmeasure2=quantity*120 if quantity_unit_orthographic=="sacs" & partner_orthographic=="Hollande"
*** theoretically a sack from England should be equal to 4 bushels (James Sheppard, the British corn merchant's and farmer's manual), that is 259 livres de pdm, but this does not make any sense for us.
replace unifiedmeasure2=quantity*259 if quantity_unit_orthographic=="sacs" & partner_orthographic=="Angleterre"
* boisseaux at 120, pots at 0,45 boisseaux
replace unifiedmeasure2=quantity*54 if quantity_unit_orthographic=="pots"
**despite the similarity with the measure "quarter", it seems that quartier is similar to quartier mesure de blaye and therefore 1,25 boisseaux
replace unifiedmeasure2=quantity*152 if quantity_unit_orthographic=="quartiers"
replace unifiedmeasure2=quantity*240 if quantity_unit_orthographic=="setiers"
*according to Savary: 1 tonneau==20 boisseaux, 2880 livres
replace unifiedmeasure2=quantity*2880 if quantity_unit_orthographic=="tonneaux"
** selon le Dictionnaire universel de commerce, banque, manufactures, douanes, 1805, la fanègue pèse autour des 150 livres pdm but it is too little, still better than the usual estimation at 95
replace unifiedmeasure2=quantity*150 if quantity_unit_orthographic=="fanègues"

***collapse by year
collapse (sum) value unifiedmeasure unifiedmeasure2, by (year importexport)


*** tsset

reshape wide value unifiedmeasure unifiedmeasure2 , i(year) j(importexport)
tsset year
rename unifiedmeasure0 qimport
rename unifiedmeasure1 qexport
rename unifiedmeasure20 qimport_corrected
rename unifiedmeasure21 qexport_corrected
rename value0 vimport
rename value1 vexport
foreach x of varlist vimport qimport vexport qexport {
  label variable `x'
}
foreach x of varlist vimport qimport vexport qexport {
  replace `x' = 0 if(`x' == .)
}
tsfill
* graph for import

gen pimport=vimport/qexport
gen pexport=vexport/qexport
