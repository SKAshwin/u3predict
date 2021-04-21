clear all

*import and clean (by converting a date to stata date from string) laborforce data, then save it
import delim raw/CLF16OV.csv, varn(1) clear
*convert date from string to date
gen dateformatted = date(date, "YMD")
drop date
rename dateformatted date
format date %td
save data/laborforce.dta, replace

*imports the U3 raw data and creates a merged dataset with the claims data 
*(after claims data have been processed)

import delim raw/UNRATE.csv, varn(1) clear
*convert date from string to date
gen dateformatted = date(date, "YMD")
drop date
rename dateformatted date
format date %td

*merge all the datasets
merge 1:1 date using data/laborforce
//keep if _merge==3
drop _merge

merge 1:1 date using data/ICSA_1wdelayed
//keep if _merge==3
drop _merge
merge 1:1 date using data/CCSA_1wdelayed
//keep if _merge==3
drop _merge
rename icsa initclaims_1wdelay
rename ccsa contclaims_1wdelay

merge 1:1 date using data/ICSA
//keep if _merge==3 | _merge==2 //keep if unemployment rate not available, but ICSA available
drop _merge
merge 1:1 date using data/CCSA
//keep if _merge==3 | _merge==2
drop _merge

*just renaming and reordering the dataset to make it friendlier
order date, first
rename icsa initclaims
rename ccsa contclaims
rename clf16ov labforce
gen totclaims = initclaims+contclaims
gen totclaims_1wdelay = initclaims_1wdelay +contclaims_1wdelay
lab var initclaims "Initial Unemployment Claims (in BLS Household survey reference week)"
lab var contclaims "Continuing Unemployment Claims (in BLS Household survey reference week)"
lab var initclaims_1wdelay "Initial Unemployment Claims (in week after BLS Household survey reference week)"
lab var contclaims_1wdelay "Continuing Unemployment Claims (in week after BLS Household survey reference week)"
lab var unrate "U3 Unemployment Rate"
lab var labforce "Labour Force size (in 1000s)"
lab var totclaims "Total Outstanding Unemployment Claims (initclaims + contclaims)"
lab var totclaims_1wdelay "Total Outstanding Unemployment Claims the week after the BLS survey (initclaims_1wdelay + contclaims_1weekdelay)"

drop if date < date("1 Jan 1967", "DMY")

save data/unrate_claims, replace
