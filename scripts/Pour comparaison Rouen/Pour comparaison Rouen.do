

local XI = "Exports"
local year = 1730

capture program drop verification_Rouen
program verification_Rouen
args XI year

use "/Users/guillaumedaudin/Documents/Recherche/Commerce International Français XVIIIe.xls/Balance du commerce/Retranscriptions_Commerce_France/Données Stata/bdd courante_avec_out.dta", clear

keep if tax_department=="Rouen"
keep if export_import=="`XI'"
keep if year==`year'
keep if strmatch(source,"*Dardel*")==1

generate string3 = partner + product + quantity_unit

generate sortkey = ustrsortkeyex(string3,  "fr",-1,2,-1,-1,-1,0,-1)
sort sortkey quantity value
drop sortkey

if value==. replace value = quantity*value_per_unit if value==.



/*
local Dardel = 0
if `year'==1728 local Dardel = 1

if `Dardel'==0 import delimited "/Users/guillaumedaudin/Documents/Recherche/Commerce International Français XVIIIe.xls/Balance du commerce/Retranscriptions_Commerce_France/toflit18_data_GIT/sources/Local/Archives_de_la_CCI_de_Rouen_Carton_VIII_Rouen_`XI'_`year'.csv", encoding(UTF-8) clear 

if `Dardel'==1 import delimited "/Users/guillaumedaudin/Documents/Recherche/Commerce International Français XVIIIe.xls/Balance du commerce/Retranscriptions_Commerce_France/toflit18_data_GIT/sources/Local/AD76_7F97_via_Dardel_`XI'.csv", encoding(UTF-8) clear 


replace product = subinstr(product," ; "," ",.)
replace product = subinstr(product,"; "," ",.)

replace value = subinstr(value,",",".",.)
destring value, replace
replace value=. if value==0

replace value_per_unit = subinstr(value_per_unit,",",".",.)
destring value_per_unit, replace


replace quantity = subinstr(quantity,",",".",.)
destring quantity, replace

replace value = quantity*value_per_unit if value==.
*/



save temp.dta, replace

import delimited "/Users/guillaumedaudin/Documents/Recherche/Commerce International Français XVIIIe.xls/Balance du commerce/Retranscriptions_Commerce_France/toflit18_data_GIT/scripts/Pour comparaison Rouen/bdd_commerce_rouen_categories avec corrections.csv", encoding(UTF-8) clear asdouble

rename quantit quantity
replace quantity = subinstr(quantity,",",".",.)
destring quantity, replace


keep if year==`year'
keep if exportsimports=="`XI'"

rename marchandises product
sort numrodeligne
rename pays partner
rename prix_unitaire value_per_unit

generate string3 = partner +  product + quantity_unit

generate sortkey = ustrsortkeyex(string3,  "fr",-1,2,-1,-1,-1,0,-1)
sort sortkey quantity value
drop sortkey


display "Master : données de PMH ; Using : données Toflit18"

cf product value partner quantity quantity_unit value_per_unit using temp.dta, verbose



erase temp.dta

end

capture noisily verification_Rouen Imports 1728
blif


capture noisily verification_Rouen Exports 1775
capture noisily verification_Rouen Exports 1776 Pas les mêmes données
capture noisily verification_Rouen Exports 1774 Pas les mêmes données
capture noisily verification_Rouen Exports 1773
capture noisily verification_Rouen Exports 1772
capture noisily verification_Rouen Exports 1771 Pas les mêmes données
capture noisily verification_Rouen Exports 1770
capture noisily verification_Rouen Exports 1769 Pas les mêmes données
capture noisily verification_Rouen Exports 1768
capture noisily verification_Rouen Exports 1767 Pas les mêmes données
capture noisily verification_Rouen Exports 1766 Soucis X de farine vers les isles et la guinée
capture noisily verification_Rouen Exports 1764
capture noisily verification_Rouen Exports 1763
capture noisily verification_Rouen Exports 1755
capture noisily verification_Rouen Exports 1750 Local et Gournay
capture noisily verification_Rouen Exports 1738 Pas les mêmes données
capture noisily verification_Rouen Exports 1733
capture noisily verification_Rouen Exports 1732
capture noisily verification_Rouen Exports 1731
capture noisily verification_Rouen Exports 1730
capture noisily verification_Rouen Exports 1728





























/*
gen tax_office=""
gen origin=""
gen width_in_line=.
gen value_total=.
gen value_sub_total_1=.
gen value_sub_total_2=.
gen value_sub_total_3=.
gen unverified=""
gen remarks=""
gen value_minus_unit_val_x_qty=.
gen trade_deficit=.
gen trade_surplus=.
gen duty_quantity=.
gen duty_quantity_unit=""
gen duty_by_unit=.
gen duty_total=.
gen duty_part_of_bundle=.
gen duty_remarks=""

*plutot passer par cf, verbose ? 

