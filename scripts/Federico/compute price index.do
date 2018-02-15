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
keep if grains!="Pas grain (0)"
keep if grains!="Substituts (4)"
keep if grains!="Grains transformés (5)"

***SOURCETYPE
encode sourcetype, generate(sourcetype_encode) label(sourcetype)

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
sort year importexport value_inclusive geography grains_num pays_grouping marchandises_simplification
quietly by year importexport value_inclusive geography grains_num pays_grouping marchandises_simplification:  gen dup = cond(_N==1,0,_n)
drop if dup>1 

**merge local and national par directions series (Guillaume please check these lines!!!)
clonevar sourcetype_merged=sourcetype_encode 
replace sourcetype_merged=3 if sourcetype_merged==5
replace sourcetype_merged=3 if sourcetype_merged==6

*combine Resumé and Objet Général
replace sourcetype_merged=8 if sourcetype=="Résumé"
replace sourcetype_merged=8 if sourcetype=="Tableau de marchandises"
replace sourcetype_merged=8 if sourcetype=="Tableau des quantités"

*drop local without direction (mainly colonies for 1789)
drop if  sourcetype_merged!=8 & geography==.
*force Objet général entries with a geography into Objet Général, assuming they are simply late coming data (CHECK THIS WITH GUILLAUME!)
replace geography=0 if sourcetype_merged==8

drop if year==.



***generate panelid var
egen panelid=group(sourcetype_merged grains_num geography importexport quantity_unit_ortho pays  marchandises_simplification), label

***compute average price as yearly weighted average of unit_price_kg for each type of grain and each geography and each etc
bys year panelid: egen num= total(quantit*prix_unitaire*!missing(quantit, prix_unitaire)) 
bys year panelid: egen den= total(quantit*!missing(quantit, prix_unitaire)) 
gen wtpricekg=num/den





