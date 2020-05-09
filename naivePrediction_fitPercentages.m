% This script will construct a naive-predictor that will then compute
% predictions for each test dataset for the subject. Those predictions will
% then be compared against the true test data by computing the fit
% percentage 100*(1-NRMSE) = 100*(1 - RMSE/STDEV) and then these results
% will be stored for later comparison against the model predicted 1-step
% ahead fit percentages

% I will clear the workspace and then only load the needed variables to
% free up RAM
clear all

%% Import testing data
% Load the testing data from the mat file where the SS models were stored
loadDataName = 'Results\Example_models_ssest.mat';

% Load testing data
load(loadDataName, ...
    'D1_1_HR', 'D1_1_PPGamp', 'D1_2_HR', 'D1_2_PPGamp', ...
    'D2_HR', 'D2_PPGamp', 'D3_HR', 'D3_PPGamp')


%% Call naive predictor function for each dataset
% Calling this function returns the naive 1-step predictions for the
% dataset passed to it
predicted_D1_1_HR = naivePred(D1_1_HR.OutputData);
predicted_D1_1_PPGamp = naivePred(D1_1_PPGamp.OutputData);

predicted_D1_2_HR = naivePred(D1_2_HR.OutputData);
predicted_D1_2_PPGamp = naivePred(D1_2_PPGamp.OutputData);

predicted_D2_HR = naivePred(D2_HR.OutputData);
predicted_D2_PPGamp = naivePred(D2_PPGamp.OutputData);

predicted_D3_HR = naivePred(D3_HR.OutputData);
predicted_D3_PPGamp = naivePred(D3_PPGamp.OutputData);


%% Compute fit percentages
% The formula for fit percentage can be simplified to be RMSE/STDEV
% subtracted from 1 and then multiplied by 100 for a percentage. This is
% equivalently 100*(1 - norm(predicted - real)/norm(real - mean(real)))

fit_D1_1_HR = fitCalc(D1_1_HR.OutputData, predicted_D1_1_HR);
fit_D1_1_PPGamp = fitCalc(D1_1_PPGamp.OutputData, predicted_D1_1_PPGamp);

fit_D1_2_HR = fitCalc(D1_2_HR.OutputData, predicted_D1_2_HR);
fit_D1_2_PPGamp = fitCalc(D1_2_PPGamp.OutputData, predicted_D1_2_PPGamp);

fit_D2_HR = fitCalc(D2_HR.OutputData, predicted_D2_HR);
fit_D2_PPGamp = fitCalc(D2_PPGamp.OutputData, predicted_D2_PPGamp);

fit_D3_HR = fitCalc(D3_HR.OutputData, predicted_D3_HR);
fit_D3_PPGamp = fitCalc(D3_PPGamp.OutputData, predicted_D3_PPGamp);


%% Output results to excel doc
excelResults = table(...
    fit_D1_1_HR, fit_D1_1_PPGamp, ...
    fit_D1_2_HR, fit_D1_2_PPGamp, ...
    fit_D2_HR, fit_D2_PPGamp, ...
    fit_D3_HR, fit_D3_PPGamp);

% Write the results to the specified file
filename = 'Results\naivePredictorFits.csv';
writetable(excelResults,filename)

%% Save results
% In case these need to be accessed later
saveDataName = 'Results\Example_naivePred_Fits.mat';
save(saveDataName)