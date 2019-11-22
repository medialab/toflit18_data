

global dir "~/Documents/Recherche/Commerce International Français XVIIIe.xls/Balance du commerce/Retranscriptions_Commerce_France"


***Evolution de chaque gamme
capture program drop evolution_gamme
program evolution_gamme
args geographie exportsimports reference sitc
** reference peut être product_luxe_dans_type product_luxe_dans_type product_sitc_FR tous

use "$dir/Données Stata/bdd courante.dta", clear

keep if exportsimports=="`exportsimports'"
if "`sitc'"!="tous" keep if product_sitc=="`sitc'"

if "`geographie'"=="France" {
	keep if NationalBestGuess==1
	gen geographie="France"
	merge m:1 geographie exportsimports year using "~/Dropbox/Partage GD-LC/2019 Colloque Haut de gamme Bercy/Pour_echantillon_luxe.dta"/*
	*/, keep(3)
}

if "`geographie'" !="France" {
	keep if LocalBestGuess==1 & strmatch(direction,"*`geographie'*")==1
	gen geographie="`geographie'"
	merge m:1 geographie exportsimports year using "~/Dropbox/Partage GD-LC/2019 Colloque Haut de gamme Bercy/Pour_echantillon_luxe.dta"/*
	*/, keep(3)
}
drop _merge
drop if keep_for_luxe==0

gen textile = 0
replace textile=1 if product_sitc=="6d" | product_sitc=="6e" | product_sitc=="6f" | product_sitc=="6g" | /*
					 */ product_sitc=="6h" | product_sitc=="6i"

gen classifie_luxe =0
replace classifie_luxe=1 if  product_type_textile =="passementerie" | product_type_textile =="tissés" 



keep if textile==1 & classifie_luxe==1


replace value=value/1000000
rename value _
replace `reference'=word(`reference',1)
collapse (sum) _, by(`reference' year )
reshape wide _, i(year) j(`reference') string

replace _haut=0 if _haut==.
replace _milieu=0 if _milieu==.
replace _bas=0 if _bas==.

gen total = (_bas+_milieu+_haut)
gen share_haut=_haut/(total)
gen share_milieu=_milieu/(total)
gen share_bas=_bas/(total)

replace year=1806 if year==1805.75
tsset year
tsfill




local reference = substr("`reference'",-4,4)
display "`reference'"

replace share_milieu=share_bas+share_milieu
replace share_haut=share_milieu+share_haut

graph twoway (bar share_haut year, cmissing(n) color(dknavy)) (bar share_milieu year, cmissing(n) color(blue)) /*
	*/ (bar share_bas year, cmissing(n) color(ltblue)) /*
	*/ (connected total year, yaxis(2) cmissing(n) msymbol(diamond) msize(small) lcolor(red) mcolor(red)), /*
	*/ name(`geographie'_`exportsimports'_`reference'_`sitc', replace) /*
	*/ title (`geographie'--`exportsimports'--`reference' -- `sitc' SITC18) /*
	*/ legend (label(1 "Haut de gamme") label(2 "Milieu de gamme") label(3 "Bas de gamme") label(4 "Valeur totale du commerce")) /*
	*/ ytitle("Millions de livres ou de francs", axis(2)) /*
	*/ yscale(range(0) axis(2)) yscale(range(0) axis(1))
		
	
graph export "~/Dropbox/Partage GD-LC/2019 Colloque Haut de gamme Bercy/`geographie'_`exportsimports'_`reference'.pdf", replace

end


evolution_gamme France Exports product_luxe_dans_SITC 6g
evolution_gamme France Exports product_luxe_dans_type 6g
aienu

foreach z in France Nantes Marseille Rennes Bordeaux Bayonne Rochelle Rouen {

capture evolution_gamme `z' Exports product_luxe_dans_type tous
capture evolution_gamme `z' Imports product_luxe_dans_type tous

capture evolution_gamme `z' Exports product_luxe_dans_SITC tous
capture evolution_gamme `z' Imports product_luxe_dans_SITC tous

}
