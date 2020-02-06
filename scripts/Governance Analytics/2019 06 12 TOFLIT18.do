

***** TOFLIT18 (Governance Analytics countribution)

set excelxlsxlargefile on


*** (1)
*** strdist or ustrdist for Levenshtein distance

* marchandises vs simplification
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
   quietly summarize `var'    
   g Flag_`var'= (`var' > 4*r(sd)) if `var' < .      
   list `var' Flag_`var' if Flag_`var' == 1
}
tab Flag_goodsGA

* marchandises vs orthographics
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


* partners vs grouping
ustrdist partners_simpl_classificationifi grouping_classification, g(countryGA)
sum countryGA
recode countryGA (0 = .) if missing(partners_simpl_classificationifi)
*(countryGA: 2630 changes made)
recode countryGA (0 / 1000 = .) if missing(grouping_classification)
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

* pays vs orthographics
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

* quantity_unit vs orthographics
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

*** Check for one to many changes
sort marchandises
by marchandises: egen 
bysort marchandises goodsGA: gen goodsChange = _n

*** (2)
*** Detecting outliers of observations
* dependant: quantites_metric prix_unitaire value
* independent: year grouping_classification nbr_obs goods_ortho_classification direction


*correction in nbr_obs
gen nbr_obs_new = nbr_obs
recode nbr_obs_new ( 4722 = .)
graph box nbr_obs_new, over(year)

*by grouping_classification
* should be changed to numbers
sort grouping_classification
egen grouping_classification_id = group(grouping_classification)
sum grouping_classification_id
sort goods_ortho_classification
egen goods_ortho_classification_id = group(goods_ortho_classification)
sum goods_ortho_classification_id
sort direction
egen direction_id = group(direction)
sum direction_id
sort country_grouping
egen country_grouping_id = group(country_grouping)
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


*                          Quantity
*year
bacon quantites_metric year, generate(out_quantites_year) percentile(0.0001)
tab out_quantites_year
scatter quantites_metric year, ml(out_quantites_year) ms(i) note("0 = nonoutlier, 1 = outlier")
*partner country
bacon quantites_metric grouping_classification_id, generate(out_quantites_partner) percentile(0.0001)
tab out_quantites_partner
scatter quantites_metric grouping_classification_id, ml(out_quantites_partner) ms(i) note("0 = nonoutlier, 1 = outlier")
* origin country
bacon quantites_metric direction_id, generate(out_quantites_direction) percentile(0.001)
tab out_quantites_direction
scatter quantites_metric direction_id, ml(out_quantites_direction) ms(i) note("0 = nonoutlier, 1 = outlier")
*observation
bacon quantites_metric nbr_obs_new, generate(out_quantites_obs) percentile(0.0001)
tab out_quantites_obs
scatter quantites_metric nbr_obs_new, ml(out_quantites_obs) ms(i) note("0 = nonoutlier, 1 = outlier")
*goods
bacon quantites_metric goods_ortho_classification_id, generate(out_quantites_goods) percentile(0.001)
tab out_quantites_goods
scatter quantites_metric goods_ortho_classification_id, ml(out_quantites_goods) ms(i) note("0 = nonoutlier, 1 = outlier")
*all
bacon quantites_metric year grouping_classification_id direction_id nbr_obs_new goods_ortho_classification_id, generate(out_quantites_all) percentile(0.001)
tab out_quantites_all
scatter quantites_metric year, ml(out_quantites_all) ms(i) note("0 = nonoutlier, 1 = outlier")


*                          Price
*year
bacon prix_unitaire year, generate(out_prix_year) percentile(0.0001)
tab out_prix_year
scatter prix_unitaire year, ml(out_prix_year) ms(i) note("0 = nonoutlier, 1 = outlier")
*partner country
bacon prix_unitaire grouping_classification_id, generate(out_prix_partner) percentile(0.0001)
tab out_prix_partner
scatter prix_unitaire grouping_classification_id, ml(out_prix_partner) ms(i) note("0 = nonoutlier, 1 = outlier")
* origin country
bacon prix_unitaire direction_id, generate(out_prix_direction) percentile(0.001)
tab out_prix_direction
scatter prix_unitaire direction_id, ml(out_prix_direction) ms(i) note("0 = nonoutlier, 1 = outlier")
*observation
bacon prix_unitaire nbr_obs_new, generate(out_prix_obs) percentile(0.0001)
tab out_prix_obs
scatter prix_unitaire nbr_obs_new, ml(out_prix_obs) ms(i) note("0 = nonoutlier, 1 = outlier")
*goods
bacon prix_unitaire goods_ortho_classification_id, generate(out_prix_goods) percentile(0.001)
tab out_prix_goods
scatter prix_unitaire goods_ortho_classification_id, ml(out_prix_goods) ms(i) note("0 = nonoutlier, 1 = outlier")
*all
bacon prix_unitaire year grouping_classification_id direction_id nbr_obs_new goods_ortho_classification_id, generate(out_prix_all) percentile(0.01)
tab out_prix_all
scatter prix_unitaire year, ml(out_prix_all) ms(i) note("0 = nonoutlier, 1 = outlier")

*                          Value
*year
bacon value year, generate(out_value_year) percentile(0.0001)
tab out_value_year
scatter value year, ml(out_value_year) ms(i) note("0 = nonoutlier, 1 = outlier")
*partner country
bacon value grouping_classification_id, generate(out_value_partner) percentile(0.0001)
tab out_value_partner
scatter value grouping_classification_id, ml(out_value_partner) ms(i) note("0 = nonoutlier, 1 = outlier")
* origin country
bacon value direction_id, generate(out_value_direction) percentile(0.001)
tab out_value_direction
scatter value direction_id, ml(out_value_direction) ms(i) note("0 = nonoutlier, 1 = outlier")
*observation
bacon value nbr_obs_new, generate(out_value_obs) percentile(0.0001)
tab out_value_obs
scatter value nbr_obs_new, ml(out_value_obs) ms(i) note("0 = nonoutlier, 1 = outlier")
*goods
bacon value goods_ortho_classification_id, generate(out_value_goods) percentile(0.001)
tab out_value_goods
scatter value goods_ortho_classification_id, ml(out_value_goods) ms(i) note("0 = nonoutlier, 1 = outlier")
*all
bacon value year grouping_classification_id direction_id nbr_obs_new goods_ortho_classification_id, generate(out_value_all) percentile(0.01)
tab out_value_all
scatter value year, ml(out_value_all) ms(i) note("0 = nonoutlier, 1 = outlier")


*** (3)
* second round of outlier detection by request

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


*                          Quantity

bacon quantites_metric year grouping_classification_id direction_id nbr_obs_new goods_ortho_classification_id if year <= 1744, generate(out_quantity_peace1744) percentile(0.01)
tab out_quantity_peace1744
bacon quantites_metric year grouping_classification_id direction_id nbr_obs_new goods_ortho_classification_id if year >= 1745 & year <=1748 <= 1748, generate(out_quantity_war1748) percentile(0.01)
tab out_quantity_war1748
bacon quantites_metric year grouping_classification_id direction_id nbr_obs_new goods_ortho_classification_id if year >= 1749 & year <=1755, generate(out_quantity_peace1755) percentile(0.01)
tab out_quantity_peace1755
bacon quantites_metric year grouping_classification_id direction_id nbr_obs_new goods_ortho_classification_id if year >= 1756 & year <=1763, generate(out_quantity_war1763) percentile(0.01)
tab out_quantity_war1763
bacon quantites_metric year grouping_classification_id direction_id nbr_obs_new goods_ortho_classification_id if year >= 1763 & year <=1777, generate(out_quantity_peace1777) percentile(0.01)
tab out_quantity_peace1777
bacon quantites_metric year grouping_classification_id direction_id nbr_obs_new goods_ortho_classification_id if year >= 1778 & year <=1783 & year <=1748 <= 1748, generate(out_quantity_war1783) percentile(0.01)
tab out_quantity_war1783
bacon quantites_metric year grouping_classification_id direction_id nbr_obs_new goods_ortho_classification_id if year >= 1784 & year <=1792, generate(out_quantity_peace1792) percentile(0.01)
tab out_quantity_peace1792
bacon quantites_metric year grouping_classification_id direction_id nbr_obs_new goods_ortho_classification_id if year >= 1793 & year <=1807 & year <=1748 <= 1748, generate(out_quantity_war1807) percentile(0.01)
tab out_quantity_war1807
bacon quantites_metric year grouping_classification_id direction_id nbr_obs_new goods_ortho_classification_id if year >= 1808 & year <=1815, generate(out_quantity_blockade1815) percentile(0.01)
tab out_quantity_blockade1815
bacon quantites_metric year grouping_classification_id direction_id nbr_obs_new goods_ortho_classification_id if year >= 1816 & year <=1748 <= 1748, generate(out_quantity_peace1840) percentile(0.01)
tab out_quantity_peace1840

*                          Price

bacon prix_unitaire year grouping_classification_id direction_id nbr_obs_new goods_ortho_classification_id if year <= 1744, generate(out_prix_peace1744) percentile(0.01)
tab out_prix_peace1744
bacon prix_unitaire year grouping_classification_id direction_id nbr_obs_new goods_ortho_classification_id if year >= 1745 & year <=1748 <= 1748, generate(out_prix_war1748) percentile(0.01)
tab out_prix_war1748
bacon prix_unitaire year grouping_classification_id direction_id nbr_obs_new goods_ortho_classification_id if year >= 1749 & year <=1755, generate(out_prix_peace1755) percentile(0.01)
tab out_prix_peace1755
bacon prix_unitaire year grouping_classification_id direction_id nbr_obs_new goods_ortho_classification_id if year >= 1756 & year <=1763, generate(out_prix_war1763) percentile(0.01)
tab out_prix_war1763
bacon prix_unitaire year grouping_classification_id direction_id nbr_obs_new goods_ortho_classification_id if year >= 1763 & year <=1777, generate(out_prix_peace1777) percentile(0.01)
tab out_prix_peace1777
bacon prix_unitaire year grouping_classification_id direction_id nbr_obs_new goods_ortho_classification_id if year >= 1778 & year <=1783 & year <=1748 <= 1748, generate(out_prix_war1783) percentile(0.01)
tab out_prix_war1783
bacon prix_unitaire year grouping_classification_id direction_id nbr_obs_new goods_ortho_classification_id if year >= 1784 & year <=1792, generate(out_prix_peace1792) percentile(0.01)
tab out_prix_peace1792
bacon prix_unitaire year grouping_classification_id direction_id nbr_obs_new goods_ortho_classification_id if year >= 1793 & year <=1807 & year <=1748 <= 1748, generate(out_prix_war1807) percentile(0.01)
tab out_prix_war1807
bacon prix_unitaire year grouping_classification_id direction_id nbr_obs_new goods_ortho_classification_id if year >= 1808 & year <=1815, generate(out_prix_blockade1815) percentile(0.01)
tab out_prix_blockade1815
bacon prix_unitaire year grouping_classification_id direction_id nbr_obs_new goods_ortho_classification_id if year >= 1816 & year <=1748 <= 1748, generate(out_prix_peace1840) percentile(0.01)
tab out_prix_peace1840

*                          Value

bacon value year grouping_classification_id direction_id nbr_obs_new goods_ortho_classification_id if year <= 1744, generate(out_value_peace1744) percentile(0.01)
tab out_value_peace1744
bacon value year grouping_classification_id direction_id nbr_obs_new goods_ortho_classification_id if year >= 1745 & year <=1748 <= 1748, generate(out_value_war1748) percentile(0.01)
tab out_value_war1748
bacon value year grouping_classification_id direction_id nbr_obs_new goods_ortho_classification_id if year >= 1749 & year <=1755, generate(out_value_peace1755) percentile(0.01)
tab out_value_peace1755
bacon value year grouping_classification_id direction_id nbr_obs_new goods_ortho_classification_id if year >= 1756 & year <=1763, generate(out_value_war1763) percentile(0.01)
tab out_value_war1763
bacon value year grouping_classification_id direction_id nbr_obs_new goods_ortho_classification_id if year >= 1763 & year <=1777, generate(out_value_peace1777) percentile(0.01)
tab out_value_peace1777
bacon value year grouping_classification_id direction_id nbr_obs_new goods_ortho_classification_id if year >= 1778 & year <=1783 & year <=1748 <= 1748, generate(out_value_war1783) percentile(0.01)
tab out_value_war1783
bacon value year grouping_classification_id direction_id nbr_obs_new goods_ortho_classification_id if year >= 1784 & year <=1792, generate(out_value_peace1792) percentile(0.01)
tab out_value_peace1792
bacon value year grouping_classification_id direction_id nbr_obs_new goods_ortho_classification_id if year >= 1793 & year <=1807 & year <=1748 <= 1748, generate(out_value_war1807) percentile(0.01)
tab out_value_war1807
bacon value year grouping_classification_id direction_id nbr_obs_new goods_ortho_classification_id if year >= 1808 & year <=1815, generate(out_value_blockade1815) percentile(0.01)
tab out_value_blockade1815
bacon value year grouping_classification_id direction_id nbr_obs_new goods_ortho_classification_id if year >= 1816 & year <=1748 <= 1748, generate(out_value_peace1840) percentile(0.01)
tab out_value_peace1840


*** (3)
* Third round of outlier detection by request
*year direction_id country_grouping_id exportsimports_id product_simplification_id quantity_unit_ortho_id



*                          Quantity

bacon quantites_metric year direction_id country_grouping_id exportsimports_id product_simplification_id if year <= 1744, generate(out_quantity_peace1744) percentile(0.01)
tab out_quantity_peace1744
bacon quantites_metric year direction_id country_grouping_id exportsimports_id product_simplification_id if year >= 1745 & year <=1748 <= 1748, generate(out_quantity_war1748) percentile(0.01)
tab out_quantity_war1748
bacon quantites_metric year direction_id country_grouping_id exportsimports_id product_simplification_id if year >= 1749 & year <=1755, generate(out_quantity_peace1755) percentile(0.01)
tab out_quantity_peace1755
bacon quantites_metric year direction_id country_grouping_id exportsimports_id product_simplification_id if year >= 1756 & year <=1763, generate(out_quantity_war1763) percentile(0.01)
tab out_quantity_war1763
bacon quantites_metric year direction_id country_grouping_id exportsimports_id product_simplification_id if year >= 1763 & year <=1777, generate(out_quantity_peace1777) percentile(0.01)
tab out_quantity_peace1777
bacon quantites_metric year direction_id country_grouping_id exportsimports_id product_simplification_id if year >= 1778 & year <=1783 & year <=1748 <= 1748, generate(out_quantity_war1783) percentile(0.01)
tab out_quantity_war1783
bacon quantites_metric year direction_id country_grouping_id exportsimports_id product_simplification_id if year >= 1784 & year <=1792, generate(out_quantity_peace1792) percentile(0.01)
tab out_quantity_peace1792
bacon quantites_metric year direction_id country_grouping_id exportsimports_id product_simplification_id if year >= 1793 & year <=1807 & year <=1748 <= 1748, generate(out_quantity_war1807) percentile(0.01)
tab out_quantity_war1807
bacon quantites_metric year direction_id country_grouping_id exportsimports_id product_simplification_id if year >= 1808 & year <=1815, generate(out_quantity_blockade1815) percentile(0.01)
tab out_quantity_blockade1815
bacon quantites_metric year direction_id country_grouping_id exportsimports_id product_simplification_id if year >= 1816 & year <=1748 <= 1748, generate(out_quantity_peace1840) percentile(0.01)
tab out_quantity_peace1840

*                          Price

bacon prix_unitaire year direction_id country_grouping_id exportsimports_id product_simplification_id quantity_unit_ortho_id if year <= 1744, generate(out_prix_peace1744) percentile(0.01)
tab out_prix_peace1744
bacon prix_unitaire year direction_id country_grouping_id exportsimports_id product_simplification_id quantity_unit_ortho_id if year >= 1745 & year <=1748 <= 1748, generate(out_prix_war1748) percentile(0.01)
tab out_prix_war1748
bacon prix_unitaire year direction_id country_grouping_id exportsimports_id product_simplification_id quantity_unit_ortho_id if year >= 1749 & year <=1755, generate(out_prix_peace1755) percentile(0.01)
tab out_prix_peace1755
bacon prix_unitaire year direction_id country_grouping_id exportsimports_id product_simplification_id quantity_unit_ortho_id if year >= 1756 & year <=1763, generate(out_prix_war1763) percentile(0.01)
tab out_prix_war1763
bacon prix_unitaire year direction_id country_grouping_id exportsimports_id product_simplification_id quantity_unit_ortho_id if year >= 1763 & year <=1777, generate(out_prix_peace1777) percentile(0.01)
tab out_prix_peace1777
bacon prix_unitaire year direction_id country_grouping_id exportsimports_id product_simplification_id quantity_unit_ortho_id if year >= 1778 & year <=1783 & year <=1748 <= 1748, generate(out_prix_war1783) percentile(0.01)
tab out_prix_war1783
bacon prix_unitaire year direction_id country_grouping_id exportsimports_id product_simplification_id quantity_unit_ortho_id if year >= 1784 & year <=1792, generate(out_prix_peace1792) percentile(0.01)
tab out_prix_peace1792
bacon prix_unitaire year direction_id country_grouping_id exportsimports_id product_simplification_id quantity_unit_ortho_id if year >= 1793 & year <=1807 & year <=1748 <= 1748, generate(out_prix_war1807) percentile(0.01)
tab out_prix_war1807
bacon prix_unitaire year direction_id country_grouping_id exportsimports_id product_simplification_id quantity_unit_ortho_id if year >= 1808 & year <=1815, generate(out_prix_blockade1815) percentile(0.01)
tab out_prix_blockade1815
bacon prix_unitaire year direction_id country_grouping_id exportsimports_id product_simplification_id quantity_unit_ortho_id if year >= 1816 & year <=1748 <= 1748, generate(out_prix_peace1840) percentile(0.01)
tab out_prix_peace1840

*                          Value

bacon value year direction_id country_grouping_id exportsimports_id product_simplification_id if year <= 1744, generate(out_value_peace1744) percentile(0.01)
tab out_value_peace1744
bacon value year direction_id country_grouping_id exportsimports_id product_simplification_id if year >= 1745 & year <=1748 <= 1748, generate(out_value_war1748) percentile(0.01)
tab out_value_war1748
bacon value year direction_id country_grouping_id exportsimports_id product_simplification_id if year >= 1749 & year <=1755, generate(out_value_peace1755) percentile(0.01)
tab out_value_peace1755
bacon value year direction_id country_grouping_id exportsimports_id product_simplification_id if year >= 1756 & year <=1763, generate(out_value_war1763) percentile(0.01)
tab out_value_war1763
bacon value year direction_id country_grouping_id exportsimports_id product_simplification_id if year >= 1763 & year <=1777, generate(out_value_peace1777) percentile(0.01)
tab out_value_peace1777
bacon value year direction_id country_grouping_id exportsimports_id product_simplification_id if year >= 1778 & year <=1783 & year <=1748 <= 1748, generate(out_value_war1783) percentile(0.01)
tab out_value_war1783
bacon value year direction_id country_grouping_id exportsimports_id product_simplification_id if year >= 1784 & year <=1792, generate(out_value_peace1792) percentile(0.01)
tab out_value_peace1792
bacon value year direction_id country_grouping_id exportsimports_id product_simplification_id if year >= 1793 & year <=1807 & year <=1748 <= 1748, generate(out_value_war1807) percentile(0.01)
tab out_value_war1807
bacon value year direction_id country_grouping_id exportsimports_id product_simplification_id if year >= 1808 & year <=1815, generate(out_value_blockade1815) percentile(0.01)
tab out_value_blockade1815
bacon value year direction_id country_grouping_id exportsimports_id product_simplification_id if year >= 1816 & year <=1748 <= 1748, generate(out_value_peace1840) percentile(0.01)
tab out_value_peace1840




* Other ways of detection

foreach var of varlist nbr_obs_new {    
   quietly summarize `var'    
   g Out_`var'= (`var' > 3*r(sd)) if `var' < .      
   list `var' Flag_`var' if Flag_`var' == 1
}
tab Out_nbr_obs_new


foreach y of varlist year {
  foreach c of varlist grouping_classification {
    foreach var of varlist nbr_obs_new {    
     quietly summarize `var' if grouping_classification==`c' & year==`y'
     g Out_`var'= (`var' > 3*r(sd)) if `var' < .      
     list `var' Out_`var' if Out_`var' == 1
    }
  }
}
tab Out_nbr_obs_new

hadimvo quantites_metric year, generate(out_quantites_GA) p(0.0001)

twoway lfit nbr_obs year
twoway qfit nbr_obs year
twoway lfitci nbr_obs year
twoway qfitci nbr_obs year
graph twoway (lfit nbr_obs year) (scatter nbr_obs year)
graph twoway (lfit nbr_obs year) (box nbr_obs year)
