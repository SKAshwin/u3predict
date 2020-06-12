use data/unrate_claims_1wdelayed, clear

*create lags and claimrate variables

forval i = 1 / 12 {
	gen unrate_`i' = unrate[_n-`i']
}

gen claimrate = totclaims/(labforce*1000) * 100
gen claimrate_1wdelay = totclaims_1wdelay/(labforce*1000) * 100

forval i = 1 / 12 {
	gen claimrate_`i' = claimrate[_n-`i']
}

forval i = 1 / 12 {
	gen claimrate_1wdelay_`i' = claimrate_1wdelay[_n-`i']
}

*Pick any one of the models below to test out - replace the model in the for loop
*reg unrate claimrate claimrate_1 claimrate_2 claimrate_3 claimrate_4 claimrate_5 claimrate_6 claimrate_7 claimrate_8 claimrate_9 claimrate_10 claimrate_11 claimrate_12 unrate_1 unrate_2 unrate_3 unrate_4 unrate_5 unrate_6 unrate_7 unrate_8 unrate_9 unrate_10 unrate_11 unrate_12
reg unrate claimrate claimrate_1 claimrate_2 claimrate_3 claimrate_4 claimrate_5 claimrate_6 unrate_1 unrate_2 unrate_3 unrate_4 unrate_5 unrate_6
*reg unrate claimrate_1wdelay claimrate_1wdelay_1 claimrate_1wdelay_2 claimrate_1wdelay_3 claimrate_1wdelay_4 claimrate_1wdelay_5 claimrate_1wdelay_6 claimrate_1wdelay_7 claimrate_1wdelay_8 claimrate_1wdelay_9 claimrate_1wdelay_10 claimrate_1wdelay_11 claimrate_1wdelay_12 claimrate claimrate_1 claimrate_2 claimrate_3 claimrate_4 claimrate_5 claimrate_6 claimrate_7 claimrate_8 claimrate_9 claimrate_10 claimrate_11 claimrate_12 unrate_1 unrate_2 unrate_3 unrate_4 unrate_5 unrate_6 unrate_7 unrate_8 unrate_9 unrate_10 unrate_11 unrate_12
*reg unrate claimrate_1wdelay claimrate_1wdelay_1 claimrate_1wdelay_2 claimrate_1wdelay_3 claimrate_1wdelay_4 claimrate_1wdelay_5 claimrate_1wdelay_6 claimrate claimrate_1 claimrate_2 claimrate_3 claimrate_4 claimrate_5 claimrate_6 unrate_1 unrate_2 unrate_3 unrate_4 unrate_5 unrate_6
*reg unrate claimrate_1wdelay claimrate_1wdelay_1 claimrate_1wdelay_2 claimrate_1wdelay_3 claimrate_1wdelay_4 claimrate_1wdelay_5 claimrate_1wdelay_6 unrate_1 unrate_2 unrate_3 unrate_4 unrate_5 unrate_6
*reg unrate claimrate_1wdelay claimrate_1wdelay_1 claimrate_1wdelay_2 claimrate_1wdelay_3 claimrate_1wdelay_4 claimrate_1wdelay_5 claimrate_1wdelay_6 claimrate_1wdelay_7 claimrate_1wdelay_8 claimrate_1wdelay_9 claimrate_1wdelay_10 claimrate_1wdelay_11 claimrate_1wdelay_12 unrate_1 unrate_2 unrate_3 unrate_4 unrate_5 unrate_6 unrate_7 unrate_8 unrate_9 unrate_10 unrate_11 unrate_12


save data/final_model_data, replace

*drop osefcast

*one step ahead forecast
*calculated by, from the 50th month onwards, estimating the model with all previous data
*and then predicting out of sample the current month
*forecast accuracy is then calculated
gen osefcast = .

local maxindex = _N
forval i = 50 / `maxindex' {
    reg unrate claimrate claimrate_1 claimrate_2 claimrate_3 claimrate_4 claimrate_5 claimrate_6 unrate_1 unrate_2 unrate_3 unrate_4 unrate_5 unrate_6 if _n<`i'
    predict fcast if _n==`i'
    replace osefcast = fcast if osefcast == . & fcast != .
    di fcast[`i']
    drop fcast
}

order date unrate osefcast
drop fcasterr fcasterr2 abserror
gen fcasterr = unrate - osefcast
gen fcasterr2 = fcasterr^2
gen abserror = abs(fcasterr)

mean fcasterr2
*manually calculate RMSE from the mean squared error
mean abserror
