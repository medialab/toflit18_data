


if "`c(username)'" =="federico.donofrio" {
	*import delimited "C:\Users\federico.donofrio\Documents\TOFLIT desktop\Données Stata\bdd courante.csv", varnames(1) encoding(UTF-8) 
	**GD20200710 Déjà, cela c’est assez suspect. Il faut exploiter le .zip qui est intégré dans le git, plutôt ? Tu peux unzipper depuis stata
	*avec la commande unzipfile
	*save "C:\Users\federico.donofrio\Documents\GitHub\Données Stata\bdd courante.dta", replace
	global dir "C:\Users\federico.donofrio\Documents\GitHub\"
	
}

if "`c(username)'" =="guillaumedaudin" {
	global dir "~/Documents/Recherche/Commerce International Français XVIIIe.xls/Balance du commerce/Retranscriptions_Commerce_France"
}


clear
cd `"$dir"'
capture log using "`c(current_time)' `c(current_date)'"
*À faire pour récupérer les données
unzipfile "toflit18_data_GIT\base/bdd courante.csv.zip", replace
insheet using "toflit18_data_GIT\base/bdd courante.csv", clear
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
keep if best_guess_national_prodxpart==1 | best_guess_region_prodxpart==1 | (year==1789 & source_type=="National toutes directions partenaires manquants")
drop if customs_region =="Colonies Françaises de l'Amérique"


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
gen natlocal=customs_region


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
encode product_grains, generate(grains_num)label(grains)

*********************************************Fin de la préparation des données
*cancel years
***drop local post 1749
drop if natlocal!="National" & year>1749

*** compute total value_inclusive by year
bys year importexport : egen total_trade = total(value)


*** aggregate by: country, importexport, year
collapse (sum) value, by (year total_trade importexport grains_num)
*** ratio of grains on total import or export
bys importexport grains_num  year total_trade value: generate g_ratio = (value/total_trade)*100
drop total_trade
*** reshape
*reshape wide value_inclusive total_trade country_ratio, i(year grouping_classification source_type_encode) j(importexport)
reshape wide g_ratio value, i( grains_num year) j(importexport)
rename value0 import
rename value1 export
rename g_ratio0 import_share
rename g_ratio1 export_share

replace year=1806 if year==1805.75
xtset grains_num year
tsfill

*other cereals
twoway (tsline export if grains_num==1 , cmissing(no) yaxis(1) ytitle("value of exports in lt") xlabel(#15,grid)  xmtick(##15) title("other grains, export") ) 
graph export "C:\Users\federico.donofrio\Dropbox\Papier Grains\112020export_other_cereals.png", replace
twoway (tsline import if grains_num==1 , cmissing(no) yaxis(1) ytitle("value of imports in lt") xlabel(#15,grid)  xmtick(##15) title("other grains, import") ) 
graph export "C:\Users\federico.donofrio\Dropbox\Papier Grains\112020import_other_cereals.png", replace

*wheat
twoway (tsline export if grains_num==2 , cmissing(no) yaxis(1) ytitle("value of exports in lt") xlabel(#15,grid)  xmtick(##15) title("wheat, export") )
graph export "C:\Users\federico.donofrio\Dropbox\Papier Grains\112020export_wheat.png", replace 
twoway (tsline import if grains_num==2 , cmissing(no) yaxis(1) ytitle("value of imports in lt") xlabel(#15,grid)  xmtick(##15) title("wheat, import") )
graph export "C:\Users\federico.donofrio\Dropbox\Papier Grains\112020import_wheat.png", replace


*transformed grains
twoway (tsline export if grains_num==3 , cmissing(no) yaxis(1) ytitle("value of exports in lt") xlabel(#15,grid)  xmtick(##15) title("transformed grains, export") )
graph export "C:\Users\federico.donofrio\Dropbox\Papier Grains\112020export_flour.png", replace 
twoway (tsline import if grains_num==3 , cmissing(no) yaxis(1) ytitle("value of imports in lt") xlabel(#15,grid)  xmtick(##15) title("transformed grains, import") )
graph export "C:\Users\federico.donofrio\Dropbox\Papier Grains\112020import_flour.png", replace

*major cereals except wheat
twoway (tsline export if grains_num==4 , cmissing(no) yaxis(1) ytitle("value of exports in lt") xlabel(#15,grid)  xmtick(##15) title("major cereals except wheat, export") )
graph export "C:\Users\federico.donofrio\Dropbox\Papier Grains\112020export_creals.png", replace 
twoway (tsline import if grains_num==4 , cmissing(no) yaxis(1) ytitle("value of imports in lt") xlabel(#15,grid)  xmtick(##15) title("major cereals except wheat, import") )
graph export "C:\Users\federico.donofrio\Dropbox\Papier Grains\112020import_creals.png", replace

*substitutes
twoway (tsline export if grains_num==5 , cmissing(no) yaxis(1) ytitle("value of exports in lt") xlabel(#15,grid)  xmtick(##15) title("substitutes, export") )
graph export "C:\Users\federico.donofrio\Dropbox\Papier Grains\112020export_substitutes.png", replace 
twoway (tsline import if grains_num==5 , cmissing(no) yaxis(1) ytitle("value of imports in lt") xlabel(#15,grid)  xmtick(##15) title("substitutes, import") )
graph export "C:\Users\federico.donofrio\Dropbox\Papier Grains\112020import_substitutes.png", replace

*share export and import
xtline export_share , cmissing(no) yaxis(1) ytitle("share in grain exports") xlabel(#8,grid)  xmtick(##15)
graph export "C:\Users\federico.donofrio\Dropbox\Papier Grains\112020export_share.png", replace
xtline import_share, cmissing(no) yaxis(1) ytitle("value of imports in lt") xlabel(#8,grid)  xmtick(##15)
graph export "C:\Users\federico.donofrio\Dropbox\Papier Grains\112020import_share.png", replace
