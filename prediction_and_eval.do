clear all
use data/unrate_claims, clear

*fix covid19 classification errors
replace unrate = unrate + 1 if date == date("1 March 2020", "DMY") // March misclassified by 1% according to BLS
replace unrate = unrate + 5 if date == date("1 April 2020", "DMY") // April misclassified by 5% according to BLS
replace unrate = unrate + 3 if date == date("1 May 2020", "DMY") // May misclassified by 3% according to BLS

*create lags and claimrate variables

forval i = 1 / 12 {
	gen unrate_`i' = unrate[_n-`i']
}

gen claimrate = totclaims/(labforce[_n-1]*1000) * 100
gen claimrate_1wdelay = totclaims_1wdelay/(labforce[_n-1]*1000) * 100

order date unrate claimrate claimrate_1wdelay

forval i = 1 / 12 {
	gen claimrate_`i' = claimrate[_n-`i']
}

forval i = 1 / 12 {
	gen claimrate_1wdelay_`i' = claimrate_1wdelay[_n-`i']
}

*Pick any one of the models below to test out - uncomment it, comment the rest
*#1 AR(6) unemployment ->
*global regression reg unrate unrate_1 unrate_2 unrate_3 unrate_4 unrate_5 unrate_6
*#2 claimrate, unem ->
*global regression reg unrate claimrate claimrate_1 claimrate_2 claimrate_3 claimrate_4 claimrate_5 claimrate_6 unrate_1 unrate_2 unrate_3 unrate_4 unrate_5 unrate_6
*#3 claimrate_1wdelay, unem ->
*global regression reg unrate claimrate_1wdelay claimrate_1wdelay_1 claimrate_1wdelay_2 claimrate_1wdelay_3 claimrate_1wdelay_4 claimrate_1wdelay_5 claimrate_1wdelay_6 unrate_1 unrate_2 unrate_3 unrate_4 unrate_5 unrate_6
*#4 claimrate, claimrate_1wdelay, unem ->
global regression reg unrate claimrate_1wdelay claimrate_1wdelay_1 claimrate_1wdelay_2 claimrate_1wdelay_3 claimrate_1wdelay_4 claimrate_1wdelay_5 claimrate_1wdelay_6 claimrate claimrate_1 claimrate_2 claimrate_3 claimrate_4 claimrate_5 claimrate_6 unrate_1 unrate_2 unrate_3 unrate_4 unrate_5 unrate_6

save data/final_model_data, replace
export delim data/final_model_data.csv, replace

*one step ahead forecast
*calculated by, from the 50th month onwards, estimating the model with all previous data
*and then predicting out of sample the current month
*forecast accuracy is then calculated
*drop fcasterr fcasterr2 abserror jumpfcasterr absjumperr jumpfcasterr2 osefcast
gen osefcast = .

local maxindex = _N
forval i = 50 / `maxindex' {
    quietly $regression if _n<`i'
    quietly predict fcast if _n==`i'
    quietly replace osefcast = fcast if osefcast == . & fcast != .
    drop fcast
}

order date unrate osefcast

gen fcasterr = unrate - osefcast
gen fcasterr2 = fcasterr^2
gen abserror = abs(fcasterr)

mean abserror
summarize fcasterr2
di sqrt(`r(mean)')
*the RMSE


*The jump error is the forecast error limited to situations where there is a large change in
*unemployment. Worried that some methods perform much worse during these times
*for example, using total claims from the week *of* the BLS survey instead of the week after
*when processing backlogs would have been cleared

gen jumpfcasterr = unrate - osefcast if unrate-unrate_1>=0.3 | unrate-unrate_1<=-0.3
gen absjumperr = abs(jumpfcasterr)
gen jumpfcasterr2 = jumpfcasterr^2

mean absjumperr
summarize jumpfcasterr2
di sqrt(`r(mean)')
*the RMSE


*line osefcast unrate date
