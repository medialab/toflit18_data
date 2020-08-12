***version 14



global dir "C:\Users\federico.donofrio\Documents\GitHub\"
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


encode tax_department, generate(geography) label(tax_department)

*** isolate grains
**destring somehow

encode grains, generate(grains_num) 
keep if (grains!="Pas grain (0)")

***SOURCETYPE
encode source_type, generate(source_type_encode) label(source_type)


*** corrections
*replace year=1741 if year==3
*replace year=1787 if year==. & source_type_encode==6
*replace year=1743 if year==. & source_type_encode==5
* geography 19= Marseille, local = 5
replace geography=19 if geography==. & source_type_encode==5 & year==1765
*replace geography=52 if geography==.

*** restrict sample
drop if geography != 19
drop if source_type_encode==3
drop if source_type_encode==7
drop if source_type_encode==6  & year==1750





*** aggregate by: country, importexport, year
collapse (sum) value_inclusive, by (year importexport source_type_encode)

*** reshape
*reshape wide value_inclusive total_trade country_ratio, i(year grouping_classification source_type_encode) j(importexport)
reshape wide value_inclusive, i(year source_type_encode) j(importexport)
rename value_inclusive0 import
rename value_inclusive1 export
***generate sum
replace import=0 if import==.
replace export=0 if export==.
bys year : gen trade_volume=import+export




tsset  year
tsfill, full



**saving
*export excel using "C:\Users\federico.donofrio\Documents\TOFLIT 9.10.2017\Marseille trade volume.xlsx", firstrow(variables)

*save "C:\Users\federico.donofrio\Documents\TOFLIT 9.10.2017\D3a Marseille trading partners.dta", replace
*export excel using "C:\Users\federico.donofrio\Documents\TOFLIT 9.10.2017\D3a Marseille trading partners.xlsx", firstrow(variables), replace
