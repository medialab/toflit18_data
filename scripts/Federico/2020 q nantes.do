
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



***Regions
generate region="KO"
replace region="NE" if direction=="Amiens" | direction=="Dunkerque"| direction=="Saint-Quentin" | direction=="Châlons" | direction=="Langres" | direction=="Flandre"  
replace region="N" if direction=="Caen" | direction=="Rouen" | direction=="Le Havre"
replace region="NW" if direction=="Rennes" | direction=="Lorient" | direction=="Nantes" | direction=="Saint-Malo"
replace region="SW" if direction=="La Rochelle" | direction=="Bordeaux" | direction=="Bayonne" 
replace region="S" if direction=="Marseille" | direction=="Toulon" | direction=="Narbonne" | direction=="Montpellier"
replace region="SE" if direction=="Grenoble" | direction=="Lyon" 
replace region="E" if direction=="Besancon" | direction=="Bourgogne"| direction=="Charleville"

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
drop if geography!=21
drop geography
***SOURCETYPE

encode sourcetype, generate(sourcetype_encode) label(sourcetype)

***only wheat
keep if grains_num==2
***convert measures
gen unifiedmeasure=quantit
replace unifiedmeasure=quantit*2400 if quantity_unit_orthographic=="tonneaux" 
replace unifiedmeasure=quantit*32.5 if quantity_unit_orthographic=="boisseau"
* The ratio tonneaux/sacs is not stable, but we can deduce from here that it is 117 livres (it does not fit well with our data, but the q is relatively small): https://www.persee.fr/doc/pharm_0035-2349_1972_num_60_212_7117
replace unifiedmeasure=quantit*117 if quantity_unit_orthographic=="sacs"
replace unifiedmeasure=quantit*240 if quantity_unit_orthographic=="setiers"




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
rename q_charges10 import_corrected
rename q_charges11 export_corrected
rename q_charges20 import
rename q_charges21 export

* graph for import

twoway (line unifiedmeasure year if  importexport==0, yaxis(1) ) (line unifiedmeasure2 year if  & importexport==0, yaxis(1) )
