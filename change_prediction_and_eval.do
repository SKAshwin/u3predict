clear all
use data/unrate_claims, clear

*fix covid19 classification errors; unclear if you want to count *all* the misclassified as unemployed,
*seems better to leave off
*replace unrate = unrate + 1 if date == date("1 March 2020", "DMY") // March misclassified by 1% according to BLS
*replace unrate = unrate + 5 if date == date("1 April 2020", "DMY") // April misclassified by 5% according to BLS
*replace unrate = unrate + 3 if date == date("1 May 2020", "DMY") // May misclassified by 3% according to BLS

*create lags and claimrate variables

gen claimrate = totclaims/(labforce[_n-1]*1000) * 100
gen claimrate_1wdelay = totclaims_1wdelay/(labforce[_n-1]*1000) * 100

gen cclaimrate = claimrate - claimrate[_n-1]
gen cclaimrate_1wdelay = claimrate_1wdelay - claimrate_1wdelay[_n-1]
gen cunrate = unrate - unrate[_n-1]
gen cclaimrate2 = cclaimrate^2
gen cclaimrate_1wdelay2 = cclaimrate_1wdelay^2
gen cunrate_1cclaimrate_1wdelay = cunrate[_n-1] * cclaimrate_1wdelay

order date unrate claimrate cclaimrate cunrate claimrate_1wdelay

save data/final_change_model_data, replace
export delim data/final_change_model_data.csv, replace

*Pick which model you want to test (the first is simplest and works well)
global regression reg cunrate cclaimrate
*global regression reg cunrate cclaimrate_1wdelay
*global regression reg cunrate cclaimrate cclaimrate_1wdelay

*global regression reg cunrate cclaimrate cclaimrate2
*global regression reg cunrate cclaimrate_1wdelay cunrate_1cclaimrate_1wdelay
*global regression reg cunrate cclaimrate cclaimrate_1wdelay cclaimrate2 cclaimrate_1wdelay2

*one step ahead forecast
*calculated by, from the 50th month onwards, estimating the model with all previous data
*and then predicting out of sample the current month's change in unemployment
*forecast accuracy is then calculated by adding the predicted change in unemployment
*to the previous month's unemployment
gen osefcastc = .

local maxindex = _N
forval i = 50 / `maxindex' {
    quietly $regression if _n<`i'
    quietly predict fcast if _n==`i'
    quietly replace osefcastc = fcast if osefcastc == . & fcast != .
    drop fcast
}

gen osefcast = unrate[_n-1]+osefcastc

order date unrate osefcast osefcastc cunrate cclaimrate cclaimrate_1wdelay

gen fcasterr = unrate - osefcast
gen fcasterr2 = fcasterr^2
gen abserror = abs(fcasterr)

mean abserror
summarize fcasterr2
di sqrt(`r(mean)')

gen jumpfcasterr = unrate - osefcast if cunrate>=0.3 | cunrate<=-0.3
gen absjumperr = abs(jumpfcasterr)
gen jumpfcasterr2 = jumpfcasterr^2

mean absjumperr
summarize jumpfcasterr2
di sqrt(`r(mean)')
