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
replace partner_grouping="unknown" if partner_grouping=="????"
replace partner_grouping="Flandre" if partner_grouping=="Flandre et autres états de l'Empereur"
replace partner_grouping="Levant" if partner_grouping=="Levant et Barbarie"
replace partner_grouping="USA" if partner_grouping=="États-Unis d'Amérique"
replace partner_grouping="Outremers" if partner_grouping=="Outre-mers"
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
***** compute total number of partners by partner_simplification
keep if source_type=="Local"
keep if grains_num!=5

collapse (sum) value_inclusive, by(year geography importexport partner_simplification)
bys year geography importexport partner_simplification : gen idpartners=_n==1
bys year geography importexport: egen npartners=total(idpartners)
drop idpartners
bys year geography importexport: egen graintrade=total(value_inclusive)
gen lngraintrade=ln(graintrade)
bys geography importexport: pwcorr lngraintrade npartners, obs star(.1)
**average number of partners
bys geography importexport: egen avpartners=mean(npartners)
reshape wide value_inclusive lngraintrade graintrade npartners avpartners, i(geography year partner_simplification) j(importexport)
egen panelid=group(geography partner_simplification), label
xtset panelid year
tsfill, full
xtreg npartners0 lngraintrade0 i.geography i.year

***invert

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
replace partner_grouping="unknown" if partner_grouping=="????"
replace partner_grouping="Flandre" if partner_grouping=="Flandre et autres états de l'Empereur"
replace partner_grouping="Levant" if partner_grouping=="Levant et Barbarie"
replace partner_grouping="USA" if partner_grouping=="États-Unis d'Amérique"
replace partner_grouping="Outremers" if partner_grouping=="Outre-mers"
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
***** compute total number of partners by partner_simplification
keep if source_type=="Local"
keep if grains_num!=5

gen period="empty"
replace period="1early" if year<1756
replace period="2sevenywar" if year>1755 & year<1764
replace period="3liberalization" if year>1763 & year<1776
replace period="4americanwar" if year>1775 & year<1784
replace period="5crisis" if year>1783 & year<1790
replace period="6revolutionnapoleon" if year>1789 & year<1814
replace period="7restoration" if year>1813 & year<1823
drop if year==1823

collapse (sum) value_inclusive, by(year geography importexport partner_grouping)
egen panelid=group(geography partner_grouping), label

reshape wide value_inclusive, i(geography year partner_grouping panelid) j(importexport)
rename value_inclusive0 import
rename value_inclusive1 export
xtset panelid year
tsfill, full
twoway (tsline import if panelid==4, lwidth(medthick) cmissing(n)) (tsline import if panelid==10 & year!=1770, lwidth(medthick) cmissing(n)) (tsline import if panelid==22, lwidth(medthick) cmissing(n)) (tsline import if panelid==32, lwidth(medthick) cmissing(n)) (tsline import if panelid==47, lwidth(medthick) cmissing(n)) (tsline import if panelid==57, lwidth(medthick) cmissing(n)), ttitle(year) tlabel(#15, grid) title("Holland exports to France")

***restart
*** compute whether exports to atlantic and med are substitute or complementary

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
replace partner_grouping="unknown" if partner_grouping=="????"
replace partner_grouping="Flandre" if partner_grouping=="Flandre et autres états de l'Empereur"
replace partner_grouping="Levant" if partner_grouping=="Levant et Barbarie"
replace partner_grouping="USA" if partner_grouping=="États-Unis d'Amérique"
replace partner_grouping="Outremers" if partner_grouping=="Outre-mers"
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
***** compute total number of partners by partner_simplification
keep if source_type=="Local"
keep if grains_num!=5

gen period="empty"
replace period="1early" if year<1756
replace period="2sevenywar" if year>1755 & year<1764
replace period="3liberalization" if year>1763 & year<1776
replace period="4americanwar" if year>1775 & year<1784
replace period="5crisis" if year>1783 & year<1790
replace period="6revolutionnapoleon" if year>1789 & year<1814
replace period="7restoration" if year>1813 & year<1823
drop if year==1823

collapse (sum) value_inclusive, by(year geography importexport partner_grouping)


reshape wide value_inclusive, i(year partner_grouping  importexport) j(geography)
encode partner_grouping, generate(partner) label(partnergrouping)
bys importexport partner_grouping : pwcorr value_inclusive2 value_inclusive4 value_inclusive15 value_inclusive20 value_inclusive22 value_inclusive24, obs star(.05)
bys importexport partner_grouping : corr value_inclusive2 value_inclusive4 value_inclusive15 value_inclusive20 value_inclusive22 value_inclusive24
