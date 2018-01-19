*calculate index riots/pop
gen riot_index=riots/population_ipo
gen geostring="city"

replace geostring="Bordeaux" if generalites_encode==6
replace geostring="La Rochelle" if generalites_encode==14
replace geostring="Marseille" if generalites_encode==17
replace geostring="Rennes" if generalites_encode==27

drop if geostring=="city"

merge 1:1 geostring year using "C:\Users\federico.donofrio\Documents\TOFLIT desktop\Données Stata\beta_select_ready.dta"
drop if _merge!=3
xtset geo year
foreach i in 4 14 20 24 {
reg riot_index bannee L.bannee bgeo if geo==`i', noconstant
mat beta`i'=e(b)
svmat beta`i'
 }
