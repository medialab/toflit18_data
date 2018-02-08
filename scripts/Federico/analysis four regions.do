 use "C:\Users\federico.donofrio\Documents\TOFLIT desktop\Données Stata\population_riots.dta", clear
*calculate index riots/pop
gen riot_index=riots/population_ipo
gen geography=0
*"Bayonne"
replace geography=2 if generalites_encode==3
*"Bordeaux"
replace geography=4 if generalites_encode==6
*"La Rochelle"
replace geography=15 if generalites_encode==14
*"Marseille"
replace geography=20 if generalites_encode==17
*"Nantes" pour Bretagne (drop Rennes because smaller and less data)
replace geography=22 if generalites_encode==27

drop if geography==0

merge 1:1 geography year using "C:\Users\federico.donofrio\Documents\TOFLIT desktop\importandexport_fourdirections.dta" 
drop if _merge!=3
drop _merge
xtset geography year
*create 0 where import or export missing because that's probably the real figure
replace import=0 if import==. & export!=.
replace export=0 if export==. & import!=.
*expand
tsfill
**generate net import, yearly variation
generate netimport=import-export
xtset geography year
generate variation=netimport-L.netimport
generate variation_percent=variation*100/abs(L.netimport)
generate total_trade=import+export
xtset geography year


twoway bar riots year , yaxis(1) yscale(range(0 20) axis(1))|| line netimport year, yaxis(2) yscale(range(0) axis(2)) by(geography)
twoway bar riots year , yaxis(1) yscale(range(0 20) axis(1))|| line variation_percent year, yaxis(2) yscale(range(0) axis(2)) by(geography)
twoway bar riots year , yaxis(1) yscale(range(0 20) axis(1))|| line export year, yaxis(2) yscale(range(0) axis(2)) by(geography)
twoway bar riots year , yaxis(1) yscale(range(0 20) axis(1))|| line import year, yaxis(2) yscale(range(0) axis(2)) by(geography)
bysort geography : pwcorr riots import export L.export L.import F.netimport F.variation netimport variation variation_percent, print(0.5) star(0.5) obs

bysort geography: egen mean_netimport=mean(netimport)
bysort geography: egen sd_netimport=sd(netimport)
generate var_netimport=sd_netimport^2
xtset geography year

xtreg riots mean_netimport variation_percent, be

*Marseille
drop if geography!=20
save "importandexport_Marseille.dta", replace
*Bordeaux
drop if geography!=20
save "importandexport_Bordeaux.dta", replace
