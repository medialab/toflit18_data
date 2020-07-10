




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



***Regions
generate region="KO"
replace region="NE" if direction=="Amiens" | direction=="Dunkerque"| direction=="Saint-Quentin" | direction=="Châlons" | direction=="Langres" | direction=="Flandre"  
replace region="N" if direction=="Caen" | direction=="Rouen" | direction=="Le Havre"
replace region="NW" if direction=="Rennes" | direction=="Lorient" | direction=="Nantes" | direction=="Saint-Malo"
replace region="SW" if direction=="La Rochelle" | direction=="Bordeaux" | direction=="Bayonne" 
replace region="S" if direction=="Marseille" | direction=="Toulon" | direction=="Narbonne" | direction=="Montpellier"
replace region="SE" if direction=="Grenoble" | direction=="Lyon" 
replace region="E" if direction=="Besancon" | direction=="Bourgogne"| direction=="Charleville"



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
generate ln_value_inclusive=ln(value_inclusive)

***reshape import and export
reshape wide ln_value_inclusive value_inclusive, i(year geography) j(importexport)
rename value_inclusive1 export
rename value_inclusive0 import
rename ln_value_inclusive1 ln_export
rename ln_value_inclusive0 ln_import


*** now regress
 xi:  regress ln_import i.year i.geography  [iweight=import]
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

drop if geography!=23
drop _fillin _Iyear_2 _Iyear_3 _Iyear_4 _Iyear_5 _Iyear_6 _Iyear_7 _Iyear_8 _Iyear_9 _Iyear_10 _Iyear_11 _Iyear_12 _Iyear_13 _Iyear_14 _Iyear_15 _Iyear_16 _Iyear_17 _Iyear_18 _Iyear_19 _Iyear_20 _Iyear_21 _Iyear_22 _Iyear_23 _Iyear_24 _Iyear_25 _Iyear_26 _Iyear_27 _Iyear_28 _Iyear_29 _Iyear_30 _Iyear_31 _Iyear_32 _Iyear_33 _Iyear_34 _Iyear_35 _Iyear_36 _Iyear_37 _Iyear_38 _Iyear_39 _Iyear_40 _Iyear_41 _Iyear_42 _Iyear_43 _Iyear_44 _Iyear_45 _Iyear_46 _Iyear_47 _Iyear_48 _Iyear_49 _Iyear_50 _Iyear_51 _Iyear_52 _Iyear_53 _Iyear_54 _Iyear_55 _Iyear_56 _Iyear_57 _Iyear_58 _Iyear_59 _Iyear_60 _Iyear_61 _Iyear_62 _Iyear_63 _Iyear_64 _Iyear_65 _Iyear_66 _Iyear_67 _Iyear_68 _Iyear_69 _Iyear_70 _Iyear_71 _Iyear_72 _Iyear_73 _Iyear_74 _Iyear_75 _Iyear_76 _Iyear_77 _Iyear_78 _Iyear_79 _Iyear_80 _Iyear_81 _Iyear_82 _Iyear_83 _Iyear_84 _Iyear_85 _Iyear_86 _Iyear_87 _Iyear_88 _Iyear_89 _Iyear_90 _Iyear_91 _Iyear_92 _Iyear_93 _Iyear_94 _Iyear_95 _Igeography_2 _Igeography_3 _Igeography_4 _Igeography_5 _Igeography_6 _Igeography_7 _Igeography_8 _Igeography_9 _Igeography_10 _Igeography_11 _Igeography_12 _Igeography_13 _Igeography_14 _Igeography_15 _Igeography_16 _Igeography_17 _Igeography_18 _Igeography_19 _Igeography_20 _Igeography_21 _Igeography_22 _Igeography_23 _Igeography_24 _Igeography_25 _Igeography_26 _Igeography_27 _Igeography_28 _Igeography_29 _Igeography_30

drop geography
gen NX=export_predict-import_predict

* graph for geography == national

twoway (line import_predict year if geography==23, yaxis(1) ) (line export_predict year if geography==23, yaxis(2))
