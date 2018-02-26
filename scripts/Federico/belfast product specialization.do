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
drop if dup>1 
clonevar sourcetype_grains=sourcetype
replace sourcetype_grains="National" if sourcetype=="Résumé"
replace sourcetype_grains="National" if sourcetype=="Tableau des quantités"
replace sourcetype_grains="National" if sourcetype=="Objet Général"
replace sourcetype_grains="National" if sourcetype=="National toutes directions tous partenaires"

drop if grains=="Pas grain (0)"
drop if missing(grains)


*drop local without direction and strange things from the 1780s (mainly colonies for 1789)

drop if  sourcetype_grains!="National" & geography==.
*force Objet général entries with a geography into Objet Général, assuming they are simply late coming data (CHECK THIS WITH GUILLAUME!)
replace geography=0 if sourcetype_grains=="National"

drop if year==.
keep if sourcetype_grains=="National"

replace pays_grouping="unknown" if pays_grouping=="????"
replace pays_grouping="Flandre" if pays_grouping=="Flandre et autres états de l'Empereur"
replace pays_grouping="Levant" if pays_grouping=="Levant et Barbarie"
replace pays_grouping="USA" if pays_grouping=="États-Unis d'Amérique"
replace pays_grouping="Outremers" if pays_grouping=="Outre-mers"

*** compute total value_inclusive by year
bys year importexport : egen total_trade = total(value_inclusive)

*** aggregate by: country, importexport, year
collapse (sum) value_inclusive, by (year total_trade importexport grains)
*** ratio of grains on total import or export
bys importexport grains year: generate g_ratio = (value_inclusive/total_trade)*100
drop total_trade value_inclusive
*** reshape
*reshape wide value_inclusive total_trade country_ratio, i(year pays_grouping sourcetype_encode) j(importexport)
reshape wide g_ratio, i(year grains) j(importexport)
rename g_ratio0 import
rename g_ratio1 export
encode grains, generate(grains_num) label(grains)
tsset year
tsfill
reshape wide import export, i(year) j(grains_num) 

tsset year




******************************************AVERAGES********************

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
replace pays_grouping="unknown" if pays_grouping=="????"
replace pays_grouping="Flandre" if pays_grouping=="Flandre et autres états de l'Empereur"
replace pays_grouping="Levant" if pays_grouping=="Levant et Barbarie"
replace pays_grouping="USA" if pays_grouping=="États-Unis d'Amérique"
replace pays_grouping="Outremers" if pays_grouping=="Outre-mers"


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
sort year importexport value_inclusive geography grains_num pays_grouping marchandises_simplification
quietly by year importexport value_inclusive geography grains_num pays_grouping marchandises_simplification:  gen dup = cond(_N==1,0,_n)
drop if dup>1 
clonevar sourcetype_grains=sourcetype
replace sourcetype_grains="National" if sourcetype=="Résumé"
replace sourcetype_grains="National" if sourcetype=="Tableau des quantités"
replace sourcetype_grains="National" if sourcetype=="Objet Général"
replace sourcetype_grains="National" if sourcetype=="National toutes directions tous partenaires"

drop if grains=="Pas grain (0)"
drop if missing(grains)


*drop local without direction and strange things from the 1780s (mainly colonies for 1789)

drop if  sourcetype_grains!="National" & geography==.
*force Objet général entries with a geography into Objet Général, assuming they are simply late coming data (CHECK THIS WITH GUILLAUME!)
replace geography=0 if sourcetype_grains=="National"

drop if year==.
keep if sourcetype_grains=="National"
gen period="empty"
replace period="Aearly" if year<1756
replace period="Bsevenywar" if year>1755 & year<1764
replace period="Cliberalization" if year>1763 & year<1776
replace period="Damericanwar" if year>1775 & year<1784
replace period="Ecrisis" if year>1783 & year<1790
replace period="Frevolutionnapoleon" if year>1789 & year<1814
replace period="Grestoration" if year>1813 & year<1823
drop if year==1823

*Pays_grouping
replace pays_grouping="unknown" if pays_grouping=="????"
replace pays_grouping="Flandre" if pays_grouping=="Flandre et autres états de l'Empereur"
replace pays_grouping="Levant" if pays_grouping=="Levant et Barbarie"
replace pays_grouping="USA" if pays_grouping=="États-Unis d'Amérique"
replace pays_grouping="Outremers" if pays_grouping=="Outre-mers"

*** compute total value_inclusive by period
bys period importexport pays_grouping : egen total_trade = total(value_inclusive)

*** aggregate by: country, importexport, period
collapse (sum) value_inclusive, by (period total_trade importexport grains pays_grouping)
*** ratio of grains on total import or export
bys importexport period grains pays_grouping: generate g_ratio = (value_inclusive/total_trade)*100
drop total_trade value_inclusive
*** reshape
*reshape wide value_inclusive total_trade country_ratio, i(year pays_grouping sourcetype_encode) j(importexport)
reshape wide g_ratio, i(period grains pays_grouping) j(importexport)
rename g_ratio0 import
rename g_ratio1 export


reshape wide import  export, i(period grains) j(pays_grouping) string

bys period  grains: gen importContinentalEurope=importAllemagne+importSuisse+importFlandre
bys period grains : gen exportContinentalEurope=exportAllemagne+exportSuisse+exportFlandre




******************************************AVERAGES********************

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
replace pays_grouping="unknown" if pays_grouping=="????"
replace pays_grouping="Flandre" if pays_grouping=="Flandre et autres états de l'Empereur"
replace pays_grouping="Levant" if pays_grouping=="Levant et Barbarie"
replace pays_grouping="USA" if pays_grouping=="États-Unis d'Amérique"
replace pays_grouping="Outremers" if pays_grouping=="Outre-mers"


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
sort year importexport value_inclusive geography grains_num pays_grouping marchandises_simplification
quietly by year importexport value_inclusive geography grains_num pays_grouping marchandises_simplification:  gen dup = cond(_N==1,0,_n)
drop if dup>1 
clonevar sourcetype_grains=sourcetype
replace sourcetype_grains="National" if sourcetype=="Résumé"
replace sourcetype_grains="National" if sourcetype=="Tableau des quantités"
replace sourcetype_grains="National" if sourcetype=="Objet Général"
replace sourcetype_grains="National" if sourcetype=="National toutes directions tous partenaires"

drop if grains=="Pas grain (0)"
drop if missing(grains)


*drop local without direction and strange things from the 1780s (mainly colonies for 1789)

drop if  sourcetype_grains!="National" & geography==.
*force Objet général entries with a geography into Objet Général, assuming they are simply late coming data (CHECK THIS WITH GUILLAUME!)
replace geography=0 if sourcetype_grains=="National"

drop if year==.
keep if sourcetype_grains=="National"
gen period="empty"
replace period="Aearly" if year<1756
replace period="Bsevenywar" if year>1755 & year<1764
replace period="Cliberalization" if year>1763 & year<1776
replace period="Damericanwar" if year>1775 & year<1784
replace period="Ecrisis" if year>1783 & year<1790
replace period="Frevolutionnapoleon" if year>1789 & year<1814
replace period="Grestoration" if year>1813 & year<1823
drop if year==1823

*Pays_grouping
replace pays_grouping="unknown" if pays_grouping=="????"
replace pays_grouping="Flandre" if pays_grouping=="Flandre et autres états de l'Empereur"
replace pays_grouping="Levant" if pays_grouping=="Levant et Barbarie"
replace pays_grouping="USA" if pays_grouping=="États-Unis d'Amérique"
replace pays_grouping="Outremers" if pays_grouping=="Outre-mers"

*** compute total value_inclusive by period
bys period importexport  : egen total_trade = total(value_inclusive)

*** aggregate by: country, importexport, period
collapse (sum) value_inclusive, by (period total_trade importexport grains )
*** ratio of grains on total import or export
bys importexport period grains : generate g_ratio = (value_inclusive/total_trade)*100
drop total_trade value_inclusive
*** reshape
*reshape wide value_inclusive total_trade country_ratio, i(year pays_grouping sourcetype_encode) j(importexport)
reshape wide g_ratio, i(period grains ) j(importexport)
rename g_ratio0 import
rename g_ratio1 export
encode grains, generate (grains_num) label(grains)
drop grains
reshape wide import export, i(period) j(grains_num)
rename import1 import_cereales_inf
rename import2 import_wheat
rename import3 import_flour
rename import4 import_other_grains
rename import5 import_substitutes

rename export1 export_cereales_inf
rename export2 export_wheat
rename export3 export_flour
rename export4 export_other_grains
rename export5 export_substitutes


*************************************destintion/origin for different goods
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
drop if dup>1 
clonevar sourcetype_grains=sourcetype
replace sourcetype_grains="National" if sourcetype=="Résumé"
replace sourcetype_grains="National" if sourcetype=="Tableau des quantités"
replace sourcetype_grains="National" if sourcetype=="Objet Général"
replace sourcetype_grains="National" if sourcetype=="National toutes directions tous partenaires"

drop if grains=="Pas grain (0)"
drop if missing(grains)


*drop local without direction and strange things from the 1780s (mainly colonies for 1789)

drop if  sourcetype_grains!="National" & geography==.
*force Objet général entries with a geography into Objet Général, assuming they are simply late coming data (CHECK THIS WITH GUILLAUME!)
replace geography=0 if sourcetype_grains=="National"

drop if year==.
keep if sourcetype_grains=="National"

replace pays_grouping="unknown" if pays_grouping=="????"
replace pays_grouping="Flandre" if pays_grouping=="Flandre et autres états de l'Empereur"
replace pays_grouping="Levant" if pays_grouping=="Levant et Barbarie"
replace pays_grouping="USA" if pays_grouping=="États-Unis d'Amérique"
replace pays_grouping="Outremers" if pays_grouping=="Outre-mers"

*** compute total value_inclusive by year
bys grains importexport : egen total_trade = total(value_inclusive)

*** aggregate by: country, importexport, year
collapse (sum) value_inclusive, by (pays_group total_trade importexport grains)
*** ratio of grains on total import or export
bys importexport grains pays_grouping: generate g_ratio = (value_inclusive/total_trade)*100
drop total_trade value_inclusive
*** reshape
*reshape wide value_inclusive total_trade country_ratio, i(year pays_grouping sourcetype_encode) j(importexport)
reshape wide g_ratio, i(grains pays_grouping) j(importexport)
rename g_ratio0 import
rename g_ratio1 export
encode grains, generate(grains_num) label(grains)

