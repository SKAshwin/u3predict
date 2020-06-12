Continuing claims and initial claims are measured weekly, but U3 (and the labor force size) is measured once a month. So we need to take the claims data measured the same week as the reference week for U3, which is the week that contains the 12th. So import_claims.do handles that. Then make_merged_dataset.do prepares the final dataset by merging U3, the labor force size and the initial and continuing claims (and producing total outstanding claims by summing up the two). Labels are added to each variable as appropriate.

Using the 12th for the source of the claimrate, RMSE is 0.265, mean absolute error is 0.128. Dropping the last 6 lags, RMSE = 0.254, MAE = 0.126
Using the 12th and the 19th claimrates (and their lags), RMSE is 0.353, mean absolute error is 0.148. Dropping the last 6 lags, RMSE = 0.291, MAE = 0.129
Using just the 19th for the claimrates, RMSE is 0.375, mean absolute error is 0.134. Dropping the last 6 lags, RMSE = 0.350, MAE=0.132.
