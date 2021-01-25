*** compute average price per kg in 1787, 1788 and 1789 - compare with Labrousse's prices

use "C:\Users\federico.donofrio\Documents\GitHub\Données Stata\bdd courante.dta", clear

keep if grains!="Pas grain (0)"
keep if grains!="Substituts (4)"


keep if year==1787 | year==1788 | year ==1789

tab source_type year


keep if source_type=="National par customs_region" | source_type=="Objet Général"

drop if u_conv=="pièces" | u_conv=="unité manquante"
gen unit_price_kg=0
replace unit_price_kg=value/quantites_metric
drop if  unit_price_kg==.

**** CHECK FOR OUTLIERS
twoway (scatter unit_price_kg quantites_metric if grains=="Froment (1)"), by (year)

***compute average price
bys year grains: egen totalq=sum(quantites_metric)
bys year grains: egen totalp=sum(value)
bys year grains : gen averagep=totalp/totalq


*** compute q net export
collapse(sum)quantites_metric, by (year grains export_import)
reshape wide quantites_metric, i(year grains) j(export_import)string
bys year grains : gen qnetexport=quantites_metricExports-quantites_metricImports

*** compute q in 1787, 1788 and 1789 with Résumé

use "C:\Users\federico.donofrio\Documents\GitHub\Données Stata\bdd courante.dta", clear

keep if grains!="Pas grain (0)"
keep if grains!="Substituts (4)"


keep if year==1787 | year==1788 | year ==1789

tab source_type year


keep if source_type=="Résumé"
summarize value
collapse(sum)value, by (year grains export_import)
reshape wide value, i(year grains) j(export_import)string
replace valueExports=0 if valueExports==.
replace valueImports=0 if valueImports==.

bys year grains : gen pnetexport=valueExports-valueImports


*** compute q in 1787, 1788 and 1789

use "C:\Users\federico.donofrio\Documents\GitHub\Données Stata\bdd courante.dta", clear

keep if grains!="Pas grain (0)"
keep if grains!="Substituts (4)"
drop if missing(grains)

keep if year==1787 | year==1788 | year ==1789

tab source_type year


keep if source_type=="National par customs_region" | source_type=="Objet Général"

summarize value
collapse(sum)value, by (year grains export_import)
reshape wide value, i(year grains) j(export_import)string
replace valueExports=0 if valueExports==.
replace valueImports=0 if valueImports==.

bys year grains : gen pnetexport=valueExports-valueImports

*** compute basket price for grains 1 and 2
use "C:\Users\federico.donofrio\Documents\GitHub\Données Stata\bdd courante.dta", clear
keep if year==1787 | year==1788 | year ==1789
keep if source_type=="National par customs_region" | source_type=="Objet Général"
keep if grains=="Froment (1)" | grains=="Céréales inférieures (2)"
bys year : egen totalq=sum(quantites_metric)
bys year : egen totalp=sum(value)
bys year : gen averagep=totalp/totalq
collapse (mean) averagep, by (year)

*** compute total value 1+2 based on ObjGen+National par dir. 

use "C:\Users\federico.donofrio\Documents\GitHub\Données Stata\bdd courante.dta", clear

keep if grains!="Pas grain (0)"
keep if grains!="Substituts (4)"
drop if missing(grains)

keep if year==1787 | year==1788 | year ==1789

tab source_type year


keep if source_type=="National par customs_region" | source_type=="Objet Général"
keep if grains=="Froment (1)" | grains=="Céréales inférieures (2)"

summarize value
collapse(sum)value, by (year export_import)
reshape wide value, i(year) j(export_import)string
replace valueExports=0 if valueExports==.
replace valueImports=0 if valueImports==.

bys year: gen pnetexport=valueExports-valueImports

***and based on Résumé
use "C:\Users\federico.donofrio\Documents\GitHub\Données Stata\bdd courante.dta", clear

keep if grains!="Pas grain (0)"
keep if grains!="Substituts (4)"
drop if missing(grains)

keep if year==1787 | year==1788 | year ==1789

tab source_type year


keep if source_type=="Résumé" 
keep if grains!="Pas grain (0)"
keep if grains!="Substituts (4)"
drop if missing(grains)

*keep if grains=="Froment (1)" | grains=="Céréales inférieures (2)"
tab year grains
summarize value
collapse(sum)value, by (year export_import)
reshape wide value, i(year) j(export_import)string
replace valueExports=0 if valueExports==.
replace valueImports=0 if valueImports==.

bys year : gen pnetexport=valueExports-valueImports




