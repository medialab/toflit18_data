**** create .dta files, tsset

***CONTEXT DEPENDING 
import excel "C:\Users\federico.donofrio\Dropbox\Papier Grains\db_grainprices_unpivoted.xlsx", sheet("Feuil2") firstrow clear
save "C:\Users\federico.donofrio\Documents\GitHub\toflit18_data_GIT\traitements_marchandises\simplifications_perso_des_participants\db_grainprices.dta", replace

import excel "C:\Users\federico.donofrio\Dropbox\Papier Grains\DB_markets_coordinates.xlsx", sheet("Feuil1") firstrow clear

save "C:\Users\federico.donofrio\Documents\GitHub\toflit18_data_GIT\traitements_marchandises\simplifications_perso_des_participants\db_markets_coordinates.dta", replace

*** merge to turn market names into integers
use "C:\Users\federico.donofrio\Documents\GitHub\toflit18_data_GIT\traitements_marchandises\simplifications_perso_des_participants\db_grainprices.dta", clear



merge m:m market using "C:\Users\federico.donofrio\Documents\GitHub\toflit18_data_GIT\traitements_marchandises\simplifications_perso_des_participants\db_markets_coordinates.dta"
*** drop cities with no data
drop if _merge==2
drop _merge

***in order to make a panel maybe not always necessary
encode market, generate(market_integer) label(market)

drop market

rename market_integer market

*** recreate original files: db_grainprice
save "C:\Users\federico.donofrio\Documents\GitHub\toflit18_data_GIT\traitements_marchandises\simplifications_perso_des_participants\db_markets_coordinates.dta", replace

drop Latitude

drop Longitude

save "C:\Users\federico.donofrio\Documents\GitHub\toflit18_data_GIT\traitements_marchandises\simplifications_perso_des_participants\db_grainprices.dta", replace

*** recreate original files: db_markets_coordinates
use "C:\Users\federico.donofrio\Documents\GitHub\toflit18_data_GIT\traitements_marchandises\simplifications_perso_des_participants\db_markets_coordinates.dta", clear
drop year price
collapse Longitude Latitude, by (market)
save "C:\Users\federico.donofrio\Documents\GitHub\toflit18_data_GIT\traitements_marchandises\simplifications_perso_des_participants\db_markets_coordinates.dta", replace


***419 cities!
use "C:\Users\federico.donofrio\Documents\GitHub\toflit18_data_GIT\traitements_marchandises\simplifications_perso_des_participants\db_grainprices.dta", clear

xtset market year, yearly
       *panel variable:  market (unbalanced)
        *time variable:  year, 1700 to 1824, but with gaps
         *       delta:  1 unit

browse

tsfill

browse
save "C:\Users\federico.donofrio\Documents\GitHub\toflit18_data_GIT\traitements_marchandises\simplifications_perso_des_participants\db_grainprices.dta", replace


