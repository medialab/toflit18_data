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
keep if grains!="Pas grain (0)"
keep if grains!="Substituts (4)"
keep if grains!="Grains transformés (5)"

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



*adjust 1749, 1751, 1777, 1789 and double accounting in order to keep only single values from series "Local" and "National toutes customs_regions partenaires manquants"
sort year importexport value_inclusive geography grains_num grouping_classification simplification_classification
quietly by year importexport value_inclusive geography grains_num grouping_classification simplification_classification:  gen dup = cond(_N==1,0,_n)
drop if dup>1 

**merge local and national par customs_regions series (Guillaume please check these lines!!!)
clonevar source_type_merged=source_type_encode 
replace source_type_merged=3 if source_type_merged==5
replace source_type_merged=3 if source_type_merged==6

*combine Resumé and Objet Général
replace source_type_merged=8 if source_type=="Résumé"
replace source_type_merged=8 if source_type=="Tableau de product"
replace source_type_merged=8 if source_type=="Tableau des quantités"

*drop local without customs_region (mainly colonies for 1789)
drop if  source_type_merged!=8 & geography==.
*force Objet général entries with a geography into Objet Général, assuming they are simply late coming data (CHECK THIS WITH GUILLAUME!)
replace geography=0 if source_type_merged==8

drop if year==.

* gen quantit_inclusive
gen quantit_inclusive=value_inclusive/value_unit
replace quantit_inclusive=quantity if quantit!=. & value_unit!=.
browse if quantit_inclusive!=quantity & quantit!=.
drop quantit
rename quantit_inclusive quantit
drop if quantit==.

** for each year geography product simplifiees compute average prix unitaire of a given measuring units and collapse
bys year geography simplification_classification quantity_unit_ortho: egen num= total(quantit*value_unit*!missing(quantit, value_unit)) 


bys year geography simplification_classification quantity_unit_ortho: egen den= total(quantit*!missing(quantit, value_unit)) 

gen avprix=num/den

collapse (mean) avprix, by (year geography simplification_classification quantity_unit_ortho)

replace quantity_unit_ortho="quartmesuredeblaye" if quantity_unit_ortho=="quartiers mesure de blaye"
replace quantity_unit_ortho="sacsde2800boi" if quantity_unit_ortho=="sacs de 2800 boisseaux"
replace quantity_unit_ortho="cartdupiedde480l" if quantity_unit_ortho=="cartier du pied de 480 livres"
replace quantity_unit_ortho="charge300l" if quantity_unit_ortho=="charge de 300 livres"
***reshape?
reshape wide @avprix , i(year geography simplification_classification) j(quantity_unit_ortho) string
*** for every year geography etc. compute ratio between different measuring units: how to? result is a matrix.
**generate ratios by line 
gen boisseauxtonneaux=tonneauxavprix/boisseauavprix
gen chargelivre=chargesavprix/livresavprix
gen cartdupiedl=cartdupiedde480lavprix/livresavprix
gen charge300livres=charge300lavprix/livresavprix
gen boisseaubarrique=barriquesavprix/boisseauavprix
gen sacsboisseau=sacsavprix/boisseauavprix
gen sacslivre=sacsavprix/livresavprix
gen laestlivres= laestavprix/livresavprix
gen lastlivres= lastavprix/livresavprix
gen lethslivres= lethsavprix/livresavprix
gen letslivres= letsavprix/livresavprix
gen letzlivres= letzavprix/livresavprix
gen laestboisseau= laestavprix/boisseauavprix
gen lastboisseau= lastavprix/boisseauavprix
gen lethsboisseau= lethsavprix/boisseauavprix
gen letsboisseau= letsavprix/boisseauavprix
gen letzboisseau= letzavprix/boisseauavprix
gen conqueslivres=conquesavprix/livresavprix
gen conquesboisseau=conquesavprix/boisseauavprix
gen quartierboisseau= quartiersavprix/boisseauavprix
gen quartiertonneau= tonneauxavprix/quartiersavprix
gen quartierlivres= quartiersavprix/livresavprix
gen septierlivre=setiersavprix/livresavprix
gen setierboisseau=setiersavprix/boisseauavprix
gen tonneausetier= tonneauxavprix/setiersavprix
gen boisseaulivre=boisseauavprix/livresavprix
gen tonneaulivre=tonneauxavprix/livresavprix

