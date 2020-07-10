
global dir "C:\Users\federico.donofrio\Documents\TOFLIT desktop\"
clear
cd "$dir"
capture log using "`c(current_time)' `c(current_date)'"
use "Données Stata/bdd courante.dta", clear

*** dummy importexport
gen importexport=0
replace importexport=1 if (exportsimports=="Export" | exportsimports=="Exports"| exportsimports=="Sortie")



*** deal with missing values and generate value_inclusive
generate value_inclusive=value
replace value_inclusive=prix_unitaire*quantit if value_inclusive==. & prix_unitaire!=.
drop if value_inclusive==.
drop if value_inclusive==0





*** isolate grains
drop if product_grains=="Pas grain (0)"

encode product_grains, generate(grains_num) 
*

drop if product_grains=="."
drop if grains_num==.
drop if sourcetype=="1792-first semester"
*FOR SOME REASONS THIS DOES NOT WORK
*drop if  year==1787.2
drop if year>1787 & year<1788

*drop if yearstr=="10 mars-31 décembre 1787" 
*GUILLAUME WHY?
*drop colonies
drop if sourcetype=="Local"  & year==1787
drop if sourcetype=="Local"  & year==1788
*Unify Resumé and O.G.
**drop Resumé 1788
drop if sourcetype=="Résumé"  & year==1788


*create national and local
gen natlocal=direction
replace natlocal="National" if sourcetype=="1792-both semester" | sourcetype=="Résumé" | sourcetype=="Tableau des quantités" | sourcetype=="Objet Général"
drop if natlocal=="[vide]"
*ID LOVE GUILLAUME TO VERIFY THIS: adjust 1749, 1751, 1777, 1789 and double accounting in order to keep only single values from series "Local" and "National toutes directions partenaires manquants"
sort year importexport natlocal value_inclusive grains_num country_grouping sourcetype  
quietly by year importexport natlocal value_inclusive grains_num country_grouping  :  gen dup = cond(_N==1,0,_n)
drop if sourcetype!="Local" & dup!=0 
*create geography

encode natlocal, generate(geography) label(natlocal)

drop if year==.
drop if geography==.
drop if geography!=5
drop geography
***SOURCETYPE

encode sourcetype, generate(sourcetype_encode) label(sourcetype)

***only wheat
keep if grains_num==2
***convert measures
gen unifiedmeasure=quantit 
*a boisseau de bordeaux according to dictionnaire Leopold =2 setiers de Paris, that is approx 120 livres, but if the grain is good then 124.
replace unifiedmeasure=quantit*124 if quantity_unit_orthographic=="boisseau"
*a 1 quartier de blaye corresponds according to brutails to 1.25 boisseaux de Bordeaux, that is about 152 livres (1 boisseau de bordeaux ==122 livres)
replace unifiedmeasure=quantit*152 if quantity_unit_orthographic=="quartiers mesure de blaye"
* Leopold claims 1 last=38 boisseaux de bordeaux
replace unifiedmeasure=quantit*38*124 if quantity_unit_orthographic=="last"
*based on : the universal cambist, the quintal in bordeaux is actually 101 lpdm
replace unifiedmeasure=quantit*101 if quantity_unit_orthographic=="quintal"
***based on universal cambist sack of wheat from holland should be about 127 lpdm, but 120 seems more accurate, i.e. == boisseaux
replace unifiedmeasure=quantit*120 if quantity_unit_orthographic=="sacs" & country_orthographic=="Hollande"
*** theoretically a sack from England should be equal to 4 bushels (James Sheppard, the British corn merchant's and farmer's manual), that is 259 livres de pdm, but this does not make any sense for us.
replace unifiedmeasure=quantit*259 if quantity_unit_orthographic=="sacs" & country_orthographic=="Angleterre"
***not very significant, retrieved from price ratio with boisseau (1 pots at 2,7=0,45 boisseaux at 6 livres t)
replace unifiedmeasure=quantit*55.8 if quantity_unit_orthographic=="pots"
**despite the similarity with the measure "quarter", it seems that quartier is similar to quartier mesure de blaye and therefore 1,25 boisseaux
replace unifiedmeasure=quantit*152 if quantity_unit_orthographic=="quartiers"
replace unifiedmeasure=quantit*240 if quantity_unit_orthographic=="setiers"
*according to Savary: 1 tonneau==20 boisseaux, 2880 livres
replace unifiedmeasure=quantit*2880 if quantity_unit_orthographic=="tonneaux"
** selon le Dictionnaire universel de commerce, banque, manufactures, douanes, 1805, la fanègue pèse autour des 150 livres pdm but it is too little, still better than the usual estimation at 95
replace unifiedmeasure=quantit*150 if quantity_unit_orthographic=="fanègues"

***LOWER LIMIT convert measures without hypothesis that boisseaux==120 livres, which is very low.
gen unifiedmeasure2=quantit
replace unifiedmeasure2=quantit*120 if quantity_unit_orthographic=="boisseau"

replace unifiedmeasure2=quantit*150 if quantity_unit_orthographic=="quartiers mesure de blaye"
* Leopold claims 1 last=38 boisseaux de bordeaux
replace unifiedmeasure2=quantit*38*120 if quantity_unit_orthographic=="last"
*based on : the universal cambist, the quintal in bordeaux is actually 101 lpdm
replace unifiedmeasure2=quantit*100 if quantity_unit_orthographic=="quintal"
***based on universal cambist sack of wheat from holland should be about 127 lpdm, but 120 seems more accurate, i.e. == boisseaux
replace unifiedmeasure2=quantit*120 if quantity_unit_orthographic=="sacs" & country_orthographic=="Hollande"
*** theoretically a sack from England should be equal to 4 bushels (James Sheppard, the British corn merchant's and farmer's manual), that is 259 livres de pdm, but this does not make any sense for us.
replace unifiedmeasure2=quantit*259 if quantity_unit_orthographic=="sacs" & country_orthographic=="Angleterre"
* boisseaux at 120, pots at 0,45 boisseaux
replace unifiedmeasure2=quantit*54 if quantity_unit_orthographic=="pots"
**despite the similarity with the measure "quarter", it seems that quartier is similar to quartier mesure de blaye and therefore 1,25 boisseaux
replace unifiedmeasure2=quantit*152 if quantity_unit_orthographic=="quartiers"
replace unifiedmeasure2=quantit*240 if quantity_unit_orthographic=="setiers"
*according to Savary: 1 tonneau==20 boisseaux, 2880 livres
replace unifiedmeasure2=quantit*2880 if quantity_unit_orthographic=="tonneaux"
** selon le Dictionnaire universel de commerce, banque, manufactures, douanes, 1805, la fanègue pèse autour des 150 livres pdm but it is too little, still better than the usual estimation at 95
replace unifiedmeasure2=quantit*150 if quantity_unit_orthographic=="fanègues"

***collapse by year
collapse (sum) unifiedmeasure unifiedmeasure2, by (year importexport)

***transform into charges Romano
gen q_charges1=unifiedmeasure/240
gen q_charges2=unifiedmeasure2/240

*** tsset
drop unifiedmeasure
drop unifiedmeasure2
reshape wide q_charges1 q_charges2 , i(year) j(importexport)
tsset year
rename q_charges10 import_high
rename q_charges11 export_high
rename q_charges20 import
rename q_charges21 export




* graphs for import and export

twoway (line import year , yaxis(1) ) (line import_high year , yaxis(1) )

twoway (line export year , yaxis(1) ) (line export_high year , yaxis(1) )
