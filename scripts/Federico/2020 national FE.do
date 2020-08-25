




if "`c(username)'" =="federico.donofrio" {
	import delimited "C:\Users\federico.donofrio\Documents\TOFLIT desktop\Données Stata\bdd courante.csv", varnames(1) encoding(UTF-8) 
	**GD20200710 Déjà, cela c’est assez suspect. Il faut exploiter le .zip qui est intégré dans le git, plutôt ? Tu peux unzipper depuis stata
	*avec la commande unzipfile
	save "C:\Users\federico.donofrio\Documents\TOFLIT desktop\Données Stata\bdd courante.dta", replace
	global dir "C:\Users\federico.donofrio\Documents\TOFLIT desktop\"
}

if "`c(username)'" =="guillaumedaudin" {
	global dir "~/Documents/Recherche/Commerce International Français XVIIIe.xls/Balance du commerce/Retranscriptions_Commerce_France"
}


clear
cd `"$dir"'
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


*** isolate grains
drop if product_grains=="Pas grain (0)"

encode product_grains, generate(grains_num) 
*

drop if product_grains=="."
drop if grains_num==.
drop if sourcetype=="1792-first semester"

*FOR SOME REASONS THIS DOES NOT WORK
*drop if  year==1787.2
drop if year>1787 & year<1788
*drop if yearstr=="10 mars-31 décembre 1787" 
*GUILLAUME WHY?
**GD20200710 Je ne sais pas. C’est bizarre...
drop if year>1805 & year <1806
*drop colonies
drop if sourcetype=="Local"  & year==1787
drop if sourcetype=="Local"  & year==1788

*Unify Resumé and O.G.
**drop Resumé 1788
drop if sourcetype=="Résumé"  & year==1788


*create national and local
gen natlocal=direction
replace natlocal="National" if sourcetype=="1792-both semester" | sourcetype=="Résumé" | sourcetype=="Tableau des quantités" | sourcetype=="Objet Général"
drop if natlocal=="[vide]"
*ID LOVE GUILLAUME TO VERIFY THIS: adjust 1749, 1751, 1777, 1789 and double accounting in order to keep only single values from series "Local" and "National toutes directions partenaires manquants"
sort year importexport natlocal value_inclusive grains_num country_grouping sourcetype  

**GD20200710 Il faut sans doute agréger si on a plusieurs flux pour une même catégorie de bien ? C’est ce que je fait ici

duplicates report year importexport natlocal sourcetype grains_num country_grouping

collapse (sum) value_inclusive, by(year importexport natlocal sourcetype grains_num country_grouping)

**GD20200710 Maintenant, on regardi s’il y a des flux en trop

duplicates report year importexport natlocal grains_num country_grouping
duplicates tag    year importexport natlocal grains_num country_grouping, generate(tag)
tab year tag
*GD20200710 Les soucis sont en 49, 50, 51 et 77 : je ne vois plus ceux de 89.
*GD20200710 On privilégie toujours "local"
keep if (tag==1 & sourcetype=="Local") | tag==0

/* GD20200710 Je pense que ce que tu faisais était très proche ?
quietly by year importexport natlocal value_inclusive grains_num country_grouping  :  gen dup = cond(_N==1,0,_n)
drop if sourcetype!="Local" & dup!=0 
*/

*GD20200710 J’aimerai bien créer les flux dont on sait qu’ils sont nuls...
fillin year importexport natlocal grains_num country_grouping

*Pour éliminer les rapporteurs qui ne sont pas là pour une année particulière
bys natlocal year : egen out_fillin = min (_fillin)
drop if out_fillin==1
drop out_fillin

*Pour éliminer les paires partenaires x rapporteurs x produits x importexport qui ne sont jamais là
bys natlocal country_grouping grains_num importexport : egen out_fillin = min (_fillin)
drop if out_fillin==1
drop out_fillin

*Pour éliminer les partenaires qui ne sont pas là certaines années ?
bys year  country_grouping : egen out_fillin = min (_fillin)
drop if out_fillin==1
drop out_fillin



**Pour identifier ceux dont on ne connait pas tous les partenaires
gen flag_partenaires_manquants = .
replace flag_partenaires_manquants =1 if sourcetype=="National toutes directions partenaires manquants"

bys year country_grouping natlocal : egen out_fillin=min(_fillin)
bys year country_grouping natlocal : egen out_partenaires_manquants=max(flag_partenaires_manquants)
drop if out_fillin==1 & out_partenaires_manquants ==1 
**Je suis surpris que cela ne conduisent pas à éliminer des flux ??

** et finalement
replace value_inclusive=0 if value_inclusive==.

**Je vérifie que tous ces zéros ont un sens
bys country_grouping natlocal importexport grains_num : egen max_value=max(value_inclusive)
assert max_value !=0

drop out_fillin max_value flag_partenaires_manquants tag

*GD20200710 Bien sûr, se pose la question de savoir quoi en faire si on prend le log des flux...





*create geography
encode natlocal, generate(geography) label(natlocal)

drop if year==.
drop if geography==.
***SOURCETYPE

encode sourcetype, generate(sourcetype_encode) label(sourcetype)

*
***collapse by year
collapse (sum) value_inclusive, by (year geography importexport)


***generate ln value
gen value_inclusive_c=value_inclusive+0.5
drop value_inclusive
rename value_inclusive_c value_inclusive
generate ln_value_inclusive=ln(value_inclusive)

***reshape import and export
reshape wide ln_value_inclusive value_inclusive, i(year geography) j(importexport)
rename value_inclusive1 export
rename value_inclusive0 import
rename ln_value_inclusive1 ln_export
rename ln_value_inclusive0 ln_import


*** now regress
 xi:  regress ln_import i.year i.geography   [iweight=import]
 *** now rectangularize (filling missing explanatory variables (year, geography))
fillin geography year 

*** predict and scatter national value of imports
*** it is very important to fill the missing values
xi i.year i.geography 
predict ln_import_predict
generate import_predict=exp(ln_import_predict)
*export
*** now regress
 xi:  regress ln_export i.year i.geography  [iweight=export]

*** predict and scatter national value of imports
*** it is very important to fill the missing values
xi i.year i.geography 
predict ln_export_predict
generate export_predict=exp(ln_export_predict)

drop _fillin _Iyear_1719 _Iyear_1720 _Iyear_1721 _Iyear_1722 _Iyear_1723 _Iyear_1724 _Iyear_1725 _Iyear_1726 _Iyear_1727 _Iyear_1728 _Iyear_1729 _Iyear_1730 _Iyear_1731 _Iyear_1732 _Iyear_1733 _Iyear_1734 _Iyear_1735 _Iyear_1736 _Iyear_1737 _Iyear_1738 _Iyear_1739 _Iyear_1740 _Iyear_1741 _Iyear_1742 _Iyear_1743 _Iyear_1744 _Iyear_1745 _Iyear_1746 _Iyear_1747 _Iyear_1748 _Iyear_1749 _Iyear_1750 _Iyear_1751 _Iyear_1752 _Iyear_1753 _Iyear_1754 _Iyear_1755 _Iyear_1756 _Iyear_1757 _Iyear_1758 _Iyear_1759 _Iyear_1760 _Iyear_1761 _Iyear_1762 _Iyear_1763 _Iyear_1764 _Iyear_1765 _Iyear_1766 _Iyear_1767 _Iyear_1768 _Iyear_1769 _Iyear_1770 _Iyear_1771 _Iyear_1772 _Iyear_1773 _Iyear_1774 _Iyear_1775 _Iyear_1776 _Iyear_1777 _Iyear_1778 _Iyear_1779 _Iyear_1780 _Iyear_1782 _Iyear_1787 _Iyear_1788 _Iyear_1789 _Iyear_1792 _Iyear_1797 _Iyear_1798 _Iyear_1799 _Iyear_1800 _Iyear_1801 _Iyear_1802 _Iyear_1803 _Iyear_1804 _Iyear_1805 _Iyear_1807 _Iyear_1808 _Iyear_1809 _Iyear_1810 _Iyear_1811 _Iyear_1812 _Iyear_1813 _Iyear_1814 _Iyear_1815 _Iyear_1816 _Iyear_1817 _Iyear_1818 _Iyear_1819 _Iyear_1820 _Iyear_1821 _Iyear_1822 _Iyear_1823 _Igeography_2 _Igeography_3 _Igeography_4 _Igeography_5 _Igeography_6 _Igeography_7 _Igeography_8 _Igeography_9 _Igeography_10 _Igeography_11 _Igeography_12 _Igeography_13 _Igeography_14 _Igeography_15 _Igeography_16 _Igeography_17 _Igeography_18 _Igeography_19 _Igeography_20 _Igeography_21 _Igeography_22 _Igeography_23 _Igeography_24 _Igeography_25 _Igeography_26 _Igeography_27 _Igeography_28 _Igeography_29 _Igeography_30
tab geography

keep if geography==23
drop geography
gen retrofitted_import=import_predict
replace retrofitted_import=import if import!=.
gen retrofitted_export=export_predict
replace retrofitted_export=export if export!=.
gen NX=retrofitted_export-retrofitted_import
tsset year
tsfill
* graph for geography == national

twoway (line retrofitted_import year , yaxis(1) ) (line retrofitted_export year , yaxis(1)) (line NX year, yaxis(2))

