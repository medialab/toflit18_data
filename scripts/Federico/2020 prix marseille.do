import delimited "C:\Users\federico.donofrio\Documents\TOFLIT desktop\Données Stata\bdd courante.csv", varnames(1) encoding(UTF-8) 
save "C:\Users\federico.donofrio\Documents\TOFLIT desktop\Données Stata\bdd courante.dta", replace
global dir "C:\Users\federico.donofrio\Documents\TOFLIT desktop\"
clear
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

*to study local drop direction vide
drop if direction=="[vide]"
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

encode product_grains, generate(grains_num) 
*drop if grains=="Pas grain (0)"
 
*** corrections
*replace year=1741 if year==3
*replace year=1787 if year==. & sourcetype_encode==6
*replace year=1743 if year==. & sourcetype_encode==5
* geography 19= Marseille, local = 5
*replace geography=19 if geography==. & sourcetype_encode==5 & year==1765
*replace geography=52 if geography==.
drop if product_grains=="."
drop if grains_num==.
drop if sourcetype=="1792-first semestre"
drop if  year==1805.75 
*drop if yearstr=="10 mars-31 décembre 1787" 
*GUILLAUME WHY?
*drop colonies
drop if sourcetype=="Local"  & year==1787
drop if sourcetype=="Local"  & year==1788
*Unify Resumé and O.G.
**drop Resumé 1787, 1789
drop if sourcetype=="Résumé"  & year==1787
drop if sourcetype=="Résumé"  & year==1788



*adjust 1749, 1751, 1777, 1789 and double accounting in order to keep only single values from series "Local" and "National toutes directions partenaires manquants"
sort year importexport value_inclusive geography grains_num country_simplification country_grouping  
quietly by year importexport value_inclusive geography grains_num country_simplification country_grouping  :  gen dup = cond(_N==1,0,_n)
*drop if dup>1 

drop if year==.
drop if geography==.

gen period="empty"
replace period="1early" if year<1756
replace period="2sevenywar" if year>1755 & year<1764
replace period="3liberalization" if year>1763 & year<1776
replace period="4americanwar" if year>1775 & year<1784
replace period="5crisis" if year>1783 & year<1790
replace period="6revolutionnapoleon" if year>1789 & year<1814
replace period="7restoration" if year>1813 & year<1823
drop if year==1823

*compute average price per unit per period
bysort geography quantity_unit_ortho period grains_num: asgen average_pp=prix_unitaire, weights(value_inclusive)
*compute average price per unit per year
bysort geography quantity_unit_ortho year grains_num: asgen average_py=prix_unitaire, weights(value_inclusive)
*compute average price per unit per year per group of countries
bysort geography quantity_unit_ortho year country_grouping grains_num: asgen average_pyc=prix_unitaire, weights(value_inclusive)
*compute median price per unit per year
bysort geography quantity_unit_ortho year grains_num: egen median_py=median(prix_unitaire)
*graphs
twoway (scatter prix_unitaire year if direction=="Marseille" & grains_num==2 & quantity_unit_ortho=="charges", yaxis(1) ) (line median_py year if direction=="Marseille" & grains_num==2 & quantity_unit_ortho=="charges", yaxis(1) ) (scatter prix_unitaire year if direction=="Marseille" & grains_num==2 & quantity_unit_ortho=="livres", yaxis(2) ) (line median_py year if direction=="Marseille" & grains_num==2 & quantity_unit_ortho=="livres", yaxis(2) xlabel(#10) )
*frequency
hist prix_unitaire if direction=="Marseille" & grains_num==2 & quantity_unit_ortho=="charges", freq
*anova
encode country_grouping, generate(partner) label(country_grouping)
anova prix_unitaire partner if  direction=="Marseille" & grains_num==2 & quantity_unit_ortho=="charges"
