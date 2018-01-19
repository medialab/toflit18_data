*create population par generalites file
import excel "C:\Users\federico.donofrio\Dropbox\Papier Grains\population par generalite.xlsx", sheet("Feuil1") firstrow case(lower) clear
rename c c1
rename d c2
replace generalites = "Marseille" in 1
replace generalites = "Bordeaux-Bayonne" in 6
replace generalites = "La Rochelle" in 12
replace generalites = "Montauban" in 17
replace generalites = "Montpellier" in 18
gen c3=.
 reshape long c, i(generalites region density) j(year)
replace year = 1700 if year==1
replace year =1783 if year ==2
replace year=1789 if year==3
rename c population

encode generalites, generate(generalites_encode) label(generalites)
xtset generalites_encode year
tsfill
bysort generalites_encode: ipolate population year, g(population_ipo) epolate
save "C:\Users\federico.donofrio\Documents\TOFLIT desktop\Données Stata\population_generalites.dta", replace

*create riots par generalites file
import delimited "C:\Users\federico.donofrio\Documents\toflit 30.10.2017\emotion_annee_generalites.csv", clear 
save "C:\Users\federico.donofrio\Documents\TOFLIT desktop\Données Stata\emotions.dta"
drop v133 v134 v135 v136 v137 v138 
drop total v132 
save "C:\Users\federico.donofrio\Documents\TOFLIT desktop\Données Stata\emotions.dta", replace
replace generalites = "NA" in 32
save "C:\Users\federico.donofrio\Documents\TOFLIT desktop\Données Stata\emotions.dta", replace
drop if generalites=="TOTAL"
drop if generalites=="Total"
drop if v102=.
drop if v102==.
save "C:\Users\federico.donofrio\Documents\TOFLIT desktop\Données Stata\emotions.dta", replace
help destring
destring v2 v2 v3 v4 v5 v6 v7 v8 v9 v10 v11 v12 v13 v14 v15 v16 v17 v18 v19 v20 v21 v22 v23 v24 v25 v26 v27 v28 v29 v30 v31 v32 v33 v34 v35 v36 v37 v38 v39 v40 v41 v42 v43 v44 v45 v46 v47 v48 v49 v50 v51 v52 v53 v54 v55 v56 v57 v58 v59 v60 v61 v62 v63 v64 v65 v66 v67 v68 v69 v70 v71 v72 v73 v74 v75 v76 v77 v78 v79 v80 v81 v82 v83 v84 v85 v86 v87 v88 v89 v90 v91 v92 v93 v94 v95 v96 v97 v98 v99 v100 v101 v102 v103 v104 v105 v106 v107 v108 v109 v110 v111 v112 v113 v114 v115 v116 v117 v118 v119 v120 v121 v122 v123 v124 v125 v126 v127 v128 v129 v130, replace
reshape long v, i(generalites ) j(year)
browse
save "C:\Users\federico.donofrio\Documents\TOFLIT desktop\Données Stata\emotions.dta", replace
gen year2=year+1659
drop year
rename year2 year
rename v riots
save "C:\Users\federico.donofrio\Documents\TOFLIT desktop\Données Stata\emotions.dta", replace
drop if year<1700

generate generalites1=generalites
replace generalites1 = "Montpellier" if generalites=="MONTPELLIER"
replace generalites1 = "Montauban" if generalites=="MONTAUBAN"
drop if generalites=="NA"
drop generalites
rename generalites1 generalites
save "C:\Users\federico.donofrio\Documents\TOFLIT desktop\Données Stata\emotions.dta", replace

*merge the two into 
merge m:m  year generalites_encode using "C:\Users\federico.donofrio\Documents\TOFLIT desktop\Données Stata\population_generalites.dta"
save "C:\Users\federico.donofrio\Documents\TOFLIT desktop\Données Stata\population_riots.dta"

gen coastaldummy=1
replace coastaldummy=0 if generalites=="ALENCON"| generalites=="AUCH"|generalites=="BESANCON"|generalites=="BOURGES"|generalites=="CHALONS"|generalites=="DIJON"|generalites=="GRENOBLE"|generalites=="LILLE"|generalites=="LIMOGES"|generalites=="LYON"|generalites=="METZ"|generalites=="MOULINS" |generalites=="NANCY" |generalites=="Montauban" |generalites=="ORLEANS"|generalites=="PARIS" |generalites=="PERPIGNAN" |generalites=="RIOM" |generalites=="SOISSONS"|generalites=="TOURS" |generalites=="VALENCIENNES"

*calculate index riots/pop
gen riot_index=riots/population_ipo

save "C:\Users\federico.donofrio\Documents\TOFLIT desktop\Données Stata\population_riots.dta"
xtset generalites_encode year
collapse (mean) riot_index,  by (year coastaldummy)
reshape wide riot_index, i(year) j(coastaldummy)
line riot_index0 riot_index1 year
