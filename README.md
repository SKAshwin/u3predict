Claims data is available before the publishing of U3, and total unemployment should, in theory, equal the claims rate plus some amount of unemployed that are not currently on benefits. The best model would use the claimrate and then aim to somehow estimate the number of people without a claim looking for work. A lazy model, which is this one, just uses lags of unemployment and lags of claims data.

Continuing claims and initial claims are measured weekly, but U3 (and the labor force size) is measured once a month. So we need to take the claims data measured the same week as the reference week for U3, which is the week that contains the 12th. So import_claims.do handles that. Then make_merged_dataset.do prepares the final dataset by merging U3, the labor force size and the initial and continuing claims (and producing total outstanding claims by summing up the two). Labels are added to each variable as appropriate. prediction_and_eval.do adds some more variables (mainly the lags) and runs some models and tests their one step ahead forecast accuracy.

We can also choose to use the claims data from the week *after* the BLS measurement, which seems to more accurately deal with sudden shifts in unemployment (though as you see below, it has a worse RMSE and MAE overall), which may be because claims data from the week of measurement are backlogged when unemployment rises quickly (as in March 2020 for an instructive example between including and not including week-after claims) and thus are not a good estimate of "people recently unemployed", as it is meant to be.

Using the 12th for the source of the claimrate, RMSE is 0.265, mean absolute error is 0.128. Dropping the last 6 lags, RMSE = 0.254, MAE = 0.126

Using the 12th and the 19th claimrates (and their lags), RMSE is 0.353, mean absolute error is 0.148. Dropping the last 6 lags, RMSE = 0.291, MAE = 0.129

Using just the 19th for the claimrates, RMSE is 0.375, mean absolute error is 0.134. Dropping the last 6 lags, RMSE = 0.350, MAE=0.132.
