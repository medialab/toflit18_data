
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
drop if geography!=3
drop geography
***SOURCETYPE

encode sourcetype, generate(sourcetype_encode) label(sourcetype)

***only wheat
keep if grains_num==2
***convert measures
gen unifiedmeasure=quantit 
*a conque is steadily equal to 2 mesures
replace unifiedmeasure=quantit*120 if quantity_unit_orthographic=="mesures"
* The ratio or prices conque/livres is not stable, it obscillates around 70:1, but Savary claims there are 60 livres in a conques de Bayonne
replace unifiedmeasure=quantit*60 if quantity_unit_orthographic=="conques"
replace unifiedmeasure=quantit*100 if quantity_unit_orthographic=="quintaux"

***convert measures without hypothesis
gen unifiedmeasure2=quantit
replace unifiedmeasure2=quantit*140 if quantity_unit_orthographic=="mesures"
* The ratio or prices conque/livres is not stable, it obscillates around 70:1, but Savary claims there are 60 livres in a conques de Bayonne
replace unifiedmeasure2=quantit*70 if quantity_unit_orthographic=="conques"
replace unifiedmeasure2=quantit*100 if quantity_unit_orthographic=="quintaux"

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




* graphs for import and export

twoway (line import year , yaxis(1) ) (line import_corrected year , yaxis(1) )

twoway (line export year , yaxis(1) ) (line export_corrected year , yaxis(1) )
