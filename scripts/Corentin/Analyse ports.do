***** NATIONAL
use "/Users/Corentin/Desktop/script/test.dta", clear

	keep if sourcetype == "Objet Général" | sourcetype == "Résumé"

	drop if sourcetype == "Résumé" & year == 1787 
	drop if sourcetype == "Résumé" & year == 1788
	drop if sourcetype == "Objet Général" & year > 1788
	drop if sourcetype == "Résumé" & year < 1787
	
	sort year
	collapse (sum) value, by(year)
	rename value totalN
save "/Users/Corentin/Desktop/script/test2.dta", replace

***** LOCAL
use "/Users/Corentin/Desktop/script/test.dta", clear


set more off
keep if sourcetype == "National par direction"  | sourcetype == "Local"

replace direction = "La_Rochelle" if direction == "La Rochelle"
replace direction = "Saint-Malo" if direction == "Saint Malo"
replace direction = "Saint_Malo" if direction == "Saint-Malo"
replace direction = "Passeport_du_roy" if direction == "Passeport du roy"
collapse (sum) value , by(year direction)


merge m:1 year using "/Users/Corentin/Desktop/script/test2.dta"
drop if _merge == 2
drop _merge

gen proportiondir = value / totalN * 100

keep if year == 1789

levelsof direction, local(levels)
	foreach l of local levels {
	gen `l' = .
	replace `l' = proportiondir if direction == "`l'"
    }

set obs 17
replace year = 1789 in 17
gen Autres = .	
egen temp = total(proportiondir)
replace Autres = (100 - temp) in 17
graph  pie Autres Amiens Bayonne Bordeaux Caen Charleville  Lille Lorient Marseille Montpellier Nantes Narbonne Passeport_du_roy Passeports  Rouen Saint_Malo Valenciennes, plabel(_all percent)
/*
graph twoway (connected proportiondir year if direction == "Caen"  )  (connected proportiondir year if direction == "Bordeaux"  ) (connected proportiondir year if direction == "Rouen"  ) (connected proportiondir year if direction == "Bayonne"  ) (connected proportiondir year if direction == "Nantes"  ), legend(label(1 "Caen") label(2 "Bordeaux") label(3 "Rouen") label(4 "Bayonne") label(5 "Nantes") )


********* only local
/*
levelsof direction, local(levels)
	foreach l of local levels {
	gen `l' = .
	replace `l' = value if direction == "`l'"
    }
keep if year == 1789

	foreach var of varlist Amiens Bayonne Bordeaux Caen La_Rochelle Lille Lorient Marseille Montpellier Nantes Passeports Rouen Saint_Malo Valenciennes Passeport_du_roy {
	tab `var', gen(z`var')
	}

graph  pie Amiens Bayonne Bordeaux Caen Charleville La_Rochelle Lille Lorient Marseille Montpellier Nantes Narbonne Passeport_du_roy Passeports Rennes Rouen Saint_Malo Valenciennes, plabel(_all percent)




