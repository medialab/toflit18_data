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
*drop if grains=="Pas grain (0)"
 
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
***** compute share of frains on total
keep if sourcetype=="Local"

bys year geography importexport : egen totaltrade=total(value_inclusive)

generate totgrain1=0
replace totgrain1=value_inclusive if grains_num!=5
bys year geography importexport : egen totgrains=total(totgrain1)
bys year geography importexport : gen share=totgrains/totaltrade*100
sort year geography importexport
*isolate prix setiers of froment
keep if grains_num==2
keep if quantity_unit_ortho=="setiers"
collapse (mean) prix_unitaire [w=quantit] , by(year)

global dir "C:\Users\federico.donofrio\Documents\TOFLIT desktop\"
cd "$dir"
capture log using "`c(current_time)' `c(current_date)'"


 

***GRAIN TRADE******************************************************************
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
sort year importexport value_inclusive geography grains_num pays_grouping	 pays_simplification	
quietly by year importexport value_inclusive geography grains_num pays_grouping	 pays_simplification	:  gen dup = cond(_N==1,0,_n)
drop if dup>1 
clonevar sourcetype_grains=sourcetype
replace sourcetype_grains="National" if sourcetype=="Résumé"
replace sourcetype_grains="National" if sourcetype=="Tableau des quantités"
replace sourcetype_grains="National" if sourcetype=="Objet Général"
replace sourcetype_grains="National" if sourcetype=="National toutes directions tous partenaires"
replace sourcetype_grains="National" if sourcetype=="National toutes directions partenaires manquants"
replace sourcetype_grains="National" if sourcetype=="National toutes directions partenaires manquants"
replace sourcetype_grains="National" if sourcetype=="National partenaires manquants"
replace sourcetype_grains="National" if sourcetype=="National partenaires Manquants"



drop if year==.

drop if sourcetype_grains!="Local" & sourcetype_grains!="National"

drop if grains=="Pas grain (0)"
drop if missing(grains)

drop if grains_num!=2

****resonable method
egen panelid=group(pays_grouping	 grains year importexport), label
bys panelid sourcetype_grains: egen totalv=total(value_inclusive)
collapse (mean) totalv, by (panelid sourcetype_grains year importexport)
reshape wide totalv, i(sourcetype_grains year panelid) j(importexport)

reshape wide totalv0 totalv1, i(year panelid) j(sourcetype_grains) string
gen deltaimp= totalv0Local-totalv0National
gen deltaexp= totalv1Local-totalv1National
replace deltaexp=0 if deltaexp==.
replace deltaimp=0 if deltaimp==.
gen correctionimp=0
replace correctionimp=deltaimp if deltaimp>0
gen correctionexp=0
replace correctionexp=deltaexp if deltaexp>0

gen newimp=correctionimp+totalv0National
gen newexp=correctionexp+totalv1National

replace newimp=0 if newimp==. & newexp!=.
replace newexp=0 if newexp==. & newimp!=.

collapse (sum) newimp newexp, by(year)
replace newimp=. if newimp==0 & newexp==0
replace newexp=. if newexp==0 & newimp==.

tsset year
tsfill, full
gen nx=newexp-newimp
* estimate tot quantity at 15 livres tournois par setiers
gen nx15=nx/15

* estimate tot quantity at max prix 42.8 in 1720
gen nxmin=nx/42.8
* estimate tot quantity at min prix 7.5 in 1741
gen nxmax=nx/7.5
* estimate at modal price 20
gen nxmod=nx/20
