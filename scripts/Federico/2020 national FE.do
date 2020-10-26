




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
/*À faire pour récupérer les données
unzipfile "toflit18_data_GIT/base/bdd courante.csv.zip", replace
insheet using "toflit18_data_GIT/base/bdd courante.csv", clear
save "Données Stata/bdd courante.dta", replace
*/

use "Données Stata/bdd courante.dta", clear


codebook product_grains


*** dummy importexport
gen importexport=0
replace importexport=1 if (export_import=="Export" | export_import=="Exports"| export_import=="Sortie")



*** deal with missing values and generate value ** Devrait être fait dand la base 
/*
generate value=value
replace value=prix_unitaire*quantit if value==. & prix_unitaire!=.
drop if value==.
drop if value==0
*/



***garder quand on a le commerce national complet ou les flux locaux complets
****Je garde 1789 (pour du local) car il ne manque que le commerce avec les Indes.
keep if best_guess_national_prodxpart==1 | best_guess_department_prodxpart==1 | (year==1789 & source_type=="National toutes directions partenaires manquants")
drop if tax_department =="Colonies Françaises de l'Amérique"


/*Nott useful anymore : the best guesses are defined elsewhere
drop if source_type=="1792-first semester"

*FOR SOME REASONS THIS DOES NOT WORK
*drop if  year==1787.2
drop if year>1787 & year<1788
*drop if yearstr=="10 mars-31 décembre 1787" 
*GUILLAUME WHY?
**GD20200710 Je ne sais pas. C’est bizarre...
drop if year>1805 & year <1806
*drop colonies
drop if source_type=="Local"  & year==1787
drop if source_type=="Local"  & year==1788

*Unify Resumé and O.G.
**drop Resumé 1788
drop if source_type=="Résumé"  & year==1788
*/

*create national and local
gen natlocal=tax_department


**Pour traiter 1750, qui a à la fois du local et du national. Du coup, on le met 2 fois
save temp.dta, replace
keep if year==1750
replace natlocal="National"
append using temp.dta
erase temp.dta

replace natlocal="National" if best_guess_national_prodxpart==1 & year !=1750
drop if natlocal=="[vide]"


*ID LOVE GUILLAUME TO VERIFY THIS: adjust 1749, 1751, 1777, 1789 and double accounting in order to keep only single values from series "Local" and "National toutes directions partenaires manquants"
sort year importexport natlocal value product_grains partner_grouping source_type  

**GD20200710 Il faut sans doute agréger si on a plusieurs flux pour une même catégorie de bien ? C’est ce que je fait ici

*duplicates report year importexport natlocal source_type grains_num partner_grouping

collapse (sum) value, by(year importexport natlocal product_grains partner_grouping)

**GD20200710 Maintenant, on regarde s’il y a des flux en trop

duplicates report year importexport natlocal product_grains partner_grouping
duplicates tag    year importexport natlocal product_grains partner_grouping, generate(tag)
tab year tag






/* Devenus caduc depuis que le best guess vient d’ailleurs
*GD20200710 Les soucis sont en 49, 50, 51 et 77 : je ne vois plus ceux de 89.
*GD20200710 On privilégie toujours "local"
keep if (tag==1 & source_type=="Local") | tag==0

/* GD20200710 Je pense que ce que tu faisais était très proche ?
quietly by year importexport natlocal value grains_num partner_grouping  :  gen dup = cond(_N==1,0,_n)
drop if source_type!="Local" & dup!=0 
*/
*/


*GD20200710 J’aimerai bien créer les flux dont on sait qu’ils sont nuls... (et qui peuvent être comparés avec d’autre flux)
fillin year importexport natlocal product_grains partner_grouping

replace value=0 if value==.

*Pour éliminer les rapporteurs qui ne sont pas là pour une année particulière
bys natlocal year : egen out_fillin = max (value)
drop if out_fillin==0
drop out_fillin

*Pour éliminer les paires partenaires x rapporteurs x produits x importexport qui ne sont jamais là
bys natlocal partner_grouping product_grains importexport : egen out_fillin = max (value)
drop if out_fillin==0
drop out_fillin

*Pour éliminer les partenaires qui ne sont pas là certaines années ?
bys year  partner_grouping : egen out_fillin = max (value)
drop if out_fillin==0
drop out_fillin


/*Plus la peine : nous ne les prennons pas
**Pour identifier ceux dont on ne connait pas tous les partenaires
gen flag_partenaires_manquants = .
replace flag_partenaires_manquants =1 if source_type=="National toutes directions partenaires manquants"

bys year partner_grouping natlocal : egen out_fillin=min(_fillin)
bys year partner_grouping natlocal : egen out_partenaires_manquants=max(flag_partenaires_manquants)
drop if out_fillin==1 & out_partenaires_manquants ==1 
**Je suis surpris que cela ne conduisent pas à éliminer des flux ??
*/
** et finalement
replace value=0 if value==.

**Je vérifie que tous ces zéros ont un sens
bys partner_grouping natlocal importexport product_grains : egen max_value=max(value)
assert max_value !=0

drop max_value tag

*GD20200710 Bien sûr, se pose la question de savoir quoi en faire si on prend le log des flux...

*** isolate grains (Rq : il faut faire le fillin avant !)
drop if product_grains=="Pas grain (0)"
drop if product_grains=="."
encode product_grains, generate(grains_num)

save data_interpolation_temp.dta, replace
*********************************************Fin de la préparation des données


use data_interpolation_temp.dta, clear
*create geography
encode natlocal, generate(geography) label(natlocal)

drop if year==.
drop if geography==.

/*
***source_type

encode source_type, generate(source_type_encode) label(source_type)

*/
***collapse by year
collapse (sum) value, by (year geography natlocal importexport)

***generate ln value
gen value_c=value+0.5
drop value
rename value_c value
generate ln_value=ln(value)

***reshape import and export
reshape wide ln_value value, i(year geography natlocal) j(importexport)
rename value1 export
rename value0 import
rename ln_value1 ln_export
rename ln_value0 ln_import
fillin geography year 

replace year=1806 if year==1805.75
xtset geography year
xtgls ln_import i.year i.geography if year >=1750 & year <=1789
predict ln_import_xtgls1 if geography==23

xtreg ln_import i.year i.geography if year >=1750 & year <=1789, fe 
predict ln_import_xtreg if geography==23

gen import_xtreg=exp(ln_import_xtreg)
gen import_xtgls=exp(ln_import_xtgls)

sort year

twoway (connected import_xtreg year if year>=1750 & year <=1789 & geography==23) ///
		(connected import_xtgls year if year >=1750 & year <=1789 & geography==23) ///
		(connected import year if year >=1750 & year <=1789 & geography==23) 

blif


*** now regress
xi:  regress ln_import i.year i.geography   [iweight=import]
*** now rectangularize (filling missing explanatory variables (year, geography))
hettest 
****Il y a beaucoup d’hétérskedasticité... Voir https://trello.com/c/90CWIE9S


 blif
fillin natlocal year 

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

erase data_interpolation_temp.dta

