
use "~/Documents/Recherche/Commerce International Français XVIIIe.xls/Balance du commerce/Retranscriptions_Commerce_France/Données Stata/bdd courante.dta", clear
capture log close

log using "Log_stata_2019 07 11 TOFLIT18 _ simple_`c(current_date)'_`c(current_time)'", text

***** TOFLIT18 (Governance Analytics countribution)


*** (1)
*** strdist or ustrdist for Levenshtein distance

*1.1 marchandises vs simplification
ustrdist product product_simplification, g(goodsGA)
sum goodsGA
recode goodsGA (0 = .) if missing(product)
*(goodsGA: . changes made)
recode goodsGA (0/1000 = .) if missing(product_simplification)
*(goodsGA: 34 changes made)
kdensity goodsGA
graph box goodsGA
sum goodsGA, detail
foreach var of varlist goodsGA {
	capture drop Flag_`var'
	quietly summarize `var'    
	g Flag_`var'= (`var' > 4*r(sd)) if `var' < .      
	list `var' Flag_`var' if Flag_`var' == 1
}
tab Flag_goodsGA

** GD Calcule la distance des deux strings. Pas très intéressant dans la mesure où il s'agit parfois de simplifications faites exprès...
** What am I supposed to get from the graph and the list ?
** Why not do it from the list of goods ?
** du genre

preserve 
keep if Flag_goodsGA==1
bys product : keep if _n==1
br product product_simplification goodsGA Flag_goodsGA
gsort - goodsGA
br product product_simplification goodsGA Flag_goodsGA
restore

**On voit que le principal prédicteur de la distance orthographique est la longueur de la chaîne de caractère... Peut-être faire une mesure qui prenne cela en compte ?


*******************************************************

*1.2 marchandises vs orthographics
ustrdist product product_orthographic, g(goodsOrthGA)
sum goodsOrthGA
recode goodsOrthGA (0 = .) if missing(product) 
*(goodsOrthGA: . changes made)
recode goodsOrthGA (0/1000 = .) if missing(product_orthographic)
*(goodsOrthGA: 283 changes made)
kdensity goodsOrthGA
graph box goodsOrthGA
sum goodsOrthGA, detail
foreach var of varlist goodsOrthGA {    
   quietly summarize `var'    
   g Flag_`var'= (`var' > 4*r(sd)) if `var' < .      
   list `var' Flag_`var' if Flag_`var' == 1
}
tab Flag_goodsOrthGA


*1.3 partners vs grouping
ustrdist country_simplification country_grouping, g(countryGA)
sum countryGA
recode countryGA (0 = .) if missing(country_simplification)
*(countryGA: 2630 changes made)
recode countryGA (0 / 1000 = .) if missing(country_grouping)
* (countryGA: 0 changes made)
kdensity countryGA
graph box countryGA
sum countryGA, detail
foreach var of varlist countryGA {    
   quietly summarize `var'    
   g Flag_`var'= (`var' > 3*r(sd)) if `var' < .      
   list `var' Flag_`var' if Flag_`var' == 1
}
tab Flag_countryGA

*1.4 pays vs orthographics
ustrdist pays country_orthographic, g(countryOrthGA)
sum countryOrthGA
recode countryOrthGA (0 = .) if missing(pays)
*(countryOrthGA: 2594 changes made)
recode countryOrthGA (0/1000 = .) if missing(country_orthographic)
*(countryOrthGA: 0 changes made)
kdensity countryOrthGA
graph box countryOrthGA
sum countryOrthGA, detail
foreach var of varlist countryOrthGA {    
   quietly summarize `var'    
   g Flag_`var'= (`var' > 3*r(sd)) if `var' < .      
   list `var' Flag_`var' if Flag_`var' == 1
}
tab Flag_countryOrthGA

*1.5 quantity_unit vs orthographics
ustrdist quantity_unit quantity_unit_ortho, g(unitGA)
sum unitGA
recode unitGA (0 = .) if missing(quantity_unit)
*(unitGA: 0 changes made)
recode unitGA (0/1000 = .) if missing(quantity_unit_ortho)
*(unitGA: 524 changes made)
kdensity unitGA
graph box unitGA
sum unitGA, detail
foreach var of varlist unitGA {    
   quietly summarize `var'    
   g Flag_`var'= (`var' > 3*r(sd)) if `var' < .      
   list `var' Flag_`var' if Flag_`var' == 1
}
tab Flag_unitGA


*Bref, rien de tout cela est très utile, car la mesure de distance n'est pas pertinente.
***********************

*** (2)
*** Detecting outliers of observations
* dependant: 	 prix_unitaire value
* independent: year direction_id country_grouping_id exportsimports_id product_simplification_id quantity_unit_ortho_id

*Outliers by year categories
*"Peace 1716-1744" if year <= 1744
*"War 1745-1748" if year >= 1745 & year <=1748
*"Peace 1749-1755" if year >= 1749 & year <=1755
*"War 1756-1763" if year >= 1756 & year <=1763
*"Peace 1763-1777" if year >= 1763 & year <=1777
*"War 1778-1783" if year >= 1778 & year <=1783
*"Peace 1784-1792" if year >= 1784 & year <=1792
*"War 1793-1807" if year >= 1793 & year <=1807
*"Blockade 1808-1815" if year >= 1808 & year <=1815
*"Peace 1816-1840" if year >= 1816


*by country_grouping
* should be changed to numbers
sort country_grouping
egen country_grouping_id = group(country_grouping)
sum country_grouping_id
sort product_orthographic
egen product_orthographic_id = group(product_orthographic)
sum product_orthographic_id
sort direction
egen direction_id = group(direction)
sum direction_id
sum country_grouping_id
sort exportsimports
egen exportsimports_id = group(exportsimports)
sum exportsimports_id
sort product_simplification
egen product_simplification_id = group(product_simplification)
sum product_simplification_id
sort quantity_unit_ortho
egen quantity_unit_ortho_id = group(quantity_unit_ortho)
sum quantity_unit_ortho_id


*2.1                          Quantity

bacon q_conv year direction_id country_grouping_id exportsimports_id product_simplification_id if year <= 1744, generate(out_quantity_peace1744) percentile(0.01)
tab out_quantity_peace1744
bacon q_conv year direction_id country_grouping_id exportsimports_id product_simplification_id if year >= 1745 & year <=1748, generate(out_quantity_war1748) percentile(0.01)
tab out_quantity_war1748
bacon q_conv year direction_id country_grouping_id exportsimports_id product_simplification_id if year >= 1749 & year <=1755, generate(out_quantity_peace1755) percentile(0.01)
tab out_quantity_peace1755
bacon q_conv year direction_id country_grouping_id exportsimports_id product_simplification_id if year >= 1756 & year <=1763, generate(out_quantity_war1763) percentile(0.01)
tab out_quantity_war1763
bacon q_conv year direction_id country_grouping_id exportsimports_id product_simplification_id if year >= 1763 & year <=1777, generate(out_quantity_peace1777) percentile(0.01)
tab out_quantity_peace1777
bacon q_conv year direction_id country_grouping_id exportsimports_id product_simplification_id if year >= 1778 & year <=1783, generate(out_quantity_war1783) percentile(0.01)
tab out_quantity_war1783
bacon q_conv year direction_id country_grouping_id exportsimports_id product_simplification_id if year >= 1784 & year <=1792, generate(out_quantity_peace1792) percentile(0.01)
tab out_quantity_peace1792
bacon q_conv year direction_id country_grouping_id exportsimports_id product_simplification_id if year >= 1793 & year <=1807, generate(out_quantity_war1807) percentile(0.01)
tab out_quantity_war1807
bacon q_conv year direction_id country_grouping_id exportsimports_id product_simplification_id if year >= 1808 & year <=1815, generate(out_quantity_blockade1815) percentile(0.01)
tab out_quantity_blockade1815
bacon q_conv year direction_id country_grouping_id exportsimports_id product_simplification_id if year >= 1816 & year <=1748, generate(out_quantity_peace1840) percentile(0.01)
tab out_quantity_peace1840

*2.2                          Price

bacon prix_unitaire year direction_id country_grouping_id exportsimports_id product_simplification_id quantity_unit_ortho_id if year <= 1744, generate(out_prix_peace1744) percentile(0.01)
tab out_prix_peace1744
bacon prix_unitaire year direction_id country_grouping_id exportsimports_id product_simplification_id quantity_unit_ortho_id if year >= 1745 & year <=1748, generate(out_prix_war1748) percentile(0.01)
tab out_prix_war1748
bacon prix_unitaire year direction_id country_grouping_id exportsimports_id product_simplification_id quantity_unit_ortho_id if year >= 1749 & year <=1755, generate(out_prix_peace1755) percentile(0.01)
tab out_prix_peace1755
bacon prix_unitaire year direction_id country_grouping_id exportsimports_id product_simplification_id quantity_unit_ortho_id if year >= 1756 & year <=1763, generate(out_prix_war1763) percentile(0.01)
tab out_prix_war1763
bacon prix_unitaire year direction_id country_grouping_id exportsimports_id product_simplification_id quantity_unit_ortho_id if year >= 1763 & year <=1777, generate(out_prix_peace1777) percentile(0.01)
tab out_prix_peace1777
bacon prix_unitaire year direction_id country_grouping_id exportsimports_id product_simplification_id quantity_unit_ortho_id if year >= 1778 & year <=1783, generate(out_prix_war1783) percentile(0.01)
tab out_prix_war1783
bacon prix_unitaire year direction_id country_grouping_id exportsimports_id product_simplification_id quantity_unit_ortho_id if year >= 1784 & year <=1792, generate(out_prix_peace1792) percentile(0.01)
tab out_prix_peace1792
bacon prix_unitaire year direction_id country_grouping_id exportsimports_id product_simplification_id quantity_unit_ortho_id if year >= 1793 & year <=1807, generate(out_prix_war1807) percentile(0.01)
tab out_prix_war1807
bacon prix_unitaire year direction_id country_grouping_id exportsimports_id product_simplification_id quantity_unit_ortho_id if year >= 1808 & year <=1815, generate(out_prix_blockade1815) percentile(0.01)
tab out_prix_blockade1815
bacon prix_unitaire year direction_id country_grouping_id exportsimports_id product_simplification_id quantity_unit_ortho_id if year >= 1816 & year <=1748, generate(out_prix_peace1840) percentile(0.01)
tab out_prix_peace1840

*2.3                          Value

bacon value year direction_id country_grouping_id exportsimports_id product_simplification_id if year <= 1744, generate(out_value_peace1744) percentile(0.01)
tab out_value_peace1744
bacon value year direction_id country_grouping_id exportsimports_id product_simplification_id if year >= 1745 & year <=1748, generate(out_value_war1748) percentile(0.01)
tab out_value_war1748
bacon value year direction_id country_grouping_id exportsimports_id product_simplification_id if year >= 1749 & year <=1755, generate(out_value_peace1755) percentile(0.01)
tab out_value_peace1755
bacon value year direction_id country_grouping_id exportsimports_id product_simplification_id if year >= 1756 & year <=1763, generate(out_value_war1763) percentile(0.01)
tab out_value_war1763
bacon value year direction_id country_grouping_id exportsimports_id product_simplification_id if year >= 1763 & year <=1777, generate(out_value_peace1777) percentile(0.01)
tab out_value_peace1777
bacon value year direction_id country_grouping_id exportsimports_id product_simplification_id if year >= 1778 & year <=1783, generate(out_value_war1783) percentile(0.01)
tab out_value_war1783
bacon value year direction_id country_grouping_id exportsimports_id product_simplification_id if year >= 1784 & year <=1792, generate(out_value_peace1792) percentile(0.01)
tab out_value_peace1792
bacon value year direction_id country_grouping_id exportsimports_id product_simplification_id if year >= 1793 & year <=1807, generate(out_value_war1807) percentile(0.01)
tab out_value_war1807
bacon value year direction_id country_grouping_id exportsimports_id product_simplification_id if year >= 1808 & year <=1815, generate(out_value_blockade1815) percentile(0.01)
tab out_value_blockade1815
bacon value year direction_id country_grouping_id exportsimports_id product_simplification_id if year >= 1816 & year <=1748, generate(out_value_peace1840) percentile(0.01)
tab out_value_peace1840


*** EXAMPLE
*1) for the first specification of 2.1:
bacon q_conv year direction_id country_grouping_id exportsimports_id product_simplification_id if year <= 1744, generate(out_quantity_peace1744) percentile(0.01)
* outliers detection is saved under "out_quantity_peace1744" as a dummy variable equal to 1 if it is an outlier
br direction country_grouping product_simplification if out_quantity_peace1744==1
* above command shows several products with different origins and destination that are all outliers. We choose one of products "vin de ville" to compare it with similar products that are not selected as outlier:
br q_conv direction country_grouping out_quantity_peace1744 if product_simplification=="vin de ville" & year <= 1744
* above command shows list of "vin de ville". With the same "direction" some of them have been selected as outlier and some of them not. The same situation with "country_grouping". Two above commands show that for
* the first specification of 2.1, number of obsevations has been selected as outliers under name of "out_quantity_peace1744" with specific combination of direction, country_grouping and product name while for the
* similar variables of direction or pruduct or country_grouping there are observations that are not selected as an outlier even if they have some values equal to one of the observations that is an outlier. It shows
* a combination of feadures has been considered to determine if an observation is an outlier.
* However, in some cases the data is too limited by the product name frequency. In this case we can compare different product_names with the same direction instead of comparing same product_name with different directions:

*2) for example for the first specification of 2.2:
bacon prix_unitaire year direction_id country_grouping_id exportsimports_id product_simplification_id quantity_unit_ortho_id if year <= 1744, generate(out_prix_peace1744) percentile(0.01)
br prix_unitaire direction country_grouping product_simplification quantity_unit_ortho if out_prix_peace1744==1
* in this case frequency of each product is too low.
br prix_unitaire product_simplification out_prix_peace1744 if direction=="Bordeaux" & country_grouping=="Outre-mers" & year <= 1744
sort out_prix_peace1744
* in the above command 12 products have been selected as outliers over 5000 observation with the same direction and same country_grouping, within the same period of time.

* From this example we can see that explanatory variables have real effects on detection of dependent variable as an outlier. For example many observation with price of 800 has been and has not been detected as outliers:
* or with same origin  
br prix_unitaire direction exportsimports country_grouping quantity_unit_ortho out_prix_peace1744 if product_simplification=="coffres de chirurgie" & year <= 1744
br prix_unitaire direction exportsimports country_grouping quantity_unit_ortho out_prix_peace1744 product_simplification if year <= 1744
sort prix_unitaire

*3) same exmple from the first specification of 2.3:
bacon value year direction_id country_grouping_id exportsimports_id product_simplification_id if year <= 1744, generate(out_value_peace1744) percentile(0.01)
br direction country_grouping product_simplification if out_value_peace1744==1
br product_simplification out_value_peace1744 if direction=="Bordeaux" & country_grouping=="Outre-mers" & year <= 1744
sort out_value_peace1744

* In all example list above, a missing value of the outlier dummy means there was a missing of dependant variable. This is also an evidence that q_conv, prix_unitaire, and value are considered as the only dependents.

log close _all

