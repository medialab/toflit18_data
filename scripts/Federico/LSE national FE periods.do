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


*** isolate grains
**destring somehow

encode grains, generate(grains_num) 
drop if grains=="Pas grain (0)"
drop if missing(grains)

***SOURCETYPE

encode source_type, generate(source_type_encode) label(source_type)


*** corrections
replace year=1741 if year==3
replace year=1787 if year==. & source_type_encode==6
replace year=1743 if year==. & source_type_encode==5
replace geography=33 if geography==. & source_type_encode==5 & year==1729
replace geography=52 if geography==.
drop if source_type=="Colonies"
drop source_type


*
***collapse by year
collapse (sum) value_inclusive, by (year geography importexport source_type_encode)

***drop subyear 1792
drop if source_type_encode==2
***drop objet générale 1787, 1789
*drop if source_type_encode==7  & year==1787
*drop if source_type_encode==7  & year==1788


***generate ln value
generate ln_value_inclusive=ln(value_inclusive)

***reshape import and export
reshape wide ln_value_inclusive value_inclusive, i(year geography source_type_encode) j(importexport)
rename value_inclusive1 export
rename value_inclusive0 import
rename ln_value_inclusive1 ln_export
rename ln_value_inclusive0 ln_import




*** now regress
 xi:  regress ln_import i.year i.geography i.source_type [iweight=import]
*** now rectangularize (filling missing explanatory variables (year, geography))
fillin geography year source_type_encode
 predict ln_import_predict
generate import_predict=exp(ln_import_predict)
drop _fillin

 xi:  regress ln_export i.year i.geography i.source_type [iweight=export]

*** now rectangularize (filling missing explanatory variables (year, geography))
fillin geography year source_type_encode

*** predict and scatter national value of imports
*** it is very important to fill the missing values

xi i.year i.geography i.source_type_encode
predict ln_export_predict

generate export_predict=exp(ln_export_predict)

egen id = group(geography source_type_encode)

xtset id year
tsfill, full



twoway (line  import_predict year if geography==100)(lowess import_predict year)(line  export_predict year if geography==100)(lowess export_predict year)

gen NX=export_predict-import_predict

save "Données Stata/national_FE_imp.dta", replace

