if "`c(username)'"=="guillaumedaudin" global dir "~/Dropbox"



capture program drop reg_prices_tradeflows
program reg_prices_tradeflows
args threshold fform

use "$dir/Papier Federico Grains/LSE 2019/local series and distances.dta", clear



if "`fform'"=="linear" {
	gen price_pond = price/transport
	gen pond = 1/transport
}
if "`fform'"=="square" {
	gen price_pond = price/transport^2
	gen pond = 1/transport^2
	}
if "`fform'"=="cubic" {
	gen price_pond = price/transport^3
	gen pond = 1/transport^3
}
collapse (sum) pond price_pond, by (import export year geography)

gen mean_price=price_pond/pond

reg import mean_price i.geography
reg export mean_price i.geography

gen ln_import=ln(import)
gen ln_export=ln(export)
gen ln_mean_price=ln(mean_price)



reg import ln_mean_price i.geography
reg export ln_mean_price i.geography

bys geography : reg ln_import ln_mean_price
bys geography : reg ln_export ln_mean_price

reg ln_import ln_mean_price i.geography
reg ln_export ln_mean_price i.geography

tsset geography year

reg ln_import L.ln_mean_price i.geography
reg ln_export L.ln_mean_price i.geography

bys geography : reg ln_import L.ln_mean_price
bys geography : reg ln_export L.ln_mean_price

end

reg_prices_tradeflows 50 linear
reg_prices_tradeflows 50 square
reg_prices_tradeflows 150 linear
reg_prices_tradeflows 150 square
