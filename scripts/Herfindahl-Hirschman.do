
****To compute Herfindahl-Hirschman index data


capture program drop graph_HHI
program graph_HHI
args classification hapax
**Hapax : is 1, on les enlève 1 et moins, si 2, 2 et moins, etc.


use "~/Documents/Recherche/Commerce International Français XVIIIe.xls/Balance du commerce/Retranscriptions_Commerce_France/Données Stata/bdd courante.dta", clear

egen absurd_out=max(absurd_value), by(sourcetype year direction exportsimports)
drop if absurd_out==1

collapse (sum) value, by(sourcetype year direction exportsimports `classification') 
bys `classification': drop if _N <=`hapax'
sort year
egen prop = pc(value), by(sourcetype year direction exportsimports) prop
egen HHI = total(prop^2), by(sourcetype year direction exportsimports)



if "`classification'"=="goods_simpl_classification" local title = "Simplification" 
if "`classification'"=="sitc18_rev3" local title = "SITC18"
if "`classification'"=="goods_ortho_classification" local title = "Orthographic normalization" 

foreach dir in "La Rochelle" Bordeaux Nantes Marseille Rouen Bayonne Rennes  {
	local graph_name = subinstr("`dir'"," ","_",.)

	twoway  (connected  HHI year if direction=="`dir'" & sourcetype=="Local" & exportsimports=="Imports",msize(small) msymbol(circle)) ///
			(connected  HHI year if direction=="`dir'" & sourcetype=="Local" & exportsimports=="Exports",msize(small) msymbol(diamond)) ///
			,legend(order( ///
						1 "`dir' - Imports" 2 "`dir' - Exports" ///
			)) ///
			name("`graph_name'", replace) ///
			yscale(range(0 0.6)) ///
			ylabel(0 (0.1) 0.6)  ///
			title(`"`title'"') ///
			saving("~/Dropbox/2018 Boston - présentation Charles, Daudin, Girard/graphiques/`graph_name'_`classification'_Hapax`hapax'.gph", replace)
			
			graph export "~/Dropbox/2018 Boston - présentation Charles, Daudin, Girard/graphiques/`graph_name'_`classification'_Hapax`hapax'.pdf", replace

}

collapse (sum) value, by(sourcetype year exportsimports `classification')
egen prop = pc(value), by(sourcetype year exportsimports) prop
egen HHI = total(prop^2), by(sourcetype year exportsimports)

sort year

twoway  (connected  HHI year if (sourcetype=="National toutes directions tous partenaires" | sourcetype=="Objet Général" | (sourcetype=="Résumé" & year!=1788)) & exportsimports=="Imports",msize(small) msymbol(circle)) ///
		(connected  HHI year if (sourcetype=="National toutes directions tous partenaires" | sourcetype=="Objet Général" | (sourcetype=="Résumé" & year!=1788)) & exportsimports=="Exports",msize(small) msymbol(diamond)) ///
		,legend(order( ///
		1 "National - Imports" 2 "National - Exports" ///
		)) ///
		name("National", replace) ///
		yscale(range(0 0.6)) ///
		ylabel(0 (0.1) 0.6)  ///
		title(`"`title'"') ///
		saving("~/Dropbox/2018 Boston - présentation Charles, Daudin, Girard/graphiques/National_`classification'_Hapax`hapax'.gph", replace)
		graph export "~/Dropbox/2018 Boston - présentation Charles, Daudin, Girard/graphiques/National_`classification'_Hapax`hapax'.pdf", replace
		





end

graph_HHI goods_simpl_classification 0
graph_HHI goods_ortho_classification 0
graph_HHI sitc18_rev3 0

graph_HHI goods_simpl_classification 1
graph_HHI goods_simpl_classification 2
