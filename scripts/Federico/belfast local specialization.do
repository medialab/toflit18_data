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
sort year importexport value_inclusive geography grains_num grouping_classification simplification_classification
quietly by year importexport value_inclusive geography grains_num grouping_classification simplification_classification:  gen dup = cond(_N==1,0,_n)
drop if dup>1 


**merge local and national par customs_regions series (Guillaume please check these lines!!!)


clonevar source_type_merged=source_type 
replace source_type_merged="National" if source_type=="National toutes customs_regions tous partenaires"
replace source_type_merged="Local" if source_type=="National toutes customs_regions partenaires manquants"
replace source_type_merged="Local" if geography!=.
keep if source_type_merged=="Local"


drop if year==.
drop if geography==.

*compute total for local series and regional series
**local total all grains
bys geography year importexport : egen totalv=total(value_inclusive)
***local total each grain
bys geography year importexport grains: egen eachgrain=total(value_inclusive)
****ratio
bys geography year importexport grains: gen yratio=eachgrain/totalv*100

**average over period for regions
*** create periods
gen period="empty"
replace period="Aearly" if year<1756
replace period="Bsevenywar" if year>1755 & year<1764
replace period="Cliberalization" if year>1763 & year<1776
replace period="Damericanwar" if year>1775 & year<1784
replace period="Ecrisis" if year>1783 & year<1790
replace period="Frevolutionnapoleon" if year>1789 & year<1814
replace period="Grestoration" if year>1813 & year<1823
drop if year==1823
**** local all grains for regions and periods
bys region period importexport : egen regallgrains=total(value_inclusive)
bys region period importexport grains: egen regeachgrain=total(value_inclusive)
bys region period importexport grains: gen regratio=regeachgrain/regallgrains*100
collapse (mean) regratio, by(region period importexport grains)
reshape wide regratio, i(region period grains) j(importexport)
rename regratio0 import
rename regratio1 export

replace grains="froment" if grains=="Froment (1)"
replace grains="inferior" if grains=="Céréales inférieures (2)"
replace grains="menus" if grains=="Menus grains (3)"
replace grains="substitutes" if grains=="Substituts (4)"
replace grains="transformed" if grains=="Grains transformés (5)"

reshape wide import export, i(region period) j(grains) string

