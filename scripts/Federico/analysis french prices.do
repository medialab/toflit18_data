import excel "C:\Users\federico.donofrio\Documents\wheat_prices_FRANCE(dbversion ).xlsx", sheet("Foglio1") firstrow, clear
encode market, generate(market_encode) label(market)
xtset market_encode year
gen structural_break=0
replace structural_break=1 if year>=1763
replace structural_break=2 if year>=1790
replace structural_break=3 if year>=1800
replace structural_break=4 if year>=1816
bysort market_encode structural_break : egen average_price=mean(price)

xtline average_price, overlay
bysort market_encode : gen period = ceil(_n/5)
bysort market_encode period : egen average_price2=mean(price)
xtline average_price2 if market_encode==40, overlay
xtset market_encode year

tssmooth ma ma_price=price, window(4 1)

gen group=0
replace group=1 if market_encode==13 | market_encode==40 | market_encode==43 | market_encode==50 | market_encode==56 | market_encode==59
xtline ma_price if group==1, overlay
