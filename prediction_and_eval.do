use data/unrate_claims, clear

*create lags and claimrate variables

forval i = 1 / 12 {
	gen unrate_`i' = unrate[_n-`i']
}

*fix covid19 classification errors
replace unrate = unrate + 1 if date == date("1 March 2020", "DMY") // March misclassified by 1% according to BLS
replace unrate = unrate + 5 if date == date("1 April 2020", "DMY") // April misclassified by 5% according to BLS
replace unrate = unrate + 3 if date == date("1 May 2020", "DMY") // May misclassified by 3% according to BLS


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

*12 lags model
*global regression reg unrate claimrate claimrate_1 claimrate_2 claimrate_3 claimrate_4 claimrate_5 claimrate_6 claimrate_7 claimrate_8 claimrate_9 claimrate_10 claimrate_11 claimrate_12 unrate_1 unrate_2 unrate_3 unrate_4 unrate_5 unrate_6 unrate_7 unrate_8 unrate_9 unrate_10 unrate_11 unrate_12
*global regression reg unrate claimrate_1wdelay claimrate_1wdelay_1 claimrate_1wdelay_2 claimrate_1wdelay_3 claimrate_1wdelay_4 claimrate_1wdelay_5 claimrate_1wdelay_6 claimrate_1wdelay_7 claimrate_1wdelay_8 claimrate_1wdelay_9 claimrate_1wdelay_10 claimrate_1wdelay_11 claimrate_1wdelay_12 claimrate claimrate_1 claimrate_2 claimrate_3 claimrate_4 claimrate_5 claimrate_6 claimrate_7 claimrate_8 claimrate_9 claimrate_10 claimrate_11 claimrate_12 unrate_1 unrate_2 unrate_3 unrate_4 unrate_5 unrate_6 unrate_7 unrate_8 unrate_9 unrate_10 unrate_11 unrate_12
*global regression reg unrate claimrate_1wdelay claimrate_1wdelay_1 claimrate_1wdelay_2 claimrate_1wdelay_3 claimrate_1wdelay_4 claimrate_1wdelay_5 claimrate_1wdelay_6 claimrate_1wdelay_7 claimrate_1wdelay_8 claimrate_1wdelay_9 claimrate_1wdelay_10 claimrate_1wdelay_11 claimrate_1wdelay_12 unrate_1 unrate_2 unrate_3 unrate_4 unrate_5 unrate_6 unrate_7 unrate_8 unrate_9 unrate_10 unrate_11 unrate_12


save data/final_model_data, replace

gen cunrate = unrate - unrate_1

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

mean fcasterr2
*manually calculate RMSE from the mean squared error
mean abserror

gen jumpfcasterr = unrate - osefcast if unrate-unrate_1>=0.3 | unrate-unrate_1<=-0.3
gen absjumperr = abs(jumpfcasterr)
gen jumpfcasterr2 = jumpfcasterr^2

mean absjumperr
mean jumpfcasterr2

reg fcasterr cunrate,r

*line osefcast unrate date
