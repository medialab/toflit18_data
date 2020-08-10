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

bys year geography importexport pays_simplification: egen totaltrade=total(value_inclusive)

generate totgrain1=0
replace totgrain1=value_inclusive if grains_num!=5
bys year geography importexport pays_simplification: egen totgrains=total(totgrain1)
bys year geography importexport pays_simplification: gen share=totgrains/totaltrade*100
sort year geography importexport
collapse (mean) share, by (year geography importexport totgrains totaltrade pays_simplification)
***gen id combining trading pairs (direction and partner)
egen panelid=group(geography pays_simplification), label
*create TS
reshape wide share totgrains totaltrade, i(geography year panelid pays_simplification) j(importexport) 
rename share0 import
rename share1 export
rename totgrains0 gimport_abs
rename totgrains1 gexport_abs
rename totaltrade0 timport_abs
rename totaltrade1 texport_abs
xtset panelid year
tsfill, full

gen tottrade=timport_abs+texport_abs
gen grains=gimport_abs+gexport_abs
gen nongrains=tottrade-grains
gen lngrains=ln(grains)
replace lngrains=0 if grains==0 
gen lnnongrains=ln(nongrains)

**compute corr
corr lngrains lnnongrains

bys panelid : corr lngrains lnnongrains
bys panelid : pwcorr lngrains lnnongrains, star(.1) obs
xtset panelid year
tsfill, full



gen lndiffgrains=ln(d.grains)
gen lndiffnongrains=ln(d.nongrains)
corr lndiffgrains lndiffnongrains
pwcorr lndiffgrains lndiffnongrains, star(.1) obs
bys panelid : pwcorr lndiffgrains lndiffnongrains, star(.1) obs

xtreg nongrains grains l.nongrains, fe
xtreg lndiffnongrains lndiffgrains, fe

bys year : pwcorr lngrains lnnongrains, star(.1) obs

