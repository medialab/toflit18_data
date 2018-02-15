use "C:\Users\federico.donofrio\Documents\TOFLIT desktop\Données Stata\riots_price_cheflieux.dta" 
** I want to compute the average price (based on Epstein Federico et alii) and then deviation from the mean for each year and check partial correlation between riots and deviation and with mean standard deviation. then apply granger test
*** compute average
bys market : egen avprice=mean(price)
** compute variation from mean
gen ydev=abs(price-avprice)
* now deviation as percent of mean
gen percentdev=ydev/avprice*100
* check partial correlation riots percentdev
 bys market: pwcorr riots percentdev ydev percent_var, star(.5)
 *try lags
xtset generalites_encode year
pwcorr riots percentdev L.percentdev ydev percent_var, star(.5)
