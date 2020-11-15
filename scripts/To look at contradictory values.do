


global dir "~/Documents/Recherche/Commerce International Français XVIIIe.xls/Balance du commerce/Retranscriptions_Commerce_France"

if "`c(username)'"=="Matthias" global dir "/Users/Matthias/"

if "`c(username)'"=="Tirindelli" global dir "/Users/Tirindelli/Google Drive/ETE/Thesis"

if "`c(username)'"=="federico.donofrio" global dir "C:\Users\federico.donofrio\Documents\GitHub"

if "`c(username)'"=="pierr" global dir "/Users/pierr/Documents/Toflit/"

if "`c(username)'"=="loiccharles" global dir "/Users/loiccharles/Documents/"

cd "$dir"


import delimited "$dir/toflit18_data_GIT/base/bdd_centrale.csv",  encoding(UTF-8) clear varname(1) stringcols(_all)  

destring value_total value_sub_total_1 value_sub_total_2 value_sub_total_3  value_part_of_bundle, replace
destring quantity value_per_unit value, replace

drop if source==""
drop if value==0 & quantity==. & value_per_unit ==. /*Dans tous les cas regardés le 31 mai 2016, ce sont des "vrais" 0*/
drop if (value==0|value==.) & (quantity ==.|quantity ==0) & (value_per_unit ==.|value_per_unit ==0) /*idem*/
replace value=. if (value==0 & quantity !=. & quantity !=0)
replace quantity=. if quantity==0


**Je mets des majuscules à toutes les "product" de la source
replace product = upper(substr(product,1,1))+substr(product,2,.)



capture drop v24


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
gen abs_diff=abs(value_minus_unit_val_x_qty)
gsort - ln_diff
gsort - abs_diff
format abs_diff value quantity %15.2gc

order line_number-product value value quantity quantity_unit value_per_unit sheet remarks value_minus_un_source value_minus_unit_val_x_qty diff ln_diff abs_diff


list year product value_per_unit quantity_unit if strmatch(product,"*itrons")==1 & strmatch(quantity_unit,"*illier*")==1 

edit if absurd_value !="absurd"
*******
blouf
*********


*Pour revenir : 

replace value=. if computed_value==1
replace value_per_unit = .  if computed_value_per_unit ==1
drop diff ln_diff value_minus_unit_val_x_qty computed_value_per_unit computed_value abs_diff
rename value_minus_un_source value_minus_unit_val_x_qty

export delimited using "$dir/toflit18_data_GIT/base/bdd_centrale.csv", replace

cd "$dir/toflit18_data_GIT/scripts"

python script "split_bdd_centrale_in_sources.py"

python script "aggregate_sources_in_bdd_centrale.py"

/*
À faire si le programme suivant dépend du fichier zip !


cd "$dir/toflit18_data_GIT/base"
zipfile "bdd_centrale.csv", saving("bdd_centrale.csv.zip", replace)

cd "$dir/toflit18_data_GIT/scripts"
*/
do "Pour BDD courante et mise à jour des autres tables.do"
