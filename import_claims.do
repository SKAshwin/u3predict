global claimtype ICSA
global weekdelay 0
*run for ICSA (initial claims), CCSA (continuing claims) and then weekdelay=0 and weekdelay=1, to use
*weekdelay=1 means the claims from the week *after* the BLS reference week are used

import delim raw/${claimtype}.csv, varn(1) clear
*convert date from string to 
gen dateformatted = date(date, "YMD")
drop date
rename dateformatted date

*finding the claim which is the same week as the 12th
gen u3measuredate = mdy(month(date), 12, year(date))
*check what the sunday was for the reference week where U3 was measured
*because claims are for each sunday
gen u3measuresunday = u3measuredate+(6-dow(u3measuredate))
*keep the claims data for the U3 reference week (+however many weeks delayed), drop all else
keep if date==u3measuresunday + 7*$weekdelay
*drop helping variables
drop u3measuredate
drop u3measuresunday

*drop day data, keep only month, for merging with UNRATE
replace date = mdy(month(date), 1, year(date))
format date %td

if $weekdelay == 0 {
	save data/${claimtype}, replace
}
else {
	save data/${claimtype}_${weekdelay}wdelayed, replace
}

