*****Pour tester les tris


global dir "~/Documents/Recherche/Commerce International Français XVIIIe.xls/Balance du commerce/Retranscriptions_Commerce_France"
import delimited "$dir/toflit18_data_GIT/base/classification_product_orthographic.csv",  encoding(UTF-8) clear varname(1)
generate sortkey =  ustrsortkeyex(source, "fr",-1,2,-1,-1,-1,0,-1)
sort sortkey
drop sortkey
save "$dir/Données Stata/classification_product_orthographic.dta", replace
export delimited "$dir/toflit18_data_GIT/base/classification_product_orthographic.csv", replace
