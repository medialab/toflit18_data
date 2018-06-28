***version 14



global dir "C:\Users\federico.donofrio\Documents\TOFLIT desktop\"
cd "$dir"
capture log using "`c(current_time)' `c(current_date)'"

use "Données Stata/bdd courante.dta", clear

*** dummy importexport
gen importexport=0
replace importexport=1 if (exportsimports=="Export" | exportsimports=="Exports"| exportsimports=="Sortie")



*** deal with missing values and generate value_inclusive
generate value_inclusive=value
replace value_inclusive=prix_unitaire*quantit if value_inclusive==. & prix_unitaire!=.
drop if value_inclusive==.
drop if value_inclusive==0

encode direction, generate(geography) label(direction)

***Regions
generate region="KO"
replace region="NE" if direction=="Amiens" | direction=="Dunkerque"| direction=="Saint-Quentin" | direction=="Châlons" | direction=="Langres" | direction=="Flandre"  
replace region="N" if direction=="Caen" | direction=="Rouen" | direction=="Le Havre"
replace region="NW" if direction=="Rennes" | direction=="Lorient" | direction=="Nantes" | direction=="Saint-Malo"
replace region="SW" if direction=="La Rochelle" | direction=="Bordeaux" | direction=="Bayonne" 
replace region="S" if direction=="Marseille" | direction=="Toulon" | direction=="Narbonne" | direction=="Montpellier"
replace region="SE" if direction=="Grenoble" | direction=="Lyon" 
replace region="E" if direction=="Besancon" | direction=="Bourgogne"| direction=="Charleville"

*** isolate grains
**destring somehow

encode grains, generate(grains_num) 
keep if (grains!="Pas grain (0)")

***SOURCETYPE
encode sourcetype, generate(sourcetype_encode) label(sourcetype)

*** corrections
*replace year=1741 if year==3
*replace year=1787 if year==. & sourcetype_encode==6
*replace year=1743 if year==. & sourcetype_encode==5
* geography 19= Marseille, local = 5
*replace geography=19 if geography==. & sourcetype_encode==5 & year==1765
*replace geography=52 if geography==.
drop if grains=="."
drop if grains_num==.
drop if sourcetype=="1792-first semestre"
drop if  year==1805.75 
drop if yearstr=="10 mars-31 décembre 1787" 
*GUILLAUME WHY?
*drop colonies
drop if sourcetype=="Local"  & year==1787
drop if sourcetype=="Local"  & year==1788
*Unify Resumé and O.G.
**drop Resumé 1787, 1789
drop if sourcetype=="Résumé"  & year==1787
drop if sourcetype=="Résumé"  & year==1788



*adjust 1749, 1751, 1777, 1789 and double accounting in order to keep only single values from series "Local" and "National toutes directions partenaires manquants"
sort year importexport value_inclusive geography grains_num grouping_classification simplification_classification pays
quietly by year importexport value_inclusive geography grains_num grouping_classification simplification_classification pays:  gen dup = cond(_N==1,0,_n)
drop if dup>1 

**merge local and national par directions series (Guillaume please check these lines!!!)
clonevar sourcetype_merged=sourcetype_encode 
replace sourcetype_merged=3 if sourcetype_merged==5
replace sourcetype_merged=3 if sourcetype_merged==6

*combine Resumé and Objet Général
replace sourcetype_merged=7 if sourcetype=="Résumé"
replace sourcetype_merged=7 if sourcetype=="Tableau de marchandises"
replace sourcetype_merged=7 if sourcetype=="Tableau des quantités"

*drop local without direction (mainly colonies for 1789)
drop if  sourcetype_merged!=7 & geography==.
*force Objet général entries with a geography into Objet Général, assuming they are simply late coming data (CHECK THIS WITH GUILLAUME!)
replace geography=0 if sourcetype_merged==7

drop if year==.


***collapse by year TO OBTAIN IMPORT+EXPORT
collapse (sum) value_inclusive, by (year geography sourcetype_merged)




***generate ln value
generate ln_value_inclusive=ln(value_inclusive)

***cut to period 1750-1789
drop if year<1749 | year>1789

*** now regress
 xi:  regress ln_value_inclusive i.year i.geography i.sourcetype_merged [iweight=value_inclusive]
mat beta=e(b)
svmat beta


rename beta#  bannee#
rename (bannee36 bannee37 bannee38 bannee39 bannee40 bannee41 bannee42 bannee43 bannee44 bannee45 bannee46 bannee47 bannee48 bannee49 bannee50 bannee51 bannee52 bannee53 bannee54 bannee55 bannee56 bannee57 bannee58 bannee59 bannee60 bannee61 bannee62) bgeo#, addnumber

rename bannee35 bannee40
rename bannee34 bannee39
rename bannee33 bannee38
rename bannee32 bannee33

rename bannee63 bsource7
rename (bgeo9 bgeo10 bgeo11 bgeo12 bgeo13 bgeo14 bgeo15 bgeo16 bgeo17 bgeo18 bgeo19 bgeo20 bgeo21 bgeo22 bgeo23 bgeo24 bgeo25 bgeo26 bgeo27)(bgeo10 bgeo11 bgeo12 bgeo13 bgeo14 bgeo15 bgeo16 bgeo17 bgeo18 bgeo19 bgeo20 bgeo21 bgeo22 bgeo23 bgeo24 bgeo25 bgeo26 bgeo27 bgeo28)
rename bannee64 bconstant
keep bannee1 bannee2 bannee3 bannee4 bannee5 bannee6 bannee7 bannee8 bannee9 bannee10 bannee11 bannee12 bannee13 bannee14 bannee15 bannee16 bannee17 bannee18 bannee19 bannee20 bannee21 bannee22 bannee23 bannee24 bannee25 bannee26 bannee27 bannee28 bannee29 bannee30 bannee31 bannee33 bannee38 bannee39 bannee40 bgeo1 bgeo2 bgeo3 bgeo4 bgeo5 bgeo6 bgeo7 bgeo8 bgeo10 bgeo11 bgeo12 bgeo13 bgeo14 bgeo15 bgeo16 bgeo17 bgeo18 bgeo19 bgeo20 bgeo21 bgeo22 bgeo23 bgeo24 bgeo25 bgeo26 bgeo27 bgeo28 bsource7 bconstant
drop if bannee1==.
save "importandexport_coefficients.dta", replace








