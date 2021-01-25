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

*drop local without customs_region and strange things from the 1780s (mainly colonies for 1789)
***NATIONAL PARTNAIRES MANQUANTS IS IMPORTANT, IT S ALL WE HAVE FOR the 1780s. 
drop if  source_type_merged!=8 & geography==.
*force Objet général entries with a geography into Objet Général, assuming they are simply late coming data (CHECK THIS WITH GUILLAUME!)
replace geography=0 if source_type_merged==8

drop if year==.

** to reconstruct the series of values, I need to EGEN TOTAL of all different reported values by year, geography, type of grain and importexport dummy. 

bys year geography grains importexport : egen totalv=total(value_inclusive)

collapse(mean) totalv, by (year geography grains importexport)
***gen total of local series
bys year grains importexport: egen localtotal=total(totalv) if geography!=0
*** how much do the local series capture of the national one?
gen 
  



*charges et sacs
replace u_conv="kg" if quantity_unit_ortho=="charges"
replace q_conv=0.4895*243 if quantity_unit_ortho=="charges"
replace quantites_metric=quantit*q_conv if quantites_metric==.

gen unit_price_kg=0
replace unit_price_kg=value_inclusive/quantites_metric if u_conv=="kg"
replace unit_price_kg=. if unit_price_kg==0



**** CHECK FOR OUTLIERS
twoway (scatter unit_price_kg quantites_metric if grains=="Froment (1)"), by (geography)
twoway (line unit_price_kg quantites_metric year if grains=="Froment (1)"), by (geography)

***compute average price as yearly weighted average of unit_price_kg for each type of grain and each geography and each
bys year grains geography: egen num= total(quantites_metric*unit_price_kg*!missing(quantites_metric, unit_price_kg)) 
bys year grains geography: egen den= total(quantites_metric*!missing(quantites_metric, unit_price_kg)) 
gen wtpricekg=num/den

twoway (scatter unit_price_kg year if grains=="Froment (1)" & geography==20)(line wtpricekg year if grains=="Froment (1)"& geography==20)
bys year grains geography importexport: egen totalpkg=sum(value_inclusive)

*study quantities
bys year grains geography importexport: egen totalq=sum(quantites_metric) if  unit_price_kg!=.
gen quantitkg=totalpkg/wtpricekg
twoway (scatter totalq year if grains=="Froment (1)" & geography==20 & importexport==1)(line quantitkg year if grains=="Froment (1)"& geography==20 & importexport==1)(scatter totalq year if grains=="Froment (1)" & geography==20 & importexport==0)(line quantitkg year if grains=="Froment (1)"& geography==20 & importexport==0)

*** compute average price by q_unit
gen priceu=value_inclusive/quantit
bys year grains geography quantity_unit_ortho : egen numu= total(quantit*priceu*!missing(quantit, priceu))
bys year grains geography quantity_unit_ortho : egen demu= total(quantit*!missing(quantit, priceu))
gen avpriceu=numu/demu
twoway (scatter priceu year if grains=="Froment (1)" & geography==15 & quantity_unit_ortho=="tonneaux")(line avpriceu year if grains=="Froment (1)" & geography==15 & quantity_unit_ortho=="tonneaux")
twoway (scatter priceu year if grains=="Froment (1)" & geography==4 & quantity_unit_ortho=="boisseau")(line avpriceu year if grains=="Froment (1)" & geography==4 & quantity_unit_ortho=="boisseau")
***study local quantities
*Marseille based on kg is ok!!!
**Bordeaux based on the boisseau until 1773 and on the livre starting from 1765
gen qpriceu=totalpkg/avpriceu
browse qpriceu if geography==4 & grains_num==1 & quantity_unit_ortho=="boisseau" 
*this is the q of boisseaux in Bordeaux
twoway (line qpriceu year if grains=="Froment (1)" & geography==4 & quantity_unit_ortho=="boisseau" & importexport==0 & year!=1770)(line qpriceu year if grains=="Froment (1)" & geography==4 & quantity_unit_ortho=="livres" & importexport==0& year!=1770)
bys grains geography quantity_unit_ortho importexport: egen avqpriceu=mean(qpriceu)
bys grains geography quantity_unit_ortho importexport: egen sdpriceu=sd(qpriceu)
gen pcdevpriceu=sdpriceu/avqpriceu*100
collapse (mean) pcdevpriceu, by(grains geography quantity_unit_ortho importexport)

***total trade
bys year grains geography: egen totaltrade=sum(value_inclusive)
gen qtotaltrade=totaltrade/avpriceu
bys grains geography quantity_unit_ortho : egen avqu=mean(qtotaltrade)
bys grains geography quantity_unit_ortho : egen sdqu=sd(qtotaltrade)
gen pcdevu= sdqu/avqu*100
collapse (mean) pcdevu , by(grains geography quantity_unit_ortho)


*** compute local price indexes by year and then divide year variation by index for each locality
* generate ln_priceu
*gen lnpriceu=ln(priceu)

* regression to compute price index
** Bayonne
*xi: regress lnpriceu i.year i.quantity_unit_ortho i.importexport [iweight=value_inclusive] if geography==2 & grains=="Froment (1)"


** Bordeaux
*xi: regress lnpriceu i.year i.quantity_unit_ortho i.importexport [iweight=value_inclusive] if geography==4 & grains=="Froment (1)"

**La Rochelle

*xi: regress lnpriceu i.year i.quantity_unit_ortho i.importexport [iweight=value_inclusive] if geography==15 & grains=="Froment (1)"
**Marseille

*xi: regress lnpriceu i.year i.quantity_unit_ortho i.importexport [iweight=value_inclusive] if geography==20 & grains=="Froment (1)"
**Nantes

*xi: regress lnpriceu i.year i.quantity_unit_ortho i.importexport [iweight=value_inclusive] if geography==22 & grains=="Froment (1)"
**Rennes

*xi: regress lnpriceu i.year i.quantity_unit_ortho i.importexport [iweight=value_inclusive] if geography==24 & grains=="Froment (1)"

*save "C:\Users\federico.donofrio\Documents\TOFLIT desktop\Données Stata\average_prices.dta"
*merge m:1 year geography using "C:\Users\federico.donofrio\Documents\TOFLIT desktop\Données Stata\priceindex_variouscustoms_region.dta"

*compute BE coefficients of E(q) on var(prindex)
**gen var
*bys year grains geography : egen sdprindex=sd(prindex)
*gen varprindex=sdprindex^2

***gen E(q)
*bys year grains geography : egen totaltrade=sum(value_inclusive)
****ETC INCOMPLETE HERE: I should have calculated totaltrade/L.totaltrade and then divided it by prindex/L.prindex and the average the result...

*** compute q net export
*collapse(sum)quantites_metric, by (year grains geography importexport)
*reshape wide quantites_metric, i(year grains geography) j(importexport)
*replace quantites_metric0=0 if quantites_metric0==. & quantites_metric1!=.
*replace quantites_metric1=0 if quantites_metric1==. & quantites_metric0!=.

*bys year grains geography : gen qnetexport=quantites_metric0-quantites_metric1
**bys year grains geography: gen totexport=quantites_metric0+quantites_metric1
**bysort grains geography : egen sdprice = sd(price)
**gen price_var=sdprice^2
**twoway (line quantites_metric0 quantites_metric1 year if grains=="Froment (1)"  & geography== 4 | geography==20), by (geography)



