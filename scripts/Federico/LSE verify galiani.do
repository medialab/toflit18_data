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
*drop if grains=="Pas grain (0)"
 
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
sort year importexport value_inclusive geography grains_num partner_grouping partner_simplification
quietly by year importexport value_inclusive geography grains_num partner_grouping partner_simplification:  gen dup = cond(_N==1,0,_n)
*drop if dup>1 

drop if year==.
drop if geography==.
***** compute share of frains on total
keep if source_type=="Local"

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

gen tottrade=timport_abs+texport_abs
gen grains=gimport_abs+gexport_abs
gen nongrains=tottrade-grains
xtset geography year
xtreg nongrains grains l.nongrains, fe


*experimenting with cross-sectional dependence
reshape wide import export gimport_abs gexport_abs timport_abs texport_abs tottrade grains nongrains, i(year) j(geography)

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

 
