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

encode customs_region, generate(geography) label(customs_region)

***Regions
generate region="KO"
replace region="NE" if customs_region=="Amiens" | customs_region=="Dunkerque"| customs_region=="Saint-Quentin" | customs_region=="Châlons" | customs_region=="Langres" | customs_region=="Flandre"  
replace region="N" if customs_region=="Caen" | customs_region=="Rouen" | customs_region=="Le Havre"
replace region="NW" if customs_region=="Rennes" | customs_region=="Lorient" | customs_region=="Nantes" | customs_region=="Saint-Malo"
replace region="SW" if customs_region=="La Rochelle" | customs_region=="Bordeaux" | customs_region=="Bayonne" 
replace region="S" if customs_region=="Marseille" | customs_region=="Toulon" | customs_region=="Narbonne" | customs_region=="Montpellier"
replace region="SE" if customs_region=="Grenoble" | customs_region=="Lyon" 
replace region="E" if customs_region=="Besancon" | customs_region=="Bourgogne"| customs_region=="Charleville"

*** isolate grains
**destring somehow

encode grains, generate(grains_num) 
drop if grains=="Pas grain (0)"
 
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



*adjust 1749, 1751, 1777, 1789 and double accounting in order to keep only single values from series "Local" and "National toutes customs_regions partenaires manquants"
sort year importexport value_inclusive geography grains_num partner_grouping partner_simplification
quietly by year importexport value_inclusive geography grains_num partner_grouping partner_simplification:  gen dup = cond(_N==1,0,_n)
*drop if dup>1 

drop if year==.
drop if geography==.
***** examine by series Bayonne, Bordeaux, La Rochelle, Marseille, Nantes, Rennes
keep if source_type=="Local"

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

*experimenting with cross-sectional dependence
reshape wide import export, i(year) j(geography)

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

by period, sort: pwcorr import_bordeaux import_larochelle import_nantes import_marseille import_rennes import_rouen import_bayonne, obs star(0.1)

estpost correlate import_bordeaux import_larochelle import_nantes import_marseille import_rennes import_rouen import_bayonne , matrix
eststo correlation
esttab correlation using LSE_local_correlations.rtf, unstack compress b(2)

estpost correlate export_bordeaux export_larochelle export_nantes export_marseille export_rennes export_rouen export_bayonne , matrix
eststo correlation
esttab correlation using LSE_local_correlations_export.rtf, unstack compress b(2)

reg import_bordeaux import_larochelle import_marseille year period
