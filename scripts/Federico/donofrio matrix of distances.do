*** calculate distances matrix

use "C:\Users\federico.donofrio\Documents\GitHub\toflit18_data_GIT\traitements_product\simplifications_perso_des_participants\db_markets_coordinates.dta", clear


clear
set obs 419
gen id =_n
set seed 1234
gen Latitude = 10*uniform()
gen Longitude = 10*uniform()

///Mata  
mata
X= st_data(.,( "Latitude" , "Longitude"))
X =X*(pi()/180)
km = J(rows(X),rows(X), 0)
for (i = 1; i <=rows(X); i++) {
    for (j = 1; j <=rows(X); j++) {
	  km[i,j] = 6372.795*(2*asin(sqrt( sin((X[i,1] /// 
	  - X[j,1])/2)^2 +  cos(X[i,1])*cos(X[j,1])*sin((X[i,2] ///
	  - X[j,2])/2)^2  )))
	  miles = km*(1/1.609)
	  furlongs = miles/8
     }
}
end

//Stata
qui levelsof id, local(level1)
replace Latitude = (_pi/180)*Latitude
replace Longitude = (_pi/180)*Longitude

foreach l1 of local level1 {
	qui gen dist_to_`l1' = .
}

local i = 1
foreach l1 of local level1 {
   local j = 1
      foreach l2 of local level1 {
         qui replace dist_to_`l2' = 6372.795*(2*asin(sqrt( /// 
	 sin((Latitude[`i'] - Latitude[`j'])/2)^2 ///
	 + cos(Latitude[`i'])*cos(Latitude[`j'])*sin((Longitude[`i'] ///
	 - Longitude[`j'])/2)^2  ))) in `i'
	 local ++j
      }
local ++i
}


