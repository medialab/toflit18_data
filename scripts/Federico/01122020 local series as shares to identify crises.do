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
sort year importexport natlocal value product_grains partner_grouping partner_simplification source_type  

**GD20200710 Il faut sans doute agréger si on a plusieurs flux pour une même catégorie de bien ? C’est ce que je fait ici

*duplicates report year importexport natlocal source_type grains_num partner_grouping

collapse (sum) value, by(year importexport natlocal product_grains partner_simplification)

**GD20200710 Maintenant, on regarde s’il y a des flux en trop

duplicates report year importexport natlocal product_grains partner_simplification
duplicates tag    year importexport natlocal product_grains partner_simplification, generate(tag)
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
fillin year importexport natlocal product_grains partner_simplification

replace value=0 if value==.

*Pour éliminer les rapporteurs qui ne sont pas là pour une année particulière
bys natlocal year : egen out_fillin = max (value)
drop if out_fillin==0
drop out_fillin

*Pour éliminer les paires partenaires x rapporteurs x produits x importexport qui ne sont jamais là
bys natlocal partner_simplification product_grains importexport : egen out_fillin = max (value)
drop if out_fillin==0
drop out_fillin

*Pour éliminer les partenaires qui ne sont pas là certaines années ?
bys year  partner_simplification : egen out_fillin = max (value)
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
bys partner_simplification natlocal importexport product_grains : egen max_value=max(value)
assert max_value !=0

drop max_value tag


bys year natlocal importexport : egen total_value = sum(value)

*** isolate grains (Rq : il faut faire le fillin avant !)
drop if product_grains=="Pas grain (0)"
drop if product_grains=="."
encode product_grains, generate(grains_num)label(grains)

*********************************************Fin de la préparation des données

*** count number of parners for each year, direction across all categories
drop if _fillin>0
egen n_partners=nvals(partner), by(year natlocal importexport)


***drop national
drop if natlocal=="National"
***total trade of grains for each locality 

bys year natlocal importexport : egen grain_trade = sum(value)

***generate graph and table showing for each series max ratio of grains in imports and exports
save temp.dta, replace
collapse(mean) grain_trade, by(year natlocal importexport total_value)
gen grain_share=grain_trade/total_value*100

gen flag=0
replace flag=1 if grain_share>9.99

***reshape
reshape wide total_value grain_trade grain_share flag, i( year natlocal) j(importexport)
rename total_value0 total_imports
rename total_value1 total_exports
rename grain_trade0 grain_imports
rename grain_trade1 grain_exports
rename grain_share0 share_imports
rename grain_share1 share_exports
rename flag0 flag_imports
rename flag1 flag_exports
foreach x of varlist total_imports grain_imports flag_imports total_exports grain_exports share_imports share_exports flag_exports {
  label variable `x'
}
***panel
keep if natlocal=="Bayonne" | natlocal=="Bordeaux" | natlocal=="La Rochelle" | natlocal=="Marseille" | natlocal=="Nantes" | natlocal=="Rennes" | natlocal=="Rouen"

replace year=1806 if year==1805.75
encode natlocal, generate(locality) label(natlocal) 
xtset locality year
foreach x of varlist total_imports grain_imports flag_imports total_exports grain_exports share_imports share_exports flag_exports {
  replace `x' = 0 if(`x' == .)
}
tsfill
drop if year==1789
drop natlocal
**dev from mean of share
bys locality: egen average_expshare=mean(share_exports)
bys locality: egen average_impshare=mean(share_imports)
gen dev_exshare=(share_exports-average_expshare)/average_expshare*100
gen dev_imshare=(share_imports-average_impshare)/average_impshare*100

** dev from MA
***4yy ma
generate maexports = (l1.grain_exports+l2.grain_exports+l3.grain_exports+l4.grain_exports) / 4
gen maimports=(l1.grain_imports+l2.grain_imports+l3.grain_imports+l4.grain_imports) / 4
* dev
gen dev_imports=((grain_imports-maimports)/maimports)*100 
gen dev_exports=((grain_exports-maexports)/maexports)*100 
gen ma_flag_exports=0
replace ma_flag_exports=1 if dev_exshare>100
gen ma_flag_imports=0
replace ma_flag_imports=1 if dev_imshare>100
*compare ma_flag and flag
gen import_confirm_flag=0
replace import_confirm_flag=1 if ma_flag_imports==1 & flag_imports==1
gen export_confirm_flag=0
replace export_confirm_flag=1 if ma_flag_exports==1 & flag_exports==1

*drop after 1780
drop if year>1780
***export to excel
export excel  using "C:\Users\federico.donofrio\Dropbox\Papier Grains\01122020crises.xlsx" , replace
*graph imports NAME OF VARIABLES HAD TO BE CHANGED MANUALLY
twoway (line share_imports year if locality==1, cmissing(no) yaxis(1) ytitle("share of grains")  ylabel(,grid) xlabel(#15,grid)  xmtick(##15))(line share_imports year if locality==2, cmissing(no) yaxis(1) ytitle("share of grains") ylabel(,grid) xlabel(#15,grid)  xmtick(##15))(line share_imports year if locality==3, cmissing(no) yaxis(1) ytitle("share of grains") ylabel(,grid) xlabel(#15,grid)  xmtick(##15))(line share_imports year if locality==4, cmissing(no) yaxis(1) ytitle("share of grains") ylabel(,grid) xlabel(#15,grid)  xmtick(##15))(line share_imports year if locality==5, cmissing(no) yaxis(1) ytitle("share of grains") ylabel(,grid) xlabel(#15,grid)  xmtick(##15))(line share_imports year if locality==6, cmissing(no) yaxis(1) ytitle("share of grains") ylabel(,grid) xlabel(#15,grid)  xmtick(##15))(line share_imports year if locality==7, cmissing(no) yaxis(1) ytitle("share of grains") ylabel(,grid) xlabel(#15,grid)  xmtick(##15)) 
graph export "C:\Users\federico.donofrio\Dropbox\Papier Grains\01122020crises_imports.png", replace

**graph exports NAME OF VARIABLES HAD TO BE CHANGED MANUALLY
twoway (line share_exports year if locality==1, cmissing(no) yaxis(1) ytitle("share of grains")  ylabel(,grid) xlabel(#15,grid)  xmtick(##15))(line share_exports year if locality==2, cmissing(no) yaxis(1) ytitle("share of grains") ylabel(,grid) xlabel(#15,grid)  xmtick(##15))(line share_exports year if locality==3, cmissing(no) yaxis(1) ytitle("share of grains") ylabel(,grid) xlabel(#15,grid)  xmtick(##15))(line share_exports year if locality==4, cmissing(no) yaxis(1) ytitle("share of grains") ylabel(,grid) xlabel(#15,grid)  xmtick(##15))(line share_exports year if locality==5, cmissing(no) yaxis(1) ytitle("share of grains") ylabel(,grid) xlabel(#15,grid)  xmtick(##15))(line share_exports year if locality==6, cmissing(no) yaxis(1) ytitle("share of grains") ylabel(,grid) xlabel(#15,grid)  xmtick(##15))(line share_exports year if locality==7, cmissing(no) yaxis(1) ytitle("share of grains") ylabel(,grid) xlabel(#15,grid)  xmtick(##15)) 
graph export "C:\Users\federico.donofrio\Dropbox\Papier Grains\01122020crises_exports.png", replace

*** create table with confirm flags only
save temp2.dta
drop if import_confirm_flag==0
keep import_confirm_flag year locality
export excel  using "C:\Users\federico.donofrio\Dropbox\Papier Grains\01122020import_confirm_flag.xlsx" , replace
use temp2.dta, clear
drop if export_confirm_flag==0
keep export_confirm_flag year locality
export excel  using "C:\Users\federico.donofrio\Dropbox\Papier Grains\01122020export_confirm_flag.xlsx" , replace

*create table when at least one of the indicators is positive for a tax district
use temp2.dta, clear
keep year locality ma_flag_imports ma_flag_exports import_confirm_flag export_confirm_flag flag_imports flag_exports
replace ma_flag_exports=. if flag_exports==.
replace ma_flag_imports=. if flag_imports==.
gen minor_flag_imports=0
replace minor_flag_imports=1 if ma_flag_exports==1 | flag_imports==1
gen minor_flag_exports=0
replace minor_flag_exports=1 if ma_flag_exports==1 | flag_exports==1

reshape wide ma_flag_imports ma_flag_exports import_confirm_flag export_confirm_flag flag_imports flag_exports minor_flag_imports minor_flag_exports, i(year) j(locality)
*1=bayonne, 2=bordeaux, 3=larochelle, 4=marseille, 5=nantes, 6=Rennes, 7=rouen
export excel  using "C:\Users\federico.donofrio\Dropbox\Papier Grains\01122020crises_flag_only.xlsx" , replace


***partners in 1764
use temp.dta, clear
***

***collapse over all grain types
collapse(sum) value, by(year natlocal importexport grains_num total_value n_partners)


