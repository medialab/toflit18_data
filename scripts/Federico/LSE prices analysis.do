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
collapse (mean) share, by (year geography importexport totgrains totaltrade)


*create TS
reshape wide share totgrains totaltrade, i(geography year) j(importexport) 
rename share0 import
rename share1 export
rename totgrains0 gimport_abs
rename totgrains1 gexport_abs
rename totaltrade0 timport_abs
rename totaltrade1 texport_abs
xtset geography year
tsfill, full

*experimenting with cross-sectional dependence
reshape wide import export gimport_abs gexport_abs timport_abs texport_abs, i(year) j(geography)

rename import2 import_bayonne
rename export2 export_bayonne
rename import4 import_bordeaux
rename export4 export_bordeaux
rename import6 import_caen
rename export6 export_caen
rename import15 import_larochelle
rename export15 export_larochelle
rename import19 import_lyon
rename export19 export_lyon
rename import20 import_marseille
rename export20 export_marseille
rename import21 import_montpellier
rename export21 export_montpellier
rename import22 import_nantes
rename export22 export_nantes
rename import24 import_rennes
rename export24 export_rennes
rename import25 import_rouen
rename export25 export_rouen


tsset year
gen period="empty"
replace period="1early" if year<1756
replace period="2sevenywar" if year>1755 & year<1764
replace period="3liberalization" if year>1763 & year<1776
replace period="4americanwar" if year>1775 & year<1784
replace period="5crisis" if year>1783 & year<1790
replace period="6revolutionnapoleon" if year>1789 & year<1814
replace period="7restoration" if year>1813 & year<1823
drop if year==1823

twoway (tsline import_bayonne, lwidth(medthick) cmissing(n)) (tsline import_bordeaux, lwidth(medthick) cmissing(n)) (tsline import_larochelle, lwidth(medthick) cmissing(n)) (tsline import_marseille, lwidth(medthick) cmissing(n)) (tsline import_nantes, lwidth(medthick) cmissing(n)) (tsline import_rennes, lwidth(medthick) cmissing(n)), ttitle(year) tlabel(#15, grid) title("share of grains in total imports")

bys period : pwcorr import_bordeaux import_marseille import_larochelle import_nantes import_rennes, obs star(.01)

merge 1:1 year using "C:\Users\federico.donofrio\Documents\TOFLIT desktop\Données Stata\french_prices_wide.dta"


 
