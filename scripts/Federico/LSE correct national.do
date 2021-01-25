global dir "C:\Users\federico.donofrio\Documents\TOFLIT desktop\"
cd "$dir"
capture log using "`c(current_time)' `c(current_date)'"


 

***GRAIN TRADE******************************************************************
use "Données Stata/bdd courante.dta", clear

*** dummy importexport
gen importexport=0
replace importexport=1 if (export_import=="Export" | export_import=="Exports"| export_import=="Sortie")



*** deal with missing values and generate value_inclusive
generate value_inclusive=value
replace value_inclusive=value_unit*quantity if value_inclusive==. & value_unit!=.
drop if value_inclusive==.
drop if value_inclusive==0

encode customs_region, generate(geography) label(customs_region)

***Regions
generate region="KO"
replace region="NE" if customs_region=="Amiens" | customs_region=="Dunkerque"| customs_region=="Saint-Quentin" | customs_region=="Châlons" | customs_region=="Langres" | customs_region=="Flandre"  
replace region="N" if customs_region=="Caen" | customs_region=="Rouen" | customs_region=="Le Havre"
replace region="NW" if customs_region=="Rennes" | customs_region=="Lorient" | customs_region=="Nantes" | customs_region=="Saint-Malo"
replace region="SW" if customs_region=="La Rochelle" | customs_region=="Bordeaux" | customs_region=="Bayonne" 
replace region="S" if customs_region=="Marseille" | customs_region=="Toulon" | customs_region=="Narbonne" | customs_region=="Montpellier"
replace region="SE" if customs_region=="Grenoble" | customs_region=="Lyon" 
replace region="E" if customs_region=="Besancon" | customs_region=="Bourgogne"| customs_region=="Charleville"

*** isolate grains
**destring somehow

encode grains, generate(grains_num) 
 
*** corrections
*replace year=1741 if year==3
*replace year=1787 if year==. & source_type_encode==6
*replace year=1743 if year==. & source_type_encode==5
* geography 19= Marseille, local = 5
*replace geography=19 if geography==. & source_type_encode==5 & year==1765
*replace geography=52 if geography==.
drop if grains=="."
drop if grains_num==.
drop if source_type=="1792-first semestre"
drop if  year==1805.75 
drop if yearstr=="10 mars-31 décembre 1787" 
*GUILLAUME WHY?
*drop colonies
drop if source_type=="Local"  & year==1787
drop if source_type=="Local"  & year==1788
*Unify Resumé and O.G.
**drop Resumé 1787, 1789
drop if source_type=="Résumé"  & year==1787
drop if source_type=="Résumé"  & year==1788



*adjust 1749, 1751, 1777, 1789 and double accounting in order to keep only single values from series "Local" and "National toutes customs_regions partenaires manquants"
sort year importexport value_inclusive geography grains_num partner_grouping partner_simplification
quietly by year importexport value_inclusive geography grains_num partner_grouping partner_simplification:  gen dup = cond(_N==1,0,_n)
drop if dup>1 
clonevar source_type_grains=source_type
replace source_type_grains="National" if source_type=="Résumé"
replace source_type_grains="National" if source_type=="Tableau des quantités"
replace source_type_grains="National" if source_type=="Objet Général"
replace source_type_grains="National" if source_type=="National toutes customs_regions tous partenaires"
replace source_type_grains="National" if source_type=="National toutes customs_regions partenaires manquants"
replace source_type_grains="National" if source_type=="National toutes customs_regions partenaires manquants"
replace source_type_grains="National" if source_type=="National partenaires manquants"
replace source_type_grains="National" if source_type=="National partenaires Manquants"



drop if year==.

drop if source_type_grains!="Local" & source_type_grains!="National"

drop if grains=="Pas grain (0)"
drop if missing(grains)



****resonable method
egen panelid=group(partner_grouping grains year importexport), label
bys panelid source_type_grains: egen totalv=total(value_inclusive)
collapse (mean) totalv, by (panelid source_type_grains year importexport)
reshape wide totalv, i(source_type_grains year panelid) j(importexport)

reshape wide totalv0 totalv1, i(year panelid) j(source_type_grains) string
gen deltaimp= totalv0Local-totalv0National
gen deltaexp= totalv1Local-totalv1National
replace deltaexp=0 if deltaexp==.
replace deltaimp=0 if deltaimp==.
gen correctionimp=0
replace correctionimp=deltaimp if deltaimp>0
gen correctionexp=0
replace correctionexp=deltaexp if deltaexp>0

gen newimp=correctionimp+totalv0National
gen newexp=correctionexp+totalv1National

replace newimp=0 if newimp==. & newexp!=.
replace newexp=0 if newexp==. & newimp!=.

collapse (sum) newimp newexp, by(year)

twoway (line newimp year) (line newexp year)

save "C:\Users\federico.donofrio\Documents\TOFLIT desktop\Données Stata\belfast_natgtrade_corrected.dta", replace


***brutal method
collapse (sum) value_inclusive, by(importexport source_type_grains year)

reshape wide value_inclusive, i(source_type_grains year) j(importexport)

reshape wide value_inclusive0 value_inclusive1, i(year) j(source_type_grains) string

gen deltaimp= value_inclusive0Local-value_inclusive0National
gen deltaexp= value_inclusive1Local-value_inclusive1National
replace deltaexp=0 if deltaexp==.
replace deltaimp=0 if deltaimp==.
gen correctionimp=0
replace correctionimp=deltaimp if deltaimp>0
gen correctionexp=0
replace correctionexp=deltaexp if deltaexp>0

gen newimp=correctionimp+value_inclusive0National
gen newexp=correctionexp+value_inclusive1National

replace newimp=0 if newimp==. & newexp!=.
replace newexp=0 if newexp==. & newimp!=.


