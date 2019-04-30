import excel "C:\Users\federico.donofrio\Documents\wheat_prices_FRANCE(dbversion ).xlsx", firstrow clear
merge n:1 market using  "C:\Users\federico.donofrio\Documents\TOFLIT desktop\Données Stata\insee_codes.dta"
drop if _merge!=3
drop _merge
rename insee inseeCon
save "C:\Users\federico.donofrio\Documents\TOFLIT desktop\Données Stata\french_prices_insee.dta", replace
