global dir "C:\Users\federico.donofrio\Documents\TOFLIT desktop\"
cd "$dir"
capture log using "`c(current_time)' `c(current_date)'"

use "Données Stata/bdd courante.dta", clear

*** dummy importexport
gen importexport=0
replace importexport=1 if (export_import=="Export" | export_import=="Exports"| export_import=="Sortie")



*** deal with missing values and generate value_inclusive
generate value_inclusive=value
replace value_inclusive=value_unit*quantity if value_inclusive==. & value_unit!=.
drop if value_inclusive==.
drop if value_inclusive==0

encode tax_department, generate(geography) label(tax_department)

***Regions
generate region="KO"
replace region="NE" if tax_department=="Amiens" | tax_department=="Dunkerque"| tax_department=="Saint-Quentin" | tax_department=="Châlons" | tax_department=="Langres" | tax_department=="Flandre"  
replace region="N" if tax_department=="Caen" | tax_department=="Rouen" | tax_department=="Le Havre"
replace region="NW" if tax_department=="Rennes" | tax_department=="Lorient" | tax_department=="Nantes" | tax_department=="Saint-Malo"
replace region="SW" if tax_department=="La Rochelle" | tax_department=="Bordeaux" | tax_department=="Bayonne" 
replace region="S" if tax_department=="Marseille" | tax_department=="Toulon" | tax_department=="Narbonne" | tax_department=="Montpellier"
replace region="SE" if tax_department=="Grenoble" | tax_department=="Lyon" 
replace region="E" if tax_department=="Besancon" | tax_department=="Bourgogne"| tax_department=="Charleville"

*** isolate grains
**destring somehow

encode grains, generate(grains_num) 




*** corrections
*replace year=1741 if year==3
*replace year=1787 if year==. & source_type_encode==6
*replace year=1743 if year==. & source_type_encode==5
* geography 19= Marseille, local = 5
*replace geography=19 if geography==. & source_type_encode==5 & year==1765
*replace geography=52 if geography==.
drop if grains=="."
drop if grains_num==.
drop if source_type=="1792-first semestre"
drop if  year==1805.75 
drop if yearstr=="10 mars-31 décembre 1787" 
*GUILLAUME WHY?
*drop colonies
drop if source_type=="Local"  & year==1787
drop if source_type=="Local"  & year==1788
*Unify Resumé and O.G.
**drop Resumé 1787, 1789
drop if source_type=="Résumé"  & year==1787
drop if source_type=="Résumé"  & year==1788



*adjust 1749, 1751, 1777, 1789 and double accounting in order to keep only single values from series "Local" and "National toutes tax_departments partenaires manquants"
sort year importexport value_inclusive geography grains_num grouping_classification simplification_classification
quietly by year importexport value_inclusive geography grains_num grouping_classification simplification_classification:  gen dup = cond(_N==1,0,_n)
drop if dup>1 

**exclude incomplete series
clonevar source_type_merged=source_type 
replace source_type_merged="Local" if source_type=="National toutes tax_departments partenaires manquants"

drop if source_type=="National Partenaires Manquants" | source_type=="National Partenaires Manquants"| source_type=="Tableau de product"

*combine Resumé and Objet Général
replace source_type_merged="National" if source_type=="Résumé"
replace source_type_merged="National" if source_type=="Tableau des quantités"
replace source_type_merged="National" if source_type=="Objet Général" & year==1788
replace source_type_merged="National" if source_type=="Tableau Général"


***SOURCETYPE ENCODE
encode source_type_merged, generate(source_type_encode) label(source_type_merged)
bys year source_type_merged importexport: egen totaltrade=total(value_inclusive)




***NATIONAL PARTNAIRES MANQUANTS IS IMPORTANT, IT S ALL WE HAVE FOR the 1780s. 
drop if  source_type_merged!="National" & geography==.

drop if year==.
keep if source_type_merged=="National"

collapse (sum) value_inclusive, by (year source_type importexport)
reshape wide value_inclusive, i(year source_type) j(importexport)
rename value_inclusive0 import
rename value_inclusive1 export
twoway (line import year) (line export year)

 save "C:\Users\federico.donofrio\Documents\TOFLIT desktop\Données Stata\total_trade.dta", replace
 
 

***GRAIN TRADE******************************************************************
use "Données Stata/bdd courante.dta", clear

*** dummy importexport
gen importexport=0
replace importexport=1 if (export_import=="Export" | export_import=="Exports"| export_import=="Sortie")



*** deal with missing values and generate value_inclusive
generate value_inclusive=value
replace value_inclusive=value_unit*quantity if value_inclusive==. & value_unit!=.
drop if value_inclusive==.
drop if value_inclusive==0

encode tax_department, generate(geography) label(tax_department)

***Regions
generate region="KO"
replace region="NE" if tax_department=="Amiens" | tax_department=="Dunkerque"| tax_department=="Saint-Quentin" | tax_department=="Châlons" | tax_department=="Langres" | tax_department=="Flandre"  
replace region="N" if tax_department=="Caen" | tax_department=="Rouen" | tax_department=="Le Havre"
replace region="NW" if tax_department=="Rennes" | tax_department=="Lorient" | tax_department=="Nantes" | tax_department=="Saint-Malo"
replace region="SW" if tax_department=="La Rochelle" | tax_department=="Bordeaux" | tax_department=="Bayonne" 
replace region="S" if tax_department=="Marseille" | tax_department=="Toulon" | tax_department=="Narbonne" | tax_department=="Montpellier"
replace region="SE" if tax_department=="Grenoble" | tax_department=="Lyon" 
replace region="E" if tax_department=="Besancon" | tax_department=="Bourgogne"| tax_department=="Charleville"

*** isolate grains
**destring somehow

encode grains, generate(grains_num) 
 
*** corrections
*replace year=1741 if year==3
*replace year=1787 if year==. & source_type_encode==6
*replace year=1743 if year==. & source_type_encode==5
* geography 19= Marseille, local = 5
*replace geography=19 if geography==. & source_type_encode==5 & year==1765
*replace geography=52 if geography==.
drop if grains=="."
drop if grains_num==.
drop if source_type=="1792-first semestre"
drop if  year==1805.75 
drop if yearstr=="10 mars-31 décembre 1787" 
*GUILLAUME WHY?
*drop colonies
drop if source_type=="Local"  & year==1787
drop if source_type=="Local"  & year==1788
*Unify Resumé and O.G.
**drop Resumé 1787, 1789
drop if source_type=="Résumé"  & year==1787
drop if source_type=="Résumé"  & year==1788



*adjust 1749, 1751, 1777, 1789 and double accounting in order to keep only single values from series "Local" and "National toutes tax_departments partenaires manquants"
sort year importexport value_inclusive geography grains_num grouping_classification simplification_classification
quietly by year importexport value_inclusive geography grains_num grouping_classification simplification_classification:  gen dup = cond(_N==1,0,_n)
drop if dup>1 
clonevar source_type_grains=source_type
replace source_type_grains="National" if source_type=="Résumé"
replace source_type_grains="National" if source_type=="Tableau des quantités"
replace source_type_grains="National" if source_type=="Objet Général"
replace source_type_grains="National" if source_type=="National toutes tax_departments tous partenaires"

drop if grains=="Pas grain (0)"
drop if missing(grains)


*drop local without tax_department and strange things from the 1780s (mainly colonies for 1789)

drop if  source_type_grains!="National" & geography==.
*force Objet général entries with a geography into Objet Général, assuming they are simply late coming data (CHECK THIS WITH GUILLAUME!)
replace geography=0 if source_type_grains=="National"

drop if year==.
keep if source_type_grains=="National"


collapse (sum) value_inclusive, by (year source_type importexport)

reshape wide value_inclusive, i(source_type year) j(importexport)
rename value_inclusive0 import_grains
rename value_inclusive1 export_grains

twoway (line import_grains year) (line export_grains year)

*****GRAINS AS PERCENT OF TOTAL************************************************
merge 1:1 year using "C:\Users\federico.donofrio\Documents\TOFLIT desktop\Données Stata\total_trade.dta"
bysort year : gen percentimport=import_grains/import*100
bysort year : gen percentexport=export_grains/export*100



