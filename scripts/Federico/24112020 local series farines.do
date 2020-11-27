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
keep if best_guess_national_prodxpart==1 | best_guess_department_prodxpart==1 | (year==1789 & source_type=="National toutes directions partenaires manquants")
drop if tax_department =="Colonies Françaises de l'Amérique"




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



*** isolate grains (Rq : il faut faire le fillin avant !)
drop if product_grains=="Pas grain (0)"
drop if product_grains=="."
encode product_grains, generate(grains_num)label(grains)

*********************************************Fin de la préparation des données

*** count number of parners for each year, direction across all categories

egen n_partners=nvals(partner_simplification), by(year natlocal importexport)


***drop national
drop if natlocal=="National"
***total trade of grains for each locality, 

bys year natlocal importexport  : egen total_value = sum(value)
bys year natlocal importexport grains_num  : egen total_value_category = sum(value)

***exceptional replace
replace quantity_unit_orthographic="boisseau" if quantity_unit_orthographic =="boisseaux"
replace quantity_unit_orthographic="quart" if quantity_unit_orthographic=="quarts"
****limit natloc
keep if natlocal=="Bayonne" | natlocal=="Bordeaux" | natlocal=="La Rochelle" | natlocal=="Marseille" | natlocal=="Nantes" | natlocal=="Rennes" | natlocal=="Rouen"
****farine GUILLAUME CHECK THIS IDEA
keep if grains_num==3
keep if product_simplification=="farine" | product_simplification=="gruau"
***convert to metric
gen hl_conv=.
*barillets: without reliable sources, the conversion factor is imputed through price: 1 livre de hollande is at 0.9 livres tournois while 1 barillets sales at 0.11, then it will have a volume corresponding to 11/9 of the volume of a livre, which is about 1.02465/180 hl=0.0056925. therefore 1 barillet = 0.0056925/9*11=0.0069575 hl
replace hl_conv=0.0069575 if quantity_unit_orthographic=="barillets" 
**barils: thomas Myers introduction and europe 1822: english barrel=32 gallons, 8601.6 cubic inches = 1.4095497 hl, but barrels of 196 livres de poid de marc (200 livres avoirdupois)  

*** larger barrels (190 to 200 livres) before 1744
replace hl_conv=1.11573  if quantity_unit_orthographic=="barils" & year<1744
****barils de 180 livres (arret du conseil d'etat 1 mars 1744)
replace hl_conv=1.02465 if quantity_unit_orthographic=="barils" & year>1743


*barrique, according to doursthier
replace hl_conv=2.275 if quantity_unit_orthographic=="barriques"  & natlocal=="Bordeaux"  
replace hl_conv=1.2 if quantity_unit_orthographic=="barriques" & natlocal=="Nantes"
replace hl_conv= if quantity_unit_orthographic=="barriques" & natlocal=="Rennes"
replace hl_conv= if quantity_unit_orthographic=="barriques" & natlocal=="Rouen"
* barriques de 500 livres: every livre is about 0.0056925, then 500 livres==2.84625
replace hl_conv= if quantity_unit_orthographic=="barriques de 500 livres" & natlocal=="Nantes"

*boisseau
replace hl_conv= if quantity_unit_orthographic=="boisseau" & natlocal=="Bordeaux"  
replace hl_conv= if quantity_unit_orthographic=="boisseau" & natlocal=="Nantes"
replace hl_conv= if quantity_unit_orthographic=="boisseau" & natlocal=="Rennes"
replace hl_conv= if quantity_unit_orthographic=="boisseau" & natlocal=="Rouen"
*bottes 
replace hl_conv= if quantity_unit_orthographic=="bottes" & natlocal=="Rennes"

*boucaux   
replace hl_conv= if quantity_unit_orthographic=="boucaux" & natlocal=="La Rochelle"
replace hl_conv= if quantity_unit_orthographic=="boucaux" & natlocal=="Nantes"
replace hl_conv= if quantity_unit_orthographic=="boucaux" & natlocal=="Rennes"

*conques
replace hl_conv=0.423425 if quantity_unit_orthographic=="conques"
**coupons
replace hl_conv= if quantity_unit_orthographic=="coupons"  & natlocal=="Rennes"

*douelle
replace hl_conv= if quantity_unit_orthographic=="douelles"  & natlocal=="La Rochelle"

*en nombre
replace hl_conv=. if quantity_unit_orthographic=="en nombre"
*faix
replace hl_conv= if quantity_unit_orthographic=="faix" & natlocal=="Rennes"

**fanegues: let's assume an average from cadix, seville, bilbano or saint sebastien 1fanègues=1/22.5 of a tonneau de nantes, therefore hl 14.396447/22.5=0.63984 but l'art de verifier les dates depuis l'annee 1770 estime la fanegue portugaise à 53,552 litres https://books.google.it/books?id=C2hLAAAAcAAJ&pg=PA579&dq=barrique+de+farine+en+livres+tonneau&hl=en&sa=X&ved=2ahUKEwim6oqp46DtAhXJzqQKHSW2BIMQ6AEwAnoECAAQAg#v=snippet&q=farine&f=false 

replace hl_conv=0.6398421 if quantity_unit_orthographic=="fanègues" & natlocal=="Bordeaux"  

*futuailles
replace hl_conv= if quantity_unit_orthographic=="futailles" & natlocal=="Nantes"
replace hl_conv= if quantity_unit_orthographic=="futailles" & natlocal=="Rennes"

*grosses
replace hl_conv= if quantity_unit_orthographic=="grosses" & natlocal=="Bordeaux"  

*last: let's assume is a last d'amsterdam but it is only gruau at a very low price
*replace hl_conv= if quantity_unit_orthographic=="last" & natlocal=="Rennes"

*livres: computed from the barrel of 180 livres. Considering that the livre is lighter in Marseille, we calculate the corresponding value
replace hl_conv=0.0056925 if quantity_unit_orthographic=="livres"   
replace hl_conv= if quantity_unit_orthographic=="livres" & natlocal=="Marseille"
*muids
replace hl_conv=21.594671 if quantity_unit_orthographic=="muids" & natlocal=="Rouen"
*pièces
replace hl_conv=. if quantity_unit_orthographic=="pièces"
*quart, assuming it's a quart de boisseau

  
replace hl_conv= if quantity_unit_orthographic=="quart" & natlocal=="La Rochelle"
replace hl_conv= if quantity_unit_orthographic=="quart" & natlocal=="Nantes"
replace hl_conv= if quantity_unit_orthographic=="quart" & natlocal=="Rennes"


*quintal, let's assume it's 100 livres   
replace hl_conv=0.6398 if quantity_unit_orthographic=="quintal" & natlocal=="Bordeaux"  
replace hl_conv= if quantity_unit_orthographic=="quintal" & natlocal=="Marseille"

*sacs de farine de livourne, selon doursthier: 73.08 litres; nantes: sac ou setier: Nantes. Le sac ou setier,1/10 du tonneau,=12boisseaux 150l, Le sac de farine est de 159 kilogrammes
replace hl_conv= if quantity_unit_orthographic=="sacs" & natlocal=="Bordeaux"  
replace hl_conv= if quantity_unit_orthographic=="sacs" & natlocal=="La Rochelle"
replace hl_conv= if quantity_unit_orthographic=="sacs" & natlocal=="Marseille"
replace hl_conv= if quantity_unit_orthographic=="sacs" & natlocal=="Nantes"
replace hl_conv= if quantity_unit_orthographic=="sacs" & natlocal=="Rennes"


*setiers

replace hl_conv=1.439645 if quantity_unit_orthographic=="setiers" & natlocal=="Nantes"

replace hl_conv=1.515415 if quantity_unit_orthographic=="setiers" & natlocal=="Rouen"
*tierçons, according to brouard 2016, a tierçons ==152 litres: Annales de Bretagne et des Pays de l’OuestAnjou. Maine. Poitou-Charente. Touraine123-1 | 2016Varia Quel commerce fluvial en Loire angevine au XVIIIesiècle ? Nantes et son arrière-pays ligérienEmmanuel BrouardÉdition électroniqueURL : http://journals.openedition.org/abpo/3210DOI : 10.4000/abpo.3210ISBN : 978-2-7535-5040-7ISSN : 2108-6443
replace hl_conv=1.52 if quantity_unit_orthographic=="tierçons" & natlocal=="Nantes"

*tonneaux
replace hl_conv=14.396447 if quantity_unit_orthographic=="barils" & natlocal=="Nantes"

                      



***collapse over all grain types
collapse(sum) value quantity, by(year natlocal importexport grains_num total_value n_partners quantity_unit_orthographic value_per_unit total_value_category)

