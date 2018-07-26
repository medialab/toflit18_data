

global dir "~/Dropbox/2018 Boston - présentation Charles, Daudin, Girard"

use "~/Documents/Recherche/Commerce International Français XVIIIe.xls/Balance du commerce/Retranscriptions_Commerce_France/Données Stata/bdd courante.dta", clear

gen blif = sitc_classification +"-"+ sitc18_en
drop if blif=="-"

bys blif : gen nbr_occu=_N

egen sum_value=total(value)
gen sum_occu=_N

gen share_value:"share of value"=value/sum_value
gen share_occu:"share of trade flows"=1/sum_occu

collapse (sum) share_value share_occu, by(blif)

label var share_value "share of traded value"
label var share_occu "share of trade flows"

graph hbar (asis) share_occu share_value, over(blif,label(labsize(vsmall))) legend(row(2) )

graph export "$dir/graphiques/histo_sitc.pdf", replace
