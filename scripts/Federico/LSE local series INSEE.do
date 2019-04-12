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
drop if value_inclusive==0

encode direction, generate(geography) label(direction)

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
**destring somehow

encode grains, generate(grains_num) 
drop if grains=="Pas grain (0)"
 
*** corrections
*replace year=1741 if year==3
*replace year=1787 if year==. & sourcetype_encode==6
*replace year=1743 if year==. & sourcetype_encode==5
* geography 19= Marseille, local = 5
*replace geography=19 if geography==. & sourcetype_encode==5 & year==1765
*replace geography=52 if geography==.
drop if grains=="."
drop if grains_num==.
drop if sourcetype=="1792-first semestre"
drop if  year==1805.75 
drop if yearstr=="10 mars-31 décembre 1787" 
*GUILLAUME WHY?
*drop colonies
drop if sourcetype=="Local"  & year==1787
drop if sourcetype=="Local"  & year==1788
*Unify Resumé and O.G.
**drop Resumé 1787, 1789
drop if sourcetype=="Résumé"  & year==1787
drop if sourcetype=="Résumé"  & year==1788



*adjust 1749, 1751, 1777, 1789 and double accounting in order to keep only single values from series "Local" and "National toutes directions partenaires manquants"
sort year importexport value_inclusive geography grains_num pays_grouping pays_simplification
quietly by year importexport value_inclusive geography grains_num pays_grouping pays_simplification:  gen dup = cond(_N==1,0,_n)
*drop if dup>1 

drop if year==.
drop if geography==.
***** examine by series Bayonne, Bordeaux, La Rochelle, Marseille, Nantes, Rennes
keep if sourcetype=="Local"

bys grains year geography importexport : egen eachgrain=total(value_inclusive)
bys year geography importexport : egen totgrain=total(value_inclusive)
sort year geography importexport
collapse (mean) totgrain, by (year geography importexport)

*create TS
reshape wide totgrain, i(geography year) j(importexport) 
rename totgrain0 import
rename totgrain1 export
xtset geography year
tsfill, full

*create variable markets for merge
decode geography , generate(market)
*merge with insee codes
merge n:n market using "Données Stata\insee_codes.dta"
drop if _merge!=3

drop _merge
xtset insee year
tsfill, full

* merge with distances and create port-market couples
merge m:m insee using "Données Stata\distances_localseries.dta"
drop if _merge!=3
drop _merge
xtset newid year
tsfill, full
bysort newid (geography) : replace geography = geography[_n-1] if missing(geography) 
bysort newid (insee) : replace insee = insee[_n-1] if missing(insee) 
bysort newid (inseecon) : replace inseecon = inseecon[_n-1] if missing(inseecon) 
bysort inseecon (nomCon) : replace nomCon = nomCon[_n-1] if nomCon=="" 
bysort insee (nomSup) : replace nomSup = nomSup[_n-1] if nomSup=="" 
bysort newid (popCon) : replace popCon = popCon[_n-1] if missing(popCon) 
bysort newid (popSup) : replace popSup = popSup[_n-1] if missing(popSup)  
bysort newid (transport) : replace transport=transport[_n-1] if missing(transport) 
bysort newid (market) : replace market=market[_n-1] if market==""
bysort year geography (import): replace import=import[_n-1] if missing(import)
bysort year geography (export): replace export=export[_n-1] if missing(export)
**merge with prices using price insee through inseecon
merge m:m inseecon using "Données Stata\french_prices_insee.dta"
drop if _merge!=3
drop _merge

sort year geography inseecon

