use "C:\Users\federico.donofrio\Documents\TOFLIT desktop\importandexport_coefficients.dta" 
help reshape
drop bgeo1 
drop bgeo3 
drop bgeo5 bgeo6 bgeo7 bgeo8 bgeo10 bgeo11 bgeo12 bgeo13 
drop bgeo15 bgeo16 bgeo17 bgeo18 bgeo19 
drop bgeo21 
drop bgeo23 
drop bgeo25 bgeo26 bgeo27 bgeo28 
 reshape long bannee, i(bgeo2 bgeo4 bgeo14 bgeo20 bgeo22 bgeo24 bsource7 bconstant) j(year_sequence)
browse
save "C:\Users\federico.donofrio\Documents\TOFLIT desktop\Données Stata\beta.dta"
gen year=year_sequence+1749
browse year
browse
drop year_sequence
reshape long bgeo, i(year bannee bsource7 bconstant) j(geo)
xtset geo year
tsfill
gen geostring="city"
replace geostring="Bayonne" if geo==2
replace geostring="Bordeaux" if geo==4
replace geostring="La Rochelle" if geo==14
replace geostring="Marseille" if geo==20
replace geostring="Nantes" if geo==22
replace geostring="Rennes" if geo==24
save "C:\Users\federico.donofrio\Documents\TOFLIT desktop\Données Stata\beta_select_ready.dta"
