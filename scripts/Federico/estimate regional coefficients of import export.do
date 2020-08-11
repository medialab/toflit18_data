***version 14



global dir "C:\Users\federico.donofrio\Documents\TOFLIT desktop\"
cd "$dir"
capture log using "`c(current_time)' `c(current_date)'"

use "Données Stata/bdd courante.dta", clear

*** dummy importexport
gen importexport=0
replace importexport=1 if (export_import=="Export" | export_import=="Exports"| export_import=="Sortie")



*** deal with missing values and generate value_inclusive
generate value_inclusive=value
replace value_inclusive=value_unit*quantity if value_inclusive==. & value_unit!=.
drop if value_inclusive==.
drop if value_inclusive==0

encode tax_department, generate(geography) label(tax_department)

***Regions
generate region="KO"
replace region="NE" if tax_department=="Amiens" | tax_department=="Dunkerque"| tax_department=="Saint-Quentin" | tax_department=="Châlons" | tax_department=="Langres" | tax_department=="Flandre"  
replace region="N" if tax_department=="Caen" | tax_department=="Rouen" | tax_department=="Le Havre"
replace region="NW" if tax_department=="Rennes" | tax_department=="Lorient" | tax_department=="Nantes" | tax_department=="Saint-Malo"
replace region="SW" if tax_department=="La Rochelle" | tax_department=="Bordeaux" | tax_department=="Bayonne" 
replace region="S" if tax_department=="Marseille" | tax_department=="Toulon" | tax_department=="Narbonne" | tax_department=="Montpellier"
replace region="SE" if tax_department=="Grenoble" | tax_department=="Lyon" 
replace region="E" if tax_department=="Besancon" | tax_department=="Bourgogne"| tax_department=="Charleville"

*** isolate grains
**destring somehow

encode grains, generate(grains_num) 
keep if (grains!="Pas grain (0)")

***SOURCETYPE
encode source_type, generate(source_type_encode) label(source_type)

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



*adjust 1749, 1751, 1777, 1789 and double accounting in order to keep only single values from series "Local" and "National toutes tax_departments partenaires manquants"
sort year importexport value_inclusive geography grains_num grouping_classification simplification_classification partner
quietly by year importexport value_inclusive geography grains_num grouping_classification simplification_classification partner:  gen dup = cond(_N==1,0,_n)
drop if dup>1 

**merge local and national par tax_departments series (Guillaume please check these lines!!!)
clonevar source_type_merged=source_type_encode 
replace source_type_merged=3 if source_type_merged==5
replace source_type_merged=3 if source_type_merged==6

*combine Resumé and Objet Général
replace source_type_merged=7 if source_type=="Résumé"
replace source_type_merged=7 if source_type=="Tableau de product"
replace source_type_merged=7 if source_type=="Tableau des quantités"

*drop local without tax_department (mainly colonies for 1789)
drop if  source_type_merged!=7 & geography==.
*force Objet général entries with a geography into Objet Général, assuming they are simply late coming data (CHECK THIS WITH GUILLAUME!)
replace geography=0 if source_type_merged==7

drop if year==.


***collapse by year TO OBTAIN IMPORT+EXPORT
collapse (sum) value_inclusive, by (year geography source_type_merged)




***generate ln value
generate ln_value_inclusive=ln(value_inclusive)

***cut to period 1750-1789
drop if year<1749 | year>1789

*** now regress
 xi:  regress ln_value_inclusive i.year i.geography i.source_type_merged [iweight=value_inclusive]
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








