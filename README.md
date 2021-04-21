Unemployment claims data is available before the publishing of U3, and the objective of this project was to estimate the unemployment rate for the moment based off the total number of claims, and see if this methodology would work better than a simple VAR of the unemployment rate (which, during the outbreak of the pandemic, seemed to produced wildly off-mark estimates). To this end, we calculate an estimated *claim rate* for the month, which is the total claims divided by the previous months labor force size (used as a proxy for the current month's labor force).

The raw csv data files are stored in raw/ (see raw/README.md for the sources of data). Claims data comes in the form of new initial claims (ICSA) for that week, and continuing claims (CCSA, how many pre-existing claims continued being paid out for that week). Total claims, which we are interested in, are the sum of these two values.

*import_claims.do* takes the raw csv of the weekly claims data (ICSA and CCSA) and produces dta files of a table with one claim reading a month. The reading used is by default that of the **BLS reference week**, which is the week during which unemployment is measured, and is defined as the week containing the 12th. A parameter can be changed to also construct dta files for unemployment claims of the week *after* the BLS reference week, which may be more reflective of claims filed during the reference week if there is a surge in claims that produces a backlog (as happened during COVID19). Outputs of dta files are deposited in the data/ folder.

*make_merged_dataset.do* merges in U3, the labor force size and the claims data (ICSA and CCSA) from the week of and the week after the BLS refrence week. Each variable is labelled. The final output is stored in the data/ folder.

*prediction_and_eval.do* adds some more variables (mainly the lags) and estimates a one-step-ahead forecast using several VARs of unemployment and the claim rate. It then calculates the mean absolute and root mean squared errors for the model selected. A "jump" mean absolute/root mean squared error is also calculated, where the models performance is only evaluated in months where unemployment rose by 0.3 or more.

*change_prediction_and_eval.do* tests a different set of models that tries to estimate the *change* in unemployment from the *change* in the claim rate, and uses this to construct a one step ahead forecast. It generally performs much better; its only a separate file because I thought of this at a later date.

Some of the prediction models tested, and their performances, are listed below:

Model (1) Basic VAR
Regress unemployment on the last 6 lags of unemployment.

Model (2) VAR with BLS reference week claim rates
Regress unemployment on the last 6 lags of unemployment and the last 6 readings of the claim rate during the BLS reference week.

Model (3) VAR with delayed claim rates
Regress unemployment on the last 6 lags of unemployment and the last 6 readings of the claim rate during the week after BLS reference week.

Model (4) VAR with both claim rates
Regress unemployment on the last 6 lags of unemployment and the last 6 readings of the claim rate during the week after BLS reference week, and the last 6 readings of the claim rate during the BLS reference week.

Model (5) Changes in unemployment
Regress the change in unemployment on the change of claim rate (measuring during the BLS reference week). Construct the one step ahead forecast by adding the predicted change to the previous months unemployment rate.

Their performances are in the table below. MAE and RMSE refer to mean absolute error and root mean square error - both are about the one step ahead forecast error, ie error on new data one period ahead, not data used to train the model. "Jump" MAE and RMSE refer to the error in predicted unemployment in periods when actual unemployment rose by more than 0.3


| Model | MAE | RMSE | Jump MAE | Jump RMSE |
| ----- | --- | ---- | -------- | --------- |
|#1|0.185|0.634|0.830|1.90|
|#2|0.155|0.391|0.574|1.132|
|#3|0.152|0.397|0.562|1.153|
|#4|0.151|0.379|0.537|1.09|
|#5|0.131|0.193|0.332|0.449|

