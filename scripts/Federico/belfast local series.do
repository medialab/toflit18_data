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
sort year importexport value_inclusive geography grains_num pays_grouping marchandises_simplification
quietly by year importexport value_inclusive geography grains_num pays_grouping marchandises_simplification:  gen dup = cond(_N==1,0,_n)
*drop if dup>1 

drop if year==.
drop if geography==.
***** examine by series Bayonne, Bordeaux, La Rochelle, Marseille, Nantes, Rennes
keep if sourcetype=="Local"

bys grains year geography importexport : egen eachgrain=total(value_inclusive)
twoway (line eachgrain year if geography==19 & grains_num==2 & importexport==0) (line eachgrain year if geography==19 & grains_num==2 & importexport==1)
egen partners = nvals(pays_simplification), by(year importexport geography grains) 
gen period="empty"
replace period="Aearly" if year<1756 
replace period="Bsevenywar" if year>1755 & year<1764
replace period="Cliberalization" if year>1763 & year<1776
replace period="Damericanwar" if year>1775 & year<1784
replace period="Ecrisis" if year>1783 & year<1790
bys period grains  geography importexport : egen avpartners=mean(partners)

*Bordeaux
twoway (line eachgrain year if geography==4 & grains_num==2 & importexport==0 & year!=1770 & year!=1771) (line eachgrain year if geography==4 & grains_num==3 & importexport==1)
*Bayonne
twoway (line eachgrain year if geography==2 & grains_num==2 & importexport==0) (line eachgrain year if geography==2 & grains_num==2 & importexport==1)
*La Rochelle 14
twoway (line eachgrain year if geography==14 & grains_num==2 & importexport==0) (line eachgrain year if geography==14 & grains_num==2 & importexport==1)
twoway (line eachgrain year if geography==14 & grains_num==2 & importexport==0) (line eachgrain year if geography==14 & grains_num==3 & importexport==1)
twoway (line eachgrain year if geography==14 & grains_num==1 & importexport==0) (line eachgrain year if geography==14 & grains_num==1 & importexport==1)
bys year marchandises_simplification importexport geography : egen marchsimp=total(value_inclusive)
bys year grains_num  importexport geography: egen countryshareden=total(value_inclusive)
bys year grains_num  importexport geography pays_grouping: egen countrysharenum=total(value_inclusive)
bys year grains_num importexport geography pays_grouping: gen countryshare=countrysharenum/countryshareden*100
bys period grains_num  importexport geography: egen countrysharedenp=total(value_inclusive)
bys period grains_num  importexport geography pays_grouping: egen countrysharenump=total(value_inclusive)
bys period grains_num importexport geography pays_grouping: gen countrysharep=countrysharenump/countrysharedenp*100

* Nantes 21
twoway (line eachgrain year if geography==21 & grains_num==2 & importexport==0) (line eachgrain year if geography==21 & grains_num==3 & importexport==1)

* Rennes 23
twoway (line eachgrain year if geography==23 & grains_num==2 & importexport==1) (line eachgrain year if geography==21 & grains_num==3 & importexport==1)

*Rouen 24
twoway (line eachgrain year if geography==24 & grains_num==2 & importexport==0) (line eachgrain year if geography==24 & grains_num==2 & importexport==1)















**merge local and national par directions series (Guillaume please check these lines!!!)


clonevar sourcetype_merged=sourcetype 
replace sourcetype_merged="National" if sourcetype=="National toutes directions tous partenaires"
replace sourcetype_merged="Local" if sourcetype=="National toutes directions partenaires manquants"
replace sourcetype_merged="Local" if geography!=.
keep if sourcetype_merged=="Local"


drop if year==.
drop if geography==.



bys year geography importexport : egen allgrains=total(value_inclusive)

 
***
collapse (mean)  allgrains, by(year geography importexport)
***reshape import export
reshape wide allgrains, i(year geography) j(importexport)
*** how much do the local series capture of the national one?
merge m:1 year using "C:\Users\federico.donofrio\Documents\TOFLIT desktop\Données Stata\belfast_natgtrade_corrected.dta"
gen portshareimport=allgrains0/newimp*100
gen portshareexport=allgrains1/newexp*100
bys year : egen controltotexp=total(portshareexport)
bys year : egen controltotimp=total(portshareimport)

gen period="empty"
replace period="Aearly" if year<1756 & year>1751
replace period="Bsevenywar" if year>1755 & year<1764
replace period="Cliberalization" if year>1763 & year<1776
replace period="Damericanwar" if year>1775 & year<1784
replace period="Ecrisis" if year>1783 & year<1790
replace period="Frevolutionnapoleon" if year>1789 & year<1814
replace period="Grestoration" if year>1813 & year<1823
drop if year==1823

bys period geography : egen numimp=total(allgrains0)
bys period geography : egen denimp=total(newimp)
gen shareimp=numimp/denimp*100
bys period geography : egen numexp=total(allgrains1)
bys period geography : egen denexp=total(newexp)
gen shareexp=numexp/denexp*100
collapse (mean) shareimp shareexp, by(geography period)