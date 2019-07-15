
cd "/Users/guillaumedaudin/Google Drive/TOFLIT18_paper_HM/Graphiques_stata"





capture program drop graph_canada
program graph_canada
args marchandises_dinteret

*exemple graph_canada product_sitc

use "/Users/guillaumedaudin/Documents/Recherche/Commerce International Français XVIIIe.xls/Balance du commerce/Retranscriptions_Commerce_France/Données Stata/bdd courante.dta", clear



format value %-15.2fc
replace value=value/1000000


drop if sourcetype=="Divers" | sourcetype=="Tableau Général"

replace country_grouping ="Outre-mers" if country_grouping =="États-Unis d'Amérique"
replace country_grouping ="Pas Outre-mers" if country_grouping !="Outre-mers"

collapse (sum) value, by(year exportsimports direction product_canada product_sitc product_beaver sourcetype country_grouping)
*fillin year direction product_canada country_grouping
replace value=. if value==0

gen commerce_national = 1 if (sourcetype=="Objet Général" & year<=1786) | (sourcetype=="Résumé" & year <= 1790) | sourcetype=="National toutes directions tous partenaires"

save blink.dta, replace
keep if year==1750 & sourcetype=="National toutes directions tous partenaires"
collapse (sum) value, by(year product_canada product_sitc product_beaver sourcetype country_grouping commerce_national)
append using blink.dta
erase blink.dta
replace commerce_national=0 if direction!=""

gen commerce_local = 1 if sourcetype=="Local" & year!=1750 | sourcetype=="National toutes directions tous partenaires" | ////
			(sourcetype=="National toutes directions partenaires manquants" & year==1788 & country_grouping=="Outre-mers") | ////
			(sourcetype=="National toutes directions partenaires manquants" & year==1789 & country_grouping=="Pas Outre-mers")

**Nous n'avons pas les importations depuis les colonies par direction de ferme pour 1789




if "`marchandises_dinteret'"=="product_canada" {

	local lignes_du_graph (connected value year if product_canada=="Exclusivement Canada" & \`conditions_options') ///
			(connected value year if product_canada=="Peut-être Canada"  & \`conditions_options') ///
			(connected value year if product_canada=="Hors Canada" & \`conditions_options') ///
			
	local legende , legend(label(1 "From Canada") label(2 "Maybe from Canada") label(3 "Not from Canada")) ///

	keep if exportsimports=="Imports"
	collapse (sum) value, by(year exportsimports direction product_canada sourcetype country_grouping commerce_national commerce_local) 
}

if "`marchandises_dinteret'"=="product_sitc" {

	replace product_sitc="others" if product_sitc!="6a"

	local lignes_du_graph (connected value year if product_sitc=="6a" & exportsimports=="Imports" & \`conditions_options') ///
						  (connected value year if product_sitc=="6a" & exportsimports=="Exports" & \`conditions_options') ///
			
	local legende , legend(row(2) label(1 "Imports of leather products (except saddlery)") label(2 "Exports of leather products (except saddlery)"))  ///

	collapse (sum) value, by(year exportsimports direction product_sitc sourcetype country_grouping commerce_national commerce_local) 
}


if "`marchandises_dinteret'"=="product_beaver" {

	*replace product_sitc="others" if product_sitc!="6a" & product_sitc!="0b"

	local lignes_du_graph (connected value year if product_beaver=="beaver raw material" & exportsimports=="Imports" & \`conditions_options') ///
			(connected value year if product_beaver=="Using beaver"  & exportsimports=="Exports" & \`conditions_options') ///
			(connected value year if product_beaver=="beaver raw material" & exportsimports=="Exports" & \`conditions_options') ///
			(connected value year if product_beaver=="Using beaver"  & exportsimports=="Imports" & \`conditions_options') ///
			
	local legende , legend(label(1 "Beaver material imports") label(2 "Beaver goods exports") label(3 "Beaver material exports") label(4 "Beaver goods imports")) ///

	collapse (sum) value, by(year exportsimports direction product_beaver sourcetype country_grouping commerce_national commerce_local) 
}


local conditions_options commerce_national==1 & country_grouping=="Outre-mers", msize(small) cmissing(n) 

twoway  `lignes_du_graph' ///
		`legende' ///
		ytitle("Millions of livres tournois") title("National, Atlantic trade") ///
		xscale(range(1715 1790)) xlabel(1720 (10) 1790) ///
		name("Objet_General_OM", replace)	
				
graph export "`marchandises_dinteret'_Objet_General_OM.png", replace


local conditions_options commerce_national==1 & country_grouping=="Pas Outre-mers", msize(small) cmissing(n) 
	
twoway `lignes_du_graph' ///
		`legende' ///
	ytitle("Millions of livres tournois") title("National, Not Atlantic trade") ///
	xscale(range(1715 1790)) xlabel(1720 (10) 1790) ///
	name("Objet_General_POM", replace)
graph export "`marchandises_dinteret'_Objet_General_POM.png", replace
	
foreach direction in Nantes Marseille Bayonne Bordeaux Rouen Rennes "La Rochelle"  {

	local name = subinstr("`direction'"," ","_",.)

	local conditions_options commerce_local==1 & direction=="`direction'" & country_grouping=="Outre-mers", msize(small) cmissing(n) 

	twoway `lignes_du_graph' ///
		`legende' ///
	ytitle("Millions of livres tournois") title("`direction', Atlantic trade") ///
	xscale(range(1715 1790)) xlabel(1720 (10) 1790) ///
	name("`name'_OM", replace)
	graph export "`marchandises_dinteret'_`name'_OM.png", replace

	local conditions_options commerce_local==1 & direction=="`direction'" & country_grouping=="Pas Outre-mers", msize(small) cmissing(n) 
	
	twoway `lignes_du_graph' ///
		`legende' ///
		ytitle("Millions of livres tournois") title("`direction', Not Atlantic trade") ///
		xscale(range(1715 1790)) xlabel(1720 (10) 1790) ///
		name("`name'_POM", replace)	
	
	graph export "`marchandises_dinteret'_ `name'_POM.png", replace
}

collapse (sum) value, by(exportsimports year direction  `marchandises_dinteret' sourcetype commerce_national commerce_local)

local conditions_options commerce_national==1 , msize(small) cmissing(n) 

twoway `lignes_du_graph' ///
		`legende' ///
		ytitle("Millions of livres tournois") title("National") ///
		xscale(range(1715 1790)) xlabel(1720 (10) 1790) ///
		name("Objet_General", replace)
graph export "`marchandises_dinteret'_Objet_General.png", replace
	

foreach direction in Nantes Marseille Bayonne Bordeaux Rouen Rennes "La Rochelle"  {

	local name = subinstr("`direction'"," ","_",.)

	local conditions_options commerce_local==1 & direction=="`direction'", msize(small) cmissing(n) 


	twoway `lignes_du_graph' ///
		`legende' ///
		xscale(range(1715 1790)) xlabel(1720 (10) 1790) ///
		ytitle("Millions of livres tournois") title("`direction'") ///
		name("`name'", replace)
graph export "`marchandises_dinteret'_`name'.png", replace

}
end


graph_canada product_canada
graph_canada product_sitc
graph_canada product_beaver
