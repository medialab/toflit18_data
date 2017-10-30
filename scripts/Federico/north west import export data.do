***version 14



global dir "C:\Users\federico.donofrio\Documents\GitHub\"
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


encode direction, generate(geography) label(direction)

*** isolate grains
**destring somehow

encode grains, generate(grains_num) 
keep if (grains!="Pas grain (0)")

***SOURCETYPE
encode sourcetype, generate(sourcetype_encode) label(sourcetype)


*** corrections
*replace year=1741 if year==3
*replace year=1787 if year==. & sourcetype_encode==6
*replace year=1743 if year==. & sourcetype_encode==5
* geography 19= Marseille, local = 5
replace geography=19 if geography==. & sourcetype_encode==5 & year==1765
*replace geography=52 if geography==.


keep if geography==14 | geography==21 | geography==23
drop if sourcetype_encode==3| sourcetype_encode==7| sourcetype_encode==8 | sourcetype_encode==6
**only Local remains

*
***collapse by year
collapse (sum) value_inclusive, by (year geography importexport)

***drop subyear 1787

***drop objet générale 1787, 1789
*drop if sourcetype_encode==7  & year==1787
*drop if sourcetype_encode==7  & year==1788


***generate ln value
generate ln_value_inclusive=ln(value_inclusive)

***reshape import and export
reshape wide ln_value_inclusive value_inclusive, i(year geography ) j(importexport)
rename value_inclusive1 export
rename value_inclusive0 import
rename ln_value_inclusive1 ln_export
rename ln_value_inclusive0 ln_import

*replace import=0 if import==.
*replace export=0 if export==.
bys year  : gen trade_volume=import+export

*** generate geography NW
bys year sourcetype_encode

***generate ln trade volume
generate ln_trade_volume=ln(trade_volume)

*** now regress
 xi:  regress ln_trade_volume i.year i.geography i.sourcetype [iweight=trade_volume]

*** now rectangularize (filling missing explanatory variables (year, geography))
fillin geography year sourcetype_encode

*** predict and scatter national value of imports
*** it is very important to fill the missing values
xi i.year i.geography i.sourcetype_encode
predict ln_import_predict
generate import_predict=exp(ln_import_predict)

keep if geography==52 & sourcetype_encode==7


save "national_FE_imp.dta", replace


use "Données Stata/bdd_courante_grains.dta", clear

*** dummy importexport
gen importexport=0
replace importexport=1 if (exportsimports=="Export" | exportsimports=="Exports"| exportsimports=="Sortie")



*** deal with missing values and generate value_inclusive
generate value_inclusive=value
replace value_inclusive=prix_unitaire*quantit if value_inclusive==. & prix_unitaire!=.
drop if value_inclusive==.


encode direction, generate(geography) label(direction)

*** isolate grains
**destring somehow

encode grains, generate(grains_num) 
keep if (grains!="0")
***SOURCETYPE

encode sourcetype, generate(sourcetype_encode) label(sourcetype)


*** corrections
replace year=1741 if year==3
replace year=1787 if year==. & sourcetype_encode==6
replace year=1743 if year==. & sourcetype_encode==5
replace geography=33 if geography==. & sourcetype_encode==5 & year==1729
replace geography=52 if geography==.
drop if sourcetype=="Colonies"
drop sourcetype


*
***collapse by year
collapse (sum) value_inclusive, by (year geography importexport sourcetype_encode)

***drop subyear 1792
drop if sourcetype_encode==2
***drop objet générale 1787, 1789
*drop if sourcetype_encode==7  & year==1787
*drop if sourcetype_encode==7  & year==1788


***generate ln value
generate ln_value_inclusive=ln(value_inclusive)

***reshape import and export
reshape wide ln_value_inclusive value_inclusive, i(year geography sourcetype_encode) j(importexport)
rename value_inclusive1 export
rename value_inclusive0 import
rename ln_value_inclusive1 ln_export
rename ln_value_inclusive0 ln_import


*** now regress
 xi:  regress ln_export i.year i.geography i.sourcetype [iweight=export]

*** now rectangularize (filling missing explanatory variables (year, geography))
fillin geography year sourcetype_encode

*** predict and scatter national value of imports
*** it is very important to fill the missing values
xi i.year i.geography i.sourcetype_encode
predict ln_export_predict
generate export_predict=exp(ln_export_predict)

keep if geography==52 & sourcetype_encode==7



save "national_FE_exp.dta", replace
***MERGE AND IMPUTATE
use  "national_FE_imp.dta", clear

merge 1:1 year using "national_FE_exp.dta"
drop _merge
tsset year
tsfill

keep sourcetype_encode year import_predict export_predict

twoway (line  imp_predict year)(lowess imp_predict year)(line  exp_predict year)(lowess exp_predict year)

gen NX=exp_predict-imp_predict

save "national_FE_imp.dta", replace


