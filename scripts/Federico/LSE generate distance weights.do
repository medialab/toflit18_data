use "C:\Users\federico.donofrio\Documents\TOFLIT desktop\Bilateral transport costs\BDD_Domestic trade and market size.dta", clear
keep if nomSup=="Bordeaux" | nomSup=="Marseille"  | nomSup=="La Rochelle" | nomSup=="Nantes" | nomSup=="Rennes" | nomSup=="Rouenc"
collapse (mean) transport, by(insee inseesup inseecon nomSup nomCon  popCon popSup)
gen newid=0000000000
format newid %010.0f
recast double newid
replace newid=insee*100000
replace newid=newid+inseecon



drop insee
rename inseesup insee
sort  newid



