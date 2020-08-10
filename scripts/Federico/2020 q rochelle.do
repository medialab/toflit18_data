
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
drop if geography!=14
drop geography
***SOURCETYPE

encode sourcetype, generate(sourcetype_encode) label(sourcetype)

***only wheat
keep if grains_num==2
***convert measures 

gen unifiedmeasure=quantit 
*** it's unclear why, but Savary is certainly wrong when he claims 32boisseaux de Rochelle=19setiers de Paris. It seems instead that 36 boisseaux=1 tonneau=9 setier de paris
replace unifiedmeasure=quantit*71 if quantity_unit_orthographic=="boisseau"
replace unifiedmeasure=quantit*100 if quantity_unit_orthographic=="quintaux"
***based on Le négoce d'Amsterdam ou Traité de sa banque, de ses changes, des Compagnies ...by Jacques Le Moine de l'Espine
* sacs are1/36th of a last d'Amsterdam, we deduce therefore that 1 setiers=1,9 sacs and therefore 150 livres pdm
replace unifiedmeasure=quantit*150 if quantity_unit_orthographic=="sacs"
*** theoretically a sack from England should be equal to 4 bushels (James Sheppard, the British corn merchant's and farmer's manual), that is 259 livres de pdm, but this does not make any sense for us. 
*Or to 3 bushels (boisseau?)
replace unifiedmeasure=quantit*250 if quantity_unit_orthographic=="sacs" & country_orthographic=="Angleterre"
***let's assume it works easily
replace unifiedmeasure=quantit*480 if quantity_unit_orthographic=="cartier du pied de 480 livres"
*** retrive it from the price ratio with tonneaux
replace unifiedmeasure=quantit*60 if quantity_unit_orthographic=="barils" & year==1752
replace unifiedmeasure=quantit*192 if quantity_unit_orthographic=="barils" & year==1739

**despite the similarity with the measure "quarter", it seems that quartier is similar to quartier mesure de blaye and therefore 1,25 boisseaux
replace unifiedmeasure=quantit*152 if quantity_unit_orthographic=="quartiers"
replace unifiedmeasure=quantit*240 if quantity_unit_orthographic=="setiers"
*according to Savary: 1 tonneau==19 boisseaux, that is between 2160 livres and 2560. prices seem to justify the higher estimate at least for the later period
replace unifiedmeasure=quantit*2560 if quantity_unit_orthographic=="tonneaux"
*no clear info, retrive from price ratio
replace unifiedmeasure=quantit*285 if quantity_unit_orthographic=="barriques"
*the flacon is probably a mistake for sac, then a value around 1/14 of a tonneau de la Rochelle
replace unifiedmeasure=quantit*182 if quantity_unit_orthographic=="flacons"
replace unifiedmeasure=quantit*150 if quantity_unit_orthographic=="poches"

***LOWER LIMIT convert measures without hypothesis that boisseaux==120 livres, which is very low.
gen unifiedmeasure2=quantit
*** it's unclear why, but Savary is certainly wrong when he claims 32boisseaux de Rochelle=19setiers de Paris. It seems instead that 36 boisseaux=1 tonneau=9 setier de paris
replace unifiedmeasure2=quantit*60 if quantity_unit_orthographic=="boisseau"

* Leopold claims 1 last=38 boisseaux de bordeaux
replace unifiedmeasure2=quantit*38*120 if quantity_unit_orthographic=="last"
***let's assume it works easily
replace unifiedmeasure=quantit*480 if quantity_unit_orthographic=="cartier du pied de 480 livres"
*** retrive it from the price ratio with tonneaux
replace unifiedmeasure2=quantit*50 if quantity_unit_orthographic=="barils" & year==1752
replace unifiedmeasure2=quantit*162 if quantity_unit_orthographic=="barils" & year==1739
replace unifiedmeasure2=quantit*100 if quantity_unit_orthographic=="quintaux"
***based on Le négoce d'Amsterdam ou Traité de sa banque, de ses changes, des Compagnies ...by Jacques Le Moine de l'Espine
* sacs are1/36th of a last d'Amsterdam, we deduce therefore that 1 setiers=1,9 sacs and therefore, if 1:setier=240 livres pdm, 126 livres ==1 sacs
replace unifiedmeasure2=quantit*126 if quantity_unit_orthographic=="sacs" 
*** theoretically a sack from England should be equal to 4 bushels (James Sheppard, the British corn merchant's and farmer's manual), that is 259 livres de pdm, but this does not make any sense for us.
replace unifiedmeasure2=quantit*250 if quantity_unit_orthographic=="sacs" & country_orthographic=="Angleterre"
***let's assume it works easily
replace unifiedmeasure2=quantit*480 if quantity_unit_orthographic=="cartier du pied de 480 livres"
**despite the similarity with the measure "quarter", it seems that quartier is similar to quartier mesure de blaye and therefore 1,25 boisseaux
replace unifiedmeasure2=quantit*152 if quantity_unit_orthographic=="quartiers"
replace unifiedmeasure2=quantit*240 if quantity_unit_orthographic=="setiers"
*according to Savary: 1 tonneau==9 setiers de Paris of 240 livres, then 2160
replace unifiedmeasure2=quantit*2160 if quantity_unit_orthographic=="tonneaux"
*no clear info, retrive from price ratio
replace unifiedmeasure2=quantit*240 if quantity_unit_orthographic=="barriques"
*the flacon is probably a mistake for sac, then a value around 1/14 of a tonneau de la Rochelle
replace unifiedmeasure2=quantit*154 if quantity_unit_orthographic=="flacons"
replace unifiedmeasure2=quantit*150 if quantity_unit_orthographic=="poches"


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

twoway (line import year , yaxis(1) ) (line import_high year , yaxis(1) )(line export year , yaxis(1) ) (line export_high year , yaxis(1) )

twoway (line export year , yaxis(1) ) (line export_high year , yaxis(1) )
