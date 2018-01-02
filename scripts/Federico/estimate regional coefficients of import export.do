***version 14



global dir "C:\Users\federico.donofrio\Documents\TOFLIT desktop\"
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

encode direction, generate(geography) label(direction)

***Regions
generate region="KO"
replace region="NE" if direction=="Amiens" | direction=="Dunkerque"| direction=="Saint-Quentin" | direction=="Châlons" | direction=="Langres" | direction=="Flandre"  
replace region="N" if direction=="Caen" | direction=="Rouen" | direction=="Le Havre"
replace region="NW" if direction=="Rennes" | direction=="Lorient" | direction=="Nantes" | direction=="Saint-Malo"
replace region="SW" if direction=="La Rochelle" | direction=="Bordeaux" | direction=="Bayonne" 
replace region="S" if direction=="Marseilles" | direction=="Toulon" | direction=="Narbonne" | direction=="Montpellier"
replace region="SE" if direction=="Grenoble" | direction=="Lyon" 
replace region="E" if direction=="Besancon" | direction=="Bourgogne"| direction=="Charleville"

*** isolate grains
**destring somehow

encode grains, generate(grains_num) 
keep if (grains!="Pas grain (0)")

***SOURCETYPE
encode sourcetype, generate(sourcetype_encode) label(sourcetype)

*** corrections
*replace year=1741 if year==3
*replace year=1787 if year==. & sourcetype_encode==6
*replace year=1743 if year==. & sourcetype_encode==5
* geography 19= Marseille, local = 5
replace geography=19 if geography==. & sourcetype_encode==5 & year==1765
*replace geography=52 if geography==.
drop if sourcetype=="Colonies"
drop if sourcetype_encode==7 | year==1805.75 | year==1792.2




*
***collapse by year TO OBTAIN IMPORT+EXPORT
collapse (sum) value_inclusive, by (year geography sourcetype_encode)

***drop subyear 1792
drop if sourcetype_encode==2 | sourcetype_encode==4
***drop objet générale 1787, 1789
*drop if sourcetype_encode==7  & year==1787
*drop if sourcetype_encode==7  & year==1788


***generate ln value
generate ln_value_inclusive=ln(value_inclusive)



*** now regress
 xi:  regress ln_value_inclusive i.year i.geography i.sourcetype [iweight=value_inclusive]

*** now rectangularize (filling missing explanatory variables (year, geography))
fillin geography year sourcetype_encode

*** predict and scatter national value of imports
*** it is very important to fill the missing values
xi i.year i.geography i.sourcetype_encode
predict ln_value_predict
generate value_predict=exp(ln_value_predict)




save "national_FE_value.dta", replace



xtset geography year
tsfill



save "national_FE_value.dta", replace


