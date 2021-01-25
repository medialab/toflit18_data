
if "`c(username)'"=="guillaumedaudin" {
	global dir "~/Documents/Recherche/Commerce International Français XVIIIe.xls/Balance du commerce/Retranscriptions_Commerce_France/Données Stata"
}	
***** TOFLIT18 (Governance Analytics countribution)

set excelxlsxlargefile on
*"This simple command allows the user to bypass the pre-set limit on spreadsheet size"

use "$dir/bdd courante.dta", clear



*** (1)
*** strdist or ustrdist for Levenshtein distance
*** requires strdist.pkg to be installed : net install strdist.pkg


**** Bacon for discrepencies
**** net install st0197.pkg



* product vs simplification
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
   *Here, you can change the discrepency threshold
   list `var' Flag_`var' if Flag_`var' == 1
}
tab Flag_goodsGA

* product vs orthographics
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

* partner vs orthographics
ustrdist partner country_orthographic, g(countryOrthGA)
sum countryOrthGA
recode countryOrthGA (0 = .) if missing(partner)
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



*** (2)
*** Detecting outliers of observations
* dependant: quantites_metric value_unit value
* independent: year grouping_classification nbr_obs goods_ortho_classification customs_region


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
sort customs_region
egen customs_region_id = group(customs_region)
sum customs_region_id
sort country_grouping
egen country_grouping_id = group(country_grouping)
sum country_grouping_id
sort export_import
egen export_import_id = group(export_import)
sum export_import_id
sort product_simplification
egen product_simplification_id = group(product_simplification)
sum product_simplification_id
sort quantity_unit_ortho
egen quantity_unit_ortho_id = group(quantity_unit_ortho)
sum quantity_unit_ortho_id




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


*year customs_region_id country_grouping_id export_import_id product_simplification_id quantity_unit_ortho_id



*                          Quantity

bacon quantites_metric year customs_region_id country_grouping_id export_import_id product_simplification_id if year <= 1744, generate(out_quantity_peace1744) percentile(0.01)
tab out_quantity_peace1744
bacon quantites_metric year customs_region_id country_grouping_id export_import_id product_simplification_id if year >= 1745 & year <=1748, generate(out_quantity_war1748) percentile(0.01)
tab out_quantity_war1748
bacon quantites_metric year customs_region_id country_grouping_id export_import_id product_simplification_id if year >= 1749 & year <=1755, generate(out_quantity_peace1755) percentile(0.01)
tab out_quantity_peace1755
bacon quantites_metric year customs_region_id country_grouping_id export_import_id product_simplification_id if year >= 1756 & year <=1763, generate(out_quantity_war1763) percentile(0.01)
tab out_quantity_war1763
bacon quantites_metric year customs_region_id country_grouping_id export_import_id product_simplification_id if year >= 1763 & year <=1777, generate(out_quantity_peace1777) percentile(0.01)
tab out_quantity_peace1777
bacon quantites_metric year customs_region_id country_grouping_id export_import_id product_simplification_id if year >= 1778 & year <=1783 , generate(out_quantity_war1783) percentile(0.01)
tab out_quantity_war1783
bacon quantites_metric year customs_region_id country_grouping_id export_import_id product_simplification_id if year >= 1784 & year <=1792, generate(out_quantity_peace1792) percentile(0.01)
tab out_quantity_peace1792
bacon quantites_metric year customs_region_id country_grouping_id export_import_id product_simplification_id if year >= 1793 & year <=1807, generate(out_quantity_war1807) percentile(0.01)
tab out_quantity_war1807
bacon quantites_metric year customs_region_id country_grouping_id export_import_id product_simplification_id if year >= 1808 & year <=1815, generate(out_quantity_blockade1815) percentile(0.01)
tab out_quantity_blockade1815
bacon quantites_metric year customs_region_id country_grouping_id export_import_id product_simplification_id if year >= 1816 , generate(out_quantity_peace1840) percentile(0.01)
tab out_quantity_peace1840

*                          Price

bacon value_unit year customs_region_id country_grouping_id export_import_id product_simplification_id quantity_unit_ortho_id if year <= 1744, generate(out_prix_peace1744) percentile(0.01)
tab out_prix_peace1744
bacon value_unit year customs_region_id country_grouping_id export_import_id product_simplification_id quantity_unit_ortho_id if year >= 1745 & year <=1748, generate(out_prix_war1748) percentile(0.01)
tab out_prix_war1748
bacon value_unit year customs_region_id country_grouping_id export_import_id product_simplification_id quantity_unit_ortho_id if year >= 1749 & year <=1755, generate(out_prix_peace1755) percentile(0.01)
tab out_prix_peace1755
bacon value_unit year customs_region_id country_grouping_id export_import_id product_simplification_id quantity_unit_ortho_id if year >= 1756 & year <=1763, generate(out_prix_war1763) percentile(0.1)
tab out_prix_war1763
bacon value_unit year customs_region_id country_grouping_id export_import_id product_simplification_id quantity_unit_ortho_id if year >= 1763 & year <=1777, generate(out_prix_peace1777) percentile(0.01)
tab out_prix_peace1777
bacon value_unit year customs_region_id country_grouping_id export_import_id product_simplification_id quantity_unit_ortho_id if year >= 1778 & year <=1783, generate(out_prix_war1783) percentile(0.01)
tab out_prix_war1783
bacon value_unit year customs_region_id country_grouping_id export_import_id product_simplification_id quantity_unit_ortho_id if year >= 1784 & year <=1792, generate(out_prix_peace1792) percentile(0.01)
tab out_prix_peace1792
bacon value_unit year customs_region_id country_grouping_id export_import_id product_simplification_id quantity_unit_ortho_id if year >= 1793 & year <=1807, generate(out_prix_war1807) percentile(0.01)
tab out_prix_war1807
bacon value_unit year customs_region_id country_grouping_id export_import_id product_simplification_id quantity_unit_ortho_id if year >= 1808 & year <=1815, generate(out_prix_blockade1815) percentile(0.01)
tab out_prix_blockade1815
bacon value_unit year customs_region_id country_grouping_id export_import_id product_simplification_id quantity_unit_ortho_id if year >= 1816 , generate(out_prix_peace1840) percentile(0.01)
tab out_prix_peace1840

*                          Value

bacon value year customs_region_id country_grouping_id export_import_id product_simplification_id if year <= 1744, generate(out_value_peace1744) percentile(0.01)
tab out_value_peace1744
bacon value year customs_region_id country_grouping_id export_import_id product_simplification_id if year >= 1745 & year <=1748, generate(out_value_war1748) percentile(0.01)
tab out_value_war1748
bacon value year customs_region_id country_grouping_id export_import_id product_simplification_id if year >= 1749 & year <=1755, generate(out_value_peace1755) percentile(0.01)
tab out_value_peace1755
bacon value year customs_region_id country_grouping_id export_import_id product_simplification_id if year >= 1756 & year <=1763, generate(out_value_war1763) percentile(0.01)
tab out_value_war1763
bacon value year customs_region_id country_grouping_id export_import_id product_simplification_id if year >= 1763 & year <=1777, generate(out_value_peace1777) percentile(0.01)
tab out_value_peace1777
bacon value year customs_region_id country_grouping_id export_import_id product_simplification_id if year >= 1778 & year <=1783 , generate(out_value_war1783) percentile(0.01)
tab out_value_war1783
bacon value year customs_region_id country_grouping_id export_import_id product_simplification_id if year >= 1784 & year <=1792, generate(out_value_peace1792) percentile(0.01)
tab out_value_peace1792
bacon value year customs_region_id country_grouping_id export_import_id product_simplification_id if year >= 1793 & year <=1807 , generate(out_value_war1807) percentile(0.01)
tab out_value_war1807
bacon value year customs_region_id country_grouping_id export_import_id product_simplification_id if year >= 1808 & year <=1815, generate(out_value_blockade1815) percentile(0.01)
tab out_value_blockade1815
bacon value year customs_region_id country_grouping_id export_import_id product_simplification_id if year >= 1816, generate(out_value_peace1840) percentile(0.01)
tab out_value_peace1840



