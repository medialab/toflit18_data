
****To compute Herfindahl-Hirschman index data

global dir "~/Dropbox/2018 Boston - présentation Charles, Daudin, Girard"


capture program drop graph_HHI
program graph_HHI
args classification hapax type
**Hapax : is 1, on les enlève 1 et moins, si 2, 2 et moins, etc.


use "~/Documents/Recherche/Commerce International Français XVIIIe.xls/Balance du commerce/Retranscriptions_Commerce_France/Données Stata/bdd courante.dta", clear

keep if sourcetype=="Local" | sourcetype=="National toutes directions tous partenaires" ///
							| sourcetype=="Objet Général" | (sourcetype=="Résumé" & year!=1788)

egen absurd_out=max(absurd_value), by(sourcetype year direction exportsimports)
drop if absurd_out==1
bys `classification': drop if _N <=`hapax'




sort year


if "`classification'"=="marchandises" local title = "As retranscribed - H`hapax'" 
if "`classification'"=="goods_simpl_classification" local title = "Simplification - H`hapax'" 
if "`classification'"=="sitc_classification" local title = "SITC18"
if "`classification'"=="goods_ortho_classification" local title = "Orthographic normalization - H`hapax'" 

if "`type'"=="temp" {
collapse (sum) value, by(sourcetype year direction exportsimports `classification') 
egen prop = pc(value), by(sourcetype year direction exportsimports) prop
egen HHI = total(prop^2), by(sourcetype year direction exportsimports)

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
				saving("$dir/graphiques/`graph_name'_`classification'_Hapax`hapax'.gph", replace)
			
				graph export "$dir/graphiques/`graph_name'_`classification'_Hapax`hapax'.pdf", replace
	}
}





if "`type'"=="temp" {
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
			saving("$dir/graphiques/National_`classification'_Hapax`hapax'.gph", replace)
			graph export "$dir/graphiques/National_`classification'_Hapax`hapax'.pdf", replace
}





if "`type'"=="cross" {
	preserve
	drop if direction==""
	collapse (sum) value, by(year direction exportsimports `classification')
	egen prop = pc(value), by(year direction exportsimports) prop
	egen HHI = total(prop^2), by(year direction exportsimports)
	collapse (mean) HHI, by(direction exportsimports)
	save "$dir/temp.dta", replace
	restore
	
	
	keep if sourcetype=="National toutes directions tous partenaires" ///
		  |sourcetype=="Objet Général" | (sourcetype=="Résumé" & year!=1788)
	collapse (sum) value, by (year exportsimports `classification')
	egen prop = pc(value), by (year exportsimports) prop
	egen HHI = total(prop^2), by (year exportsimports)
	collapse (mean) HHI, by(exportsimports)
	gen direction="National"
	
	append using "$dir/temp.dta"
	erase "$dir/temp.dta"
	
	reshape wide HHI,i(direction) j(exportsimports) string
	gen HHIMoy=HHIImports+HHIExports
	sort HHIMoy
	gen order=_n
	graph hbar (asis) HHIExports HHIImports, ///
		aspectratio(1, placement(1)) over(direction, sort(order) label(angle(horizontal))) ///
		legend(placement(4)) title("mean HHI - `title'")
		
	graph export "$dir/graphiques/HHI_Cross_`classification'_H`hapax'.pdf", replace
	
}



end

graph_HHI goods_simpl_classification 0 cross
graph_HHI sitc_classification 0 cross

/*
graph_HHI marchandises 0 temp
graph_HHI goods_simpl_classification 0 temp
graph_HHI goods_ortho_classification 0 temp
graph_HHI sitc_classification 0 temp

graph_HHI goods_simpl_classification 1 temp
graph_HHI goods_simpl_classification 2 temp

