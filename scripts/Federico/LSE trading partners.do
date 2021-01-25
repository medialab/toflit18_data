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
sort year importexport value_inclusive geography grains_num partner_simplification product_simplification
quietly by year importexport value_inclusive geography grains_num partner_simplification product_simplification:  gen dup = cond(_N==1,0,_n)
drop if dup>1 
clonevar source_type_grains=source_type
replace source_type_grains="National" if source_type=="Résumé"
replace source_type_grains="National" if source_type=="Tableau des quantités"
replace source_type_grains="National" if source_type=="Objet Général"
replace source_type_grains="National" if source_type=="National toutes customs_regions tous partenaires"

drop if grains=="Pas grain (0)"
drop if missing(grains)


*drop local without customs_region and strange things from the 1780s (mainly colonies for 1789)

drop if  source_type_grains!="National" & geography==.
*force Objet général entries with a geography into Objet Général, assuming they are simply late coming data (CHECK THIS WITH GUILLAUME!)
replace geography=0 if source_type_grains=="National"

drop if year==.
keep if source_type_grains=="National"
*** compute total value_inclusive by year
bys year importexport : egen total_trade = total(value_inclusive)

*** aggregate by: country, importexport, year
collapse (sum) value_inclusive, by (year total_trade importexport partner_grouping)
*** ratio of grains on total import or export
bys importexport year: generate country_ratio = (value_inclusive/total_trade)*100
drop total_trade value_inclusive
*** reshape
*reshape wide value_inclusive total_trade country_ratio, i(year partner_grouping source_type_encode) j(importexport)
reshape wide country_ratio, i(year partner_grouping) j(importexport)
rename country_ratio0 import
rename country_ratio1 export
replace partner_grouping="unknown" if partner_grouping=="????"
replace partner_grouping="Flandre" if partner_grouping=="Flandre et autres états de l'Empereur"
replace partner_grouping="Levant" if partner_grouping=="Levant et Barbarie"
replace partner_grouping="USA" if partner_grouping=="États-Unis d'Amérique"
replace partner_grouping="Outremers" if partner_grouping=="Outre-mers"

reshape wide import  export, i(year) j(partner_grouping) string

tsset year
tsfill

gen importContinentalEurope=importAllemagne+importSuisse+importFlandre
gen exportContinentalEurope=exportAllemagne+exportSuisse+exportFlandre
tsset year

******************************************AVERAGES********************

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
replace partner_grouping="unknown" if partner_grouping=="????"
replace partner_grouping="Flandre" if partner_grouping=="Flandre et autres états de l'Empereur"
replace partner_grouping="Levant" if partner_grouping=="Levant et Barbarie"
replace partner_grouping="USA" if partner_grouping=="États-Unis d'Amérique"
replace partner_grouping="Outremers" if partner_grouping=="Outre-mers"


*** isolate grains
**destring somehow

encode grains, generate(grains_num) 
 
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
sort year importexport value_inclusive geography grains_num partner_grouping partner_grouping
quietly by year importexport value_inclusive geography grains_num partner_grouping partner_grouping:  gen dup = cond(_N==1,0,_n)
drop if dup>1 
clonevar source_type_grains=source_type
replace source_type_grains="National" if source_type=="Résumé"
replace source_type_grains="National" if source_type=="Tableau des quantités"
replace source_type_grains="National" if source_type=="Objet Général"
replace source_type_grains="National" if source_type=="National toutes customs_regions tous partenaires"

drop if grains=="Pas grain (0)"
drop if missing(grains)


*drop local without customs_region and strange things from the 1780s (mainly colonies for 1789)

drop if  source_type_grains!="National" & geography==.
*force Objet général entries with a geography into Objet Général, assuming they are simply late coming data (CHECK THIS WITH GUILLAUME!)
replace geography=0 if source_type_grains=="National"

drop if year==.
keep if source_type_grains=="National"
gen period="empty"
replace period="1early" if year<1756
replace period="2sevenywar" if year>1755 & year<1764
replace period="3liberalization" if year>1763 & year<1776
replace period="4americanwar" if year>1775 & year<1784
replace period="5crisis" if year>1783 & year<1790
replace period="6revolutionnapoleon" if year>1789 & year<1814
replace period="7restoration" if year>1813 & year<1823
drop if year==1823



*** compute total value_inclusive by period
bys period importexport : egen total_trade = total(value_inclusive)

*** aggregate by: country, importexport, period
collapse (sum) value_inclusive, by (period total_trade importexport partner_grouping)
*** ratio of grains on total import or export
bys importexport period: generate country_ratio = (value_inclusive/total_trade)*100
drop total_trade value_inclusive
*** reshape
*reshape wide value_inclusive total_trade country_ratio, i(year partner_grouping source_type_encode) j(importexport)
reshape wide country_ratio, i(period partner_grouping) j(importexport)
rename country_ratio0 import
rename country_ratio1 export
replace partner_grouping="unknown" if partner_grouping=="????"
replace partner_grouping="Flandre" if partner_grouping=="Flandre et autres états de l'Empereur"
replace partner_grouping="Levant" if partner_grouping=="Levant et Barbarie"
replace partner_grouping="USA" if partner_grouping=="États-Unis d'Amérique"
replace partner_grouping="Outremers" if partner_grouping=="Outre-mers"

reshape wide import  export, i(period) j(partner_grouping) string



bys period : gen importContinentalEurope=importAllemagne+importSuisse+importFlandre
bys period : gen exportContinentalEurope=exportAllemagne+exportSuisse+exportFlandre
