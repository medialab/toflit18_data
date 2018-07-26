

global dir "~/Dropbox/2018 Boston - présentation Charles, Daudin, Girard"


foreach  var_interet in  marchandises goods_ortho_classification goods_simpl_classification {
	use "~/Documents/Recherche/Commerce International Français XVIIIe.xls/Balance du commerce/Retranscriptions_Commerce_France/Données Stata/bdd courante.dta", clear
	collapse (count) nbr_occu=year (sum) value, by(`var_interet')
	gen nbr_occur_str =""
	
	replace nbr_occur_str="1 trade flow/good" if nbr_occu==1
	replace nbr_occur_str="2-4 trade flows/good" if nbr_occu==2 | nbr_occu==3 | nbr_occu==4
	replace nbr_occur_str="5-10 trade flows/good" if nbr_occu>=5 & nbr_occu<=10
	replace nbr_occur_str="11-100 trade flows/good" if nbr_occu>=11 & nbr_occu<=100
	replace nbr_occur_str="101+ trade flows/good" if nbr_occu>=101
	
	gen order =.
	replace order=1 if nbr_occu==1
	replace order=2 if nbr_occu==2 | nbr_occu==3 | nbr_occu==4
	replace order=5 if nbr_occu>=5 & nbr_occu<=10
	replace order=11 if nbr_occu>=11 & nbr_occu<=100
	replace order=101 if nbr_occu>=101
	
	gen blif=1
	
	egen sum_value=total(value)
	egen sum_occu=total(nbr_occu)
	
	gen share_value:"share of value"=value/sum_value
	gen share_item:"share of items"=1/_N
	gen share_occu:"share of trade flows"=1/sum_occu
	
	encode `var_interet', generate(item)
	
	collapse (sum) share_item share_value share_occu  ///
		(count) item, by(nbr_occur_str order)
	
	
	label var share_item "share of goods"
	label var share_value "share of value"
	label var share_occu "share of trade flows"
	
	if "`var_interet'"=="marchandises" local graph_name "Goods as retranscribed (c. 60,000)"
	if "`var_interet'"=="goods_ortho_classification" local graph_name "Goods after orthographic norm. (c. 25,000)"
	if "`var_interet'"=="goods_simpl_classification" local graph_name "Goods after simplification (c. 19,000)"
	
	sort order
	*graph hbar , over(nbr_occur_str) name(nbr_`var_interet', replace)
	list
	graph hbar (asis) share_item share_occu share_value, ///
			over(nbr_occur_str, sort(order)) 		///
			name(graph_`var_interet', replace) title(`graph_name') ///
			yscale(range(0 1)) ylabel(0 (0.2) 1) 
					
	graph export "$dir/graphiques/graph_`var_interet'.pdf", replace
}
*	graph combine graph_marchandises graph_goods_ortho_classification graph_goods_simpl_classification
