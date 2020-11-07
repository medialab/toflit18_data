


global dir "~/Documents/Recherche/Commerce International Français XVIIIe.xls/Balance du commerce/Retranscriptions_Commerce_France"

if "`c(username)'"=="Matthias" global dir "/Users/Matthias/"

if "`c(username)'"=="Tirindelli" global dir "/Users/Tirindelli/Google Drive/ETE/Thesis"

if "`c(username)'"=="federico.donofrio" global dir "C:\Users\federico.donofrio\Documents\GitHub"

if "`c(username)'"=="pierr" global dir "/Users/pierr/Documents/Toflit/"

if "`c(username)'"=="loiccharles" global dir "/Users/loiccharles/Documents/"

cd "$dir"


use "Données Stata/bdd_centrale.dta", clear

replace value=. if (value==0 & quantity !=. & quantity !=0)

generate byte computed_value = 0
label var computed_value "Was the value computed expost based on unit price and quantities ? 0 no 1 yes"
replace computed_value=1 if (value==0 | value==.) & value_per_unit!=0 & value_per_unit!=. & quantity!=0 & quantity!=.
replace value = quantity*value_per_unit if computed_value==1

gen byte computed_value_per_unit = 0
label var computed_value_per_unit "Was the value_per_unit computed expost based on and quantities and value ? 0 no 1 yes"
replace computed_value_per_unit = 1 if (value_per_unit==0 | value_per_unit==.) & value!=0 & value!=. ///
				& quantity!=0 & quantity!=. & (value_part_of_bundle ==. | value_part_of_bundle==0)
replace value_per_unit = value/quantity  if computed_value_per_unit ==1


destring value_minus_unit_val_x_qty, replace

replace quantity=. if quantity==0

rename value_minus_unit_val_x_qty value_minus_un_source
gen value_minus_unit_val_x_qty = value-(value_per_unit*quantity)

gen diff=abs(value_minus_unit_val_x_qty)/value
gen ln_diff=abs(ln(quantity*value_per_unit/value))

gsort - ln_diff

*******

*Pour revenir : 

replace value=. if computed_value==1
replace value_per_unit = .  if computed_value_per_unit ==1
drop diff ln_diff value_minus_unit_val_x_qty computed_value_per_unit computed_value
rename value_minus_un_source value_minus_unit_val_x_qty

export delimited using "/Users/guillaumedaudin/Documents/Recherche/Commerce International Français XVIIIe.xls/Balance du commerce/Retranscriptions_Commerce_France/toflit18_data_GIT/base/bdd_centrale.csv", replace
