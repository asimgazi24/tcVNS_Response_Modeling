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
    'HR_iddatas', 'PPGamp_iddatas')


%% Call naive predictor function for each dataset
% Calling this function returns the naive 1-step predictions for the
% dataset passed to it
predicted_HR = {};
predicted_PPGamp = {};

for dayCounter = 1:4
    predicted_HR{dayCounter} = naivePred(HR_iddatas{dayCounter}.OutputData);
    predicted_PPGamp{dayCounter} = naivePred(PPGamp_iddatas{dayCounter}.OutputData);
end

%% Compute fit percentages
% The formula for fit percentage can be simplified to be RMSE/STDEV
% subtracted from 1 and then multiplied by 100 for a percentage. This is
% equivalently 100*(1 - norm(predicted - real)/norm(real - mean(real)))

fit_HR = {};
fit_PPGamp = {};

for dayCounter = 1:4
    fit_HR{dayCounter} = fitCalc(HR_iddatas{dayCounter}.OutputData, predicted_HR{dayCounter});
    fit_PPGamp{dayCounter} = fitCalc(PPGamp_iddatas{dayCounter}.OutputData, predicted_PPGamp{dayCounter});
end


%% Output results to excel doc
excelResults = table(...
    fit_HR, fit_PPGamp);

% Write the results to the specified file
filename = 'Results\naivePredictorFits.csv';
writetable(excelResults,filename)

%% Save results
% In case these need to be accessed later
saveDataName = 'Results\Example_naivePred_Fits.mat';
save(saveDataName)